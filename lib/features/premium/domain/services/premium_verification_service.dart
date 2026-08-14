import 'package:lexi/core/services/api_service.dart';
import '../entities/premium.dart';

/// Premium verification delegated to the server subscription state. The client
/// only reads the subscription; it never mutates premium status.
class PremiumVerificationService {
  final ApiService _api;

  PremiumVerificationService({ApiService? api}) : _api = api ?? ApiService();

  Future<Premium> verifyPremiumStatus(String userId) async {
    try {
      final result = await _api.getSubscription();
      if (!result.isSuccess || result.data == null) {
        return Premium(userId: userId);
      }

      final json = result.data!;
      final planId = json['planId'] as String? ?? '';
      final plan = planId.contains('year')
          ? PremiumPlan.yearly
          : PremiumPlan.monthly;
      final endDate = json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null;
      final active =
          json['status'] == 'active' &&
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
    } catch (e) {
      return Premium(userId: userId);
    }
  }

  Future<bool> hasFeature(String userId, String feature) async {
    try {
      final premium = await verifyPremiumStatus(userId);
      if (!premium.isActive) return false;
      return premium.features.contains(feature);
    } catch (e) {
      return false;
    }
  }

  Future<bool> canAccessPremiumContent(String userId) async {
    try {
      final premium = await verifyPremiumStatus(userId);
      return premium.isActive;
    } catch (e) {
      return false;
    }
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