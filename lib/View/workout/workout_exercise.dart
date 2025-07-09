// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class WorkoutExerciseScreen extends StatefulWidget {
  final List<Map<String, dynamic>> sections;

  const WorkoutExerciseScreen({super.key, required this.sections});

  @override
  State<WorkoutExerciseScreen> createState() => _WorkoutExerciseScreenState();
}

class _WorkoutExerciseScreenState extends State<WorkoutExerciseScreen> {
  int _currentSectionIndex = 0;
  int _currentExerciseIndex = 0;
  late Timer _exerciseTimer;
  int _remainingSeconds = 0;
  bool _isResting = false;
  bool _isPaused = false;
  final int _restDuration = 30; // Rest duration in seconds
  
  @override
  void initState() {
    super.initState();
    _startExerciseTimer();
  }

  @override
  void dispose() {
    _exerciseTimer.cancel();
    super.dispose();
  }

  void _startExerciseTimer() {
    // Parse the current exercise duration
    _remainingSeconds = _getExerciseDuration();
    
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Time is up for current exercise or rest
          _exerciseTimer.cancel();
          
          if (_isResting) {
            // Rest period is over, move to next exercise
            _isResting = false;
            _moveToNextExercise();
          } else {
            // Exercise is over, start rest period
            _isResting = true;
            _remainingSeconds = _restDuration;
            _startExerciseTimer();
          }
        }
      });
    });
  }

  int _getExerciseDuration() {
    // Default duration in seconds (30 seconds per exercise if not specified)
    int duration = 30;
    
    // Try to extract duration from the current exercise
    // This depends on how your exercise data is structured
    final currentExercise = _getCurrentExercise();
    if (currentExercise != null && currentExercise.containsKey('duration')) {
      final exerciseDuration = currentExercise['duration'];
      if (exerciseDuration is int) {
        return exerciseDuration;
      } else if (exerciseDuration is String) {
        final numPattern = RegExp(r'(\d+)');
        final matches = numPattern.allMatches(exerciseDuration);
        if (matches.isNotEmpty) {
          return int.parse(matches.first.group(1) ?? '30');
        }
      }
    }
    
    return duration;
  }

  void _moveToNextExercise() {
    final currentSection = widget.sections[_currentSectionIndex];
    final exercises = currentSection['exercises'] as List<dynamic>;
    
    if (_currentExerciseIndex < exercises.length - 1) {
      // Move to next exercise in current section
      setState(() {
        _currentExerciseIndex++;
        _remainingSeconds = _getExerciseDuration();
      });
      _startExerciseTimer();
    } else if (_currentSectionIndex < widget.sections.length - 1) {
      // Move to first exercise in next section
      setState(() {
        _currentSectionIndex++;
        _currentExerciseIndex = 0;
        _remainingSeconds = _getExerciseDuration();
      });
      _startExerciseTimer();
    } else {
      // Workout completed
      _showWorkoutCompletedDialog();
    }
  }

  void _moveToPreviousExercise() {
    if (_currentExerciseIndex > 0) {
      // Move to previous exercise in current section
      setState(() {
        _currentExerciseIndex--;
        _isResting = false;
        _remainingSeconds = _getExerciseDuration();
      });
      _exerciseTimer.cancel();
      _startExerciseTimer();
    } else if (_currentSectionIndex > 0) {
      // Move to last exercise in previous section
      setState(() {
        _currentSectionIndex--;
        final previousSection = widget.sections[_currentSectionIndex];
        final exercises = previousSection['exercises'] as List<dynamic>;
        _currentExerciseIndex = exercises.length - 1;
        _isResting = false;
        _remainingSeconds = _getExerciseDuration();
      });
      _exerciseTimer.cancel();
      _startExerciseTimer();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Map<String, dynamic>? _getCurrentExercise() {
    if (_currentSectionIndex < widget.sections.length) {
      final currentSection = widget.sections[_currentSectionIndex];
      final exercises = currentSection['exercises'] as List<dynamic>;
      
      if (_currentExerciseIndex < exercises.length) {
        return exercises[_currentExerciseIndex] as Map<String, dynamic>;
      }
    }
    return null;
  }

  String _getCurrentSectionTitle() {
    if (_currentSectionIndex < widget.sections.length) {
      return widget.sections[_currentSectionIndex]['title'] as String;
    }
    return '';
  }

  void _showWorkoutCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Workout Completed!'),
        content: const Text('Congratulations! You have completed the workout.'),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveWorkoutToProgress();

              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to workout plan screen
              Navigator.of(context).pop();
            },
            child: const Text('FINISH'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkoutToProgress() async {
    try {
      // Get Firebase instances and user ID
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final userId = auth.currentUser?.uid;
      
      if (userId == null) return;
      
      // Prepare workout data
      final workout = _prepareWorkoutData();
      
      // Get today's date in the format used in the app
      final today = DateFormat('dd-MM-yy').format(DateTime.now());
      
      // Reference to user's document
      final userDoc = firestore.collection('users').doc(userId);
      
      // Check if progress document exists for today
      final progressQuery = await userDoc
          .collection('progress')
          .where('date', isEqualTo: today)
          .limit(1)
          .get();
      
      if (progressQuery.docs.isNotEmpty) {
        // Update existing progress document
        final progressDoc = progressQuery.docs.first;
        
        // Get existing workouts array or create new one
        List<dynamic> existingWorkouts = progressDoc.data()['workouts'] ?? [];
        existingWorkouts.add(workout);
        
        // Update the document with the new workout
        await progressDoc.reference.update({
          'workouts': existingWorkouts,
          'last_workout_time': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Create new progress document for today
        await userDoc.collection('progress').add({
          'date': today,
          'workouts': [workout],
          'last_workout_time': DateTime.now().millisecondsSinceEpoch,
          'calories': 0.0,
          'steps': 0.0,
          'water': 0.0,
          'sleep': 0.0,
          'mood': 'Not recorded',
          'streak_updated': false,
        });
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved successfully!')),
      );
    } catch (e) {
      print('Error saving workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout: $e')),
      );
    }
  }
  
  Map<String, dynamic> _prepareWorkoutData() {
    // Calculate total duration
    int totalDuration = 0;
    
    // Get workout type from the first section title
    String workoutType = widget.sections.isNotEmpty 
        ? widget.sections[0]['title'] 
        : 'Custom Workout';
        
    // Count total exercises
    int totalExercises = 0;
    for (final section in widget.sections) {
      final exercises = section['exercises'] as List<dynamic>;
      totalExercises += exercises.length;
      
      // Try to get duration from section
      final duration = section['duration'] as String? ?? '';
      final numPattern = RegExp(r'(\d+)');
      final matches = numPattern.allMatches(duration);
      
      if (matches.isNotEmpty) {
        totalDuration += int.parse(matches.first.group(1) ?? '0');
      }
    }
    
    // If we couldn't parse duration, estimate it
    if (totalDuration == 0) {
      // Assume 30 seconds per exercise plus 30 seconds rest between
      totalDuration = totalExercises * 60; // in seconds
      
      // Convert to minutes
      totalDuration = (totalDuration / 60).ceil();
    }
    
    // Create workout data object
    return {
      'type': workoutType,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'duration': totalDuration, // in minutes
      'exercises_count': totalExercises,
      'sections': widget.sections.map((section) => {
        'title': section['title'],
        'duration': section['duration'] ?? '',
        'exercise_count': (section['exercises'] as List).length,
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _getCurrentExercise();
    final sectionTitle = _getCurrentSectionTitle();
    final progress = _calculateProgress();
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          sectionTitle,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            _showExitConfirmationDialog();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isResting ? Colors.orange : const Color(0xFF1FC3FF),
              ),
              minHeight: 6,
            ),
            
            // Main content
            Expanded(
              child: currentExercise != null
                  ? _buildExerciseContent(currentExercise)
                  : const Center(child: Text('No exercise data available')),
            ),
            
            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseContent(Map<String, dynamic> exercise) {
    final exerciseText = exercise['text'] as String? ?? '';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Section title indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getSectionColor(_getCurrentSectionTitle()).withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _getCurrentSectionTitle(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getSectionColor(_getCurrentSectionTitle()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Rest or Exercise indicator
          Text(
            _isResting ? 'REST' : 'EXERCISE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isResting ? Colors.orange : const Color(0xFF1FC3FF),
            ),
          ),
          const SizedBox(height: 12),
          
          // Timer display
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isResting ? Colors.orange : const Color(0xFF1FC3FF),
              boxShadow: [
                BoxShadow(
                  color: (_isResting ? Colors.orange : const Color(0xFF1FC3FF)).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_remainingSeconds',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Exercise name/description
          if (!_isResting)
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  Text(
                    exerciseText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Exercise ${_currentExerciseIndex + 1} of ${_getTotalExercisesInSection()}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          if (_isResting)
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  const Text(
                    'Rest Period',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Next: Exercise ${_currentExerciseIndex + 1} of ${_getTotalExercisesInSection()}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _moveToPreviousExercise,
            icon: const Icon(Icons.skip_previous, size: 32),
            color: const Color(0xFF1FC3FF),
          ),
          FloatingActionButton(
            onPressed: _togglePause,
            backgroundColor: _isPaused ? Colors.orange : const Color(0xFF1FC3FF),
            child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          ),
          IconButton(
            onPressed: () {
              _exerciseTimer.cancel();
              _isResting = false;
              _moveToNextExercise();
            },
            icon: const Icon(Icons.skip_next, size: 32),
            color: const Color(0xFF1FC3FF),
          ),
        ],
      ),
    );
  }

  int _getTotalExercisesInSection() {
    if (_currentSectionIndex < widget.sections.length) {
      final currentSection = widget.sections[_currentSectionIndex];
      final exercises = currentSection['exercises'] as List<dynamic>;
      return exercises.length;
    }
    return 0;
  }

  double _calculateProgress() {
    int totalExercises = 0;
    int completedExercises = 0;
    
    // Count total exercises across all sections
    for (int i = 0; i < widget.sections.length; i++) {
      final section = widget.sections[i];
      final exercises = section['exercises'] as List<dynamic>;
      totalExercises += exercises.length;
      
      // Count completed exercises
      if (i < _currentSectionIndex) {
        // All exercises in previous sections are complete
        completedExercises += exercises.length;
      } else if (i == _currentSectionIndex) {
        // Count exercises in current section
        completedExercises += _currentExerciseIndex;
      }
    }
    
    return totalExercises > 0 ? completedExercises / totalExercises : 0;
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout'),
        content: const Text('Are you sure you want to exit the workout? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to workout plan screen
            },
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
  }

  // Get color based on section title (copy from WorkoutResultScreen)
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
}