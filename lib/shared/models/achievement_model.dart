class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int targetValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({
    String? id, String? title, String? description, String? icon,
    AchievementType? type, int? targetValue, bool? isUnlocked, DateTime? unlockedAt,
  }) => AchievementModel(
    id: id ?? this.id, title: title ?? this.title, description: description ?? this.description,
    icon: icon ?? this.icon, type: type ?? this.type, targetValue: targetValue ?? this.targetValue,
    isUnlocked: isUnlocked ?? this.isUnlocked, unlockedAt: unlockedAt ?? this.unlockedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description, 'icon': icon,
    'type': type.name, 'targetValue': targetValue, 'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
    id: json['id'] ?? '', title: json['title'] ?? '', description: json['description'] ?? '',
    icon: json['icon'] ?? '', type: AchievementType.values.byName(json['type'] ?? 'lessons'),
    targetValue: json['targetValue'] ?? 0, isUnlocked: json['isUnlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
  );
}

enum AchievementType { lessons, words, streak, quiz, pronunciation, chat, days }
