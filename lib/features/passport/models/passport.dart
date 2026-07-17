class PassportLevel {
  final String level;
  final String title;
  final String description;
  final int requiredXp;
  final int lessonsCompleted;
  final int totalLessons;
  final int vocabularyLearned;
  final double speakingScore;
  final bool isUnlocked;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? certificateId;

  const PassportLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.requiredXp,
    this.lessonsCompleted = 0,
    required this.totalLessons,
    this.vocabularyLearned = 0,
    this.speakingScore = 0,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.completedAt,
    this.certificateId,
  });

  double get progress => totalLessons > 0 ? lessonsCompleted / totalLessons : 0;

  Map<String, dynamic> toJson() => {
    'level': level,
    'title': title,
    'description': description,
    'requiredXp': requiredXp,
    'lessonsCompleted': lessonsCompleted,
    'totalLessons': totalLessons,
    'vocabularyLearned': vocabularyLearned,
    'speakingScore': speakingScore,
    'isUnlocked': isUnlocked,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'certificateId': certificateId,
  };

  factory PassportLevel.fromJson(Map<String, dynamic> json) => PassportLevel(
    level: json['level'] ?? 'A1',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    requiredXp: json['requiredXp'] ?? 0,
    lessonsCompleted: json['lessonsCompleted'] ?? 0,
    totalLessons: json['totalLessons'] ?? 0,
    vocabularyLearned: json['vocabularyLearned'] ?? 0,
    speakingScore: (json['speakingScore'] ?? 0).toDouble(),
    isUnlocked: json['isUnlocked'] ?? false,
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    certificateId: json['certificateId'],
  );

  static List<PassportLevel> getDefaultLevels() {
    return [
      const PassportLevel(
        level: 'A1',
        title: 'Beginner',
        description: 'Basic phrases and simple conversations',
        requiredXp: 0,
        totalLessons: 20,
        isUnlocked: true,
      ),
      const PassportLevel(
        level: 'A2',
        title: 'Elementary',
        description: 'Everyday expressions and routine tasks',
        requiredXp: 500,
        totalLessons: 25,
      ),
      const PassportLevel(
        level: 'B1',
        title: 'Intermediate',
        description: 'Work, school, and leisure topics',
        requiredXp: 1500,
        totalLessons: 30,
      ),
      const PassportLevel(
        level: 'B2',
        title: 'Upper Intermediate',
        description: 'Complex texts and abstract topics',
        requiredXp: 3000,
        totalLessons: 35,
      ),
      const PassportLevel(
        level: 'C1',
        title: 'Advanced',
        description: 'Fluent and spontaneous communication',
        requiredXp: 5000,
        totalLessons: 40,
      ),
      const PassportLevel(
        level: 'C2',
        title: 'Mastery',
        description: 'Near-native comprehension and expression',
        requiredXp: 8000,
        totalLessons: 50,
      ),
    ];
  }
}

class Passport {
  final String userId;
  final String userName;
  final String nativeLanguage;
  final String learningLanguage;
  final int totalXp;
  final int currentStreak;
  final int bestStreak;
  final List<PassportLevel> levels;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const Passport({
    required this.userId,
    required this.userName,
    required this.nativeLanguage,
    required this.learningLanguage,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    required this.levels,
    required this.createdAt,
    required this.lastActiveAt,
  });

  PassportLevel get currentLevel {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (levels[i].isUnlocked && !levels[i].isCompleted) return levels[i];
    }
    return levels.first;
  }

  int get completedLevels => levels.where((l) => l.isCompleted).length;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'nativeLanguage': nativeLanguage,
    'learningLanguage': learningLanguage,
    'totalXp': totalXp,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'levels': levels.map((l) => l.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastActiveAt': lastActiveAt.toIso8601String(),
  };

  factory Passport.fromJson(Map<String, dynamic> json) => Passport(
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    nativeLanguage: json['nativeLanguage'] ?? 'English',
    learningLanguage: json['learningLanguage'] ?? 'German',
    totalXp: json['totalXp'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    bestStreak: json['bestStreak'] ?? 0,
    levels: (json['levels'] as List?)?.map((l) => PassportLevel.fromJson(l)).toList() ?? PassportLevel.getDefaultLevels(),
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : DateTime.now(),
  );
}
