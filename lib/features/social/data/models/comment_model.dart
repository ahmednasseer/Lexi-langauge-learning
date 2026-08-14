import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.username,
    super.avatar,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      userId: comment.userId,
      username: comment.username,
      avatar: comment.avatar,
      text: comment.text,
      createdAt: comment.createdAt,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    return CommentModel(
      id: id,
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
