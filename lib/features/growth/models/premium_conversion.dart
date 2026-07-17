enum PaywallType {
  standard,
  smart,
  trial,
  exit,
}

enum PremiumPlan {
  monthly,
  yearly,
  lifetime,
}

extension PremiumPlanExtension on PremiumPlan {
  String get displayName {
    switch (this) {
      case PremiumPlan.monthly:
        return 'Monthly';
      case PremiumPlan.yearly:
        return 'Yearly';
      case PremiumPlan.lifetime:
        return 'Lifetime';
    }
  }

  double get price {
    switch (this) {
      case PremiumPlan.monthly:
        return 9.99;
      case PremiumPlan.yearly:
        return 59.99;
      case PremiumPlan.lifetime:
        return 149.99;
    }
  }

  int get discountPercent {
    switch (this) {
      case PremiumPlan.monthly:
        return 0;
      case PremiumPlan.yearly:
        return 50;
      case PremiumPlan.lifetime:
        return 75;
    }
  }
}

class SmartPaywall {
  final String id;
  final PaywallType type;
  final String title;
  final String subtitle;
  final List<String> features;
  final PremiumPlan recommendedPlan;
  final Map<String, dynamic> userContext;
  final bool hasTrial;
  final int trialDays;

  const SmartPaywall({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.recommendedPlan,
    required this.userContext,
    this.hasTrial = true,
    this.trialDays = 7,
  });

  String get personalizedMessage {
    final lessonsCompleted = userContext['lessonsCompleted'] ?? 0;
    final wordsLearned = userContext['wordsLearned'] ?? 0;
    final streak = userContext['streak'] ?? 0;

    if (lessonsCompleted > 20) {
      return 'You\'ve completed $lessonsCompleted lessons! Unlock more content.';
    }
    if (wordsLearned > 100) {
      return 'You\'ve learned $wordsLearned words! Take your learning to the next level.';
    }
    if (streak > 5) {
      return 'Amazing $streak-day streak! Keep the momentum going.';
    }
    return 'Start your German journey with Premium!';
  }

  SmartPaywall copyWith({
    String? id,
    PaywallType? type,
    String? title,
    String? subtitle,
    List<String>? features,
    PremiumPlan? recommendedPlan,
    Map<String, dynamic>? userContext,
    bool? hasTrial,
    int? trialDays,
  }) {
    return SmartPaywall(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      features: features ?? this.features,
      recommendedPlan: recommendedPlan ?? this.recommendedPlan,
      userContext: userContext ?? this.userContext,
      hasTrial: hasTrial ?? this.hasTrial,
      trialDays: trialDays ?? this.trialDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'features': features,
    'recommendedPlan': recommendedPlan.name,
    'userContext': userContext,
    'hasTrial': hasTrial,
    'trialDays': trialDays,
  };

  factory SmartPaywall.fromJson(Map<String, dynamic> json) => SmartPaywall(
    id: json['id'] ?? '',
    type: PaywallType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => PaywallType.standard,
    ),
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    features: List<String>.from(json['features'] ?? []),
    recommendedPlan: PremiumPlan.values.firstWhere(
      (p) => p.name == json['recommendedPlan'],
      orElse: () => PremiumPlan.yearly,
    ),
    userContext: Map<String, dynamic>.from(json['userContext'] ?? {}),
    hasTrial: json['hasTrial'] ?? true,
    trialDays: json['trialDays'] ?? 7,
  );

  factory SmartPaywall.standard() => SmartPaywall(
    id: 'paywall_standard',
    type: PaywallType.standard,
    title: 'Unlock Premium',
    subtitle: 'Take your German learning to the next level',
    features: [
      'Unlimited AI conversations',
      'All lesson levels (A1-C2)',
      'Advanced Speaking Lab',
      'Goethe exam preparation',
      'Priority support',
    ],
    recommendedPlan: PremiumPlan.yearly,
    userContext: {},
  );

  factory SmartPaywall.personalized(Map<String, dynamic> context) {
    final lessonsCompleted = context['lessonsCompleted'] ?? 0;
    final wordsLearned = context['wordsLearned'] ?? 0;

    return SmartPaywall(
      id: 'paywall_personalized',
      type: PaywallType.smart,
      title: 'You\'re Making Great Progress!',
      subtitle: 'Unlock your full potential with Premium',
      features: [
        'Unlimited AI conversations',
        'All lesson levels (A1-C2)',
        'Advanced Speaking Lab',
        'Goethe exam preparation',
        'Priority support',
        if (lessonsCompleted > 10) 'Personalized learning paths',
        if (wordsLearned > 50) 'Advanced vocabulary trainer',
      ],
      recommendedPlan: PremiumPlan.yearly,
      userContext: context,
    );
  }
}

class FreeTrial {
  final String id;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isExpired;
  final PremiumPlan planAfterTrial;

  const FreeTrial({
    required this.id,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isExpired = false,
    required this.planAfterTrial,
  });

  int get daysRemaining => endDate.difference(DateTime.now()).inDays.clamp(0, durationDays);
  bool get isExpiringSoon => daysRemaining <= 2;

  FreeTrial copyWith({
    String? id,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isExpired,
    PremiumPlan? planAfterTrial,
  }) {
    return FreeTrial(
      id: id ?? this.id,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isExpired: isExpired ?? this.isExpired,
      planAfterTrial: planAfterTrial ?? this.planAfterTrial,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'durationDays': durationDays,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isActive': isActive,
    'isExpired': isExpired,
    'planAfterTrial': planAfterTrial.name,
  };

  factory FreeTrial.fromJson(Map<String, dynamic> json) => FreeTrial(
    id: json['id'] ?? '',
    durationDays: json['durationDays'] ?? 7,
    startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
    isActive: json['isActive'] ?? true,
    isExpired: json['isExpired'] ?? false,
    planAfterTrial: PremiumPlan.values.firstWhere(
      (p) => p.name == json['planAfterTrial'],
      orElse: () => PremiumPlan.yearly,
    ),
  );
}
