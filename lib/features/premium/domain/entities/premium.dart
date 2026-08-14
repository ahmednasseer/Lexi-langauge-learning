import 'package:equatable/equatable.dart';

enum PremiumPlan { none, monthly, yearly, lifetime }

class Premium extends Equatable {
  final String userId;
  final bool isPremium;
  final PremiumPlan plan;
  final DateTime? expiresAt;
  final DateTime? purchasedAt;
  final List<String> features;

  const Premium({
    required this.userId,
    this.isPremium = false,
    this.plan = PremiumPlan.none,
    this.expiresAt,
    this.purchasedAt,
    this.features = const [],
  });

  bool get isActive {
    if (!isPremium) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  bool get isExpired {
    if (!isPremium || expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get daysRemaining {
    if (expiresAt == null) return -1;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  Premium copyWith({
    String? userId,
    bool? isPremium,
    PremiumPlan? plan,
    DateTime? expiresAt,
    DateTime? purchasedAt,
    List<String>? features,
  }) {
    return Premium(
      userId: userId ?? this.userId,
      isPremium: isPremium ?? this.isPremium,
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      features: features ?? this.features,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    isPremium,
    plan,
    expiresAt,
    purchasedAt,
    features,
  ];
}
