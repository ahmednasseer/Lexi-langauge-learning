import '../../../core/constants/app_assets.dart';

class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int requirement;
  final int rewardXp;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String? assetPath;

  const AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.requirement = 0,
    this.rewardXp = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.assetPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'category': category,
    'requirement': requirement,
    'rewardXp': rewardXp,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementBadge.fromJson(Map<String, dynamic> json) => AchievementBadge(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '🏆',
    category: json['category'] ?? 'general',
    requirement: json['requirement'] ?? 0,
    rewardXp: json['rewardXp'] ?? 0,
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
  );

  static List<AchievementBadge> getAllBadges() {
    return [
      // Learning badges
      AchievementBadge(id: 'b1', name: 'First Lesson', description: 'Complete your first lesson', icon: '🎯', category: 'learning', requirement: 1, rewardXp: 50, assetPath: AppAssets.achievementFirstWord),
      AchievementBadge(id: 'b2', name: '100 Words', description: 'Learn 100 vocabulary words', icon: '📚', category: 'vocabulary', requirement: 100, rewardXp: 100, assetPath: AppAssets.achievement100Words),
      const AchievementBadge(id: 'b3', name: '500 Words', description: 'Learn 500 vocabulary words', icon: '📖', category: 'vocabulary', requirement: 500, rewardXp: 250),
      const AchievementBadge(id: 'b4', name: '1000 Words', description: 'Learn 1000 vocabulary words', icon: '🎓', category: 'vocabulary', requirement: 1000, rewardXp: 500),

      // Streak badges
      AchievementBadge(id: 'b5', name: '7 Day Streak', description: 'Maintain a 7-day streak', icon: '🔥', category: 'streak', requirement: 7, rewardXp: 100, assetPath: AppAssets.achievementStreak7),
      AchievementBadge(id: 'b6', name: '30 Day Streak', description: 'Maintain a 30-day streak', icon: '💪', category: 'streak', requirement: 30, rewardXp: 300, assetPath: AppAssets.achievementStreak30),
      const AchievementBadge(id: 'b7', name: '100 Day Streak', description: 'Maintain a 100-day streak', icon: '👑', category: 'streak', requirement: 100, rewardXp: 1000),

      // Speaking badges
      const AchievementBadge(id: 'b8', name: 'First Conversation', description: 'Complete your first AI conversation', icon: '🤖', category: 'speaking', requirement: 1, rewardXp: 50),
      const AchievementBadge(id: 'b9', name: '50 Speaking Sessions', description: 'Complete 50 speaking sessions', icon: '🎤', category: 'speaking', requirement: 50, rewardXp: 500),
      const AchievementBadge(id: 'b10', name: 'Perfect Pronunciation', description: 'Get 100% pronunciation score', icon: '✨', category: 'speaking', requirement: 1, rewardXp: 200),

      // XP badges
      const AchievementBadge(id: 'b11', name: '1000 XP', description: 'Earn 1000 total XP', icon: '⭐', category: 'xp', requirement: 1000, rewardXp: 100),
      const AchievementBadge(id: 'b12', name: '5000 XP', description: 'Earn 5000 total XP', icon: '🌟', category: 'xp', requirement: 5000, rewardXp: 500),
      const AchievementBadge(id: 'b13', name: '10000 XP', description: 'Earn 10000 total XP', icon: '💫', category: 'xp', requirement: 10000, rewardXp: 1000),

      // Level badges
      const AchievementBadge(id: 'b14', name: 'A1 Complete', description: 'Complete A1 level', icon: '🏅', category: 'level', requirement: 1, rewardXp: 200),
      const AchievementBadge(id: 'b15', name: 'A2 Complete', description: 'Complete A2 level', icon: '🏅', category: 'level', requirement: 2, rewardXp: 300),
      const AchievementBadge(id: 'b16', name: 'B1 Complete', description: 'Complete B1 level', icon: '🏅', category: 'level', requirement: 3, rewardXp: 500),
      const AchievementBadge(id: 'b17', name: 'B2 Complete', description: 'Complete B2 level', icon: '🏅', category: 'level', requirement: 4, rewardXp: 750),
      const AchievementBadge(id: 'b18', name: 'C1 Complete', description: 'Complete C1 level', icon: '🏅', category: 'level', requirement: 5, rewardXp: 1000),
      const AchievementBadge(id: 'b19', name: 'C2 Complete', description: 'Complete C2 level', icon: '🏅', category: 'level', requirement: 6, rewardXp: 2000),

      // Special badges
      const AchievementBadge(id: 'b20', name: 'Early Bird', description: 'Study before 7 AM', icon: '🌅', category: 'special', requirement: 1, rewardXp: 50),
      const AchievementBadge(id: 'b21', name: 'Night Owl', description: 'Study after 10 PM', icon: '🦉', category: 'special', requirement: 1, rewardXp: 50),
      const AchievementBadge(id: 'b22', name: 'Daily Champion', description: 'Complete all daily missions', icon: '🏆', category: 'special', requirement: 1, rewardXp: 200),
      const AchievementBadge(id: 'b23', name: 'Grammar Master', description: 'Complete 10 grammar lessons', icon: '📝', category: 'grammar', requirement: 10, rewardXp: 300),
      const AchievementBadge(id: 'b24', name: 'Listening Expert', description: 'Complete 20 listening exercises', icon: '🎧', category: 'listening', requirement: 20, rewardXp: 300),
    ];
  }

  static List<AchievementBadge> getBadgesByCategory(String category) {
    return getAllBadges().where((b) => b.category == category).toList();
  }
}
