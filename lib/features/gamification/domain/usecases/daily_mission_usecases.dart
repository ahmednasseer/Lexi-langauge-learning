import '../entities/daily_mission.dart';
import '../repositories/daily_mission_repository.dart';

class GetDailyMissionsUseCase {
  final DailyMissionRepository repository;

  GetDailyMissionsUseCase(this.repository);

  Future<List<DailyMission>> call(String userId, DateTime date) async {
    return repository.getDailyMissions(userId, date);
  }
}

class SaveDailyMissionsUseCase {
  final DailyMissionRepository repository;

  SaveDailyMissionsUseCase(this.repository);

  Future<void> call(String userId, List<DailyMission> missions) async {
    await repository.saveDailyMissions(userId, missions);
  }
}

class UpdateMissionProgressUseCase {
  final DailyMissionRepository repository;

  UpdateMissionProgressUseCase(this.repository);

  Future<void> call(String userId, String missionId, int progress) async {
    await repository.updateMissionProgress(userId, missionId, progress);
  }
}

class ClaimMissionRewardUseCase {
  final DailyMissionRepository repository;

  ClaimMissionRewardUseCase(this.repository);

  Future<void> call(String userId, String missionId) async {
    await repository.claimMissionReward(userId, missionId);
  }
}

class GetAllMissionsUseCase {
  final DailyMissionRepository repository;

  GetAllMissionsUseCase(this.repository);

  Future<List<DailyMission>> call(String userId) async {
    return repository.getAllMissions(userId);
  }
}
