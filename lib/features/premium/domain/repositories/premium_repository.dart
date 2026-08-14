import '../entities/premium.dart';

abstract class PremiumRepository {
  Future<Premium?> getPremium(String userId);
  Future<void> savePremium(Premium premium);
  Future<void> activatePremium({
    required String userId,
    required PremiumPlan plan,
    required int durationDays,
  });
  Future<void> deactivatePremium(String userId);
  Future<void> cancelPremium(String userId);
  Future<bool> isPremiumActive(String userId);
}
