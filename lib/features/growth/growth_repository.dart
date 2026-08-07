import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';

class GrowthRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getGrowthStats() async {
    try {
      final result = await _api.getGrowthStats();
      if (result.isSuccess && result.data != null) {
        return Map<String, dynamic>.from(result.data!);
      }
    } catch (_) {}
    final user = AuthService.instance.currentUser;
    return {
      'totalXp': user?.xp ?? 0,
      'streak': user?.streak ?? 0,
      'lessonsCompleted': 0,
      'wordsLearned': 0,
      'leaderboardRank': null,
      'weeklyXp': 0,
      'monthlyXp': 0,
    };
  }
}
