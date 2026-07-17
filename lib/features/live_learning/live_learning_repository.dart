import '../../services/api_service.dart';

class LiveLearningRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final result = await _api.getLiveRooms();
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getPartners() async {
    try {
      final result = await _api.getLivePartners();
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final result = await _api.getLiveEvents();
      if (result.isSuccess && result.data != null) {
        return (result.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
