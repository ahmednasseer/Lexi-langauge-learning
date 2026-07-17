import '../../services/api_service.dart';
import '../../data/german_content.dart';
import 'models/lesson_model.dart';

class LessonRepository {
  final ApiService _api = ApiService();

  Future<List<LessonModel>> getLessons(String level, String category, String language) async {
    try {
      final result = await _api.getLessons(language.toLowerCase(), level: level, category: category);
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => LessonModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    // Local fallback
    return GermanContent.getLessonsByCategory(level, category)
        .where((l) => l.language == language)
        .toList();
  }

  Future<List<LessonModel>> getAllLessons(String language) async {
    try {
      final result = await _api.getLessons(language.toLowerCase());
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => LessonModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return GermanContent.getAllLessons().where((l) => l.language == language).toList();
  }

  Future<LessonModel?> getLessonDetail(String lessonId, String language) async {
    try {
      final result = await _api.getLessonDetail(lessonId);
      if (result.isSuccess) {
        return LessonModel.fromJson(result.data!);
      }
    } catch (_) {}
    final local = GermanContent.getAllLessons().where((l) => l.language == language);
    try {
      return local.firstWhere((l) => l.id == lessonId);
    } catch (_) {
      return null;
    }
  }

  Future<void> completeLesson(String lessonId, double score, int timeSpent) async {
    try {
      await _api.completeLesson(lessonId, score, timeSpent);
    } catch (_) {
      // Offline: track locally only
    }
  }
}
