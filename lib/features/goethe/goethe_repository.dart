import '../../core/services/api_service.dart';
import 'models/exam_models.dart';

class GoetheRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getLevels() async {
    final result = await _api.getGoetheLevels();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load exam levels');
    }
    return (result.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getExams(String level) async {
    final result = await _api.getGoetheExams(level);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load exams');
    }
    return (result.data as List).cast<Map<String, dynamic>>();
  }

  Future<WritingEvaluation> analyzeWriting(
    String text,
    String level,
    String prompt,
  ) async {
    final result = await _api.analyzeGoetheWriting(text, level: level, prompt: prompt);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to analyze writing');
    }
    return WritingEvaluation.fromJson(
      Map<String, dynamic>.from(result.data as Map),
    );
  }

  Future<SpeakingEvaluation> analyzeSpeaking(
    String transcript,
    String level,
  ) async {
    final result = await _api.analyzeGoetheSpeaking(transcript, level: level);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to analyze speaking');
    }
    return SpeakingEvaluation.fromJson(
      Map<String, dynamic>.from(result.data as Map),
    );
  }
}
