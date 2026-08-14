import '../entities/progress.dart';

abstract class ProgressRepository {
  Future<Progress?> getProgress(String userId);
  Future<void> saveProgress(Progress progress);
  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required String category,
    required double score,
    required int xpEarned,
  });
  Future<void> addXp(String userId, int amount);
  Future<void> updateLessonScore(String userId, String lessonId, double score);
  Future<List<String>> getCompletedLessons(String userId);
  Future<void> resetProgress(String userId);
}
