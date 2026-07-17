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
    lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : DateTime.now(),
  );

  static List<CommunityUser> getLeaderboard() {
    final now = DateTime.now();
    return [
      CommunityUser(id: 'u1', name: 'Sarah', level: 'C1', xp: 12500, streak: 45, rank: 1, isPremium: true, lastActiveAt: now),
      CommunityUser(id: 'u2', name: 'Ahmed', level: 'B2', xp: 9800, streak: 32, rank: 2, isPremium: true, lastActiveAt: now),
      CommunityUser(id: 'u3', name: 'Alice', level: 'B2', xp: 8700, streak: 28, rank: 3, isPremium: false, lastActiveAt: now),
      CommunityUser(id: 'u4', name: 'Mohammed', level: 'B1', xp: 6500, streak: 21, rank: 4, isPremium: false, lastActiveAt: now),
      CommunityUser(id: 'u5', name: 'Emma', level: 'B1', xp: 5200, streak: 18, rank: 5, isPremium: false, lastActiveAt: now),
      CommunityUser(id: 'u6', name: 'John', level: 'A2', xp: 3800, streak: 14, rank: 6, isPremium: false, lastActiveAt: now),
      CommunityUser(id: 'u7', name: 'Maria', level: 'A2', xp: 2900, streak: 10, rank: 7, isPremium: false, lastActiveAt: now),
      CommunityUser(id: 'u8', name: 'David', level: 'A1', xp: 1500, streak: 7, rank: 8, isPremium: false, lastActiveAt: now),
    ];
  }
}
