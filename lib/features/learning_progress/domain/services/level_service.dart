class LevelService {
  static const Map<String, int> levelThresholds = {
    'A1': 0,
    'A2': 500,
    'B1': 1000,
    'B2': 2000,
    'C1': 5000,
    'C2': 10000,
  };

  static const List<String> levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static String calculateLevel(int totalXp) {
    if (totalXp >= 10000) return 'C2';
    if (totalXp >= 5000) return 'C1';
    if (totalXp >= 2000) return 'B2';
    if (totalXp >= 1000) return 'B1';
    if (totalXp >= 500) return 'A2';
    return 'A1';
  }

  static int getLevelNumber(String level) {
    return levelOrder.indexOf(level) + 1;
  }

  static int xpForNextLevel(int currentXp) {
    if (currentXp >= 10000) return 0;
    if (currentXp >= 5000) return 10000;
    if (currentXp >= 2000) return 5000;
    if (currentXp >= 1000) return 2000;
    if (currentXp >= 500) return 1000;
    return 500;
  }

  static int currentLevelBaseXp(String level) {
    return levelThresholds[level] ?? 0;
  }

  static double levelProgress(int totalXp) {
    final currentLevel = calculateLevel(totalXp);
    final currentBase = currentLevelBaseXp(currentLevel);
    final nextXp = xpForNextLevel(totalXp);
    if (nextXp == currentBase) return 1.0;
    return (totalXp - currentBase) / (nextXp - currentBase);
  }

  static bool hasLeveledUp(int previousXp, int newXp) {
    return calculateLevel(previousXp) != calculateLevel(newXp);
  }
}
