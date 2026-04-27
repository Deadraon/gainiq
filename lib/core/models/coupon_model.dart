import '../models/subscription_model.dart';

enum CouponPlan { pro, advance }

class CouponModel {
  final String code;
  final CouponPlan plan;
  final int durationDays;
  final int maxUses;
  final int usedCount;
  final List<String> usedBy;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime createdAt;
  final String description;

  const CouponModel({
    required this.code,
    required this.plan,
    this.durationDays = 30,
    this.maxUses = 1,
    this.usedCount = 0,
    this.usedBy = const [],
    this.expiresAt,
    this.isActive = true,
    required this.createdAt,
    this.description = '',
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isExhausted => usedCount >= maxUses;

  bool get canRedeem => isActive && !isExpired && !isExhausted;

  String get planName => plan == CouponPlan.pro ? 'Pro' : 'Advance';
  String get planEmoji => plan == CouponPlan.pro ? '⚡' : '👑';

  SubscriptionPlan get subscriptionPlan =>
      plan == CouponPlan.pro ? SubscriptionPlan.pro : SubscriptionPlan.advance;

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code'] as String,
      plan: json['plan'] == 'advance' ? CouponPlan.advance : CouponPlan.pro,
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 30,
      maxUses: (json['maxUses'] as num?)?.toInt() ?? 1,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      usedBy: List<String>.from(json['usedBy'] as List? ?? []),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'plan': plan.name,
        'durationDays': durationDays,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'usedBy': usedBy,
        'expiresAt': expiresAt?.toIso8601String(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'description': description,
      };
}
