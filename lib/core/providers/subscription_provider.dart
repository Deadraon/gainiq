import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';

class SubscriptionProvider with ChangeNotifier {
  SubscriptionModel _subscription = const SubscriptionModel();
  bool _isLoading = false;

  SubscriptionModel get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get isPro => _subscription.isPro;
  bool get isAdvance => _subscription.isAdvance;
  bool get isPaid => _subscription.isPaid;

  SubscriptionProvider() {
    _listenToSubscription();
  }

  void _listenToSubscription() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists && doc.data()?['subscription'] != null) {
            _subscription = SubscriptionModel.fromJson(
              Map<String, dynamic>.from(doc.data()!['subscription']),
            );
          } else {
            _subscription = const SubscriptionModel();
          }
          notifyListeners();
        });
      } else {
        _subscription = const SubscriptionModel();
        notifyListeners();
      }
    });
  }

  /// Called after a successful payment to activate the plan
  Future<bool> activatePlan(SubscriptionPlan plan) async =>
      activatePlanWithDuration(plan, 30);

  /// Called after coupon redemption — duration can vary
  Future<bool> activatePlanWithDuration(
      SubscriptionPlan plan, int days) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final expires = now.add(Duration(days: days));

      final sub = SubscriptionModel(
        plan: plan,
        startedAt: now,
        expiresAt: expires,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'subscription': sub.toJson()}, SetOptions(merge: true));

      _subscription = sub;
      return true;
    } catch (e) {
      debugPrint('Error activating plan: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelPlan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      const sub = SubscriptionModel(plan: SubscriptionPlan.free);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'subscription': sub.toJson()}, SetOptions(merge: true));

      _subscription = sub;
      return true;
    } catch (e) {
      debugPrint('Error cancelling plan: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
