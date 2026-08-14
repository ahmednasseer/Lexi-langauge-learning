import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';

/// API-backed implementation. Lesson completion, XP and level are computed and
/// stored server-side (NestJS + PostgreSQL). Client-side XP write methods are
/// no-ops because the server is authoritative.
class ProgressRepositoryImpl implements ProgressRepository {
  final ApiService _api;

  ProgressRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<Progress?> getProgress(String userId) async {
    final statsResult = await _api.getStats();
    if (!statsResult.isSuccess || statsResult.data == null) {
      return null;
    }
    final data = statsResult.data!;
    final totalXp = data['totalXp'] as int? ?? 0;
    final completionRate =
        (data['completionRate'] as num?)?.toDouble() ?? 0.0;

    final completed = await getCompletedLessons(userId);

    return Progress(
      userId: userId,
      completedLessons: completed,
      totalXp: totalXp,
      currentLevel: int.tryParse(data['level']?.toString().substring(1) ?? '') ?? 1,
      completionPercentage: completionRate,
      streak: data['streak'] as int? ?? 0,
      lastActivityAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveProgress(Progress progress) {
    throw UnsupportedError(
      'Progress is managed server-side. Use completeLesson via the API.',
    );
  }

  @override
  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required String category,
    required double score,
    required int xpEarned,
  }) async {
    final result = await _api.completeLesson(lessonId, score, 0);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to save progress');
    }
  }

  @override
  Future<void> addXp(String userId, int amount) async {
    // XP is awarded server-side (lesson completion, mission rewards).
    // No client-side XP mutation.
  }

  @override
  Future<void> updateLessonScore(
    String userId,
    String lessonId,
    double score,
  ) async {
    // Best-effort no-op: the server records the score on lesson completion.
  }

  @override
  Future<List<String>> getCompletedLessons(String userId) async {
    final result = await _api.getProgressHistory();
    if (!result.isSuccess || result.data == null) return [];
    return result.data!
        .where((raw) {
          final map = (raw as Map).cast<String, dynamic>();
          return map['completed'] == true;
        })
        .map<String>((raw) {
          final map = raw as Map<String, dynamic>;
          final lesson = map['lesson'] is Map<String, dynamic>
              ? (map['lesson'] as Map).cast<String, dynamic>()
              : const <String, dynamic>{};
          return lesson['id'] as String? ?? map['lessonId'] as String? ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> resetProgress(String userId) async {
    // Best-effort no-op: there is no client-accessible reset endpoint.
  }
}