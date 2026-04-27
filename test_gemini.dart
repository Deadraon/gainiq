import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyD6fQIv-NWEohcx0BRMjhJQPlNBLsvN3vw';
  final prompt = '''
You are an expert Indian nutritionist. Generate a personalized Indian daily diet plan.

USER PROFILE:
- Age: 25y, Gender: Male, Weight: 70kg, Height: 175cm
- Goal: Muscle Gain, Body Type: Ectomorph
- Diet: Non-Veg, Budget: ₹150/day
- Workout: Morning, Allergies: None

TARGETS: 2500kcal | Protein:150g | Carbs:300g | Fat:70g

RULES:
- DIET REQUIREMENT: Non-veg=MUST INCLUDE chicken, fish, or mutton as main protein sources in lunch and dinner.
- Only common affordable Indian foods. Real INR prices. Stay within ₹150 budget.
- For EACH food item provide 2 alternatives (similar macros, same diet type, different food).
- Alternatives must follow the same diet rules strictly.

Return ONLY valid JSON (no markdown):
{
  "targetCalories": 2500,
  "targetProtein": 150,
  "targetCarbs": 300,
  "targetFat": 70,
  "dailyBudget": 150,
  "meals": [
    {
      "id": "breakfast",
      "title": "Breakfast",
      "time": "8:00 AM",
      "emoji": "☀️",
      "calories": 450,
      "proteinGrams": 30,
      "carbsGrams": 55,
      "fatGrams": 12,
      "cost": 38,
      "foodItems": []
    }
  ]
}
''';

  try {
    print('Sending request...');
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]}
        ],
        'generationConfig': {
          'temperature': 0.7,
        }
      }),
    ).timeout(const Duration(seconds: 60));

    print('Status: \${response.statusCode}');
    if (response.statusCode != 200) {
      print('Error: \${response.body}');
      return;
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    print('Response Text:\\n\$text');
  } catch (e) {
    print('EXCEPTION: \$e');
  }
}
