import '../../core/services/api_service.dart';
import 'models/community_user.dart';

class LeaderboardRepository {
  final ApiService _api = ApiService();

  Future<List<CommunityUser>> getLeaderboard({String period = 'weekly'}) async {
    try {
      final result = await _api.getLeaderboard(period: period);
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!
            .map((e) => CommunityUser.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return CommunityUser.getLeaderboard();
  }
}
