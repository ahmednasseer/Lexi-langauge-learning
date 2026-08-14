import 'package:equatable/equatable.dart';

enum AchievementType {
  lessonsCompleted,
  xpEarned,
  levelReached,
  streakDays,
  quizPerfect,
  categoryMaster,
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requirementValue;
  final int rewardXp;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirementValue,
    this.rewardXp = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
  });

  double get progressPercent {
    if (requirementValue == 0) return 0;
    return (progress / requirementValue).clamp(0.0, 1.0);
  }

  bool get isComplete => progress >= requirementValue;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    int? requirementValue,
    int? rewardXp,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      requirementValue: requirementValue ?? this.requirementValue,
      rewardXp: rewardXp ?? this.rewardXp,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    type,
    requirementValue,
    rewardXp,
    isUnlocked,
    unlockedAt,
    progress,
  ];
}
