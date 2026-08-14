import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/repositories/daily_mission_repository.dart';
import '../../domain/services/daily_mission_service.dart';
import '../../domain/usecases/daily_mission_usecases.dart';

// States
abstract class DailyMissionState extends Equatable {
  const DailyMissionState();

  @override
  List<Object?> get props => [];
}

class DailyMissionInitial extends DailyMissionState {}

class DailyMissionLoading extends DailyMissionState {}

class DailyMissionLoaded extends DailyMissionState {
  final List<DailyMission> missions;
  final int totalXpAvailable;

  const DailyMissionLoaded({required this.missions, this.totalXpAvailable = 0});

  @override
  List<Object?> get props => [missions, totalXpAvailable];
}

class DailyMissionClaimed extends DailyMissionState {
  final DailyMission mission;
  final int xpEarned;

  const DailyMissionClaimed(this.mission, this.xpEarned);

  @override
  List<Object?> get props => [mission, xpEarned];
}

class DailyMissionError extends DailyMissionState {
  final String message;

  const DailyMissionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DailyMissionCubit extends Cubit<DailyMissionState> {
  final DailyMissionRepository repository;
  late final GetDailyMissionsUseCase getDailyMissionsUseCase;
  late final SaveDailyMissionsUseCase saveDailyMissionsUseCase;
  late final UpdateMissionProgressUseCase updateMissionProgressUseCase;
  late final ClaimMissionRewardUseCase claimMissionRewardUseCase;
  late final GetAllMissionsUseCase getAllMissionsUseCase;

  DailyMissionCubit(this.repository) : super(DailyMissionInitial()) {
    getDailyMissionsUseCase = GetDailyMissionsUseCase(repository);
    saveDailyMissionsUseCase = SaveDailyMissionsUseCase(repository);
    updateMissionProgressUseCase = UpdateMissionProgressUseCase(repository);
    claimMissionRewardUseCase = ClaimMissionRewardUseCase(repository);
    getAllMissionsUseCase = GetAllMissionsUseCase(repository);
  }

  Future<void> loadDailyMissions(String userId) async {
    emit(DailyMissionLoading());
    try {
      final today = DateTime.now();
      final missions = await getDailyMissionsUseCase(userId, today);

      if (missions.isEmpty) {
        final generated = DailyMissionService.generateDailyMissions(
          userId,
          today,
        );
        await saveDailyMissionsUseCase(userId, generated);
        final totalXp = generated.fold<int>(0, (sum, m) => sum + m.rewardXp);
        emit(
          DailyMissionLoaded(missions: generated, totalXpAvailable: totalXp),
        );
      } else {
        final totalXp = missions.fold<int>(
          0,
          (sum, m) => sum + (!m.isClaimed ? m.rewardXp : 0),
        );
        emit(DailyMissionLoaded(missions: missions, totalXpAvailable: totalXp));
      }
    } catch (e) {
      emit(DailyMissionError(e.toString()));
    }
  }

  Future<void> updateMissionProgress(
    String userId,
    String missionId,
    int progress,
  ) async {
    try {
      await updateMissionProgressUseCase(userId, missionId, progress);
      await loadDailyMissions(userId);
    } catch (e) {
      emit(DailyMissionError(e.toString()));
    }
  }

  Future<int> claimReward(String userId, String missionId) async {
    try {
      final missions = await getDailyMissionsUseCase(userId, DateTime.now());
      final mission = missions.firstWhere((m) => m.id == missionId);

      if (mission.canClaim) {
        await claimMissionRewardUseCase(userId, missionId);
        emit(DailyMissionClaimed(mission, mission.rewardXp));
        await loadDailyMissions(userId);
        return mission.rewardXp;
      }
      return 0;
    } catch (e) {
      emit(DailyMissionError(e.toString()));
      return 0;
    }
  }

  Future<void> trackActivity({
    required String userId,
    int? lessonsCompleted,
    int? xpEarned,
    int? questionsAnswered,
  }) async {
    try {
      final today = DateTime.now();
      final missions = await getDailyMissionsUseCase(userId, today);

      if (missions.isEmpty) return;

      final updated = DailyMissionService.updateMissionProgress(
        missions,
        lessonsCompleted: lessonsCompleted,
        xpEarned: xpEarned,
        questionsAnswered: questionsAnswered,
      );

      await saveDailyMissionsUseCase(userId, updated);
      final totalXp = updated.fold<int>(
        0,
        (sum, m) => sum + (!m.isClaimed && m.isCompleted ? m.rewardXp : 0),
      );
      emit(DailyMissionLoaded(missions: updated, totalXpAvailable: totalXp));
    } catch (e) {
      // Silently handle errors
    }
  }
}
