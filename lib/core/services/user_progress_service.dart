class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  Future<void> initialize() async {}

  Future<void> completeLesson(String lessonId) async {
    // Lesson completion is handled by the backend via ProgressRepository.completeLesson.
    // This client-side method is retained for backward compatibility but is a no-op.
  }

  List<String> getCompletedLessons() {
    return [];
  }

  Future<void> saveQuizScore(String lessonId, int score, int total) async {
    // Quiz scores are persisted by the backend via lesson completion.
  }

  Future<void> addXp(int amount) async {
    // No-op: XP is awarded server-side (lesson completion, mission rewards).
  }

  int getXp() {
    // XP is server-authoritative via ProgressRepository / AuthService.
    return 0;
  }

  int getStreak() {
    // Streak is server-authoritative via ProgressRepository / StreakRepository.
    return 0;
  }

  bool isLessonCompleted(String lessonId) {
    return false;
  }

  int getCompletedLessonsCount() {
    return 0;
  }
}
