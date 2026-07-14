class SubscriptionModel {
  final String id;
  final String name;
  final double price;
  final String currency;
  final int durationInDays;
  final List<String> features;
  final bool isPopular;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.durationInDays,
    required this.features,
    this.isPopular = false,
  });

  static const List<SubscriptionModel> plans = [
    SubscriptionModel(
      id: 'monthly',
      name: 'Monthly',
      price: 9.99,
      currency: '\$',
      durationInDays: 30,
      isPopular: false,
      features: [
        'Unlimited AI Chat',
        'All Languages',
        'Voice Conversations',
        'Progress Reports',
        'No Ads',
      ],
    ),
    SubscriptionModel(
      id: 'yearly',
      name: 'Yearly',
      price: 59.99,
      currency: '\$',
      durationInDays: 365,
      isPopular: true,
      features: [
        'Everything in Monthly',
        '60% Savings',
        'Priority Support',
        'Early Access to Features',
        'Offline Lessons',
      ],
    ),
  ];
}
