import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getCurrentProfile();
  Future<Profile?> getProfile(String userId);
  Future<Profile> updateProfile(Profile profile);
  Future<void> deleteProfile(String userId);
  Future<void> updatePreferences({
    bool? notificationsEnabled,
    int? dailyGoal,
    String? learningLanguage,
    String? nativeLanguage,
  });
}
