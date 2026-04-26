import 'package:flutter/material.dart';
import '../../models/diet_model.dart';
import '../../models/user_model.dart';
import '../services/diet_generator.dart';

class DietProvider with ChangeNotifier {
  DietPlanModel? _currentDietPlan;

  DietPlanModel? get currentDietPlan => _currentDietPlan;

  /// Called once we have the user's profile (e.g. from Firestore)
  void generateForUser(UserModel user) {
    _currentDietPlan = DietGenerator.generate(user);
    notifyListeners();
  }

  /// Fallback: generate for a default mock profile
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
    notifyListeners();
  }
}
