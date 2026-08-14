import '../../core/services/api_service.dart';

class LiveLearningRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getRooms() async {
    final result = await _api.getLiveRooms();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load live rooms');
    }
    if (result.data == null) return [];
    return (result.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPartners() async {
    final result = await _api.getLivePartners();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load speaking partners');
    }
    if (result.data == null) return [];
    return (result.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final result = await _api.getLiveEvents();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load live events');
    }
    if (result.data == null) return [];
    return (result.data as List).cast<Map<String, dynamic>>();
  }
}
