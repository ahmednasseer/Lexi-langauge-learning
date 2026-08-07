import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import 'models/passport.dart';

class PassportRepository {
  final ApiService _api = ApiService();

  Future<Passport> getPassport() async {
    try {
      final result = await _api.getGrowthStats();
      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        if (data['passport'] != null) {
          return Passport.fromJson(data['passport'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return _localPassport();
  }

  Passport _localPassport() {
    final user = AuthService.instance.currentUser;
    final levels = PassportLevel.getDefaultLevels();
    final totalXp = user?.xp ?? 0;
    return Passport(
      userId: user?.id ?? '',
      userName: user?.name ?? 'Student',
      nativeLanguage: user?.nativeLanguage ?? 'English',
      learningLanguage: user?.learningLanguage ?? 'German',
      totalXp: totalXp,
      currentStreak: user?.streak ?? 0,
      bestStreak: user?.streak ?? 0,
      levels: levels,
      createdAt: user?.createdAt ?? DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }
}
