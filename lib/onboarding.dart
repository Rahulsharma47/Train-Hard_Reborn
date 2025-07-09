// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:train_hard_reborn/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: 'Track Your Fitness Journey',
      description: 'Monitor your workouts, progress, and achieve your fitness goals.',
      imagePath: 'assets/images/tracker.svg',
      backgroundColor: Colors.blue.shade50,
      iconData: Icons.fitness_center,
    ),
    OnboardingData(
      title: 'Personalized Workout Plans',
      description: 'Get customized workout routines tailored to your fitness level and goals.',
      imagePath: 'assets/images/training.svg',
      backgroundColor: Colors.blue.shade50,
      iconData: Icons.schedule,
    ),
    OnboardingData(
      title: 'Nutrition Tracking',
      description: 'Log your meals, track calories, and maintain a balanced diet.',
      imagePath: 'assets/images/nutrion.svg',
      backgroundColor: Colors.blue.shade50,
      iconData: Icons.restaurant_menu,
    ),
    OnboardingData(
      title: 'Community & Motivation',
      description: 'Connect with fitness enthusiasts, share progress, and stay motivated.',
      imagePath: 'assets/images/community.svg',
      backgroundColor: Colors.blue.shade50,
      iconData: Icons.people,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
          ),

          // Onboarding Pages
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_onboardingPages[index]);
            },
          ),

          // Page Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _onboardingPages.length,
                effect: ExpandingDotsEffect(
                  dotColor: Colors.blue.shade200,
                  activeDotColor: Colors.blue.shade700,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                  spacing: 6,
                ),
              ),
            ),
          ),

          // Navigation Buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  _currentPage != _onboardingPages.length - 1
                      ? TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(_onboardingPages.length - 1);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : SizedBox(width: 70),

                  // Next/Get Started Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingPages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Navigate to the main app screen
                          AppRoutes.navigateToLogin(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.blue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _currentPage < _onboardingPages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Image with animated container
            Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  page.imagePath,
                  height: 180,
                  width: 180,
                  placeholderBuilder: (BuildContext context) => Icon(
                    page.iconData,
                    size: 80,
                    color: Colors.blue.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Title with enhanced typography
            Text(
              page.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Description with improved styling
            Text(
              page.description,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade700,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final IconData iconData;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.iconData,
  });
}