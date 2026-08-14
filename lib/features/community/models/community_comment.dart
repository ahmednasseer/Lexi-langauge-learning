class CommunityComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String userLevel;
  final String text;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userLevel,
    required this.text,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  CommunityComment copyWith({int? likes, bool? isLiked}) {
    return CommunityComment(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userLevel: userLevel,
      text: text,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'userLevel': userLevel,
    'text': text,
    'likes': likes,
    'isLiked': isLiked,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      CommunityComment(
        id: json['id'] ?? '',
        postId: json['postId'] ?? '',
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        userAvatar: json['userAvatar'],
        userLevel: json['userLevel'] ?? 'A1',
        text: json['text'] ?? '',
        likes: json['likes'] ?? 0,
        isLiked: json['isLiked'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
