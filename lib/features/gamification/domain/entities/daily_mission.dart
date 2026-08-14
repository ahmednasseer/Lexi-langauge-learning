import 'package:equatable/equatable.dart';

enum MissionType {
  completeLessons,
  earnXp,
  answerQuestions,
  completeQuiz,
  maintainStreak,
}

class DailyMission extends Equatable {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int target;
  final int currentProgress;
  final int rewardXp;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime date;
  final String? icon;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.currentProgress = 0,
    required this.rewardXp,
    this.isCompleted = false,
    this.isClaimed = false,
    required this.date,
    this.icon,
  });

  double get progressPercent {
    if (target == 0) return 0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  bool get canClaim => isCompleted && !isClaimed;

  DailyMission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    int? target,
    int? currentProgress,
    int? rewardXp,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? date,
    String? icon,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardXp: rewardXp ?? this.rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      date: date ?? this.date,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    target,
    currentProgress,
    rewardXp,
    isCompleted,
    isClaimed,
    date,
    icon,
  ];
}
