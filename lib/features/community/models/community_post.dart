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
    type: PostType.values.firstWhere((e) => e.name == json['type'], orElse: () => PostType.discussion),
    groupId: json['groupId'],
    likes: json['likes'] ?? 0,
    commentsCount: json['commentsCount'] ?? 0,
    isLiked: json['isLiked'] ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
  );

  static List<CommunityPost> getSamplePosts() {
    return [
      CommunityPost(
        id: 'p1',
        userId: 'u1',
        userName: 'Alice',
        userLevel: 'B1',
        userXp: 2500,
        content: 'Just completed my B1 Passport! 🎓 It took me 3 months of consistent practice. Never give up!',
        type: PostType.achievement,
        likes: 45,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: 'p2',
        userId: 'u2',
        userName: 'Mohammed',
        userLevel: 'A2',
        userXp: 1200,
        content: 'Can someone explain the difference between "der", "die", and "das"? I keep getting confused!',
        type: PostType.question,
        likes: 8,
        commentsCount: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: 'p3',
        userId: 'u3',
        userName: 'Sarah',
        userLevel: 'A1',
        userXp: 450,
        content: 'Tip: I found that watching German cartoons helps a lot with learning basic vocabulary! Try "Peppa Wutz" 📺',
        type: PostType.tip,
        likes: 32,
        commentsCount: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      CommunityPost(
        id: 'p4',
        userId: 'u4',
        userName: 'Ahmed',
        userLevel: 'B2',
        userXp: 4500,
        content: 'Starting the 30 Words Challenge! Who wants to join? 💪 Day 1: learning 10 words about food.',
        type: PostType.challenge,
        likes: 28,
        commentsCount: 20,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
