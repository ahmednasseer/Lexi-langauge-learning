import '../../core/services/api_service.dart';

class GoetheRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getLevels() async {
    try {
      final result = await _api.getGoetheLevels();
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getExams(String level) async {
    try {
      final result = await _api.getGoetheExams(level);
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> analyzeWriting(String text) async {
    try {
      final result = await _api.analyzeGoetheWriting(text);
      if (result.isSuccess && result.data != null) {
        return result.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
