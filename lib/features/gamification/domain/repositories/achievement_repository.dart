import '../entities/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAllAchievements();
  Future<List<Achievement>> getUserAchievements(String userId);
  Future<void> saveUserAchievements(
    String userId,
    List<Achievement> achievements,
  );
  Future<void> unlockAchievement(String userId, String achievementId);
  Future<void> updateAchievementProgress(
    String userId,
    List<Achievement> achievements,
  );
}
