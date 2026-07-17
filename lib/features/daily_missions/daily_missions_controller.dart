import 'package:flutter/material.dart';
import 'models/daily_mission.dart';
import 'models/mission_reward.dart';
import 'daily_missions_repository.dart';

class DailyMissionsController extends ChangeNotifier {
  final DailyMissionsRepository _repository;

  DailyMissionsController(this._repository);

  List<DailyMission> _missions = [];
  int _totalXpEarned = 0;
  int _totalGemsEarned = 0;
  bool _allCompleted = false;
  bool _isLoading = false;

  List<DailyMission> get missions => _missions;
  int get totalXpEarned => _totalXpEarned;
  int get totalGemsEarned => _totalGemsEarned;
  bool get allCompleted => _allCompleted;
  bool get isLoading => _isLoading;

  int get completedCount => _missions.where((m) => m.isCompleted).length;
  int get claimedCount => _missions.where((m) => m.isClaimed).length;
  int get totalMissions => _missions.length;
  double get overallProgress => totalMissions > 0 ? completedCount / totalMissions : 0;

  Future<void> loadMissions() async {
    _isLoading = true;
    notifyListeners();

    _missions = await _repository.getTodayMissions();
    _allCompleted = await _repository.allMissionsCompleted();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProgress(MissionType type, int amount) async {
    await _repository.updateProgress(type, amount);
    _missions = await _repository.getTodayMissions();
    _allCompleted = await _repository.allMissionsCompleted();
    notifyListeners();
  }

  Future<MissionReward?> claimReward(String missionId) async {
    final reward = await _repository.claimReward(missionId);
    if (reward != null) {
      _totalXpEarned += reward.xp;
      _totalGemsEarned += reward.gems;
      _missions = await _repository.getTodayMissions();
      notifyListeners();
    }
    return reward;
  }

  Future<MissionReward?> claimDailyBonus() async {
    final reward = await _repository.claimDailyBonus();
    if (reward != null) {
      _totalXpEarned += reward.xp;
      _totalGemsEarned += reward.gems;
      notifyListeners();
    }
    return reward;
  }

  Future<int> getCompletedDays() async {
    return await _repository.getCompletedDaysCount();
  }
}
