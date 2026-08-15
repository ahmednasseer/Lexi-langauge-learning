import 'dart:developer';
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
    log('LESSONS API RESULT: isSuccess=${result.isSuccess}, data=${result.data?.length ?? 0}, error=${result.error}');
    if (result.isSuccess && result.data != null) {
      try {
        final lessons = result.data!
            .map((e) {
              log('PARSING ITEM: ${e.runtimeType}');
              return LessonModel.fromJson(e as Map<String, dynamic>);
            })
            .toList();
        log('LESSONS PARSED: ${lessons.length} lessons');
        return lessons;
      } catch (e, stack) {
        log('LESSONS PARSE ERROR: $e\n$stack');
        throw Exception('Failed to parse lessons: $e');
      }
    }
    final errorMsg = result.error ?? 'Failed to load lessons';
    log('LESSONS ERROR: $errorMsg');
    throw Exception(errorMsg);
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
