import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';

/// API-backed implementation. The streak is computed and persisted server-side
/// (POST /progress/complete calls updateStreak). Local computations preserve
/// UI behavior; persistence is a no-op because the server is authoritative.
class StreakRepositoryImpl implements StreakRepository {
  final ApiService _api;

  StreakRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<Streak?> getStreak(String userId) async {
    final result = await _api.getGrowthStats();
    if (!result.isSuccess || result.data == null) {
      return null;
    }
    final data = result.data!;
    final current = data['currentStreak'] as int? ?? 0;
    final longest = data['bestStreak'] as int? ?? 0;
    final dailyXp = data['dailyXp'] as int? ?? 0;
    return Streak(
      userId: userId,
      currentStreak: current,
      longestStreak: longest,
      lastActivityAt: DateTime.now(),
      isActiveToday: dailyXp > 0 || current > 0,
    );
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    // Streak is stored server-side. This is intentionally a no-op.
  }

  @override
  Future<void> updateStreakActivity(String userId) async {
    final now = DateTime.now();
    final current = await getStreak(userId);

    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = current != null
        ? DateTime(
            current.lastActivityAt.year,
            current.lastActivityAt.month,
            current.lastActivityAt.day,
          )
        : null;

    if (lastActivity != null && today.isAtSameMomentAs(lastActivity)) {
      return;
    }

    final difference = lastActivity != null
        ? today.difference(lastActivity).inDays
        : 999;

    int newStreak;
    int newLongest = current?.longestStreak ?? 0;
    DateTime? streakStarted = current?.streakStartedAt;
    if (difference == 1) {
      newStreak = (current?.currentStreak ?? 0) + 1;
      if (newStreak > newLongest) newLongest = newStreak;
    } else {
      newStreak = 1;
      streakStarted = now;
    }

    final updated = Streak(
      userId: userId,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActivityAt: now,
      streakStartedAt: streakStarted,
      isActiveToday: true,
    );
    await saveStreak(updated);
  }

  @override
  Future<void> resetStreak(String userId) async {
    // No client-accessible reset endpoint; server is authoritative.
  }
}