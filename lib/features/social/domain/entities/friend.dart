import 'package:equatable/equatable.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
  });

  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? receiverName,
    String? receiverAvatar,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    senderAvatar,
    receiverId,
    receiverName,
    receiverAvatar,
    status,
    createdAt,
  ];
}

class Friend extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String? friendAvatar;
  final DateTime friendsSince;

  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    this.friendAvatar,
    required this.friendsSince,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    friendId,
    friendName,
    friendAvatar,
    friendsSince,
  ];
}
