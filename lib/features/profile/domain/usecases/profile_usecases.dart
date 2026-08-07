import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile?> call(String userId) async {
    return repository.getProfile(userId);
  }
}

class GetCurrentProfileUseCase {
  final ProfileRepository repository;

  GetCurrentProfileUseCase(this.repository);

  Future<Profile?> call() async {
    return repository.getCurrentProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Profile> call(Profile profile) async {
    return repository.updateProfile(profile);
  }
}

class DeleteProfileUseCase {
  final ProfileRepository repository;

  DeleteProfileUseCase(this.repository);

  Future<void> call(String userId) async {
    return repository.deleteProfile(userId);
  }
}

class UpdatePreferencesUseCase {
  final ProfileRepository repository;

  UpdatePreferencesUseCase(this.repository);

  Future<void> call({
    bool? notificationsEnabled,
    int? dailyGoal,
    String? learningLanguage,
    String? nativeLanguage,
  }) async {
    return repository.updatePreferences(
      notificationsEnabled: notificationsEnabled,
      dailyGoal: dailyGoal,
      learningLanguage: learningLanguage,
      nativeLanguage: nativeLanguage,
    );
  }
}
