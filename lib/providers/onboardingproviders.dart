// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  // User profile data
  String? gender;
  double? weight;
  double? height;
  int? age = 25; // Default age
  String? activityLevel;
  String? foodPreference;
  String? name;
  String? phone;
  String? email;
  int? streak;
  String? uid;
  double? bmi;
  int? stepsGoal;
  int? sleepGoal;
  int? waterGoal;
  String? lastCompleteDate;
  String? profileImageUrl;
  

  
  // Unit toggles
  bool isKg = true;
  bool isCm = true;
  
  // Page and validation state
  int currentPage = 0;
  String? errorMessage;
  double? maintainanceCalories;
  
  // Getters for all properties including food preference
  
  // Method to update gender
  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  void setFoodPreference(String value) {
    foodPreference = value;
    notifyListeners();
  }
  
  // Method to update weight
  void setWeight(String value) {
    weight = double.tryParse(value);
    notifyListeners();
  }
  
  // Method to update height
  void setHeight(String value) {
    height = double.tryParse(value);
    notifyListeners();
  }
  
  // Method to update age
  void setAge(int value) {
    age = value;
    notifyListeners();
  }
  
  // Method to update activity level
  void setActivityLevel(String value) {
    activityLevel = value;
    notifyListeners();
  }
  
  // Method to toggle weight unit
  void toggleWeightUnit(bool value) {
    isKg = value;
    notifyListeners();
  }
  
  // Method to toggle height unit
  void toggleHeightUnit(bool value) {
    isCm = value;
    notifyListeners();
  }
  
  // Method to update current page
  void setCurrentPage(int page) {
    currentPage = page;
    errorMessage = null;
    notifyListeners();
  }
  
  // Validate current page
  bool validateCurrentPage() {
    errorMessage = null;
    
    switch (currentPage) {
      case 0: // Gender
        if (gender == null) {
          errorMessage = "Please select your gender";
          notifyListeners();
          return false;
        }
        break;
      case 1: // Weight
        if (weight == null) {
          errorMessage = "Please enter your weight";
          notifyListeners();
          return false;
        }
        break;
      case 2: // Height
        if (height == null) {
          errorMessage = "Please enter your height";
          notifyListeners();
          return false;
        }
        break;
      case 3: // Age
        if (age == null) {
          errorMessage = "Please select your age";
          notifyListeners();
          return false;
        }
        break;
      case 4: // Activity Level
        if (activityLevel == null) {
          errorMessage = "Please select your activity level";
          notifyListeners();
          return false;
        }
        break;
      case 5: // Food preference validation
        if (foodPreference == null) {
          errorMessage = 'Please select your food preference';
          notifyListeners();
          return false;
        }
        break;
    }
    notifyListeners();
    return true;
  }
  
  // Method to submit user data
  Future<void> submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Convert measurements if needed
    double convertedWeight = weight!;
    double convertedHeight = height!;
    
    // Convert weight to kg if needed
    if (!isKg) {
      convertedWeight = weight! * 0.453592; // Convert lbs to kg
    }
    
    // Convert height to cm if needed
    if (!isCm) {
      convertedHeight = height! * 30.48; // Convert feet to cm
    }
    
    double bmr;
    if (gender == 'Male') {
      bmr = 88.362 + (13.397 * convertedWeight) + (4.799 * convertedHeight) - (5.677 * age!.toDouble());
    } else {
      bmr = 447.593 + (9.247 * convertedWeight) + (3.098 * convertedHeight) - (4.330 * age!.toDouble());
    }

    if (activityLevel == 'Very active') {
      maintainanceCalories = 1.88 * bmr;
    } else if (activityLevel == 'Active') {
      maintainanceCalories = 1.6 * bmr;
    } else {
      maintainanceCalories = 1.2 * bmr;
    }

    // BMI Calculation
    double heightInMeters = convertedHeight / 100;
    double bmi = convertedWeight / (heightInMeters * heightInMeters);

    String uid = user.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid);
    
    await docRef.set({
      'gender': gender,
      'weight': convertedWeight,
      'height': convertedHeight,
      'age': age,
      'activity_level': activityLevel,
      'profile_completed': true,
      'foodPreference': foodPreference,
      'maintainanceCalories': maintainanceCalories,
      'bmi': bmi,
      'stepsGoal': 10000,
      'sleepGoal': 8,
      'waterGoal': 4,
    }, SetOptions(merge: true));
    
    // Save to SharedPreferences
    await saveProfileCompletionStatus(true);
    notifyListeners();
  }
  
  // Save profile completion status to SharedPreferences
  Future<void> saveProfileCompletionStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_completed', status);
  }
  
  // Check if profile is completed
  static Future<bool> isProfileCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('profile_completed') ?? false;
  }

  Future<void> loadUserDataFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data() ?? {};

      gender = data['gender'];
      weight = (data['weight'] as num?)?.toDouble();
      height = (data['height'] as num?)?.toDouble();
      age = data['age'];
      activityLevel = data['activity_level'];
      foodPreference = data['foodPreference'];
      maintainanceCalories = (data['maintainanceCalories'] as num?)?.toDouble();
      bmi = (data['bmi'] as num?)?.toDouble();
      stepsGoal = data['stepsGoal'];
      sleepGoal = data['sleepGoal'];
      waterGoal = data['waterGoal'];
      lastCompleteDate = data['last_complete_date'];
      email = data['email'];
      name = data['name'];
      phone = data['phone'];
      uid = data['uid'];
      streak = data['streak'];
      profileImageUrl = data['profileImageUrl'];

      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profileImageUrl': imageUrl});

      profileImageUrl = imageUrl;
      notifyListeners();
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

}