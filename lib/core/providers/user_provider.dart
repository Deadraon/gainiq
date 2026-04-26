import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import 'diet_provider.dart';
import 'workout_provider.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  DietProvider? _dietProvider;
  WorkoutProvider? _workoutProvider;

  void setDietProvider(DietProvider dp) => _dietProvider = dp;
  void setWorkoutProvider(WorkoutProvider wp) => _workoutProvider = wp;

  UserProvider() {
    _initUser();
  }

  void _initUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _fetchUserProfile(user.uid);
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromJson({'id': uid, ...doc.data()!});
      } else {
        // Doc doesn't exist yet – create a shell so we have an id
        _currentUser = UserModel(id: uid);
      }

      // Auto-generate plans now that we have user data
      if (_currentUser!.isProfileComplete) {
        _dietProvider?.generateForUser(_currentUser!);
        _workoutProvider?.generateForUser(_currentUser!);
        await _workoutProvider?.loadCustomPlans(uid);
        await _workoutProvider?.loadWorkoutLogs(uid);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      final uid2 = FirebaseAuth.instance.currentUser?.uid ?? '';
      _currentUser = UserModel(id: uid2);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-fetch from Firestore (call after edit)
  Future<void> refreshProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _fetchUserProfile(uid);
  }

  /// Save updated profile to Firestore and refresh
  Future<void> updateProfile(UserModel updated) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(updated.toJson(), SetOptions(merge: true));

    _currentUser = updated;
    _dietProvider?.generateForUser(updated);
    _workoutProvider?.generateForUser(updated);
    await _workoutProvider?.loadCustomPlans(uid);
    await _workoutProvider?.loadWorkoutLogs(uid);
    notifyListeners();
  }
}

