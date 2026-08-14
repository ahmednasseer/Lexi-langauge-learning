import '../../domain/entities/premium.dart';

class PremiumModel extends Premium {
  const PremiumModel({
    required super.userId,
    super.isPremium,
    super.plan,
    super.expiresAt,
    super.purchasedAt,
    super.features,
  });

  factory PremiumModel.fromEntity(Premium premium) {
    return PremiumModel(
      userId: premium.userId,
      isPremium: premium.isPremium,
      plan: premium.plan,
      expiresAt: premium.expiresAt,
      purchasedAt: premium.purchasedAt,
      features: premium.features,
    );
  }

  factory PremiumModel.fromJson(Map<String, dynamic> json, String userId) {
    return PremiumModel(
      userId: userId,
      isPremium: json['isPremium'] ?? false,
      plan: PremiumPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => PremiumPlan.none,
      ),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'])
          : null,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'plan': plan.name,
      'expiresAt': expiresAt?.toIso8601String(),
      'purchasedAt': purchasedAt?.toIso8601String(),
      'features': features,
    };
  }
}
