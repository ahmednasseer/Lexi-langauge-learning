import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<Friend>> call(String userId) async {
    return repository.getFriends(userId);
  }
}

class GetFriendRequestsUseCase {
  final FriendRepository repository;

  GetFriendRequestsUseCase(this.repository);

  Future<List<FriendRequest>> call(String userId) async {
    return repository.getFriendRequests(userId);
  }
}

class SendFriendRequestUseCase {
  final FriendRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<FriendRequest> call({
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
  }) async {
    return repository.sendFriendRequest(
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAvatar: receiverAvatar,
    );
  }
}

class AcceptFriendRequestUseCase {
  final FriendRepository repository;

  AcceptFriendRequestUseCase(this.repository);

  Future<void> call(String requestId) async {
    return repository.acceptFriendRequest(requestId);
  }
}

class RejectFriendRequestUseCase {
  final FriendRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<void> call(String requestId) async {
    return repository.rejectFriendRequest(requestId);
  }
}

class RemoveFriendUseCase {
  final FriendRepository repository;

  RemoveFriendUseCase(this.repository);

  Future<void> call(String userId, String friendId) async {
    return repository.removeFriend(userId, friendId);
  }
}

class SearchUsersUseCase {
  final FriendRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<String>> call(String query) async {
    return repository.searchUsers(query);
  }
}
