class CommunityUser {
  final String id;
  final String name;
  final String? avatar;
  final String level;
  final int xp;
  final int streak;
  final int rank;
  final bool isPremium;
  final bool isFriend;
  final DateTime lastActiveAt;

  const CommunityUser({
    required this.id,
    required this.name,
    this.avatar,
    required this.level,
    required this.xp,
    this.streak = 0,
    this.rank = 0,
    this.isPremium = false,
    this.isFriend = false,
    required this.lastActiveAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'level': level,
    'xp': xp,
    'streak': streak,
    'rank': rank,
    'isPremium': isPremium,
    'isFriend': isFriend,
    'lastActiveAt': lastActiveAt.toIso8601String(),
  };

  factory CommunityUser.fromJson(Map<String, dynamic> json) => CommunityUser(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    avatar: json['avatar'],
    level: json['level'] ?? 'A1',
    xp: json['xp'] ?? 0,
    streak: json['streak'] ?? 0,
    rank: json['rank'] ?? 0,
    isPremium: json['isPremium'] ?? false,
    isFriend: json['isFriend'] ?? false,
    lastActiveAt: json['lastActiveAt'] != null
        ? DateTime.parse(json['lastActiveAt'])
        : DateTime.now(),
  );

  static List<CommunityUser> getLeaderboard() {
    return [];
  }
}
