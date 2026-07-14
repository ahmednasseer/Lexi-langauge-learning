class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String nativeLanguage;
  final String learningLanguage;
  final String level;
  final int xp;
  final int streak;
  final int totalXp;
  final String? learningGoal;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final int dailyXp;
  final int dailyGoal;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.nativeLanguage = '',
    this.learningLanguage = '',
    this.level = 'A1',
    this.xp = 0,
    this.streak = 0,
    this.totalXp = 0,
    this.learningGoal,
    this.isPremium = false,
    required this.createdAt,
    this.lastActiveAt,
    this.dailyXp = 0,
    this.dailyGoal = 50,
  });

  factory UserModel.empty() => UserModel(id: '', name: '', email: '', createdAt: DateTime.now());

  int get userLevel {
    if (totalXp >= 10000) return 100;
    if (totalXp >= 5000) return 50;
    if (totalXp >= 2000) return 30;
    if (totalXp >= 1000) return 20;
    if (totalXp >= 500) return 10;
    if (totalXp >= 200) return 5;
    if (totalXp >= 50) return 2;
    return 1;
  }

  String get levelTitle {
    const levels = {
      100: 'Language Master', 90: 'Sage', 80: 'Polyglot', 70: 'Linguist',
      60: 'Master', 50: 'Scholar', 40: 'Expert', 30: 'Advanced',
      20: 'Intermediate', 15: 'Learner', 10: 'Explorer', 5: 'Novice', 1: 'Beginner',
    };
    for (final entry in levels.entries) {
      if (userLevel >= entry.key) return entry.value;
    }
    return 'Beginner';
  }

  double get dailyProgress => dailyGoal > 0 ? dailyXp / dailyGoal : 0.0;

  UserModel copyWith({
    String? id, String? name, String? email, String? photoUrl,
    String? nativeLanguage, String? learningLanguage, String? level,
    int? xp, int? streak, int? totalXp, String? learningGoal,
    bool? isPremium, DateTime? createdAt, DateTime? lastActiveAt,
    int? dailyXp, int? dailyGoal,
  }) => UserModel(
    id: id ?? this.id, name: name ?? this.name, email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl, nativeLanguage: nativeLanguage ?? this.nativeLanguage,
    learningLanguage: learningLanguage ?? this.learningLanguage, level: level ?? this.level,
    xp: xp ?? this.xp, streak: streak ?? this.streak, totalXp: totalXp ?? this.totalXp,
    learningGoal: learningGoal ?? this.learningGoal, isPremium: isPremium ?? this.isPremium,
    createdAt: createdAt ?? this.createdAt, lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    dailyXp: dailyXp ?? this.dailyXp, dailyGoal: dailyGoal ?? this.dailyGoal,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'photoUrl': photoUrl,
    'nativeLanguage': nativeLanguage, 'learningLanguage': learningLanguage,
    'level': level, 'xp': xp, 'streak': streak, 'totalXp': totalXp,
    'learningGoal': learningGoal, 'isPremium': isPremium,
    'createdAt': createdAt.toIso8601String(), 'lastActiveAt': lastActiveAt?.toIso8601String(),
    'dailyXp': dailyXp, 'dailyGoal': dailyGoal,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '', name: json['name'] ?? '', email: json['email'] ?? '',
    photoUrl: json['photoUrl'], nativeLanguage: json['nativeLanguage'] ?? '',
    learningLanguage: json['learningLanguage'] ?? '', level: json['level'] ?? 'A1',
    xp: json['xp'] ?? 0, streak: json['streak'] ?? 0, totalXp: json['totalXp'] ?? 0,
    learningGoal: json['learningGoal'], isPremium: json['isPremium'] ?? false,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
    dailyXp: json['dailyXp'] ?? 0, dailyGoal: json['dailyGoal'] ?? 50,
  );
}
