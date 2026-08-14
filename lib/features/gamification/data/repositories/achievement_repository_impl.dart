import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

/// API-backed implementation. Achievements and their unlock state are read from
/// NestJS. Unlock/progress writes are no-ops because unlocking happens
/// server-side.
class AchievementRepositoryImpl implements AchievementRepository {
  final ApiService _api;

  AchievementRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  AchievementType _mapType(String raw) {
    return AchievementType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AchievementType.lessonsCompleted,
    );
  }

  Achievement _fromJson(Map<String, dynamic> json) {
    final unlockedAt = json['unlockedAt'] != null
        ? DateTime.tryParse(json['unlockedAt'].toString())
        : null;
    return Achievement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      type: _mapType(json['type'] as String? ?? ''),
      requirementValue: json['requirementValue'] as int? ?? 0,
      rewardXp: json['xpReward'] as int? ?? json['rewardXp'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: unlockedAt,
      progress: json['progress'] as int? ?? 0,
    );
  }

  Future<List<Achievement>> _fetchAll() async {
    final result = await _api.getAchievements();
    if (!result.isSuccess || result.data == null) return [];
    return result.data!
        .map<Achievement>(
          (raw) => _fromJson((raw as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  @override
  Future<List<Achievement>> getAllAchievements() => _fetchAll();

  @override
  Future<List<Achievement>> getUserAchievements(String userId) async {
    final all = await _fetchAll();
    return all.where((a) => a.isUnlocked).toList();
  }

  @override
  Future<void> saveUserAchievements(
    String userId,
    List<Achievement> achievements,
  ) async {
    // Unlock state is server-managed.
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    // Unlocking happens server-side.
  }

  @override
  Future<void> updateAchievementProgress(
    String userId,
    List<Achievement> achievements,
  ) async {
    // Progress is server-managed.
  }
}