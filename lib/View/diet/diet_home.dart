// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:train_hard_reborn/Api/gemini_api_diet.dart';
import 'package:train_hard_reborn/View/diet/diet_result.dart';

class DietHomeScreen extends StatelessWidget {
  const DietHomeScreen({super.key});

  final List<Map<String, dynamic>> _goals = const [
    {'label': 'Weight Loss', 'icon': Icons.local_fire_department},
    {'label': 'Muscle Gain', 'icon': Icons.fitness_center},
    {'label': 'Maintenance', 'icon': Icons.restaurant_menu},
    {'label': 'Keto Diet', 'icon': Icons.fastfood},
    {'label': 'Vegan Diet', 'icon': Icons.eco},
    {'label': 'High Protein', 'icon': Icons.egg_alt},
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
          'Diet Plans',
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
              'What is your goal today?',
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
                    _goals.map((goal) {
                      return _buildGoalItem(
                        context: context,
                        icon: goal['icon'],
                        label: goal['label'],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleGoalTap(context, label),
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
                'Generate Plan',
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

  void _handleGoalTap(BuildContext context, String goal) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
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

    try {
      final userData = await fetchUserData(uid);
      final geminiDietService = GeminiDietService();

      final dietPlan = await geminiDietService.generateDietPlan(goal, userData);

      // After getting response, pop the loading dialog
      Navigator.of(context).pop();

      // Then navigate to the result screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DietResultScreen(plan: dietPlan)),
      );
    } catch (e) {
      Navigator.of(
        context,
      ).pop(); // Always remove the loading dialog on error too

      // Optionally, show error dialog/snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }
}
