import 'package:equatable/equatable.dart';

class Progress extends Equatable {
  final String userId;
  final List<String> completedLessons;
  final List<String> completedUnits;
  final int totalXp;
  final int currentLevel;
  final double completionPercentage;
  final DateTime lastActivityAt;
  final Map<String, double> lessonScores;
  final Map<String, int> categoryXp;
  final int streak;

  const Progress({
    required this.userId,
    this.completedLessons = const [],
    this.completedUnits = const [],
    this.totalXp = 0,
    this.currentLevel = 1,
    this.completionPercentage = 0.0,
    required this.lastActivityAt,
    this.lessonScores = const {},
    this.categoryXp = const {},
    this.streak = 0,
  });

  String get levelLabel {
    if (totalXp >= 10000) return 'C2';
    if (totalXp >= 5000) return 'C1';
    if (totalXp >= 2000) return 'B2';
    if (totalXp >= 1000) return 'B1';
    if (totalXp >= 500) return 'A2';
    return 'A1';
  }

  int get xpForNextLevel {
    if (totalXp >= 10000) return 0;
    if (totalXp >= 5000) return 10000;
    if (totalXp >= 2000) return 5000;
    if (totalXp >= 1000) return 2000;
    if (totalXp >= 500) return 1000;
    return 500;
  }

  double get levelProgress {
    final currentThreshold = currentLevelXp;
    final nextThreshold = xpForNextLevel;
    if (nextThreshold == currentThreshold) return 1.0;
    return (totalXp - currentThreshold) / (nextThreshold - currentThreshold);
  }

  int get currentLevelXp {
    if (totalXp >= 10000) return 10000;
    if (totalXp >= 5000) return 5000;
    if (totalXp >= 2000) return 2000;
    if (totalXp >= 1000) return 1000;
    if (totalXp >= 500) return 500;
    return 0;
  }

  bool isLessonCompleted(String lessonId) =>
      completedLessons.contains(lessonId);

  int getLessonXp(String category) {
    return categoryXp[category] ?? 0;
  }

  Progress copyWith({
    String? userId,
    List<String>? completedLessons,
    List<String>? completedUnits,
    int? totalXp,
    int? currentLevel,
    double? completionPercentage,
    DateTime? lastActivityAt,
    Map<String, double>? lessonScores,
    Map<String, int>? categoryXp,
    int? streak,
  }) {
    return Progress(
      userId: userId ?? this.userId,
      completedLessons: completedLessons ?? this.completedLessons,
      completedUnits: completedUnits ?? this.completedUnits,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lessonScores: lessonScores ?? this.lessonScores,
      categoryXp: categoryXp ?? this.categoryXp,
      streak: streak ?? this.streak,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    completedLessons,
    completedUnits,
    totalXp,
    currentLevel,
    completionPercentage,
    lastActivityAt,
     lessonScores,
     categoryXp,
     streak,
   ];
}
