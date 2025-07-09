// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class DietResultScreen extends StatefulWidget {
  final String plan;

  const DietResultScreen({super.key, required this.plan});

  @override
  State<DietResultScreen> createState() => _DietResultScreenState();
}

class _DietResultScreenState extends State<DietResultScreen> {
  
  Future<void> _saveDietToProgress() async {
    try {
      // Get Firebase instances and user ID
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final userId = auth.currentUser?.uid;
      
      if (userId == null) return;
      
      // Prepare diet data
      final diet = _prepareDietData();
      
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
        
        // Get existing diets array or create new one
        List<dynamic> existingDiets = progressDoc.data()['diets'] ?? [];
        existingDiets.add(diet);
        
        // Update the document with the new diet
        await progressDoc.reference.update({
          'diets': existingDiets,
          'last_diet_time': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Create new progress document for today
        await userDoc.collection('progress').add({
          'date': today,
          'diets': [diet],
          'last_diet_time': DateTime.now().millisecondsSinceEpoch,
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
        const SnackBar(content: Text('Diet plan saved successfully!')),
      );
    } catch (e) {
      print('Error saving diet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save diet plan: $e')),
      );
    }
  }
  
  Map<String, dynamic> _prepareDietData() {
    List<Map<String, dynamic>> meals = [];
    
    try {
      final jsonData = jsonDecode(widget.plan);
      if (jsonData != null && jsonData['meals'] != null) {
        meals = List<Map<String, dynamic>>.from(jsonData['meals']);
      }
    } catch (e) {
      print('Error parsing diet plan: $e');
    }
    
    int totalItems = 0;
    for (final meal in meals) {
      if (meal['items'] != null) {
        totalItems += (meal['items'] as List).length;
      }
    }
    
    // Create diet data object
    return {
      'type': 'Custom Diet Plan',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'meal_count': meals.length,
      'item_count': totalItems,
      'meals': meals.map((meal) => {
        'meal': meal['meal'] ?? 'Unnamed Meal',
        'item_count': (meal['items'] as List?)?.length ?? 0,
      }).toList(),
      'raw_data': widget.plan, // Store the original JSON for possible later use
    };
  }
  
  
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> meals = [];

    try {
      final jsonData = jsonDecode(widget.plan);
      if (jsonData != null && jsonData['meals'] != null) {
        meals = List<Map<String, dynamic>>.from(jsonData['meals']);
      }
    } catch (e) {
      // fallback: empty
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Your Diet Plan',
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
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Personalized Diet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...meals.map((meal) => _buildMealCard(meal)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveDietToProgress();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saving diet...')),
                    );

                    Navigator.pop(context);
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
                    'USE THIS PLAN',
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

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final mealName = meal['meal'] as String? ?? '';
    final items = meal['items'] as List<dynamic>? ?? [];

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
            decoration: const BoxDecoration(
              color: Color(0xFF1FC3FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              mealName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map<Widget>((item) {
                final text = item['text'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1FC3FF),
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
}
