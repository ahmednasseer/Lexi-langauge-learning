import '../entities/premium.dart';
import '../repositories/premium_repository.dart';

class GetPremiumUseCase {
  final PremiumRepository repository;

  GetPremiumUseCase(this.repository);

  Future<Premium?> call(String userId) async {
    return repository.getPremium(userId);
  }
}

class ActivatePremiumUseCase {
  final PremiumRepository repository;

  ActivatePremiumUseCase(this.repository);

  Future<void> call({
    required String userId,
    required PremiumPlan plan,
    required int durationDays,
  }) async {
    return repository.activatePremium(
      userId: userId,
      plan: plan,
      durationDays: durationDays,
    );
  }
}

class DeactivatePremiumUseCase {
  final PremiumRepository repository;

  DeactivatePremiumUseCase(this.repository);

  Future<void> call(String userId) async {
    return repository.deactivatePremium(userId);
  }
}

class CancelPremiumUseCase {
  final PremiumRepository repository;

  CancelPremiumUseCase(this.repository);

  Future<void> call(String userId) async {
    return repository.cancelPremium(userId);
  }
}

class IsPremiumActiveUseCase {
  final PremiumRepository repository;

  IsPremiumActiveUseCase(this.repository);

  Future<bool> call(String userId) async {
    return repository.isPremiumActive(userId);
  }
}
