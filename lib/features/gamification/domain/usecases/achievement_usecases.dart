import '../entities/achievement.dart';
import '../repositories/achievement_repository.dart';

class GetAchievementsUseCase {
  final AchievementRepository repository;

  GetAchievementsUseCase(this.repository);

  Future<List<Achievement>> call() async {
    return repository.getAllAchievements();
  }
}

class GetUserAchievementsUseCase {
  final AchievementRepository repository;

  GetUserAchievementsUseCase(this.repository);

  Future<List<Achievement>> call(String userId) async {
    return repository.getUserAchievements(userId);
  }
}

class UpdateAchievementProgressUseCase {
  final AchievementRepository repository;

  UpdateAchievementProgressUseCase(this.repository);

  Future<List<Achievement>> call({
    required String userId,
    required List<Achievement> achievements,
  }) async {
    await repository.updateAchievementProgress(userId, achievements);
    return achievements;
  }
}

class UnlockAchievementUseCase {
  final AchievementRepository repository;

  UnlockAchievementUseCase(this.repository);

  Future<void> call(String userId, String achievementId) async {
    await repository.unlockAchievement(userId, achievementId);
  }
}
