import '../entities/streak.dart';

abstract class StreakRepository {
  Future<Streak?> getStreak(String userId);
  Future<void> saveStreak(Streak streak);
  Future<void> updateStreakActivity(String userId);
  Future<void> resetStreak(String userId);
}
