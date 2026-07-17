enum SubscriptionType { free, premiumMonthly, premiumYearly }
enum SubscriptionStatus { active, cancelled, expired, trial }

class Plan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationDays;
  final List<String> features;
  final bool isPopular;
  final double? savingsPercent;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.features,
    this.isPopular = false,
    this.savingsPercent,
  });

  String get priceDisplay => '$currency ${price.toStringAsFixed(2)}';
  String get period => durationDays >= 365 ? '/year' : '/month';
  String get monthlyPrice {
    if (durationDays >= 365) {
      final monthly = price / 12;
      return '\$${monthly.toStringAsFixed(2)}/month';
    }
    return priceDisplay;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'currency': currency,
    'durationDays': durationDays,
    'features': features,
    'isPopular': isPopular,
    'savingsPercent': savingsPercent,
  };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    currency: json['currency'] ?? '\$',
    durationDays: json['durationDays'] ?? 30,
    features: List<String>.from(json['features'] ?? []),
    isPopular: json['isPopular'] ?? false,
    savingsPercent: json['savingsPercent']?.toDouble(),
  );

  static const freePlan = Plan(
    id: 'free',
    name: 'Free',
    description: 'Basic learning features',
    price: 0,
    currency: '\$',
    durationDays: 36500,
    features: [
      'A1-A2 Lessons',
      'Limited AI Coach (5 messages/day)',
      'Basic Speaking Practice',
      'Daily Missions',
      '10 Flashcard Decks',
    ],
  );

  static const premiumMonthly = Plan(
    id: 'premium_monthly',
    name: 'Premium Monthly',
    description: 'Full access to all features',
    price: 9.99,
    currency: '\$',
    durationDays: 30,
    isPopular: true,
    features: [
      'All Levels (A1-C2)',
      'Unlimited AI Coach',
      'Advanced Speaking Analysis',
      'Goethe Test Preparation',
      'Premium Certificates',
      'No Ads',
      'VIP Avatar Frames',
      'Priority Support',
    ],
  );

  static const premiumYearly = Plan(
    id: 'premium_yearly',
    name: 'Premium Yearly',
    description: 'Best value - Save 50%',
    price: 59.99,
    currency: '\$',
    durationDays: 365,
    savingsPercent: 50,
    features: [
      'All Levels (A1-C2)',
      'Unlimited AI Coach',
      'Advanced Speaking Analysis',
      'Goethe Test Preparation',
      'Premium Certificates',
      'No Ads',
      'VIP Avatar Frames',
      'Priority Support',
      '500 Free Gems',
    ],
  );

  static List<Plan> get allPlans => [freePlan, premiumMonthly, premiumYearly];
}

class UserSubscription {
  final String id;
  final String userId;
  final Plan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final String? paymentId;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.autoRenew = true,
    this.paymentId,
  });

  bool get isActive => status == SubscriptionStatus.active && endDate.isAfter(DateTime.now());
  bool get isPremium => isActive && plan.id != 'free';
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'plan': plan.toJson(),
    'status': status.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'autoRenew': autoRenew,
    'paymentId': paymentId,
  };

  factory UserSubscription.fromJson(Map<String, dynamic> json) => UserSubscription(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    plan: Plan.fromJson(json['plan'] ?? {}),
    status: SubscriptionStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => SubscriptionStatus.expired),
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    autoRenew: json['autoRenew'] ?? true,
    paymentId: json['paymentId'],
  );
}
