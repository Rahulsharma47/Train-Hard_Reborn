import 'package:flutter/material.dart';
import 'package:train_hard_reborn/widgets/bottom_nav_bar.dart';
import 'package:train_hard_reborn/View/home/home.dart';
import 'package:train_hard_reborn/View/community.dart';
import 'package:train_hard_reborn/View/workout/workout_home.dart';
import 'package:train_hard_reborn/View/diet/diet_home.dart';
import 'package:train_hard_reborn/View/user_profile.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    WorkoutHomeScreen(),
    DietHomeScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the initial index
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary reload
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
