import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    super.authorAvatar,
    required super.content,
    required super.createdAt,
    super.likesCount,
    super.commentsCount,
    super.isLikedByCurrentUser,
  });

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorId: post.authorId,
      authorName: post.authorName,
      authorAvatar: post.authorAvatar,
      content: post.content,
      createdAt: post.createdAt,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      isLikedByCurrentUser: post.isLikedByCurrentUser,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
    return PostModel(
      id: id,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }
}
