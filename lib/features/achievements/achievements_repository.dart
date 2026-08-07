import '../../core/services/api_service.dart';
import 'models/achievement_badge.dart';

class AchievementsRepository {
  final ApiService _api = ApiService();

  Future<List<AchievementBadge>> getAchievements() async {
    try {
      final result = await _api.getAchievements();
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => _mapFromApi(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _mergeLocalWithApi();
  }

  Future<List<AchievementBadge>> _mergeLocalWithApi() async {
    return AchievementBadge.getAllBadges();
  }

  AchievementBadge _mapFromApi(Map<String, dynamic> json) {
    return AchievementBadge(
      id: json['id'] ?? '',
      name: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      category: json['type'] ?? 'general',
      requirement: json['targetValue'] ?? 0,
      rewardXp: json['xpReward'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? json['unlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }
}
