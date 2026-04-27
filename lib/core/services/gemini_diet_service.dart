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
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 8192,
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
      
      onProgress?.call('Analyzing your profile & goals...');
      final response = await model.generateContent(
        [Content.text(prompt)],
      ).timeout(const Duration(seconds: 180));
      onProgress?.call('Finishing up your plan...');

      final text = response.text ?? '';
      print('GEMINI RAW (first 300): ${text.length > 300 ? text.substring(0, 300) : text}');
      if (text.isEmpty) throw Exception('Empty response from Gemini');

      return _parseDietPlan(text, user);
    } catch (e) {
      print('GEMINI SERVICE ERROR: $e — falling back to local generator');
      return DietGenerator.generate(user);
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
Indian diet plan JSON. User: ${user.age}y ${user.gender} ${user.weight}kg, goal:${user.primaryGoal}, diet:${user.dietPreference}, budget:Rs.$dailyBudget/day. Targets:${targetCals}kcal P:${targetProtein}g C:${targetCarbs}g F:${targetFat}g. Rule:$dietFocus

Fill ALL fields with real Indian food values. 2 foodItems per meal. Short names. Return ONLY minified JSON, no spaces, no markdown:
{"targetCalories":$targetCals,"targetProtein":$targetProtein,"targetCarbs":$targetCarbs,"targetFat":$targetFat,"dailyBudget":$dailyBudget,"meals":[{"id":"breakfast","title":"Breakfast","time":"8:00 AM","emoji":"sunrise","calories":FILL,"proteinGrams":FILL,"carbsGrams":FILL,"fatGrams":FILL,"cost":FILL,"foodItems":[{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL},{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL}]},{"id":"lunch","title":"Lunch","time":"1:00 PM","emoji":"sun","calories":FILL,"proteinGrams":FILL,"carbsGrams":FILL,"fatGrams":FILL,"cost":FILL,"foodItems":[{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL},{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL}]},{"id":"snack","title":"Snack","time":"5:00 PM","emoji":"bolt","calories":FILL,"proteinGrams":FILL,"carbsGrams":FILL,"fatGrams":FILL,"cost":FILL,"foodItems":[{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL},{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL}]},{"id":"dinner","title":"Dinner","time":"8:30 PM","emoji":"moon","calories":FILL,"proteinGrams":FILL,"carbsGrams":FILL,"fatGrams":FILL,"cost":FILL,"foodItems":[{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL},{"name":"FILL","calories":FILL,"protein":FILL,"carbs":FILL,"fat":FILL,"serving":"FILL","cost":FILL}]}]}
''';
  }

  static DietPlanModel _parseDietPlan(String jsonText, UserModel user) {
    String text = jsonText
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Invalid JSON response: No object found.');
    }

    String clean = text.substring(startIndex, endIndex + 1);

    // Fix common Gemini JSON mistakes
    clean = clean.replaceAll(RegExp(r',\s*]'), ']');
    clean = clean.replaceAll(RegExp(r',\s*}'), '}');
    clean = clean.replaceAll(RegExp(r'}\s*{'), '},{');
    clean = clean.replaceAll(RegExp(r']\s*\['), '],[');
    // Remove control characters but keep valid unicode/emoji
    clean = clean.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    try {
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
    } catch (e) {
      print('JSON PARSE FAILED. Clean JSON around error:');
      print(clean.length > 800 ? clean.substring(0, 800) : clean);
      rethrow;
    }
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