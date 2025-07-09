// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:train_hard_reborn/Api/gemini_api_workout.dart';
import 'package:train_hard_reborn/View/workout/workout_result.dart';

class WorkoutHomeScreen extends StatelessWidget {
  WorkoutHomeScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'Cardio', 'icon': Icons.directions_run},
    {'label': 'Yoga', 'icon': Icons.self_improvement},
    {'label': 'Full Body', 'icon': Icons.fitness_center},
    {'label': 'Stretching', 'icon': Icons.accessibility_new},
    {'label': 'Fat Loss', 'icon': Icons.local_fire_department},
    {'label': 'Hypertrophy', 'icon': Icons.sports_mma},
  ];

  final List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
  ];

  final List<String> _pplOptions = [
    'Push (Chest, Shoulders, Triceps)',
    'Pull (Back, Biceps)',
    'Legs (Quads, Hamstrings, Calves, Glutes)',
  ];

  final List<String> _trainingStyles = [
    'Bro-Split',
    'Push/Pull/Legs',
    'Compound',
  ];

  final List<String> _durations = [
    '30 minutes',
    '45 minutes',
    '60 minutes',
    '90 minutes',
  ];

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      return docSnapshot.data() ?? {};
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Workout',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'What would you like to do today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children:
                    _categories.map((category) {
                      return _buildCategoryItem(
                        context: context,
                        icon: category['icon'],
                        label: category['label'],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Handle different actions based on the category label
          _handleCategoryTap(context, label);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1FC3FF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(icon, size: 36, color: const Color(0xFF1FC3FF)),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start now',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, String category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userData = await fetchUserData(uid);

      if (category == 'Hypertrophy' || category == 'Fat Loss') {
        // Show dialog for muscle group, duration, and training style selection
        Map<String, dynamic>? additionalParams =
            await _showWorkoutPreferencesDialog(context);

        // User canceled the dialog
        if (additionalParams == null) return;

        // Add the additional parameters to userData for Gemini to process
        userData['targetMuscle'] = additionalParams['muscleGroup'];
        userData['workoutDuration'] = additionalParams['duration'];
        userData['trainingStyle'] = additionalParams['trainingStyle'];
      }

      // Show loading spinner with text
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF1FC3FF),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Generating",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );

      final geminiService = GeminiService();
      final workoutPlan = await geminiService.generateWorkoutPlan(
        category,
        userData,
      );

      // Close the loading dialog
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutResultScreen(
            plan: workoutPlan,
            category: category,
            userData: userData,
            ),
        ),
      );
    } catch (e) {
      // Close the loading dialog if it's showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }

  Future<Map<String, dynamic>?> _showWorkoutPreferencesDialog(
    BuildContext context,
  ) async {
    String selectedMuscleGroup = _muscleGroups.first;
    String selectedDuration = _durations.first;
    String selectedTrainingStyle = _trainingStyles.first;
    String selectedPPLOption = _pplOptions.first;
    bool showPPLOptions = false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Customize Your Workout'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Style:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedTrainingStyle,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      items:
                          _trainingStyles.map((style) {
                            return DropdownMenuItem<String>(
                              value: style,
                              child: Text(style),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTrainingStyle = value!;
                          // Show PPL options only when Push/Pull/Legs is selected
                          showPPLOptions = (value == 'Push/Pull/Legs');
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Conditionally show PPL options or muscle groups based on training style
                    if (showPPLOptions) ...[
                      const Text(
                        'Select PPL Day:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedPPLOption,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _pplOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: Text(
                                    option,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPPLOption = value!;
                          });
                        },
                        isExpanded: true,
                      ),
                    ] else ...[
                      const Text(
                        'Target Muscle Group:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedMuscleGroup,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _muscleGroups.map((muscle) {
                              return DropdownMenuItem<String>(
                                value: muscle,
                                child: Text(muscle),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMuscleGroup = value!;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Text(
                      'Workout Duration:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedDuration,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      items:
                          _durations.map((duration) {
                            return DropdownMenuItem<String>(
                              value: duration,
                              child: Text(duration),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDuration = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String muscleTarget =
                        showPPLOptions
                            ? selectedPPLOption
                            : selectedMuscleGroup;

                    Navigator.of(context).pop({
                      'muscleGroup': muscleTarget,
                      'duration': selectedDuration,
                      'trainingStyle': selectedTrainingStyle,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FC3FF),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
