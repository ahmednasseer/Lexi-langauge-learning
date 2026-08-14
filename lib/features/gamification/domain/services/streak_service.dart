import '../entities/streak.dart';

class StreakService {
  static Streak calculateStreak(Streak currentStreak, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      currentStreak.lastActivityAt.year,
      currentStreak.lastActivityAt.month,
      currentStreak.lastActivityAt.day,
    );

    final difference = today.difference(lastActivity).inDays;

    if (difference == 0) {
      return currentStreak.copyWith(isActiveToday: true);
    }

    if (difference == 1) {
      final newStreak = currentStreak.currentStreak + 1;
      final newLongest = newStreak > currentStreak.longestStreak
          ? newStreak
          : currentStreak.longestStreak;
      return currentStreak.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActivityAt: now,
        isActiveToday: true,
      );
    }

    return Streak(
      userId: currentStreak.userId,
      currentStreak: 1,
      longestStreak: currentStreak.longestStreak,
      lastActivityAt: now,
      streakStartedAt: now,
      isActiveToday: true,
    );
  }

  static bool shouldUpdateStreak(DateTime? lastActivityAt, DateTime now) {
    if (lastActivityAt == null) return true;
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      lastActivityAt.year,
      lastActivityAt.month,
      lastActivityAt.day,
    );
    return !today.isAtSameMomentAs(last);
  }

  static int getStreakBonusXp(int currentStreak) {
    if (currentStreak >= 30) return 50;
    if (currentStreak >= 14) return 30;
    if (currentStreak >= 7) return 15;
    if (currentStreak >= 3) return 5;
    return 0;
  }
}
