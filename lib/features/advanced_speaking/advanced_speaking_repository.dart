import '../../core/services/api_service.dart';

class AdvancedSpeakingRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getChallenges() async {
    final result = await _api.getSpeakingChallenges();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load speaking challenges');
    }
    return (result.data as List).cast<Map<String, dynamic>>();
  }
}
