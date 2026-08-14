import '../../domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.icon,
    required super.type,
    required super.requirementValue,
    super.rewardXp,
    super.isUnlocked,
    super.unlockedAt,
    super.progress,
  });

  factory AchievementModel.fromEntity(Achievement achievement) {
    return AchievementModel(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      icon: achievement.icon,
      type: achievement.type,
      requirementValue: achievement.requirementValue,
      rewardXp: achievement.rewardXp,
      isUnlocked: achievement.isUnlocked,
      unlockedAt: achievement.unlockedAt,
      progress: achievement.progress,
    );
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.lessonsCompleted,
      ),
      requirementValue: json['requirementValue'] ?? 0,
      rewardXp: json['rewardXp'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.name,
      'requirementValue': requirementValue,
      'rewardXp': rewardXp,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  factory AchievementModel.fromFirestoreDoc(
    Map<String, dynamic> doc,
    String id,
  ) {
    return AchievementModel(
      id: id,
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      icon: doc['icon'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == doc['type'],
        orElse: () => AchievementType.lessonsCompleted,
      ),
      requirementValue: doc['requirementValue'] ?? 0,
      rewardXp: doc['rewardXp'] ?? 0,
      isUnlocked: doc['isUnlocked'] ?? false,
      unlockedAt: doc['unlockedAt'] != null
          ? DateTime.parse(doc['unlockedAt'])
          : null,
      progress: doc['progress'] ?? 0,
    );
  }
}
