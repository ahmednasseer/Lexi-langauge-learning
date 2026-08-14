import '../../core/services/api_service.dart';
import 'package:lexi/features/community/models/community_user.dart';

class LeaderboardRepository {
  final ApiService _api = ApiService();
  Future<List<CommunityUser>> getLeaderboard({String period = 'weekly'}) async {
    final result = await _api.getLeaderboard(period: period);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load leaderboard');
    }
    if (result.data == null) return [];
    return (result.data as List)
        .map((e) => CommunityUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
