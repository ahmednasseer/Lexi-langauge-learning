import '../../services/api_service.dart';

class AdvancedSpeakingRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getChallenges() async {
    try {
      final result = await _api.getSpeakingChallenges();
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
