import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? avatar;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.avatar,
    required this.text,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? avatar,
    String? text,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    username,
    avatar,
    text,
    createdAt,
  ];
}
