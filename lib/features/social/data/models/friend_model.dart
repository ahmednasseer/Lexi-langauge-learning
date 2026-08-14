import '../../domain/entities/friend.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.receiverId,
    required super.receiverName,
    super.receiverAvatar,
    super.status,
    required super.createdAt,
  });

  factory FriendRequestModel.fromEntity(FriendRequest request) {
    return FriendRequestModel(
      id: request.id,
      senderId: request.senderId,
      senderName: request.senderName,
      senderAvatar: request.senderAvatar,
      receiverId: request.receiverId,
      receiverName: request.receiverName,
      receiverAvatar: request.receiverAvatar,
      status: request.status,
      createdAt: request.createdAt,
    );
  }

  factory FriendRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return FriendRequestModel(
      id: id,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverAvatar: json['receiverAvatar'],
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FriendModel extends Friend {
  const FriendModel({
    required super.id,
    required super.userId,
    required super.friendId,
    required super.friendName,
    super.friendAvatar,
    required super.friendsSince,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json, String id) {
    return FriendModel(
      id: id,
      userId: json['userId'] ?? '',
      friendId: json['friendId'] ?? '',
      friendName: json['friendName'] ?? '',
      friendAvatar: json['friendAvatar'],
      friendsSince: json['friendsSince'] != null
          ? DateTime.parse(json['friendsSince'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatar': friendAvatar,
      'friendsSince': friendsSince.toIso8601String(),
    };
  }
}
