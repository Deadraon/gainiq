import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/workout_model.dart';
import '../../models/user_model.dart';
import '../services/workout_generator.dart';

class WorkoutProvider with ChangeNotifier {
  List<WorkoutPlanModel> _availablePlans = [];
  WorkoutPlanModel? _activePlan;

  List<WorkoutPlanModel> get availablePlans => _availablePlans;
  WorkoutPlanModel? get activePlan => _activePlan;

  /// Generate personalised workout plans from the user's profile
  void generateForUser(UserModel user) {
    _availablePlans = WorkoutGenerator.generate(user);
    _activePlan = _availablePlans.isNotEmpty
        ? _availablePlans.firstWhere((p) => p.isActive, orElse: () => _availablePlans.first)
        : null;
    notifyListeners();
  }

  /// Fallback mock data
  void loadMockPlans() {
    final mockUser = UserModel(
      id: 'mock',
      name: 'User',
      age: 22,
      gender: 'Male',
      height: 175,
      weight: 70,
      bodyType: 'Average',
      primaryGoal: 'Bulking',
      experienceLevel: 'Intermediate',
      workoutLocation: 'Gym',
      dietPreference: 'Non-vegetarian',
      monthlyBudget: 3000,
    );
    generateForUser(mockUser);
  }

  void setActivePlan(String planId) {
    final index = _availablePlans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      _activePlan = _availablePlans[index];
      notifyListeners();
    }
  }

  void updateExerciseSet(String exerciseId, bool isIncrement) {
    if (_activePlan != null) {
      final index = _activePlan!.exercises.indexWhere((e) => e.id == exerciseId);
      if (index != -1) {
        final exercise = _activePlan!.exercises[index];
        final newCompleted = isIncrement
            ? (exercise.completedSets < exercise.sets ? exercise.completedSets + 1 : exercise.completedSets)
            : (exercise.completedSets > 0 ? exercise.completedSets - 1 : 0);

        _activePlan!.exercises[index] = ExerciseModel(
          id: exercise.id,
          name: exercise.name,
          sets: exercise.sets,
          reps: exercise.reps,
          completedSets: newCompleted,
          targetMuscle: exercise.targetMuscle,
          instructions: exercise.instructions,
        );
        notifyListeners();
      }
    }
  }
  /// Update a plan's exercises (called from EditWorkoutScreen)
  Future<void> updatePlan(WorkoutPlanModel updated) async {
    final idx = _availablePlans.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _availablePlans[idx] = updated;
      if (_activePlan?.id == updated.id) _activePlan = updated;
      notifyListeners();
    }
    // Persist to Firestore
    await _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'customWorkoutPlans': _availablePlans.map((p) => p.toJson()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving workout plans: $e');
    }
  }

  /// Load any previously saved custom plans from Firestore (overrides generated ones)
  Future<void> loadCustomPlans(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final raw = doc.data()?['customWorkoutPlans'] as List<dynamic>?;
      if (raw != null && raw.isNotEmpty) {
        _availablePlans = raw
            .map((e) => WorkoutPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _activePlan = _availablePlans.firstWhere(
          (p) => p.isActive,
          orElse: () => _availablePlans.first,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading custom plans: $e');
    }
  }
}
