import '../entities/streak.dart';
import '../repositories/streak_repository.dart';
import '../services/streak_service.dart';

class GetStreakUseCase {
  final StreakRepository repository;

  GetStreakUseCase(this.repository);

  Future<Streak?> call(String userId) async {
    return repository.getStreak(userId);
  }
}

class UpdateStreakUseCase {
  final StreakRepository repository;

  UpdateStreakUseCase(this.repository);

  Future<Streak> call(String userId) async {
    final currentStreak = await repository.getStreak(userId);
    final now = DateTime.now();

    final updatedStreak = StreakService.calculateStreak(
      currentStreak ?? Streak(userId: userId, lastActivityAt: now),
      now,
    );

    await repository.saveStreak(updatedStreak);
    return updatedStreak;
  }
}

class GetStreakBonusXpUseCase {
  final StreakRepository repository;

  GetStreakBonusXpUseCase(this.repository);

  Future<int> call(String userId) async {
    final streak = await repository.getStreak(userId);
    if (streak == null) return 0;
    return StreakService.getStreakBonusXp(streak.currentStreak);
  }
}

class ResetStreakUseCase {
  final StreakRepository repository;

  ResetStreakUseCase(this.repository);

  Future<void> call(String userId) async {
    await repository.resetStreak(userId);
  }
}
