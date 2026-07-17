class UserLevel {
  final int level;
  final String title;
  final int minXp;
  final int maxXp;
  final LevelReward reward;

  const UserLevel({
    required this.level,
    required this.title,
    required this.minXp,
    required this.maxXp,
    required this.reward,
  });

  double progress(int currentXp) {
    if (currentXp < minXp) return 0.0;
    if (currentXp >= maxXp) return 1.0;
    return (currentXp - minXp) / (maxXp - minXp);
  }

  bool isUnlocked(int currentXp) => currentXp >= minXp;

  Map<String, dynamic> toJson() => {
    'level': level,
    'title': title,
    'minXp': minXp,
    'maxXp': maxXp,
    'reward': reward.toJson(),
  };

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
    level: json['level'] ?? 1,
    title: json['title'] ?? '',
    minXp: json['minXp'] ?? 0,
    maxXp: json['maxXp'] ?? 100,
    reward: LevelReward.fromJson(json['reward'] ?? {}),
  );
}

class LevelReward {
  final int gems;
  final String? frameId;
  final String? badgeId;
  final String? themeId;

  const LevelReward({
    required this.gems,
    this.frameId,
    this.badgeId,
    this.themeId,
  });

  Map<String, dynamic> toJson() => {
    'gems': gems,
    'frameId': frameId,
    'badgeId': badgeId,
    'themeId': themeId,
  };

  factory LevelReward.fromJson(Map<String, dynamic> json) => LevelReward(
    gems: json['gems'] ?? 0,
    frameId: json['frameId'],
    badgeId: json['badgeId'],
    themeId: json['themeId'],
  );
}

class AvatarFrame {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final int requiredLevel;
  final bool isUnlocked;
  final bool isActive;

  const AvatarFrame({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.requiredLevel,
    this.isUnlocked = false,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'assetPath': assetPath,
    'requiredLevel': requiredLevel,
    'isUnlocked': isUnlocked,
    'isActive': isActive,
  };

  factory AvatarFrame.fromJson(Map<String, dynamic> json) => AvatarFrame(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    assetPath: json['assetPath'] ?? '',
    requiredLevel: json['requiredLevel'] ?? 1,
    isUnlocked: json['isUnlocked'] ?? false,
    isActive: json['isActive'] ?? false,
  );
}

class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeRarity rarity;
  final DateTime? unlockedAt;
  final bool isHidden;

  const AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.rarity = BadgeRarity.common,
    this.unlockedAt,
    this.isHidden = false,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'rarity': rarity.name,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'isHidden': isHidden,
  };

  factory AchievementBadge.fromJson(Map<String, dynamic> json) => AchievementBadge(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '',
    rarity: BadgeRarity.values.firstWhere(
      (r) => r.name == json['rarity'],
      orElse: () => BadgeRarity.common,
    ),
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    isHidden: json['isHidden'] ?? false,
  );
}

enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

extension BadgeRarityExtension on BadgeRarity {
  String get displayName {
    switch (this) {
      case BadgeRarity.common:
        return 'Common';
      case BadgeRarity.uncommon:
        return 'Uncommon';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Epic';
      case BadgeRarity.legendary:
        return 'Legendary';
    }
  }

  int get colorValue {
    switch (this) {
      case BadgeRarity.common:
        return 0xFF9E9E9E;
      case BadgeRarity.uncommon:
        return 0xFF4CAF50;
      case BadgeRarity.rare:
        return 0xFF2196F3;
      case BadgeRarity.epic:
        return 0xFF9C27B0;
      case BadgeRarity.legendary:
        return 0xFFFF9800;
    }
  }
}

class UserProgress {
  final int totalXp;
  final int currentLevel;
  final int gems;
  final int streak;
  final List<String> unlockedFrames;
  final List<String> unlockedBadges;
  final String? activeFrameId;
  final Map<String, dynamic> stats;

  const UserProgress({
    required this.totalXp,
    required this.currentLevel,
    required this.gems,
    required this.streak,
    this.unlockedFrames = const [],
    this.unlockedBadges = const [],
    this.activeFrameId,
    this.stats = const {},
  });

  UserProgress copyWith({
    int? totalXp,
    int? currentLevel,
    int? gems,
    int? streak,
    List<String>? unlockedFrames,
    List<String>? unlockedBadges,
    String? activeFrameId,
    Map<String, dynamic>? stats,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      activeFrameId: activeFrameId ?? this.activeFrameId,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalXp': totalXp,
    'currentLevel': currentLevel,
    'gems': gems,
    'streak': streak,
    'unlockedFrames': unlockedFrames,
    'unlockedBadges': unlockedBadges,
    'activeFrameId': activeFrameId,
    'stats': stats,
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    totalXp: json['totalXp'] ?? 0,
    currentLevel: json['currentLevel'] ?? 1,
    gems: json['gems'] ?? 0,
    streak: json['streak'] ?? 0,
    unlockedFrames: List<String>.from(json['unlockedFrames'] ?? []),
    unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
    activeFrameId: json['activeFrameId'],
    stats: Map<String, dynamic>.from(json['stats'] ?? {}),
  );

  factory UserProgress.empty() => const UserProgress(
    totalXp: 0,
    currentLevel: 1,
    gems: 0,
    streak: 0,
  );
}
