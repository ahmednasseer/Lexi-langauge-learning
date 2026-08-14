class XpSystem {
  static const int xpPerLesson = 50;
  static const int xpPerQuiz = 25;
  static const int xpPerChallenge = 100;
  static const int streakBonus = 10;

  static int calculateLessonXp(double score) {
    final base = xpPerLesson;
    final bonus = (score * 50).toInt();
    return base + bonus;
  }

  static int calculateQuizXp(double score, int questions) {
    final correct = (score * questions).toInt();
    return correct * (xpPerQuiz ~/ questions);
  }

  static int calculateStreakBonus(int streak) {
    if (streak >= 30) return streakBonus * 3;
    if (streak >= 7) return streakBonus * 2;
    return streakBonus;
  }

  static String getLevelTitle(int userLevel) {
    const levels = {
      100: 'Language Master',
      90: 'Sage',
      80: 'Polyglot',
      70: 'Linguist',
      60: 'Master',
      50: 'Scholar',
      40: 'Expert',
      30: 'Advanced',
      20: 'Intermediate',
      15: 'Learner',
      10: 'Explorer',
      5: 'Novice',
      1: 'Beginner',
    };
    for (final entry in levels.entries) {
      if (userLevel >= entry.key) return entry.value;
    }
    return 'Beginner';
  }
}
