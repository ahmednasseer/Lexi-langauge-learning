import '../../core/services/api_service.dart';

class AiLearningRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    final result = await _api.getAiLearningProfile();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load AI learning profile');
    }
    return result.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getRecommendations() async {
    final result = await _api.getAiLearningRecommendations();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load recommendations');
    }
    return (result.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getStudyPlan() async {
    final result = await _api.getAiLearningStudyPlan();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load study plan');
    }
    return result.data as Map<String, dynamic>;
  }
}
