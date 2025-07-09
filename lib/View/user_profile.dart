// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:train_hard_reborn/providers/onboardingproviders.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isUploading = false; // Added separate state for upload process
  File? _imageFile;
  String? _profileImageUrl;
  final Color _primaryColor = const Color(0xFF1FC3FF);
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      await provider.loadUserDataFromFirestore();
      
      // Load profile image URL if exists
      setState(() {
        _profileImageUrl = provider.profileImageUrl;
        _isLoading = false;
      });
    } catch (e) {
      // Error handling for loading user data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isUploading = true; // Show uploading indicator
        });
        
        await _uploadProfileImage();
        print("Image file path: ${_imageFile?.path}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      setState(() => _isUploading = false);
    }
  }
  
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) {
      setState(() => _isUploading = false);
      return;
    }
    
    try {
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      final userId = provider.uid;
      
      if (userId == null) {
        throw Exception('User ID not available');
      }
      
      // Create a unique file name
      final fileName = 'profile_$userId.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      
      // Upload the file
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
    

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Save to Firestore via provider
      await provider.updateProfileImage(downloadUrl);
      
      setState(() {
        _profileImageUrl = downloadUrl;
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      setState(() => _isUploading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    // Show loading indicator for initial data loading only
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }
    
    // User data
    final userData = {
      'name': provider.name ?? 'Guest',
      'workoutsCompleted': 87,
      'activeDays': 36,
      'achievements': 12,
      'weight': provider.weight ?? 68.5,
      'height': provider.height != null ? provider.height!.toStringAsFixed(2) : '175.00',
      'bmi': provider.maintainanceCalories != null && provider.height != null && provider.weight != null
          ? (provider.weight! / ((provider.height! / 100) * (provider.height! / 100))).toStringAsFixed(1)
          : 'N/A',
      'streak': provider.streak ?? 0,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('My Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(userData, context),
                const SizedBox(height: 20),
                _buildStatsSection(userData),
                const SizedBox(height: 20),
                _buildBodyMetricsCard(userData),
                const SizedBox(height: 20),
                _buildWorkoutHistorySection(),
                const SizedBox(height: 20),
                _buildAchievementsSection(userData),
                const SizedBox(height: 90),
              ],
            ),
          ),
          
          // Overlay loading indicator for uploads only
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _primaryColor),
                        const SizedBox(height: 16),
                        const Text(
                          'Uploading image...',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          // Profile image with edit button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: _getProfileImage(),
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: _primaryColor,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // User info
          Text(
            userData['name'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Edit profile button
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: _primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  DecorationImage _getProfileImage() {
    if (_imageFile != null) {
      // Show the selected image file
      return DecorationImage(
        image: FileImage(_imageFile!),
        fit: BoxFit.cover,
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      // Show the stored profile image
      return DecorationImage(
        image: NetworkImage(_profileImageUrl!),
        fit: BoxFit.cover,
      );
    } else {
      // Show default placeholder
      return const DecorationImage(
        image: NetworkImage('https://i.pravatar.cc/300'),
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildStatsSection(Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(userData['workoutsCompleted'].toString(), 'Workouts', Icons.fitness_center),
          _buildStatItem(userData['activeDays'].toString(), 'Active Days', Icons.calendar_today),
          _buildStatItem(userData['streak'].toString(), 'Day Streak', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: _primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMetricsCard(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Body Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Weight', '${userData['weight']} kg'),
              _buildMetricItem('Height', '${userData['height']} cm'),
              _buildMetricItem('BMI', '${userData['bmi']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistorySection() {
    // Sample workout data
    final workouts = [
      {'name': 'Full Body Workout', 'time': '45 min', 'date': 'Today', 'calories': '320'},
      {'name': 'Morning Cardio', 'time': '30 min', 'date': 'Yesterday', 'calories': '280'},
      {'name': 'Upper Body Strength', 'time': '50 min', 'date': 'Mar 30', 'calories': '350'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Workouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All', style: TextStyle(color: Color(0xFF1FC3FF))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...workouts.map((workout) => _buildWorkoutItem(workout)),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(Map<String, String> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fitness_center, color: _primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout['time']} • ${workout['date']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout['calories']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'calories',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All', style: TextStyle(color: Color(0xFF1FC3FF))),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAchievementItem('7 Day Streak', Icons.local_fire_department, Colors.orange),
                _buildAchievementItem('First Marathon', Icons.directions_run, Colors.green),
                _buildAchievementItem('10K Steps', Icons.directions_walk, _primaryColor),
                _buildAchievementItem('Weight Goal', Icons.monitor_weight, Colors.purple),
                _buildAchievementItem('Early Bird', Icons.wb_sunny, Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}