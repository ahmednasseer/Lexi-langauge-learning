enum PostType { achievement, question, challenge, discussion, tip }

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String userLevel;
  final int userXp;
  final String content;
  final PostType type;
  final String? groupId;
  final int likes;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userLevel,
    required this.userXp,
    required this.content,
    required this.type,
    this.groupId,
    this.likes = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  CommunityPost copyWith({int? likes, bool? isLiked, int? commentsCount}) {
    return CommunityPost(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userLevel: userLevel,
      userXp: userXp,
      content: content,
      type: type,
      groupId: groupId,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'userLevel': userLevel,
    'userXp': userXp,
    'content': content,
    'type': type.name,
    'groupId': groupId,
    'likes': likes,
    'commentsCount': commentsCount,
    'isLiked': isLiked,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    userAvatar: json['userAvatar'],
    userLevel: json['userLevel'] ?? 'A1',
    userXp: json['userXp'] ?? 0,
    content: json['content'] ?? '',
    type: PostType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => PostType.discussion,
    ),
    groupId: json['groupId'],
    likes: json['likes'] ?? 0,
    commentsCount: json['commentsCount'] ?? 0,
    isLiked: json['isLiked'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

}
