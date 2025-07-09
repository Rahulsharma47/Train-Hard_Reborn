// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:train_hard_reborn/providers/progress_provider.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package

class DailyProgressSection extends StatefulWidget {
  const DailyProgressSection({super.key});

  @override
  State<DailyProgressSection> createState() => _DailyProgressSectionState();
}

class _DailyProgressSectionState extends State<DailyProgressSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> todayStats = {
    'calories': 0.0,
    'calorieGoal': 0.0,
    'steps': 0.0,
    'stepsGoal': 0.0,
    'water': 0.0,
    'waterGoal': 0.0,
    'sleep': 0.0,
    'sleepGoal': 0.0,
    'mood': 'Not recorded',
    'date': DateFormat('dd-MM-yy').format(DateTime.now()),
  };

  int streak = 0;
  bool isLoading = true;
  bool streakUpdatedToday = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _manageProgressHistoryByDate() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get user document reference
      final userDocRef = _firestore.collection('users').doc(userId);

      // Get all progress documents sorted by date
      final progressDocs =
          await userDocRef
              .collection('progress')
              .orderBy('date', descending: true)
              .get();

      // If we have 7 days or less of data, do nothing
      if (progressDocs.docs.length <= 7) {
        print('Less than or equal to 7 days of data. No deletion needed.');
        return;
      }

      // Keep the most recent 7 documents, delete the rest
      final docsToKeep = progressDocs.docs.take(7).toList();
      final docsToDelete = progressDocs.docs.skip(7).toList();

      // Get the date of the newest record we're keeping for logging
      final oldestKeptDate = docsToKeep.last.data()['date'] as String;

      // Delete older documents
      for (var doc in docsToDelete) {
        await doc.reference.delete();
        print('Deleted old progress document: ${doc.data()['date']}');
      }

      print('Kept 7 days of data, oldest kept date: $oldestKeptDate');
    } catch (e) {
      print('Error managing progress history by date: $e');
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _manageProgressHistoryByDate();

      // Load user data using the query pattern from the snippet
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final userData = userDoc.data();
      final userDocRef = userDoc.reference;

      // Load today's progress data
      final today = DateFormat('dd-MM-yy').format(DateTime.now());

      // Check if progress data exists
      final progressQuery =
          await userDocRef
              .collection('progress')
              .where('date', isEqualTo: today)
              .limit(1)
              .get();

      setState(() {
        // Get streak data from user document
        streak = userData?['streak'] ?? 0;

        // Get progress data if it exists
        if (progressQuery.docs.isNotEmpty) {
          final progressData = progressQuery.docs.first.data();
          todayStats['calories'] = progressData['calories'] ?? 0.0;
          todayStats['steps'] = progressData['steps'] ?? 0.0;
          todayStats['water'] = progressData['water'] ?? 0.0;
          todayStats['sleep'] = progressData['sleep'] ?? 0.0;
          todayStats['mood'] = progressData['mood'] ?? 'Not recorded';
          // Check if streak was already updated today
          streakUpdatedToday = progressData['streak_updated'] ?? false;
        }

        // Get user goals from user document
        todayStats['calorieGoal'] = userData?['maintainanceCalories'] ?? 2500.0;
        todayStats['stepsGoal'] = userData?['stepsGoal'] ?? 10000.0;
        todayStats['waterGoal'] =
            userData?['waterGoal'] ??
            2.0; // Changed default from 8.0 cups to 2.0 L
        todayStats['sleepGoal'] = userData?['sleepGoal'] ?? 4;

        isLoading = false;
      });

      // Update provider with the loaded data
      _updateProgressProvider();
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // New method to update the ProgressProvider
  void _updateProgressProvider() {
    final provider = Provider.of<ProgressProvider>(context, listen: false);

    // Calculate percentages for each metric
    double caloriesPercent = todayStats['calories'] / todayStats['calorieGoal'];
    double stepsPercent = todayStats['steps'] / todayStats['stepsGoal'];
    double waterPercent = todayStats['water'] / todayStats['waterGoal'];
    double sleepPercent = todayStats['sleep'] / todayStats['sleepGoal'];

    // Ensure percentages are within valid range (0.0 to 1.0)
    caloriesPercent = caloriesPercent.clamp(0.0, 1.0);
    stepsPercent = stepsPercent.clamp(0.0, 1.0);
    waterPercent = waterPercent.clamp(0.0, 1.0);
    sleepPercent = sleepPercent.clamp(0.0, 1.0);

    // Update the provider
    provider.updateCalories(caloriesPercent);
    provider.updateSteps(stepsPercent);
    provider.updateWater(waterPercent);
    provider.updateSleep(sleepPercent);
  }

  Future<void> _updateProgress(String field, dynamic value) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get user document using the query pattern
      final userDocRef = _firestore.collection('users').doc(userId);
      final today = DateFormat('dd-MM-yy').format(DateTime.now());

      // Check if progress document exists for today
      final progressQuery =
          await userDocRef
              .collection('progress')
              .where('date', isEqualTo: today)
              .limit(1)
              .get();

      DocumentReference progressRef;

      if (progressQuery.docs.isEmpty) {
        // Create a new progress document if it doesn't exist
        progressRef = await userDocRef.collection('progress').add({
          'date': today,
          'created_at': FieldValue.serverTimestamp(),
          'streak_updated': false, // Initialize streak_updated field
        });
      } else {
        // Use existing progress document
        progressRef = progressQuery.docs.first.reference;
      }

      // Update the specific field
      await progressRef.update({
        field: value,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Check if all 5 fields are filled and streak hasn't been updated today
      final updatedDoc = await progressRef.get();
      final data = updatedDoc.data() as Map<String, dynamic>;

      final bool allFieldsFilled =
          data.containsKey('calories') &&
          data.containsKey('steps') &&
          data.containsKey('water') &&
          data.containsKey('sleep') &&
          data.containsKey('mood');

      final bool streakAlreadyUpdated = data['streak_updated'] ?? false;

      if (allFieldsFilled && !streakAlreadyUpdated) {
        // Update streak
        await userDocRef.update({
          'streak': FieldValue.increment(1),
          'last_complete_date': today,
        });

        // Mark that streak was updated today
        await progressRef.update({'streak_updated': true});

        // Update local streak count and streakUpdatedToday flag
        final userDoc = await userDocRef.get();
        setState(() {
          streak = userDoc.data()?['streak'] ?? 0;
          streakUpdatedToday = true;
        });
      }

      // Refresh the UI
      _loadUserData();
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  void _showInputDialog(String type, String title) {
    final TextEditingController controller = TextEditingController();
    String selectedMood = 'Good';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update $title'),
          content:
              type == 'mood'
                  ? StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Great'),
                            leading: Radio<String>(
                              value: 'Great',
                              groupValue: selectedMood,
                              onChanged: (value) {
                                setState(() => selectedMood = value!);
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Good'),
                            leading: Radio<String>(
                              value: 'Good',
                              groupValue: selectedMood,
                              onChanged: (value) {
                                setState(() => selectedMood = value!);
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Okay'),
                            leading: Radio<String>(
                              value: 'Okay',
                              groupValue: selectedMood,
                              onChanged: (value) {
                                setState(() => selectedMood = value!);
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Not good'),
                            leading: Radio<String>(
                              value: 'Not good',
                              groupValue: selectedMood,
                              onChanged: (value) {
                                setState(() => selectedMood = value!);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  : TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText:
                          'Enter ${type == 'calories'
                              ? 'calories'
                              : type == 'water'
                              ? 'liters of water'
                              : type == 'sleep'
                              ? 'hours of sleep'
                              : 'step count'}',
                    ),
                  ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (type == 'mood') {
                  _updateProgress(type, selectedMood);
                } else if (controller.text.isNotEmpty) {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    _updateProgress(type, value);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Shimmer loading widget for progress card
  Widget _buildShimmerProgressCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Progress indicators shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Mood shimmer
            Container(
              width: 120,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer loading widget for action cards
  Widget _buildShimmerActionCards() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 100,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 92,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the ProgressProvider (but don't listen to it here as we're manually managing updates)
    Provider.of<ProgressProvider>(context, listen: false);

    return isLoading
        ? Column(
          children: [_buildShimmerProgressCard(), _buildShimmerActionCards()],
        )
        : Column(
          children: [
            // Progress Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Use Provider.of with listen: true for each progress indicator
                      Consumer<ProgressProvider>(
                        builder:
                            (context, provider, _) => _buildProgressIndicator(
                              "Calories",
                              provider.caloriesPercentage,
                              "${todayStats['calories'].toInt()}/${todayStats['calorieGoal'].toInt()}",
                              Colors.orange,
                            ),
                      ),
                      Consumer<ProgressProvider>(
                        builder:
                            (context, provider, _) => _buildProgressIndicator(
                              "Steps",
                              provider.stepsPercentage,
                              "${todayStats['steps'].toInt()}",
                              Colors.blue,
                            ),
                      ),
                      Consumer<ProgressProvider>(
                        builder:
                            (context, provider, _) => _buildProgressIndicator(
                              "Water",
                              provider.waterPercentage,
                              "${todayStats['water'].toStringAsFixed(1)} L",
                              Colors.cyan,
                            ),
                      ),
                      Consumer<ProgressProvider>(
                        builder:
                            (context, provider, _) => _buildProgressIndicator(
                              "Sleep",
                              provider.sleepPercentage,
                              "${todayStats['sleep']} hrs",
                              Colors.purple,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mood, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Feeling: ${todayStats['mood']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions Section - No changes needed here
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildActionCard(
                    "Log\nMeals",
                    Icons.restaurant_menu,
                    Colors.green,
                    () {
                      _showInputDialog('calories', 'Calories');
                    },
                  ),
                  _buildActionCard(
                    "Record\nSleep",
                    Icons.bedtime,
                    Colors.indigo,
                    () {
                      _showInputDialog('sleep', 'Sleep');
                    },
                  ),
                  _buildActionCard(
                    "Steps\nCount",
                    Icons.directions_walk,
                    Colors.blue,
                    () {
                      _showInputDialog('steps', 'Steps');
                    },
                  ),
                  _buildActionCard(
                    "How are you\nfeeling?",
                    Icons.mood,
                    Colors.amber,
                    () {
                      _showInputDialog('mood', 'Mood');
                    },
                  ),
                  _buildActionCard(
                    "Water\nIntake",
                    Icons.water_drop,
                    Colors.cyan,
                    () {
                      _showInputDialog('water', 'Water');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildProgressIndicator(
    String label,
    double percentage,
    String text,
    Color color,
  ) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 35,
          lineWidth: 5,
          percent:
              percentage, // No need to check bounds since provider values are already clamped
          center: Text(
            text.split('/')[0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          progressColor: color,
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
