// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:train_hard_reborn/Auth/forgot_password.dart';
import 'package:train_hard_reborn/Auth/signup.dart';
import 'package:train_hard_reborn/View/main_layout.dart';
import 'package:train_hard_reborn/View/user_profile_onboarding.dart';
import 'package:train_hard_reborn/onboarding.dart';
import 'splash.dart';
import 'Auth/login.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding ='/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String signUp = '/signUp';
  static const String forgotpassword = '/forgotpassword';
  static const String community ='/community';
  static const String diethome ='/diet_home';
  static const String profile ='/profile';
  static const String workouthome ='/workouthome';
  static const String user_profile_onboarding = '/user_profile_onboarding';

  
  static const String initialRoute = splash;
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signUp: (context) => SignUpScreen(),
      forgotpassword: (context) => const ForgotPasswordScreen(),
      home: (context) => MainLayout(initialIndex: 0),
      diethome: (context) => MainLayout(initialIndex: 1),
      workouthome: (context) => MainLayout(initialIndex: 2),
      community: (context) => MainLayout(initialIndex: 3),
      profile: (context) => MainLayout(initialIndex: 4),
      user_profile_onboarding: (context) => const UserProfileOnboardingScreen(),   
    };
  }
  
  // Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(login);
  }

  static void navigateToOnboarding(BuildContext context){
    Navigator.of(context).pushReplacementNamed(onboarding);
  }
  
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(home);
  }

  static void navigateToSignUp(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(signUp);
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(forgotpassword);
  }

  static void navigateToCommunity(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(community);
  }

  static void navigateToWorkoutHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(workouthome);
  }

  static void navigateToDietHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(diethome);
  }

  static void navigateToUserProfile(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(profile);
  }

  static void navigateToUserProfileOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(user_profile_onboarding);
  }

}
