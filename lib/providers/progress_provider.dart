import 'package:flutter/material.dart';

class ProgressProvider with ChangeNotifier {
  double caloriesPercentage = 0.0;
  double waterPercentage = 0.0;
  double stepsPercentage = 0.0;
  double sleepPercentage = 0.0;

  void updateCalories(double percent) {
    caloriesPercentage = percent;
    notifyListeners();
  }

  void updateWater(double percent) {
    waterPercentage = percent;
    notifyListeners();
  }

  void updateSteps(double percent) {
    stepsPercentage = percent;
    notifyListeners();
  }

  void updateSleep(double percent) {
    sleepPercentage = percent;
    notifyListeners();
  }
}
