import 'package:shared_preferences/shared_preferences.dart';

class StreakManager {
  static const _streakKey = 'current_streak';
  static const _lastActiveKey = 'last_active_date';
  static const _bestStreakKey = 'best_streak';

  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<int> getBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestStreakKey) ?? 0;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getString(_lastActiveKey);
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';

    if (lastActive == today) return;

    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastActive != null) {
      final lastDate = DateTime.parse(lastActive);
      final difference = now.difference(lastDate).inDays;

      if (difference == 1) {
        streak++;
      } else if (difference > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastActiveKey, today);

    if (streak > (prefs.getInt(_bestStreakKey) ?? 0)) {
      await prefs.setInt(_bestStreakKey, streak);
    }
  }

  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, 0);
  }
}
