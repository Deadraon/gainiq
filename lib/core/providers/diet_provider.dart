import 'package:flutter/material.dart';
import '../../models/diet_model.dart';
import '../../models/user_model.dart';
import '../services/diet_generator.dart';
import '../services/gemini_diet_service.dart';

enum DietLoadState { idle, loadingAI, loadingLocal, loaded, error }

class DietProvider with ChangeNotifier {
  DietPlanModel? _currentDietPlan;
  DietLoadState _loadState = DietLoadState.idle;
  String _statusMessage = '';
  bool _isAIGenerated = false;

  DietPlanModel? get currentDietPlan => _currentDietPlan;
  DietLoadState get loadState => _loadState;
  String get statusMessage => _statusMessage;
  bool get isAIGenerated => _isAIGenerated;
  bool get isLoading =>
      _loadState == DietLoadState.loadingAI ||
      _loadState == DietLoadState.loadingLocal;

  /// Generate diet plan using Gemini AI with local fallback
  Future<void> generateForUser(UserModel user) async {
    _loadState = DietLoadState.loadingAI;
    _statusMessage = '✨ AI is crafting your personalized diet...';
    _isAIGenerated = false;
    notifyListeners();

    try {
      _currentDietPlan = await GeminiDietService.generateDietPlan(
        user,
        onProgress: (msg) {
          if (_statusMessage != msg) {
            _statusMessage = msg;
            notifyListeners();
          }
        },
      );
      _isAIGenerated = true;
      _loadState = DietLoadState.loaded;
      _statusMessage = '';
    } catch (e) {
      print('GEMINI ERROR: $e');
      _statusMessage = '⚠️ AI Error: ${e.toString().split('\n').first}';
      notifyListeners();
      
      // Wait a moment so user can see the error
      await Future.delayed(const Duration(seconds: 3));
      
      // Fallback to local
      _loadState = DietLoadState.loadingLocal;
      _statusMessage = 'Switching to variety-enhanced local plan...';
      notifyListeners();
      _currentDietPlan = DietGenerator.generate(user);
      _isAIGenerated = false;
      _loadState = DietLoadState.loaded;
      _statusMessage = '';
    }

    notifyListeners();
  }

  /// Regenerate plan (user taps refresh)
  Future<void> regenerate(UserModel user) async {
    _currentDietPlan = null;
    notifyListeners();
    await generateForUser(user);
  }

  /// Fallback mock plan
  void loadMockDietPlan() {
    final mockUser = UserModel(
      id: 'mock',
      name: 'User',
      age: 22,
      gender: 'Male',
      height: 175,
      weight: 70,
      bodyType: 'Average',
      primaryGoal: 'Bulking',
      experienceLevel: 'Beginner',
      workoutLocation: 'Gym',
      dietPreference: 'Non-vegetarian',
      monthlyBudget: 3000,
    );
    _currentDietPlan = DietGenerator.generate(mockUser);
    _isAIGenerated = false;
    _loadState = DietLoadState.loaded;
    notifyListeners();
  }
}
