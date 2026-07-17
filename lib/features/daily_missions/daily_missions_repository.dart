import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/daily_mission.dart';
import 'models/mission_reward.dart';

class DailyMissionsRepository {
  static const String _missionsKey = 'daily_missions';
  static const String _lastResetKey = 'missions_last_reset';
  static const String _completedDaysKey = 'completed_mission_days';

  final SharedPreferences _prefs;

  DailyMissionsRepository(this._prefs);

  Future<List<DailyMission>> getTodayMissions() async {
    await _checkAndReset();
    final jsonString = _prefs.getString(_missionsKey);
    if (jsonString == null) {
      final missions = DailyMission.getTodayMissions();
      await _saveMissions(missions);
      return missions;
    }
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((j) => DailyMission.fromJson(j)).toList();
  }

  Future<void> updateProgress(MissionType type, int amount) async {
    final missions = await getTodayMissions();
    bool updated = false;

    for (int i = 0; i < missions.length; i++) {
      if (missions[i].type == type && !missions[i].isCompleted) {
        final newProgress = missions[i].progress + amount;
        final isCompleted = newProgress >= missions[i].target;
        missions[i] = missions[i].copyWith(
          progress: newProgress,
          isCompleted: isCompleted,
        );
        updated = true;
      }
    }

    if (updated) {
      await _saveMissions(missions);
    }
  }

  Future<MissionReward?> claimReward(String missionId) async {
    final missions = await getTodayMissions();
    MissionReward? reward;

    for (int i = 0; i < missions.length; i++) {
      if (missions[i].id == missionId && missions[i].canClaim) {
        reward = MissionReward(
          xp: missions[i].rewardXp,
          gems: missions[i].rewardGems,
        );
        missions[i] = missions[i].copyWith(isClaimed: true);
        break;
      }
    }

    if (reward != null) {
      await _saveMissions(missions);
    }

    return reward;
  }

  Future<bool> allMissionsCompleted() async {
    final missions = await getTodayMissions();
    return missions.every((m) => m.isCompleted);
  }

  Future<MissionReward?> claimDailyBonus() async {
    if (await allMissionsCompleted()) {
      return MissionReward.dailyComplete();
    }
    return null;
  }

  Future<int> getCompletedDaysCount() async {
    return _prefs.getInt(_completedDaysKey) ?? 0;
  }

  Future<void> _checkAndReset() async {
    final lastReset = _prefs.getString(_lastResetKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastReset == null || DateTime.parse(lastReset).isBefore(today)) {
      final oldMissions = await getTodayMissions();
      if (oldMissions.every((m) => m.isCompleted)) {
        final days = await getCompletedDaysCount();
        await _prefs.setInt(_completedDaysKey, days + 1);
      }
      final newMissions = DailyMission.getTodayMissions();
      await _saveMissions(newMissions);
      await _prefs.setString(_lastResetKey, today.toIso8601String());
    }
  }

  Future<void> _saveMissions(List<DailyMission> missions) async {
    final jsonList = missions.map((m) => m.toJson()).toList();
    await _prefs.setString(_missionsKey, jsonEncode(jsonList));
  }
}
