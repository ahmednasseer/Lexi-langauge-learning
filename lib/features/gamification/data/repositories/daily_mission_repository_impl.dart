import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/repositories/daily_mission_repository.dart';

/// API-backed implementation. Daily missions are fetched from NestJS; progress
/// updates and reward claims are server operations.
class DailyMissionRepositoryImpl implements DailyMissionRepository {
  final ApiService _api;

  /// Maps daily mission entity IDs to the raw backend `type` string so that
  /// progress updates target the correct server mission.
  final Map<String, String> _rawTypeById = {};

  DailyMissionRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  MissionType _mapType(String raw) {
    return MissionType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => MissionType.completeLessons,
    );
  }

  DailyMission _fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final rawType = json['type'] as String? ?? '';
    final missionId = id.isNotEmpty ? id : (json['missionId'] as String? ?? '');
    if (missionId.isNotEmpty && rawType.isNotEmpty) {
      _rawTypeById[missionId] = rawType;
    }
    return DailyMission(
      id: missionId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _mapType(rawType),
      target: json['target'] as int? ?? 0,
      currentProgress: json['progress'] as int? ?? 0,
      rewardXp: json['rewardXp'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      icon: json['icon'] as String?,
    );
  }

  Future<List<DailyMission>> _fetchAll() async {
    final result = await _api.getDailyMissions();
    if (!result.isSuccess || result.data == null) return [];
    return result.data!
        .map<DailyMission>(
          (raw) => _fromJson((raw as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  @override
  Future<List<DailyMission>> getDailyMissions(
    String userId,
    DateTime date,
  ) async {
    return _fetchAll();
  }

  @override
  Future<void> saveDailyMissions(
    String userId,
    List<DailyMission> missions,
  ) async {
    // Missions are generated/stored server-side.
  }

  @override
  Future<void> updateMissionProgress(
    String userId,
    String missionId,
    int progress,
  ) async {
    final missions = await _fetchAll();
    DailyMission? mission;
    for (final m in missions) {
      if (m.id == missionId) {
        mission = m;
        break;
      }
    }
    if (mission == null || mission.isCompleted) return;

    final increment = progress - mission.currentProgress;
    if (increment <= 0) return;

    final backendType = _rawTypeById[missionId] ?? mission.type.name;
    final result = await _api.updateDailyMissionProgress(
      backendType,
      increment,
    );
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to update mission progress');
    }
  }

  @override
  Future<void> claimMissionReward(String userId, String missionId) async {
    try {
      await _api.claimDailyMissionReward(missionId);
    } catch (e) {
      throw Exception('Failed to claim mission reward');
    }
  }

  @override
  Future<List<DailyMission>> getAllMissions(String userId) async {
    return _fetchAll();
  }
}