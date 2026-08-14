import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/premium.dart';
import '../../domain/repositories/premium_repository.dart';

/// API-backed premium. Premium state is owned by the backend subscription
/// records (Stripe). The client only reads the subscription state and kicks
/// off the checkout flow.
class PremiumRepositoryImpl implements PremiumRepository {
  final ApiService _api;

  PremiumRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  Premium _subscriptionToPremium(String userId, Map<String, dynamic> json) {
    final planId = json['planId'] as String? ?? '';
    final plan = planId.contains('year')
        ? PremiumPlan.yearly
        : PremiumPlan.monthly;
    final endDate = json['endDate'] != null
        ? DateTime.tryParse(json['endDate'].toString())
        : null;
    final status = json['status'] as String? ?? '';
    final active = status == 'active' &&
        (endDate == null || DateTime.now().isBefore(endDate));

    return Premium(
      userId: userId,
      isPremium: active,
      plan: active ? plan : PremiumPlan.none,
      expiresAt: endDate,
      purchasedAt: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      features: active ? _getPremiumFeatures(plan) : const [],
    );
  }

  @override
  Future<Premium?> getPremium(String userId) async {
    final result = await _api.getSubscription();
    if (!result.isSuccess || result.data == null) {
      return Premium(userId: userId);
    }
    return _subscriptionToPremium(userId, result.data!);
  }

  @override
  Future<void> savePremium(Premium premium) {
    throw UnsupportedError(
      'Premium state is managed by the server subscription. Use activatePremium.',
    );
  }

  @override
  Future<void> activatePremium({
    required String userId,
    required PremiumPlan plan,
    required int durationDays,
  }) async {
    if (plan == PremiumPlan.none) {
      throw Exception('Cannot activate premium with plan "none"');
    }
    final planId = plan == PremiumPlan.monthly ? 'monthly' : 'yearly';
    final result = await _api.createCheckout(planId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to start checkout');
    }
    // The Stripe checkout session was created. Payment completion updates the
    // server subscription via webhook; the client re-reads the subscription.
  }

  @override
  Future<void> deactivatePremium(String userId) {
    throw UnsupportedError(
      'Deactivating premium is a server/admin operation.',
    );
  }

  @override
  Future<void> cancelPremium(String userId) async {
    await _api.cancelSubscription();
  }

  @override
  Future<bool> isPremiumActive(String userId) async {
    final premium = await getPremium(userId);
    return premium?.isActive ?? false;
  }

  List<String> _getPremiumFeatures(PremiumPlan plan) {
    final baseFeatures = ['unlimited_lessons', 'no_ads', 'exclusive_frames'];

    switch (plan) {
      case PremiumPlan.monthly:
        return [...baseFeatures, 'monthly_badge'];
      case PremiumPlan.yearly:
        return [...baseFeatures, 'yearly_badge', 'priority_support'];
      case PremiumPlan.lifetime:
        return [...baseFeatures, 'lifetime_badge', 'all_features'];
      case PremiumPlan.none:
        return [];
    }
  }
}