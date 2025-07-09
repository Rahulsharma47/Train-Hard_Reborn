import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:train_hard_reborn/firebase_options.dart';
import 'package:train_hard_reborn/providers/onboardingproviders.dart';
import 'package:train_hard_reborn/providers/progress_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        // Add any other providers you need here
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Train Hard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.onboarding,  // Dynamically set initial route
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}