class Profile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String nativeLanguage;
  final String learningLanguage;
  final bool isPremium;
  final int xp;
  final int level;
  final int streak;
  final int dailyGoal;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.nativeLanguage = 'English',
    this.learningLanguage = 'German',
    this.isPremium = false,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.dailyGoal = 50,
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    String? nativeLanguage,
    String? learningLanguage,
    bool? isPremium,
    int? xp,
    int? level,
    int? streak,
    int? dailyGoal,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      isPremium: isPremium ?? this.isPremium,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
