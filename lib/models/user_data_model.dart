class UserProfile {
  final String userId;
  final String name;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String fitnessLevel; // 'beginner', 'intermediate', 'advanced'
  final List<String> healthConditions; // any health issues to consider
  final List<String> preferences; // workout preferences

  UserProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessLevel,
    this.healthConditions = const [],
    this.preferences = const [],
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 30,
      weight: (data['weight'] ?? 70.0).toDouble(),
      height: (data['height'] ?? 170.0).toDouble(),
      fitnessLevel: data['fitnessLevel'] ?? 'beginner',
      healthConditions: List<String>.from(data['healthConditions'] ?? []),
      preferences: List<String>.from(data['preferences'] ?? []),
    );
  }
}