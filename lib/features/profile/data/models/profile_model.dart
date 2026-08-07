import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.bio,
    super.nativeLanguage,
    super.learningLanguage,
    super.isPremium,
    super.xp,
    super.level,
    super.streak,
    super.dailyGoal,
    super.notificationsEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      nativeLanguage: json['nativeLanguage'] ?? 'English',
      learningLanguage: json['learningLanguage'] ?? 'German',
      isPremium: json['isPremium'] ?? false,
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
      dailyGoal: json['dailyGoal'] ?? 50,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage,
      'isPremium': isPremium,
      'xp': xp,
      'level': level,
      'streak': streak,
      'dailyGoal': dailyGoal,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromFirebaseUser(String uid, String email, String? name) {
    return ProfileModel(
      id: uid,
      name: name ?? '',
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
