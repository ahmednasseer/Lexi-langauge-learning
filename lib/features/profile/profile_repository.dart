import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../shared/models/user_model.dart';

class ProfileRepository {
  final ApiService _api = ApiService();

  Future<UserModel?> getProfile() async {
    try {
      final result = await _api.getProfile();
      if (result.isSuccess && result.data != null) {
        return UserModel.fromJson(result.data!);
      }
    } catch (_) {}
    return AuthService.instance.currentUser;
  }

  Future<UserModel?> updateProfile({
    String? name,
    String? level,
    int? xp,
    String? nativeLanguage,
    String? learningLanguage,
    String? learningGoal,
    int? dailyGoal,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (level != null) body['level'] = level;
    if (xp != null) body['xp'] = xp;
    if (nativeLanguage != null) body['nativeLanguage'] = nativeLanguage;
    if (learningLanguage != null) body['learningLanguage'] = learningLanguage;
    if (learningGoal != null) body['learningGoal'] = learningGoal;
    if (dailyGoal != null) body['dailyGoal'] = dailyGoal;

    try {
      final result = await _api.updateProfile(body);
      if (result.isSuccess && result.data != null) {
        return UserModel.fromJson(result.data!);
      }
    } catch (_) {}
    final current = AuthService.instance.currentUser;
    if (current != null) {
      return current.copyWith(
        name: name ?? current.name,
        level: level ?? current.level,
        xp: xp ?? current.xp,
        nativeLanguage: nativeLanguage ?? current.nativeLanguage,
        learningLanguage: learningLanguage ?? current.learningLanguage,
      );
    }
    return null;
  }
}
