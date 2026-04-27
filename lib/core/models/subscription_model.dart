enum SubscriptionPlan { free, pro, advance }

class SubscriptionModel {
  final SubscriptionPlan plan;
  final DateTime? expiresAt;
  final DateTime? startedAt;

  const SubscriptionModel({
    this.plan = SubscriptionPlan.free,
    this.expiresAt,
    this.startedAt,
  });

  bool get isActive {
    if (plan == SubscriptionPlan.free) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  bool get isPro => plan == SubscriptionPlan.pro && isActive;
  bool get isAdvance => plan == SubscriptionPlan.advance && isActive;
  bool get isPaid => (isPro || isAdvance);

  String get planName {
    switch (plan) {
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.advance:
        return 'Advance';
      case SubscriptionPlan.free:
        return 'Free';
    }
  }

  String get planEmoji {
    switch (plan) {
      case SubscriptionPlan.pro:
        return '⚡';
      case SubscriptionPlan.advance:
        return '👑';
      case SubscriptionPlan.free:
        return '🆓';
    }
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: _planFromString(json['plan'] as String? ?? 'free'),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan.name,
        'expiresAt': expiresAt?.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
      };

  static SubscriptionPlan _planFromString(String s) {
    switch (s) {
      case 'pro':
        return SubscriptionPlan.pro;
      case 'advance':
        return SubscriptionPlan.advance;
      default:
        return SubscriptionPlan.free;
    }
  }

  SubscriptionModel copyWith({
    SubscriptionPlan? plan,
    DateTime? expiresAt,
    DateTime? startedAt,
  }) {
    return SubscriptionModel(
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
