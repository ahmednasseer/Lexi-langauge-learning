import '../../core/services/api_service.dart';

class AiLearningRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final result = await _api.getAiLearningProfile();
      if (result.isSuccess && result.data != null) {
        return result.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      final result = await _api.getAiLearningRecommendations();
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> getStudyPlan() async {
    try {
      final result = await _api.getAiLearningStudyPlan();
      if (result.isSuccess && result.data != null) {
        return result.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
