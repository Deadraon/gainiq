import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/diet_model.dart';
import '../../models/user_model.dart';
import 'diet_generator.dart'; // local fallback

class GeminiDietService {
  static GenerativeModel? _model;

  static GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      generationConfig: GenerationConfig(
        temperature: 0.9,
        maxOutputTokens: 2048,
      ),
    );
    return _model!;
  }

  /// Generate a full day diet plan via Gemini AI.
  /// Falls back to local generator if API fails.
  static Future<DietPlanModel> generateDietPlan(UserModel user, {void Function(String)? onProgress}) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        throw Exception('No API key configured');
      }

      _model = null; // Force fresh model creation
      final model = _getModel();
      final prompt = _buildPrompt(user);
      
      final stream = model.generateContentStream([Content.text(prompt)]);
      final StringBuffer buffer = StringBuffer();
      
      // Use await for to consume the stream chunks as they arrive.
      // This prevents long-idle connection drops.
      await for (final chunk in stream.timeout(const Duration(seconds: 180))) {
        buffer.write(chunk.text);
        
        // Report progress back to UI if requested
        if (onProgress != null) {
          final content = buffer.toString().toLowerCase();
          if (content.contains('"id": "dinner"')) {
            onProgress('Finishing up Dinner...');
          } else if (content.contains('"id": "snack"')) {
            onProgress('Crafting your Evening Snack...');
          } else if (content.contains('"id": "lunch"')) {
            onProgress('Preparing Lunch options...');
          } else if (content.contains('"id": "breakfast"')) {
            onProgress('Generating Breakfast...');
          } else {
            onProgress('Analyzing your profile & goals...');
          }
        }
      }
      
      final text = buffer.toString();
      if (text.isEmpty) throw Exception('Empty response from Gemini');

      return _parseDietPlan(text, user);
    } catch (e) {
      print('GEMINI SERVICE ERROR: $e');
      rethrow;
    }
  }

  static String _buildPrompt(UserModel user) {
    final targetCals = user.isProfileComplete
        ? CalorieCalculator.dailyCalories(user)
        : 2200;
    final targetProtein = user.isProfileComplete
        ? CalorieCalculator.dailyProtein(user)
        : 160;
    final dailyBudget =
        user.monthlyBudget > 0 ? (user.monthlyBudget / 30).round() : 150;

    final ratios = CalorieCalculator.macroRatios(user.primaryGoal);
    final targetCarbs = ((targetCals * ratios['carbs']!) / 4).round();
    final targetFat = ((targetCals * ratios['fat']!) / 9).round();

    final dietPref = user.dietPreference.toLowerCase();
    String dietFocus = "Vegetarian=Strictly NO eggs, meat, or fish. Plant-based and dairy only.";
    if (dietPref.contains('non')) {
      dietFocus = "Non-veg=MUST INCLUDE chicken, fish, or mutton as main protein sources in lunch and dinner.";
    } else if (dietPref.contains('egg')) {
      dietFocus = "Eggetarian=MUST INCLUDE eggs in at least two meals. Strictly NO meat or fish.";
    }

    return '''
You are an expert Indian nutritionist. Generate a personalized Indian daily diet plan.

USER PROFILE:
- Age: ${user.age}y, Gender: ${user.gender}, Weight: ${user.weight}kg, Height: ${user.height}cm
- Goal: ${user.primaryGoal}, Body Type: ${user.bodyType}
- Diet: ${user.dietPreference}, Budget: ₹$dailyBudget/day
- Workout: ${user.workoutTiming}, Allergies: ${user.allergies.isEmpty ? 'None' : user.allergies}

TARGETS: ${targetCals}kcal | Protein:${targetProtein}g | Carbs:${targetCarbs}g | Fat:${targetFat}g

RULES:
- DIET REQUIREMENT: $dietFocus
- Only common affordable Indian foods. Real INR prices. Stay within ₹$dailyBudget budget.
- Provide a clear, actionable diet plan.
- NO alternatives needed.
- VARIETY IS CRITICAL: The user is bored of basic suggestions. Do NOT suggest simple sandwiches or basic dal/roti every time.
- INCLUDE SPECIFIC FOODS: Actively include healthy, modern Indian options like Oats, Muesli, Quinoa, Paneer, Sprouts, and diverse Chicken/Fish preparations.
- RANDOMIZE: Every time you are called, suggest a DIFFERENT set of meals. Surprise the user with variety!

Return ONLY valid JSON (no markdown):
{
  "targetCalories": $targetCals,
  "targetProtein": $targetProtein,
  "targetCarbs": $targetCarbs,
  "targetFat": $targetFat,
  "dailyBudget": $dailyBudget,
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
      "foodItems": [
        {
          "name": "Moong Dal Chilla (3)",
          "calories": 320,
          "protein": 22,
          "carbs": 38,
          "fat": 6,
          "serving": "3 chillas with green chutney",
          "cost": 18
        }
      ]
    },
    {
      "id": "lunch",
      "title": "Lunch",
      "time": "1:30 PM",
      "emoji": "🌤",
      "calories": 0,
      "proteinGrams": 0,
      "carbsGrams": 0,
      "fatGrams": 0,
      "cost": 0,
      "foodItems": []
    },
    {
      "id": "snack",
      "title": "Pre-Workout Snack",
      "time": "5:00 PM",
      "emoji": "⚡",
      "calories": 0,
      "proteinGrams": 0,
      "carbsGrams": 0,
      "fatGrams": 0,
      "cost": 0,
      "foodItems": []
    },
    {
      "id": "dinner",
      "title": "Dinner",
      "time": "8:30 PM",
      "emoji": "🌙",
      "calories": 0,
      "proteinGrams": 0,
      "carbsGrams": 0,
      "fatGrams": 0,
      "cost": 0,
      "foodItems": []
    }
  ]
}
''';
  }

  static DietPlanModel _parseDietPlan(String jsonText, UserModel user) {
    final startIndex = jsonText.indexOf('{');
    final endIndex = jsonText.lastIndexOf('}');
    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Invalid JSON response: No object found.');
    }
    
    final clean = jsonText.substring(startIndex, endIndex + 1);
    final Map<String, dynamic> data = jsonDecode(clean);

    final meals = (data['meals'] as List).map((m) {
      final items = (m['foodItems'] as List).map((f) {
        // Parse alternatives
        final altList = (f['alternatives'] as List? ?? []).map((a) {
          return FoodItemDetail(
            name: a['name'] ?? '',
            calories: _toInt(a['calories']),
            protein: _toDouble(a['protein']),
            carbs: _toDouble(a['carbs']),
            fat: _toDouble(a['fat']),
            serving: a['serving'] ?? '',
            cost: _toDouble(a['cost']),
          );
        }).toList();

        return FoodItemDetail(
          name: f['name'] ?? '',
          calories: _toInt(f['calories']),
          protein: _toDouble(f['protein']),
          carbs: _toDouble(f['carbs']),
          fat: _toDouble(f['fat']),
          serving: f['serving'] ?? '',
          cost: _toDouble(f['cost']),
          alternatives: altList,
        );
      }).toList();

      return MealModel(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        time: m['time'] ?? '',
        emoji: m['emoji'] ?? '🍽',
        foodItems: items,
        calories: _toInt(m['calories']),
        proteinGrams: _toInt(m['proteinGrams']),
        carbsGrams: _toInt(m['carbsGrams']),
        fatGrams: _toInt(m['fatGrams']),
        cost: _toDouble(m['cost']),
      );
    }).toList();

    return DietPlanModel(
      id: 'ai_plan_${user.id}',
      targetCalories: _toInt(data['targetCalories']),
      targetProtein: _toInt(data['targetProtein']),
      targetCarbs: _toInt(data['targetCarbs']),
      targetFat: _toInt(data['targetFat']),
      dailyBudget: _toDouble(data['dailyBudget']),
      meals: meals,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
