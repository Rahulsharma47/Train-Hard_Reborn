// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:train_hard_reborn/Api/gemini_api_workout.dart';
import 'dart:convert';

import 'package:train_hard_reborn/View/workout/workout_exercise.dart';

class WorkoutResultScreen extends StatefulWidget {
  final String plan;
  final String category;
  final Map<String, dynamic> userData;

  const WorkoutResultScreen({
    super.key, 
    required this.plan,  
    required this.category,
    required this.userData,
    });

  @override
  State<WorkoutResultScreen> createState() => _WorkoutResultScreenState();
}

class _WorkoutResultScreenState extends State<WorkoutResultScreen> {
  late String _currentPlan;


  Future<void> _regenerateWorkout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final geminiService = GeminiService();
      final newPlan = await geminiService.generateWorkoutPlan(
        widget.category,
        widget.userData,
      );

      Navigator.of(context).pop(); // close loading

      setState(() {
        _currentPlan = newPlan;
      });
    } catch (e) {
      Navigator.of(context).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
  }


  @override
  Widget build(BuildContext context) {
    // Parse the workout plan from JSON
    List<Map<String, dynamic>> sections = [];

    try {
      // Attempt to parse the JSON
      final jsonData = jsonDecode(_currentPlan);
      if (jsonData != null && jsonData['sections'] != null) {
        sections = List<Map<String, dynamic>>.from(jsonData['sections']);
      }
    } catch (e) {
      // Fallback to the old parsing method if JSON parsing fails
      sections = _parseWorkoutPlan(_currentPlan);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Your Workout Plan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout plan title card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1FC3FF), Color(0xFF1A97C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getWorkoutIcon(_currentPlan),
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getWorkoutType(_currentPlan),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getWorkoutDuration(_currentPlan),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Workout sections
              ...sections.map((section) => _buildSectionCard(section)),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _regenerateWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FC3FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'DIFFERENT WORKOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkoutExerciseScreen(
                          sections: sections,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FC3FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'START WORKOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Parse the workout plan into sections (legacy fallback method)
  List<Map<String, dynamic>> _parseWorkoutPlan(String plan) {
    final sections = <Map<String, dynamic>>[];

    // Find sections using regex
    final sectionPattern = RegExp(
      r'\*\*(.*?)\*\*\s*(?:\((.*?)\))?\s*([\s\S]*?)(?=\*\*|\Z)',
    );
    final matches = sectionPattern.allMatches(plan);

    for (final match in matches) {
      final title = match.group(1)?.trim() ?? '';
      final duration = match.group(2)?.trim() ?? '';
      final content = match.group(3)?.trim() ?? '';

      // Parse content into exercises
      final exercises = <Map<String, String>>[];

      // First, try to parse numbered exercises
      final numberedExercisePattern = RegExp(r'(\d+)\.\s*(.*?)(?=\d+\.\s*|\Z)');
      final numberedMatches = numberedExercisePattern.allMatches(content);

      if (numberedMatches.isNotEmpty) {
        for (final exerciseMatch in numberedMatches) {
          final exerciseText = exerciseMatch.group(2)?.trim() ?? '';
          exercises.add({'text': exerciseText});
        }
      } else {
        // Check for bullet points (asterisks)
        final bulletPattern = RegExp(r'\*\s*(.*?)(?=\*\s*|\Z)');
        final bulletMatches = bulletPattern.allMatches(content);

        if (bulletMatches.isNotEmpty) {
          for (final bulletMatch in bulletMatches) {
            final exerciseText = bulletMatch.group(1)?.trim() ?? '';
            exercises.add({'text': exerciseText});
          }
        } else {
          // Just split by newlines if no specific format is detected
          final lines =
              content
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList();
          for (final line in lines) {
            exercises.add({'text': line.trim()});
          }
        }
      }

      sections.add({
        'title': title,
        'duration': duration,
        'exercises': exercises,
      });
    }

    return sections;
  }

  // Build a section card
  Widget _buildSectionCard(Map<String, dynamic> section) {
    final title = section['title'] as String;
    final duration = section['duration'] as String? ?? '';
    final exercises = section['exercises'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _getSectionColor(title),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (duration.isNotEmpty)
                  Text(
                    duration,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  exercises.map<Widget>((exercise) {
                    final text = exercise['text'] as String? ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getSectionColor(title),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on section title
  Color _getSectionColor(String title) {
    title = title.toLowerCase();
    if (title.contains('warm')) {
      return const Color(0xFFFF9800); // Orange for warm-up
    } else if (title.contains('workout') || title.contains('circuit')) {
      return const Color(0xFF1FC3FF); // Blue for main workout
    } else if (title.contains('cool')) {
      return const Color(0xFF4CAF50); // Green for cool-down
    } else {
      return const Color(0xFF9C27B0); // Purple for other sections
    }
  }

  // Get workout type from plan
  String _getWorkoutType(String plan) {
    final lowerPlan = plan.toLowerCase();

    if (lowerPlan.contains('chest')) return 'Chest Workout';
    if (lowerPlan.contains('back')) return 'Back Workout';
    if (lowerPlan.contains('biceps')) return 'Biceps Workout';
    if (lowerPlan.contains('triceps')) return 'Triceps Workout';
    if (lowerPlan.contains('legs')) return 'Leg Day';
    if (lowerPlan.contains('shoulders')) return 'Shoulder Workout';
    if (lowerPlan.contains('abs') || lowerPlan.contains('core')) {
      return 'Abs/Core Workout';
    }
    if (lowerPlan.contains('cardio')) return 'Cardio Workout';
    if (lowerPlan.contains('yoga')) return 'Yoga Session';
    if (lowerPlan.contains('stretching')) return 'Stretching Routine';
    if (lowerPlan.contains('hypertrophy')) return 'Hypertrophy Training';
    if (lowerPlan.contains('fat loss')) return 'Fat Loss Workout';

    return 'Custom Workout';
  }

  // Get workout icon based on type
  IconData _getWorkoutIcon(String plan) {
    final lowerPlan = plan.toLowerCase();

    if (lowerPlan.contains('chest')) return Icons.fitness_center;
    if (lowerPlan.contains('back')) return Icons.accessibility;
    if (lowerPlan.contains('biceps')) return Icons.sports_mma;
    if (lowerPlan.contains('triceps')) return Icons.fitness_center;
    if (lowerPlan.contains('legs')) return Icons.directions_walk;
    if (lowerPlan.contains('shoulders')) return Icons.accessibility_new;
    if (lowerPlan.contains('abs') || lowerPlan.contains('core')) {
      return Icons.grid_4x4;
    }
    if (lowerPlan.contains('cardio')) return Icons.directions_run;
    if (lowerPlan.contains('yoga')) return Icons.self_improvement;
    if (lowerPlan.contains('stretching')) return Icons.accessibility_new;
    if (lowerPlan.contains('hypertrophy')) return Icons.sports_mma;
    if (lowerPlan.contains('fat loss')) return Icons.local_fire_department;

    return Icons.fitness_center;
  }

  // Get workout duration from plan
  String _getWorkoutDuration(String plan) {
    try {
      final jsonData = jsonDecode(plan);
      if (jsonData != null && jsonData['sections'] != null) {
        final sections = List<Map<String, dynamic>>.from(jsonData['sections']);
        int totalMinutes = 0;

        for (final section in sections) {
          final duration = section['duration'] as String? ?? '';
          final numPattern = RegExp(r'(\d+)');
          final matches = numPattern.allMatches(duration);

          if (matches.isNotEmpty) {
            totalMinutes += int.parse(matches.first.group(1) ?? '0');
          }
        }

        if (totalMinutes > 0) {
          return '$totalMinutes Minute Workout';
        }
      }
    } catch (_) {
      // fallback to regex
    }

    final durationPattern = RegExp(r'(\d+)[- ]*minute');
    final match = durationPattern.firstMatch(plan);

    if (match != null) {
      return '${match.group(1)} Minute Workout';
    } else {
      return 'Custom Duration';
    }
  }
}
