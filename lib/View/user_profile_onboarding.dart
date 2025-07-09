// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:train_hard_reborn/providers/onboardingproviders.dart';// Update with your actual package name

class UserProfileOnboardingScreen extends StatefulWidget {
  const UserProfileOnboardingScreen({super.key});

  @override
  State<UserProfileOnboardingScreen> createState() =>
      _UserProfileOnboardingScreenState();
}

class _UserProfileOnboardingScreenState
    extends State<UserProfileOnboardingScreen> {
  final PageController _controller = PageController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  final Color primaryBlue = const Color(0xFF3A5A98);
  final Color softWhite = const Color(0xFFF4F6FA);
  final Color softGrey = const Color(0xFFB0B7C3);

  @override
  void dispose() {
    _controller.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    // Validate current page before proceeding
    if (!provider.validateCurrentPage()) {
      return;
    }
    
    if (provider.currentPage < 5) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      provider.submitData().then((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  Widget _buildPage({required String title, required Widget child}) {
  final provider = Provider.of<OnboardingProvider>(context);
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryBlue, softWhite],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2), // Add this to push content down from top
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        // Error message
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        // Content in the center of the screen
        child,
        const Spacer(flex: 3), // Add this with more flex to push content up
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(provider.currentPage == 5 ? 'Finish' : 'Next'),
        ),
      ],
    ),
  );
}

  Widget _buildProgressIndicator() {
    final provider = Provider.of<OnboardingProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: provider.currentPage == index ? Colors.white : softGrey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildCircularIconSelector({
    required List<Map<String, dynamic>> options,
    required String? currentValue,
    required Function(String) onSelect,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = currentValue == option['value'];
    
        return InkWell(
          onTap: () => onSelect(option['value']),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryBlue : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  option['icon'],
                  size: 35,
                  color: isSelected ? primaryBlue : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  option['label'],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitToggle({
    required bool isFirstSelected,
    required String firstOption,
    required String secondOption,
    required Function(bool) onToggle,
  }) {
    return Container(
      width: 150,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFirstSelected ? Colors.white : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                ),
                child: Text(
                  firstOption,
                  style: TextStyle(
                    color: isFirstSelected ? primaryBlue : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isFirstSelected ? Colors.white : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                ),
                child: Text(
                  secondOption,
                  style: TextStyle(
                    color: !isFirstSelected ? primaryBlue : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    
    return Scaffold(
      backgroundColor: softWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => provider.setCurrentPage(index),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage(
                    title: "What's your gender?",
                    child: _buildCircularIconSelector(
                      options: [
                        {'label': 'Male', 'value': 'Male', 'icon': Icons.male},
                        {
                          'label': 'Female',
                          'value': 'Female',
                          'icon': Icons.female,
                        },
                        {
                          'label': 'Other',
                          'value': 'Other',
                          'icon': Icons.person,
                        },
                      ],
                      currentValue: provider.gender,
                      onSelect: (value) => provider.setGender(value),
                    ),
                  ),
                  _buildPage(
                    title: 'Enter your weight',
                    child: Column(
                      children: [
                        _buildUnitToggle(
                          isFirstSelected: provider.isKg,
                          firstOption: 'kg',
                          secondOption: 'lbs',
                          onToggle: (value) => provider.toggleWeightUnit(value),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) => provider.setWeight(val),
                          decoration: InputDecoration(
                            hintText: provider.isKg ? "e.g. 70.5" : "e.g. 155",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            suffixText: provider.isKg ? 'kg' : 'lbs',
                            suffixStyle: const TextStyle(color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  _buildPage(
                    title: 'Enter your height',
                    child: Column(
                      children: [
                        _buildUnitToggle(
                          isFirstSelected: provider.isCm,
                          firstOption: 'cm',
                          secondOption: 'feet',
                          onToggle: (value) => provider.toggleHeightUnit(value),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) => provider.setHeight(val),
                          decoration: InputDecoration(
                            hintText: provider.isCm ? "e.g. 175" : "e.g. 5.9",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            suffixText: provider.isCm ? 'cm' : 'ft',
                            suffixStyle: const TextStyle(color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  _buildPage(
                    title: 'Enter your age',
                    child: NumberPicker(
                      value: provider.age ?? 25,
                      minValue: 10,
                      maxValue: 100,
                      onChanged: (val) => provider.setAge(val),
                      textStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPage(
                    title: "What's your activity level?",
                    child: _buildCircularIconSelector(
                      options: [
                        {
                          'label': 'Workout 5-6 days/week',
                          'value': 'Very active',
                          'icon': Icons.fitness_center,
                        },
                        {
                          'label': 'Workout 2-4 days/week',
                          'value': 'Active',
                          'icon': Icons.directions_run,
                        },
                        {
                          'label': 'Do not workout at all',
                          'value': 'Sedentary',
                          'icon': Icons.weekend,
                        },
                      ],
                      currentValue: provider.activityLevel,
                      onSelect: (value) => provider.setActivityLevel(value),
                    ),
                  ),
                  _buildPage(
                    title: "What's your food preference?", 
                    child: _buildCircularIconSelector(
                      options: [
                        {
                          'label': 'Veg',
                          'value': 'Vegetarian',
                          'icon': Icons.eco,
                        },
                        {
                          'label': 'Non-Veg',
                          'value': 'Non-Vegetarian',
                          'icon': Icons.fastfood,
                        },
                        {
                          'label': 'Both',
                          'value': 'Both Vegetarian and Non-Vegetarian',
                          'icon': Icons.restaurant,
                        },
                      ], 
                      currentValue: provider.foodPreference, 
                      onSelect: (value) => provider.setFoodPreference(value),
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressIndicator(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
