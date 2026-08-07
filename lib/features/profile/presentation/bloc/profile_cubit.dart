import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile.id];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileSaved extends ProfileState {
  final Profile profile;

  const ProfileSaved(this.profile);

  @override
  List<Object?> get props => [profile.id];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  late final GetCurrentProfileUseCase getCurrentProfileUseCase;
  late final UpdateProfileUseCase updateProfileUseCase;
  late final DeleteProfileUseCase deleteProfileUseCase;
  late final UpdatePreferencesUseCase updatePreferencesUseCase;

  ProfileCubit(this.repository) : super(ProfileInitial()) {
    getCurrentProfileUseCase = GetCurrentProfileUseCase(repository);
    updateProfileUseCase = UpdateProfileUseCase(repository);
    deleteProfileUseCase = DeleteProfileUseCase(repository);
    updatePreferencesUseCase = UpdatePreferencesUseCase(repository);
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await getCurrentProfileUseCase();
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(Profile profile) async {
    emit(ProfileLoading());
    try {
      final updated = await updateProfileUseCase(profile);
      emit(ProfileSaved(updated));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> deleteProfile(String userId) async {
    emit(ProfileLoading());
    try {
      await deleteProfileUseCase(userId);
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updatePreferences({
    bool? notificationsEnabled,
    int? dailyGoal,
    String? learningLanguage,
    String? nativeLanguage,
  }) async {
    try {
      await updatePreferencesUseCase(
        notificationsEnabled: notificationsEnabled,
        dailyGoal: dailyGoal,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
      );
      await loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
