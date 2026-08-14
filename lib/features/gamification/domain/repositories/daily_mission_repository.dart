import '../entities/daily_mission.dart';

abstract class DailyMissionRepository {
  Future<List<DailyMission>> getDailyMissions(String userId, DateTime date);
  Future<void> saveDailyMissions(String userId, List<DailyMission> missions);
  Future<void> updateMissionProgress(
    String userId,
    String missionId,
    int progress,
  );
  Future<void> claimMissionReward(String userId, String missionId);
  Future<List<DailyMission>> getAllMissions(String userId);
}
