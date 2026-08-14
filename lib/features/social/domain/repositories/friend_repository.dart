import '../entities/friend.dart';

abstract class FriendRepository {
  Future<List<Friend>> getFriends(String userId);
  Future<List<FriendRequest>> getFriendRequests(String userId);
  Future<List<FriendRequest>> getSentRequests(String userId);
  Future<FriendRequest> sendFriendRequest({
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
  });
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> removeFriend(String userId, String friendId);
  Future<bool> isFriend(String userId, String friendId);
  Future<List<String>> searchUsers(String query, {int limit = 20});
}
