class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isPremium;
  final int xp;
  final int level;
  final int streak;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isPremium = false,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isPremium,
    int? xp,
    int? level,
    int? streak,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
    );
  }
}
