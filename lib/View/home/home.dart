// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Import all the component files

import 'daily_progress_section.dart';
import 'bmi_section.dart';
import 'weekly_workout_section.dart';
import 'ai_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Sample workout data for the week
  final List<double> _weeklyWorkouts = [45, 0, 60, 30, 0, 50, 0];
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<Map<String, dynamic>?> userDataStream(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => snapshot.data());
}

Widget _buildAppBar(String uid) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: userDataStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        }

        final userData = snapshot.data;
        final userName = userData?['name'] ?? 'User';
        final imageUrl = userData?['imageUrl'];
        final streak = userData?['streak'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  imageUrl != null && imageUrl.isNotEmpty
                      ? Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 2),
                            color: Colors.grey.shade200,
                          ),
                          child: const Icon(Icons.person, color: Colors.blueAccent),
                        ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back,",
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department, 
                      color: Colors.white, 
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$streak",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar with user profile
              _buildAppBar(uid),
              
              // Daily progress overview
              DailyProgressSection(),//todayStats: _todayStats),
              
              // BMI information
              BmiSection(),
              
              // Weekly workout summary
              WeeklyWorkoutsSection(
                weeklyWorkouts: _weeklyWorkouts,
                weekDays: _weekDays,
              ),
              
              // AI recommendations
              const AiRecommendationsSection(),

              const SizedBox(height: 10),
              
            ],
          ),
        ),
      ),
    );
  }
}