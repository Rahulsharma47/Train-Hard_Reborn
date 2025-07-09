import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  
  const BottomNavBar({
    super.key, 
    this.selectedIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return 
    
    CurvedNavigationBar(
      backgroundColor: Colors.transparent, // Important for extendBody
      color: const Color(0xFF1FC3FF),
      buttonBackgroundColor: const Color(0xFF1FC3FF),
      height: 60,
      animationDuration: const Duration(milliseconds: 300),
      index: selectedIndex,
      onTap: onTap,
      items: const [
        Icon(Icons.home_outlined, color: Colors.white, size: 26),
        Icon(Icons.fitness_center_outlined, color: Colors.white, size: 26),
        Icon(Icons.restaurant_menu_outlined, color: Colors.white, size: 32),
        Icon(Icons.groups_2_outlined, color: Colors.white, size: 26),
        Icon(Icons.person, color: Colors.white, size: 26),
      ],
    );
  }
}