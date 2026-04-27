import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/workout_model.dart';
import '../../models/user_model.dart';
import '../services/workout_generator.dart'; // local fallback

class GeminiWorkoutService {
  static GenerativeModel? _model;

  static GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 2048,
      ),
    );
    return _model!;
  }

  static Future<List<WorkoutPlanModel>> generateWorkoutPlans(UserModel user, {void Function(String)? onProgress}) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        throw Exception('No API key configured');
      }

      final prompt = _buildPrompt(user);
      _model = null; // Force fresh model creation
      final model = _getModel();
      
      final stream = model.generateContentStream([Content.text(prompt)]);
      final StringBuffer buffer = StringBuffer();
      
      await for (final chunk in stream.timeout(const Duration(seconds: 180))) {
        buffer.write(chunk.text);
        if (onProgress != null) {
          final content = buffer.toString().toLowerCase();
          if (content.contains('"id": "plan_3"')) {
            onProgress('Finishing third plan...');
          } else if (content.contains('"id": "plan_2"')) {
            onProgress('Crafting second split...');
          } else if (content.contains('"id": "plan_1"')) {
            onProgress('Designing first routine...');
          } else {
            onProgress('Analyzing fitness profile...');
          }
        }
      }

      final text = buffer.toString();
      if (text.isEmpty) throw Exception('Empty response');

      return _parsePlans(text);
    } catch (e) {
      print('GEMINI WORKOUT SERVICE ERROR: $e');
      return WorkoutGenerator.generate(user);
    }
  }

  static String _buildPrompt(UserModel user) {
    return '''
You are an expert fitness coach. Create 3 personalized weekly workout plans for this user.

USER PROFILE:
- Age: ${user.age}, Gender: ${user.gender}, Weight: ${user.weight}kg
- Goal: ${user.primaryGoal}
- Experience: ${user.experienceLevel}
- Location: ${user.workoutLocation}
- Workout Time: ${user.workoutTiming}
- Body Type: ${user.bodyType}

RULES:
1. If location is "Home" → no gym equipment, only bodyweight exercises.
2. If location is "Gym" → use gym equipment (barbells, dumbbells, machines).
3. Adjust volume/intensity for experience: Beginner=lighter, Intermediate=moderate, Advanced=heavy.
4. Goal "${user.primaryGoal}":
   - Bulking: more sets/volume, compound lifts, caloric-surplus emphasis
   - Cutting: higher reps, supersets, cardio elements
   - Maintenance: balanced strength + cardio
5. Plan 1 = Push/Pull/Legs or Full Body (most suitable for level).
   Plan 2 = Upper/Lower split or Sport-specific.
   Plan 3 = HIIT or Cardio-strength hybrid.
6. Each exercise must have a short form tip in "instructions".

Return ONLY valid JSON (no markdown):
{
  "plans": [
    {
      "id": "plan_1",
      "title": "Push/Pull/Legs",
      "subtitle": "3-day split • Compound focus • ${user.workoutLocation}",
      "isActive": true,
      "exercises": [
        {
          "id": "ex_1",
          "name": "Barbell Bench Press",
          "sets": 4,
          "reps": "8-10",
          "targetMuscle": "Chest",
          "instructions": "Keep shoulder blades retracted, lower to mid-chest, drive up explosively."
        }
      ]
    },
    {
      "id": "plan_2",
      "title": "Upper / Lower",
      "subtitle": "4-day split • Strength + volume",
      "isActive": false,
      "exercises": []
    },
    {
      "id": "plan_3",
      "title": "HIIT & Cardio",
      "subtitle": "5-day • Fat burn • High intensity",
      "isActive": false,
      "exercises": []
    }
  ]
}
''';
  }

  static List<WorkoutPlanModel> _parsePlans(String jsonText) {
    final startIndex = jsonText.indexOf('{');
    final endIndex = jsonText.lastIndexOf('}');
    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Invalid JSON response: No object found.');
    }
    final clean = jsonText.substring(startIndex, endIndex + 1);

    final data = jsonDecode(clean) as Map<String, dynamic>;
    final plansRaw = data['plans'] as List;

    return plansRaw.map((p) {
      final exercises = (p['exercises'] as List? ?? []).map((e) {
        return ExerciseModel(
          id: e['id'] ?? 'ex_${DateTime.now().millisecondsSinceEpoch}',
          name: e['name'] ?? '',
          sets: _toInt(e['sets']),
          reps: e['reps']?.toString() ?? '10-12',
          targetMuscle: e['targetMuscle'] ?? '',
          instructions: e['instructions'] ?? '',
        );
      }).toList();

      return WorkoutPlanModel(
        id: p['id'] ?? 'plan_${DateTime.now().millisecondsSinceEpoch}',
        title: p['title'] ?? 'AI Workout',
        subtitle: p['subtitle'] ?? 'Personalized plan',
        imagePath: '',
        isActive: p['isActive'] == true,
        exercises: exercises,
      );
    }).toList();
  }

  static int _toInt(dynamic v) {
    if (v == null) return 3;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 3;
  }
}
