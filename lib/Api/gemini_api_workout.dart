import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyCIq9YZc6d8dyk0F_7V_4kUv-wA8Ga3i84';

  Future<String> generateWorkoutPlan(
    String category,
    Map<String, dynamic> userData,
  ) async {
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    final fixedDurationCategories = ['cardio', 'stretching', 'yoga'];
    final targetedWorkoutCategories = ['hypertrophy', 'fat loss'];
    final categoryLower = category.toLowerCase();

    final prompt =
        fixedDurationCategories.contains(categoryLower)
            ? '''
Generate a concise 30-minute full body $category workout plan for:
- Age: ${userData['age']}
- Gender: ${userData['gender']}
- Fitness Level: ${userData['activity_level']}

Return the workout plan as a JSON object with the following structure:
{
  "sections": [
    {
      "title": "Warm-up",
      "duration": "5-10 minutes",
      "exercises": [
        {"text": "Jumping jacks: 30 seconds"},
        {"text": "High knees: 30 seconds"}
      ]
    },
    {
      "title": "Main Workout",
      "duration": "15-20 minutes",
      "exercises": [
        {"text": "Squats: 3 sets of 10-12 reps"},
        {"text": "Push-ups: 3 sets to failure"}
      ]
    },
    {
      "title": "Cool-down",
      "duration": "5 minutes",
      "exercises": [
        {"text": "Hamstring stretch: hold for 30 seconds"},
        {"text": "Quad stretch: hold for 30 seconds"}
      ]
    }
  ]
}
IMPORTANT: Return ONLY a valid JSON object with no markdown formatting, code blocks, or additional text. Format the response as a raw JSON object without any explanations or code formatting.
'''
            : targetedWorkoutCategories.contains(categoryLower)
            ? '''
Create a concise personalized $category workout plan based on:
- Age: ${userData['age']}
- Gender: ${userData['gender']}
- Height: ${userData['height']} cm
- Weight: ${userData['weight']} kg
- Activity Level: ${userData['activity_level']}
- Target: ${userData['targetMuscle']}
- Training Style: ${userData['trainingStyle']}
- Duration: ${userData['workoutDuration']}

Return the workout plan as a JSON object with the following structure:
{
  "sections": [
    {
      "title": "Warm-up",
      "duration": "5-10 minutes",
      "exercises": [
        {"text": "Exercise 1: details"},
        {"text": "Exercise 2: details"}
      ]
    },
    {
      "title": "Main Workout",
      "duration": "",
      "exercises": [
        {"text": "Exercise 1: sets and reps"},
        {"text": "Exercise 2: sets and reps"}
      ]
    },
    {
      "title": "Cool-down",
      "duration": "5 minutes",
      "exercises": [
        {"text": "Exercise 1: details"},
        {"text": "Exercise 2: details"}
      ]
    }
  ]
}
IMPORTANT: Return ONLY a valid JSON object with no markdown formatting, code blocks, or additional text. Format the response as a raw JSON object without any explanations or code formatting.
'''
            : '''
Create a concise personalized $category workout plan based on:
- Age: ${userData['age']}
- Gender: ${userData['gender']}
- Height: ${userData['height']} cm
- Weight: ${userData['weight']} kg
- Activity Level: ${userData['activity_level']}
- Preferred Duration: ${userData['duration']} mins

Return the workout plan as a JSON object with the following structure:
{
  "sections": [
    {
      "title": "Warm-up",
      "duration": "5-10 minutes",
      "exercises": [
        {"text": "Exercise 1: details"},
        {"text": "Exercise 2: details"}
      ]
    },
    {
      "title": "Main Workout",
      "duration": "",
      "exercises": [
        {"text": "Exercise 1: sets and reps"},
        {"text": "Exercise 2: sets and reps"}
      ]
    },
    {
      "title": "Cool-down",
      "duration": "5 minutes",
      "exercises": [
        {"text": "Exercise 1: details"},
        {"text": "Exercise 2: details"}
      ]
    }
  ]
}
IMPORTANT: Return ONLY a valid JSON object with no markdown formatting, code blocks, or additional text. Format the response as a raw JSON object without any explanations or code formatting.
''';

    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String rawResponse =
          data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';

      // Process the response to extract clean JSON
      return _processGeminiResponse(rawResponse);
    } else {
      throw Exception('Failed to generate content: ${response.body}');
    }
  }

  // Add this helper method to clean up the response
  String _processGeminiResponse(String response) {
    // Check if the response is wrapped in code blocks
    if (response.contains("```json") || response.contains("```")) {
      // Extract the JSON content from between the code blocks
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        return response.substring(startIndex, endIndex + 1);
      }
    }

    // Return the original response if it's not wrapped in code blocks
    // or if we couldn't extract valid JSON
    return response;
  }
}