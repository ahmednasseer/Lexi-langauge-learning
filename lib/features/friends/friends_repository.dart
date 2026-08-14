import '../../core/services/api_service.dart';
import '../community/models/community_user.dart';
import '../community/models/message.dart';

class FriendsRepository {
  final ApiService _api = ApiService();

  Future<List<CommunityUser>> getFriends() async {
    try {
      final result = await _api.getFriends();
      if (result.isSuccess && result.data != null) {
        return (result.data as List)
            .map((e) => CommunityUser.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (result.error != null) {
        throw Exception(result.error);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load friends: $e');
    }
  }

  Future<List<MessageRequest>> getFriendRequests() async {
    try {
      final result = await _api.getFriendRequests();
      if (result.isSuccess && result.data != null) {
        return (result.data as List)
            .map((e) => MessageRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (result.error != null) {
        throw Exception(result.error);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load friend requests: $e');
    }
  }

  Future<void> respondRequest(String requestId, bool accept) async {
    final result = await _api.respondFriendRequest(requestId, accept);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to respond to friend request');
    }
  }
}
