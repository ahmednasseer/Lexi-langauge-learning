import '../../core/services/api_service.dart';
import '../community/models/community_user.dart';
import '../community/models/message.dart';

class FriendsRepository {
  final ApiService _api = ApiService();

  Future<List<CommunityUser>> getFriends() async {
    try {
      final result = await _api.getFriends();
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => CommunityUser.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _sampleFriends();
  }

  Future<List<MessageRequest>> getFriendRequests() async {
    try {
      final result = await _api.getFriendRequests();
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => MessageRequest.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> respondRequest(String requestId, bool accept) async {
    try {
      await _api.respondFriendRequest(requestId, accept);
    } catch (_) {}
  }

  List<CommunityUser> _sampleFriends() {
    final now = DateTime.now();
    return [
      CommunityUser(id: 'u1', name: 'Sarah', level: 'C1', xp: 12500, streak: 45, isFriend: true, lastActiveAt: now),
      CommunityUser(id: 'u3', name: 'Alice', level: 'B2', xp: 8700, streak: 28, isFriend: true, lastActiveAt: now),
      CommunityUser(id: 'u4', name: 'Mohammed', level: 'B1', xp: 6500, streak: 21, isFriend: true, lastActiveAt: now),
    ];
  }
}
