import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityAt;
  final DateTime? streakStartedAt;
  final bool isActiveToday;

  const Streak({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivityAt,
    this.streakStartedAt,
    this.isActiveToday = false,
  });

  bool get hasStreak => currentStreak > 0;
  bool get isOnFire => currentStreak >= 7;
  bool get isUnstoppable => currentStreak >= 30;

  int get daysUntilNextMilestone {
    if (currentStreak < 3) return 3 - currentStreak;
    if (currentStreak < 7) return 7 - currentStreak;
    if (currentStreak < 14) return 14 - currentStreak;
    if (currentStreak >= 30) return 0;
    return 30 - currentStreak;
  }

  Streak copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityAt,
    DateTime? streakStartedAt,
    bool? isActiveToday,
  }) {
    return Streak(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      streakStartedAt: streakStartedAt ?? this.streakStartedAt,
      isActiveToday: isActiveToday ?? this.isActiveToday,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    currentStreak,
    longestStreak,
    lastActivityAt,
    streakStartedAt,
    isActiveToday,
  ];
}
