import '../../core/services/api_service.dart';

class GrowthRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getGrowthStats() async {
    final result = await _api.getGrowthStats();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load growth stats');
    }
    return Map<String, dynamic>.from(result.data!);
  }
}
