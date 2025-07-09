// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BmiSection extends StatefulWidget {
  const BmiSection({super.key});

  @override
  _BmiSectionState createState() => _BmiSectionState();
}

class _BmiSectionState extends State<BmiSection> {
  bool showBmiInfo = false;
  Map<String, dynamic>? userData;
  double bmi = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        
        if (docSnapshot.exists) {
          setState(() {
            userData = docSnapshot.data();
            _calculateBmi();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _calculateBmi() {
    if (userData != null) {
      final weight = (userData!['weight'] as num?)?.toDouble() ?? 0;
      final height = (userData!['height'] as num?)?.toDouble() ?? 0;
      
      if (height > 0 && weight > 0) {
        // BMI formula: weight(kg) / (height(m))²
        final heightInMeters = height / 100;
        bmi = weight / (heightInMeters * heightInMeters);
      }
    }
  }

  void _toggleInfo() {
    setState(() {
      showBmiInfo = !showBmiInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text("No user data available"),
        ),
      );
    }

    final weight = (userData!['weight'] as num?)?.toDouble() ?? 0;
    final height = (userData!['height'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "BMI Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(showBmiInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                onPressed: _toggleInfo,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getBmiColor(bmi).withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getBmiColor(bmi),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getBmiCategory(bmi),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getBmiColor(bmi),
                    ),
                  ),
                  Text(
                    "Weight: ${weight}kg | Height: ${height.toStringAsFixed(2)}cm",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (showBmiInfo) ...[
            const SizedBox(height: 16),
            const Text(
              "BMI Categories:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBmiScale(context, bmi),
            const SizedBox(height: 8),
            const Text(
              "Note: BMI is just one health indicator. Consider also your body composition, fitness level, and other health metrics.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBmiScale(BuildContext context, double bmi) {
    double position = ((bmi - 15) / 25).clamp(0.0, 1.0); // Safely clamp value between 0 and 1

    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width * 0.8 * position,
            child: Container(
              width: 10,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Healthy";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }
}