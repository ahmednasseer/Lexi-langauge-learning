import '../../core/services/api_service.dart';
import 'models/lesson_model.dart';

class LessonRepository {
  final ApiService _api = ApiService();

  Future<List<LessonModel>> getLessons(
    String level,
    String category,
    String language,
  ) async {
    final result = await _api.getLessons(
      language.toLowerCase(),
      level: level,
      category: category,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!
          .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(result.error ?? 'Failed to load lessons');
  }

  Future<List<LessonModel>> getAllLessons(String language) async {
    final result = await _api.getLessons(language.toLowerCase());
    if (result.isSuccess && result.data != null) {
      return result.data!
          .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(result.error ?? 'Failed to load lessons');
  }

  Future<LessonModel?> getLessonDetail(String lessonId, String language) async {
    final result = await _api.getLessonDetail(lessonId);
    if (result.isSuccess && result.data != null) {
      return LessonModel.fromJson(result.data!);
    }
    if (result.error != null) {
      throw Exception(result.error);
    }
    return null;
  }

  Future<Map<String, dynamic>?> completeLesson(
    String lessonId,
    double score,
    int timeSpent,
  ) async {
    final result = await _api.completeLesson(lessonId, score, timeSpent);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to complete lesson');
    }
    return result.data;
  }
}
