import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiDietService {
  final String apiKey = 'AIzaSyAAIWAKH9gFI3cZuUZpUK1ld0jlQmdsGUg';

  Future<String> generateDietPlan(
    String goal,
    Map<String, dynamic> userData,
  ) async {
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    // Calculate target calories based on goal
    double maintenanceCalories = userData['maintainanceCalories'] ?? 2000; // fallback default
    double targetCalories;

    if (goal.toLowerCase().contains('loss')) {
      targetCalories = maintenanceCalories - 250; // calorie deficit
    } else if (goal.toLowerCase().contains('gain')) {
      targetCalories = maintenanceCalories + 250; // calorie surplus
    } else {
      targetCalories = maintenanceCalories; // maintenance
    }

    final prompt = '''
Create a concise personalized Indian diet plan based on the following user details:
- Goal: $goal
- Target Calories: approximately ${targetCalories.round()} calories/day
- Age: ${userData['age']}
- Gender: ${userData['gender']}
- Height: ${userData['height']} cm
- Weight: ${userData['weight']} kg
- Activity Level: ${userData['activity_level']}
- Food Preference: ${userData['foodPreference']}

Guidelines:
- Only suggest Indian meals and recipes.
- Respect the food preference (Vegetarian / Non-vegetarian / Vegan).
- Distribute calories appropriately across meals (breakfast, lunch, dinner, snacks).
- Meals should be balanced with proteins, carbs, and healthy fats.

Return the diet plan strictly in the following JSON structure:
{
  "meals": [
    {
      "meal": "Meal 1",
      "items": [
        {"text": "Masala oats with vegetables"},
        {"text": "Paneer bhurji"}
      ]
    },
    {
      "meal": "Meal 2",
      "items": [
        {"text": "Tandoori chicken with roti"},
        {"text": "Palak sabzi"}
      ]
    }
  ]
}
IMPORTANT:
- Use only Indian dishes and ingredients.
- Return ONLY a valid JSON object with no markdown, no code blocks, no additional explanation.
- No English / Western foods.
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

      return _processGeminiResponse(rawResponse);
    } else {
      throw Exception('Failed to generate content: ${response.body}');
    }
  }

  String _processGeminiResponse(String response) {
    if (response.contains("```json") || response.contains("```")) {
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        return response.substring(startIndex, endIndex + 1);
      }
    }
    return response;
  }
}
