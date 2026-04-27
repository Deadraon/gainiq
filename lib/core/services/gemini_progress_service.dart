import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user_model.dart';

class BodyAnalysisResult {
  final String overallFeedback;
  final String estimatedBodyFat;
  final String muscleDefinition;
  final String posture;
  final List<String> improvements;
  final List<String> strengths;
  final String nextStepTip;
  final String progressRating;

  const BodyAnalysisResult({
    required this.overallFeedback,
    required this.estimatedBodyFat,
    required this.muscleDefinition,
    required this.posture,
    required this.improvements,
    required this.strengths,
    required this.nextStepTip,
    required this.progressRating,
  });
}

class GeminiProgressService {
  static GenerativeModel? _model;

  static GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      generationConfig: GenerationConfig(
        temperature: 0.4,
        maxOutputTokens: 1024,
      ),
    );
    return _model!;
  }

  static Future<BodyAnalysisResult> analyzeProgress({
    required File imageFile,
    required UserModel user,
    void Function(String)? onProgress,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('No API key configured');
    }

    final imageBytes = await imageFile.readAsBytes();

    final prompt = '''
You are an expert fitness coach and body composition analyst. Analyze this physique/progress photo.

USER CONTEXT:
- Goal: ${user.primaryGoal}
- Experience: ${user.experienceLevel}
- Diet: ${user.dietPreference}
- Weight: ${user.weight}kg, Height: ${user.height}cm

Analyze the photo and provide honest, motivating, professional fitness feedback.
Be specific, supportive, and actionable. Do NOT make medical diagnoses.

Return ONLY valid JSON (no markdown):
{
  "overallFeedback": "2-3 sentence overall assessment",
  "estimatedBodyFat": "e.g. 15-18% (estimated, not medical)",
  "muscleDefinition": "e.g. Moderate - visible muscle tone in arms and shoulders",
  "posture": "e.g. Good posture, slight forward head tilt to work on",
  "strengths": [
    "Strong shoulder development",
    "Good overall symmetry"
  ],
  "improvements": [
    "Focus on lower chest for better definition",
    "Core engagement needs attention"
  ],
  "nextStepTip": "One specific actionable tip based on their goal and what you see",
  "progressRating": "7/10"
}
''';

    _model = null; // Force fresh model creation
    final model = _getModel();
    
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    final stream = model.generateContentStream(content);
    final StringBuffer buffer = StringBuffer();
    
    await for (final chunk in stream.timeout(const Duration(seconds: 180))) {
      buffer.write(chunk.text);
      if (onProgress != null) {
        final content = buffer.toString().toLowerCase();
        if (content.contains('"improvements"')) {
          onProgress('Generating actionable improvements...');
        } else if (content.contains('"strengths"')) {
          onProgress('Identifying key strengths...');
        } else if (content.contains('"estimatedbodyfat"')) {
          onProgress('Estimating composition details...');
        } else {
          onProgress('Analyzing physique...');
        }
      }
    }

    final text = buffer.toString();
    if (text.isEmpty) throw Exception('Empty response from Gemini');

    return _parse(text);
  }

  static BodyAnalysisResult _parse(String jsonText) {
    try {
      final startIndex = jsonText.indexOf('{');
      final endIndex = jsonText.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1) {
        throw Exception('Invalid JSON response: No object found.');
      }
      final clean = jsonText.substring(startIndex, endIndex + 1);
      final data = jsonDecode(clean) as Map<String, dynamic>;
      return BodyAnalysisResult(
        overallFeedback: data['overallFeedback'] ?? 'Great effort — keep going!',
        estimatedBodyFat: data['estimatedBodyFat'] ?? 'N/A',
        muscleDefinition: data['muscleDefinition'] ?? 'N/A',
        posture: data['posture'] ?? 'N/A',
        strengths: List<String>.from(data['strengths'] ?? []),
        improvements: List<String>.from(data['improvements'] ?? []),
        nextStepTip: data['nextStepTip'] ?? 'Stay consistent with your training.',
        progressRating: data['progressRating'] ?? '—',
      );
    } catch (_) {
      return const BodyAnalysisResult(
        overallFeedback: 'Could not parse analysis. Please try again.',
        estimatedBodyFat: 'N/A',
        muscleDefinition: 'N/A',
        posture: 'N/A',
        strengths: [],
        improvements: [],
        nextStepTip: 'Keep training consistently!',
        progressRating: '—',
      );
    }
  }
}
