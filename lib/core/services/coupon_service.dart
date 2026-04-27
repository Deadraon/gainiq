import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/coupon_model.dart';

enum CouponRedeemResult {
  success,
  notFound,
  expired,
  exhausted,
  alreadyUsed,
  inactive,
  error,
}

class CouponService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'coupons';

  // ── Admin: Create a new coupon ──────────────────────────────
  static Future<bool> createCoupon(CouponModel coupon) async {
    try {
      await _db
          .collection(_col)
          .doc(coupon.code.toUpperCase())
          .set(coupon.toJson());
      return true;
    } catch (e) {
      debugPrint('createCoupon error: $e');
      return false;
    }
  }

  // ── Admin: List all coupons ──────────────────────────────────
  static Future<List<CouponModel>> listCoupons() async {
    try {
      final snap = await _db
          .collection(_col)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((d) => CouponModel.fromJson(d.data()))
          .toList();
    } catch (e) {
      debugPrint('listCoupons error: $e');
      return [];
    }
  }

  // ── Admin: Toggle active/inactive ───────────────────────────
  static Future<bool> toggleCoupon(String code, bool isActive) async {
    try {
      await _db
          .collection(_col)
          .doc(code.toUpperCase())
          .update({'isActive': isActive});
      return true;
    } catch (e) {
      debugPrint('toggleCoupon error: $e');
      return false;
    }
  }

  // ── Admin: Delete coupon ─────────────────────────────────────
  static Future<bool> deleteCoupon(String code) async {
    try {
      await _db.collection(_col).doc(code.toUpperCase()).delete();
      return true;
    } catch (e) {
      debugPrint('deleteCoupon error: $e');
      return false;
    }
  }

  // ── User: Redeem a coupon ────────────────────────────────────
  /// Returns [CouponRedeemResult] and the [CouponModel] if successful.
  static Future<(CouponRedeemResult, CouponModel?)> redeemCoupon(
      String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return (CouponRedeemResult.error, null);

    try {
      final docRef = _db.collection(_col).doc(code);

      return await _db.runTransaction<(CouponRedeemResult, CouponModel?)>(
        (txn) async {
          final snap = await txn.get(docRef);

          if (!snap.exists) return (CouponRedeemResult.notFound, null);

          final coupon = CouponModel.fromJson(snap.data()!);

          if (!coupon.isActive) return (CouponRedeemResult.inactive, null);
          if (coupon.isExpired) return (CouponRedeemResult.expired, null);
          if (coupon.isExhausted) return (CouponRedeemResult.exhausted, null);
          if (coupon.usedBy.contains(uid)) {
            return (CouponRedeemResult.alreadyUsed, null);
          }

          // All checks passed — update counters
          txn.update(docRef, {
            'usedCount': FieldValue.increment(1),
            'usedBy': FieldValue.arrayUnion([uid]),
          });

          return (CouponRedeemResult.success, coupon);
        },
      );
    } catch (e) {
      debugPrint('redeemCoupon error: $e');
      return (CouponRedeemResult.error, null);
    }
  }
}
