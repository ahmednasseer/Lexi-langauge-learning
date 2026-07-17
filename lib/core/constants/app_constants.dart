class AppConstants {
  AppConstants._();

  static const String appName = 'Lexi';
  static const String appTagline = 'Learn Languages with AI';

  static const String apiBaseUrl = 'http://10.0.2.2:3000';

  static const int maxFreeAiMessages = 10;
  static const int maxFreeLessons = 5;
  static const int xpPerLesson = 50;
  static const int xpPerQuiz = 25;
  static const int xpPerChallenge = 100;
  static const int streakBonusXp = 10;
  static const int dailyGoalDefault = 50;

  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 500);

  static const List<String> supportedLanguages = [
    'English', 'Arabic', 'French', 'Spanish', 'German',
    'Italian', 'Portuguese', 'Japanese', 'Korean', 'Chinese',
    'Turkish', 'Hindi',
  ];

  static const Map<String, String> languageFlags = {
    'English': '🇬🇧', 'Arabic': '🇸🇦', 'French': '🇫🇷', 'Spanish': '🇪🇸',
    'German': '🇩🇪', 'Italian': '🇮🇹', 'Portuguese': '🇵🇹', 'Japanese': '🇯🇵',
    'Korean': '🇰🇷', 'Chinese': '🇨🇳', 'Turkish': '🇹🇷', 'Hindi': '🇮🇳',
  };

  static const List<String> learningGoals = [
    'Travel', 'Work', 'Study', 'Conversation', 'Hobby',
  ];

  static const List<String> goalIcons = ['✈️', '💼', '📚', '💬', '🎨'];

  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const Map<String, String> levelNames = {
    'A1': 'Beginner', 'A2': 'Elementary', 'B1': 'Intermediate',
    'B2': 'Upper Intermediate', 'C1': 'Advanced', 'C2': 'Mastery',
  };

  static const Map<int, String> userLevelTitles = {
    100: 'Language Master', 90: 'Sage', 80: 'Polyglot',
    70: 'Linguist', 60: 'Master', 50: 'Scholar',
    40: 'Expert', 30: 'Advanced', 20: 'Intermediate',
    15: 'Learner', 10: 'Explorer', 5: 'Novice', 1: 'Beginner',
  };
}
