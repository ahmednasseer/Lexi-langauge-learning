import '../../domain/entities/streak.dart';

class StreakModel extends Streak {
  const StreakModel({
    required super.userId,
    super.currentStreak,
    super.longestStreak,
    required super.lastActivityAt,
    super.streakStartedAt,
    super.isActiveToday,
  });

  factory StreakModel.fromEntity(Streak streak) {
    return StreakModel(
      userId: streak.userId,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastActivityAt: streak.lastActivityAt,
      streakStartedAt: streak.streakStartedAt,
      isActiveToday: streak.isActiveToday,
    );
  }

  factory StreakModel.fromJson(Map<String, dynamic> json, String userId) {
    return StreakModel(
      userId: userId,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt'])
          : DateTime.now(),
      streakStartedAt: json['streakStartedAt'] != null
          ? DateTime.parse(json['streakStartedAt'])
          : null,
      isActiveToday: json['isActiveToday'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'streakStartedAt': streakStartedAt?.toIso8601String(),
      'isActiveToday': isActiveToday,
    };
  }
}
