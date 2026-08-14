import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/usecases/achievement_usecases.dart';

// States
abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<Achievement> achievements;
  final List<Achievement> newlyUnlocked;

  const AchievementLoaded({
    required this.achievements,
    this.newlyUnlocked = const [],
  });

  @override
  List<Object?> get props => [achievements, newlyUnlocked];
}

class AchievementError extends AchievementState {
  final String message;

  const AchievementError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AchievementCubit extends Cubit<AchievementState> {
  final AchievementRepository repository;
  late final GetAchievementsUseCase getAchievementsUseCase;
  late final GetUserAchievementsUseCase getUserAchievementsUseCase;
  late final UpdateAchievementProgressUseCase updateAchievementProgressUseCase;
  late final UnlockAchievementUseCase unlockAchievementUseCase;

  AchievementCubit(this.repository) : super(AchievementInitial()) {
    getAchievementsUseCase = GetAchievementsUseCase(repository);
    getUserAchievementsUseCase = GetUserAchievementsUseCase(repository);
    updateAchievementProgressUseCase = UpdateAchievementProgressUseCase(
      repository,
    );
    unlockAchievementUseCase = UnlockAchievementUseCase(repository);
  }

  Future<void> loadAchievements(String userId) async {
    emit(AchievementLoading());
    try {
      final userAchievements = await getUserAchievementsUseCase(userId);
      if (userAchievements.isEmpty) {
        final defaults = AchievementService.getDefaultAchievements();
        await repository.saveUserAchievements(userId, defaults);
        emit(AchievementLoaded(achievements: defaults));
      } else {
        emit(AchievementLoaded(achievements: userAchievements));
      }
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  Future<void> checkAndUpdateAchievements({
    required String userId,
    required int lessonsCompleted,
    required int totalXp,
    required int currentLevelXp,
    required int currentStreak,
    required int perfectQuizzes,
  }) async {
    try {
      final currentAchievements = await getUserAchievementsUseCase(userId);
      final previousUnlockedIds = currentAchievements
          .where((a) => a.isUnlocked)
          .map((a) => a.id)
          .toSet();

      final updated = AchievementService.updateAchievementProgress(
        currentAchievements,
        lessonsCompleted: lessonsCompleted,
        totalXp: totalXp,
        currentLevelXp: currentLevelXp,
        currentStreak: currentStreak,
        perfectQuizzes: perfectQuizzes,
      );

      final newlyUnlocked = updated
          .where((a) => a.isUnlocked && !previousUnlockedIds.contains(a.id))
          .toList();

      await updateAchievementProgressUseCase(
        userId: userId,
        achievements: updated,
      );

      for (final achievement in newlyUnlocked) {
        await unlockAchievementUseCase(userId, achievement.id);
      }

      emit(
        AchievementLoaded(achievements: updated, newlyUnlocked: newlyUnlocked),
      );
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  List<Achievement> getUnlocked(List<Achievement> achievements) {
    return achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLocked(List<Achievement> achievements) {
    return achievements.where((a) => !a.isUnlocked).toList();
  }
}
