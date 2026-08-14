class XpService {
  static const int baseLessonXp = 50;
  static const int baseQuizXp = 30;
  static const int perfectScoreBonus = 20;
  static const int passScoreBonus = 10;
  static const double passThreshold = 0.7;
  static const double perfectThreshold = 0.9;

  static int calculateLessonXp({
    required bool isCompleted,
    double quizScore = 0.0,
    int baseReward = baseLessonXp,
  }) {
    if (!isCompleted) return 0;

    int xp = baseReward;

    if (quizScore >= perfectThreshold) {
      xp += perfectScoreBonus;
    } else if (quizScore >= passThreshold) {
      xp += passScoreBonus;
    }

    return xp;
  }

  static int calculateQuizXp({
    required int correctAnswers,
    required int totalQuestions,
    int baseReward = baseQuizXp,
  }) {
    if (totalQuestions == 0) return 0;
    final score = correctAnswers / totalQuestions;
    int xp = (baseReward * score).round();
    if (score >= perfectThreshold) xp += perfectScoreBonus;
    return xp;
  }

  static int calculateStreakBonus(int currentStreak) {
    if (currentStreak <= 0) return 0;
    if (currentStreak >= 30) return 50;
    if (currentStreak >= 14) return 30;
    if (currentStreak >= 7) return 15;
    if (currentStreak >= 3) return 5;
    return 0;
  }
}
