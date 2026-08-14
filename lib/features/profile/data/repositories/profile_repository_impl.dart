import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/error_logger.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _api;

  static final Map<String, int> _levelToInt = {
    'A1': 1,
    'A2': 2,
    'B1': 3,
    'B2': 4,
    'C1': 5,
    'C2': 6,
  };

  ProfileRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  ProfileModel _fromApiResponse(Map<String, dynamic> json) {
    final levelValue = json['level'];
    int parsedLevel;
    if (levelValue is int) {
      parsedLevel = levelValue;
    } else if (levelValue is String) {
      parsedLevel = _levelToInt[levelValue] ?? 1;
    } else {
      parsedLevel = 1;
    }

    String? avatarUrl = json['photoUrl'] ?? json['avatar'];

    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: avatarUrl,
      bio: json['bio'],
      nativeLanguage: json['nativeLanguage'] ?? 'English',
      learningLanguage: json['learningLanguage'] ?? 'German',
      isPremium: json['isPremium'] ?? false,
      xp: json['xp'] ?? 0,
      level: parsedLevel,
      streak: json['streak'] ?? 0,
      dailyGoal: json['dailyGoal'] ?? 50,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
    );
  }

  @override
  Future<Profile?> getCurrentProfile() async {
    final result = await _api.getProfile();
    if (result.isFailure) {
      if (kDebugMode) {
        print('Profile fetch failed: ${result.error}');
      }
      ErrorLogger.logError('Failed to load profile: ${result.error}', stackTrace: StackTrace.current);
      return null;
    }
    if (result.data == null) return null;
    return _fromApiResponse(result.data!);
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    return getCurrentProfile();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final data = <String, dynamic>{
      'name': profile.name,
      'nativeLanguage': profile.nativeLanguage,
      'learningLanguage': profile.learningLanguage,
      'dailyGoal': profile.dailyGoal,
      'notificationsEnabled': profile.notificationsEnabled,
    };

    final result = await _api.updateProfile(data);
    if (result.isFailure) {
      ErrorLogger.logError('Failed to update profile: ${result.error}', stackTrace: StackTrace.current);
      throw Exception(result.error ?? 'Failed to update profile');
    }
    if (result.data == null) {
      throw Exception('No data returned from server');
    }
    return _fromApiResponse(result.data!);
  }

  @override
  Future<void> deleteProfile(String userId) {
    throw UnsupportedError('Profile deletion is not supported via the API');
  }

  @override
  Future<void> updatePreferences({
    bool? notificationsEnabled,
    int? dailyGoal,
    String? learningLanguage,
    String? nativeLanguage,
  }) async {
    final data = <String, dynamic>{};
    if (notificationsEnabled != null) {
      data['notificationsEnabled'] = notificationsEnabled;
    }
    if (dailyGoal != null) data['dailyGoal'] = dailyGoal;
    if (learningLanguage != null) {
      data['learningLanguage'] = learningLanguage;
    }
    if (nativeLanguage != null) data['nativeLanguage'] = nativeLanguage;

    final result = await _api.updateProfile(data);
    if (result.isFailure) {
      ErrorLogger.logError('Failed to update preferences: ${result.error}', stackTrace: StackTrace.current);
      throw Exception(result.error ?? 'Failed to update preferences');
    }
  }
}
