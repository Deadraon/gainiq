import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/workout_model.dart';
import '../../models/workout_log_model.dart';
import '../../models/user_model.dart';
import '../services/workout_generator.dart';
import '../services/gemini_workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  List<WorkoutPlanModel> _availablePlans = [];
  WorkoutPlanModel? _activePlan;
  List<WorkoutLogModel> _logs = [];
  bool _isGenerating = false;
  bool _isAIGenerated = false;
  String _statusMessage = '';

  List<WorkoutPlanModel> get availablePlans => _availablePlans;
  WorkoutPlanModel? get activePlan => _activePlan;
  List<WorkoutLogModel> get logs => _logs;
  bool get isGenerating => _isGenerating;
  bool get isAIGenerated => _isAIGenerated;
  String get statusMessage => _statusMessage;

  /// Generate personalised workout plans using Gemini AI
  Future<void> generateForUser(UserModel user) async {
    _isGenerating = true;
    _isAIGenerated = false;
    _statusMessage = '💪 AI is building your workout plan...';
    notifyListeners();

    try {
      _availablePlans = await GeminiWorkoutService.generateWorkoutPlans(
        user,
        onProgress: (msg) {
          if (_statusMessage != msg) {
            _statusMessage = msg;
            notifyListeners();
          }
        },
      );
      _isAIGenerated = true;
    } catch (_) {
      _availablePlans = WorkoutGenerator.generate(user);
      _isAIGenerated = false;
    }

    _activePlan = _availablePlans.isNotEmpty
        ? _availablePlans.firstWhere((p) => p.isActive, orElse: () => _availablePlans.first)
        : null;
    _isGenerating = false;
    _statusMessage = '';
    notifyListeners();
  }

  /// Regenerate with fresh AI plan
  Future<void> regenerate(UserModel user) async {
    _availablePlans = [];
    _activePlan = null;
    notifyListeners();
    await generateForUser(user);
  }

  /// Fallback mock data (uses local generator, no async)
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
    _availablePlans = WorkoutGenerator.generate(mockUser);
    _activePlan = _availablePlans.isNotEmpty
        ? _availablePlans.firstWhere((p) => p.isActive, orElse: () => _availablePlans.first)
        : null;
    notifyListeners();
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

  /// Load workout logs from Firestore
  Future<void> loadWorkoutLogs(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workout_logs')
          .orderBy('date', descending: true)
          .get();
      _logs = snapshot.docs.map((doc) => WorkoutLogModel.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading logs: $e');
    }
  }

  /// Save a completed workout log
  Future<void> saveWorkoutLog(WorkoutLogModel log) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    // Add locally to update UI immediately
    _logs.insert(0, log);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workout_logs')
          .doc(log.id)
          .set(log.toJson());
    } catch (e) {
      debugPrint('Error saving log: $e');
    }
  }
}
