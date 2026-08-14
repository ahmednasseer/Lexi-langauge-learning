import '../../domain/entities/progress.dart';

class ProgressModel extends Progress {
  const ProgressModel({
    required super.userId,
    super.completedLessons,
    super.completedUnits,
    super.totalXp,
    super.currentLevel,
    super.completionPercentage,
    required super.lastActivityAt,
    super.lessonScores,
    super.categoryXp,
  });

  factory ProgressModel.fromEntity(Progress progress) {
    return ProgressModel(
      userId: progress.userId,
      completedLessons: progress.completedLessons,
      completedUnits: progress.completedUnits,
      totalXp: progress.totalXp,
      currentLevel: progress.currentLevel,
      completionPercentage: progress.completionPercentage,
      lastActivityAt: progress.lastActivityAt,
      lessonScores: progress.lessonScores,
      categoryXp: progress.categoryXp,
    );
  }

  factory ProgressModel.fromJson(Map<String, dynamic> json, String userId) {
    return ProgressModel(
      userId: userId,
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      completedUnits: List<String>.from(json['completedUnits'] ?? []),
      totalXp: json['totalXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      completionPercentage: (json['completionPercentage'] ?? 0.0).toDouble(),
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt'])
          : DateTime.now(),
      lessonScores: Map<String, double>.from(json['lessonScores'] ?? {}),
      categoryXp: Map<String, int>.from(json['categoryXp'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedLessons': completedLessons,
      'completedUnits': completedUnits,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'completionPercentage': completionPercentage,
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'lessonScores': lessonScores,
      'categoryXp': categoryXp,
    };
  }
}
