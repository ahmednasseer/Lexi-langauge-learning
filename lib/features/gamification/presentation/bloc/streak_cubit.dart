import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../domain/usesecases/streak_usecases.dart';

// States
abstract class StreakState extends Equatable {
  const StreakState();

  @override
  List<Object?> get props => [];
}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakLoaded extends StreakState {
  final Streak streak;

  const StreakLoaded(this.streak);

  @override
  List<Object?> get props => [streak];
}

class StreakUpdated extends StreakState {
  final Streak streak;
  final int bonusXp;

  const StreakUpdated(this.streak, this.bonusXp);

  @override
  List<Object?> get props => [streak, bonusXp];
}

class StreakError extends StreakState {
  final String message;

  const StreakError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class StreakCubit extends Cubit<StreakState> {
  final StreakRepository repository;
  late final GetStreakUseCase getStreakUseCase;
  late final UpdateStreakUseCase updateStreakUseCase;
  late final GetStreakBonusXpUseCase getStreakBonusXpUseCase;
  late final ResetStreakUseCase resetStreakUseCase;

  StreakCubit(this.repository) : super(StreakInitial()) {
    getStreakUseCase = GetStreakUseCase(repository);
    updateStreakUseCase = UpdateStreakUseCase(repository);
    getStreakBonusXpUseCase = GetStreakBonusXpUseCase(repository);
    resetStreakUseCase = ResetStreakUseCase(repository);
  }

  Future<void> loadStreak(String userId) async {
    emit(StreakLoading());
    try {
      final streak = await getStreakUseCase(userId);
      if (streak != null) {
        emit(StreakLoaded(streak));
      } else {
        emit(const StreakError('No streak found'));
      }
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  Future<void> updateStreak(String userId) async {
    try {
      final previousStreak = await getStreakUseCase(userId);
      final previousCount = previousStreak?.currentStreak ?? 0;

      final streak = await updateStreakUseCase(userId);
      final bonusXp = streak.currentStreak > previousCount
          ? await getStreakBonusXpUseCase(userId)
          : 0;

      emit(StreakUpdated(streak, bonusXp));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  Future<int> getBonusXp(String userId) async {
    return getStreakBonusXpUseCase(userId);
  }

  Future<void> resetStreak(String userId) async {
    emit(StreakLoading());
    try {
      await resetStreakUseCase(userId);
      final streak = await getStreakUseCase(userId);
      if (streak != null) {
        emit(StreakLoaded(streak));
      }
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }
}
