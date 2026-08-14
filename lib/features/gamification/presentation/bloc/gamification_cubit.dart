import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../learning_progress/domain/repositories/progress_repository.dart';
import 'streak_cubit.dart';
import 'achievement_cubit.dart';
import 'daily_mission_cubit.dart';

// States
abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationReady extends GamificationState {
  final int streak;
  final int totalXp;
  final String levelLabel;
  final int achievementCount;
  final int completedMissions;

  const GamificationReady({
    required this.streak,
    required this.totalXp,
    required this.levelLabel,
    required this.achievementCount,
    required this.completedMissions,
  });

  @override
  List<Object?> get props => [
    streak,
    totalXp,
    levelLabel,
    achievementCount,
    completedMissions,
  ];
}

class GamificationError extends GamificationState {
  final String message;

  const GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class GamificationCubit extends Cubit<GamificationState> {
  final ProgressRepository progressRepository;
  final StreakCubit streakCubit;
  final AchievementCubit achievementCubit;
  final DailyMissionCubit dailyMissionCubit;
  final fb.FirebaseAuth _firebaseAuth;

  GamificationCubit({
    required this.progressRepository,
    required this.streakCubit,
    required this.achievementCubit,
    required this.dailyMissionCubit,
    fb.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       super(GamificationInitial());

  String? get _userId => _firebaseAuth.currentUser?.uid;

  Future<void> initialize() async {
    emit(GamificationLoading());
    try {
      final userId = _userId;
      if (userId == null) {
        emit(const GamificationError('User not authenticated'));
        return;
      }

      await Future.wait([
        progressRepository.getProgress(userId),
        streakCubit.loadStreak(userId),
        achievementCubit.loadAchievements(userId),
        dailyMissionCubit.loadDailyMissions(userId),
      ]);

      _emitReady();
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> onLessonCompleted({
    required String lessonId,
    required String category,
    required double quizScore,
    int baseXp = 50,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return;

      await progressRepository.completeLesson(
        userId: userId,
        lessonId: lessonId,
        category: category,
        score: quizScore,
        xpEarned: _calculateXp(quizScore, baseXp),
      );

      final progress = await progressRepository.getProgress(userId);
      final completedCount = progress?.completedLessons.length ?? 0;
      final totalXp = progress?.totalXp ?? 0;

      await streakCubit.updateStreak(userId);
      await dailyMissionCubit.trackActivity(
        userId: userId,
        lessonsCompleted: completedCount,
        xpEarned: totalXp,
        questionsAnswered: (quizScore * 10).round(),
      );

      await achievementCubit.checkAndUpdateAchievements(
        userId: userId,
        lessonsCompleted: completedCount,
        totalXp: totalXp,
        currentLevelXp: totalXp,
        currentStreak: streakCubit.state is StreakLoaded
            ? (streakCubit.state as StreakLoaded).streak.currentStreak
            : 0,
        perfectQuizzes: quizScore >= 0.9 ? 1 : 0,
      );

      _emitReady();
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> onAppOpen() async {
    try {
      final userId = _userId;
      if (userId == null) return;

      await streakCubit.updateStreak(userId);
      _emitReady();
    } catch (e) {
      debugPrint('Failed to update streak in gamification: $e');
    }
  }

  Future<int> claimMissionReward(String missionId) async {
    final userId = _userId;
    if (userId == null) return 0;

    final xp = await dailyMissionCubit.claimReward(userId, missionId);
    if (xp > 0) {
      await progressRepository.addXp(userId, xp);
    }
    _emitReady();
    return xp;
  }

  int _calculateXp(double quizScore, int baseXp) {
    int xp = baseXp;
    if (quizScore >= 0.9)
      xp += 20;
    else if (quizScore >= 0.7)
      xp += 10;
    return xp;
  }

  void _emitReady() async {
    final userId = _userId;
    if (userId == null) return;

    final progress = await progressRepository.getProgress(userId);
    final streakState = streakCubit.state;
    final achievementState = achievementCubit.state;
    final missionState = dailyMissionCubit.state;

    int streak = 0;
    if (streakState is StreakLoaded) {
      streak = streakState.streak.currentStreak;
    } else if (streakState is StreakUpdated) {
      streak = streakState.streak.currentStreak;
    }

    int achievementCount = 0;
    if (achievementState is AchievementLoaded) {
      achievementCount = achievementState.achievements
          .where((a) => a.isUnlocked)
          .length;
    }

    int completedMissions = 0;
    if (missionState is DailyMissionLoaded) {
      completedMissions = missionState.missions
          .where((m) => m.isCompleted)
          .length;
    }

    emit(
      GamificationReady(
        streak: streak,
        totalXp: progress?.totalXp ?? 0,
        levelLabel: progress?.levelLabel ?? 'A1',
        achievementCount: achievementCount,
        completedMissions: completedMissions,
      ),
    );
  }
}
