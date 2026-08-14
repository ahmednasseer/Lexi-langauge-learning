import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/progress_usecases.dart';

// States
abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final Progress progress;

  const ProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ProgressUpdating extends ProgressState {}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository repository;
  late final GetProgressUseCase getProgressUseCase;
  late final CompleteLessonUseCase completeLessonUseCase;
  late final AddXpUseCase addXpUseCase;
  late final UpdateLessonScoreUseCase updateLessonScoreUseCase;
  late final GetCompletedLessonsUseCase getCompletedLessonsUseCase;
  late final ResetProgressUseCase resetProgressUseCase;

  Progress? _currentProgress;

  ProgressCubit(this.repository) : super(ProgressInitial()) {
    getProgressUseCase = GetProgressUseCase(repository);
    completeLessonUseCase = CompleteLessonUseCase(repository);
    addXpUseCase = AddXpUseCase(repository);
    updateLessonScoreUseCase = UpdateLessonScoreUseCase(repository);
    getCompletedLessonsUseCase = GetCompletedLessonsUseCase(repository);
    resetProgressUseCase = ResetProgressUseCase(repository);
  }

  Progress? get currentProgress => _currentProgress;

  Future<void> loadProgress(String userId) async {
    emit(ProgressLoading());
    try {
      final progress = await getProgressUseCase(userId);
      _currentProgress = progress;
      if (progress != null) {
        emit(ProgressLoaded(progress));
      } else {
        emit(const ProgressError('No progress found'));
      }
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required String category,
    required double quizScore,
  }) async {
    emit(ProgressUpdating());
    try {
      await completeLessonUseCase(
        userId: userId,
        lessonId: lessonId,
        category: category,
        quizScore: quizScore,
      );
      final progress = await getProgressUseCase(userId);
      _currentProgress = progress;
      if (progress != null) {
        emit(ProgressLoaded(progress));
      } else {
        emit(const ProgressError('Progress not found after completion'));
      }
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> addXp(String userId, int amount) async {
    try {
      await addXpUseCase(userId, amount);
      final progress = await getProgressUseCase(userId);
      _currentProgress = progress;
      if (progress != null) {
        emit(ProgressLoaded(progress));
      }
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> updateScore(String userId, String lessonId, double score) async {
    try {
      await updateLessonScoreUseCase(userId, lessonId, score);
      if (_currentProgress != null) {
        final lessonScores = Map<String, double>.from(
          _currentProgress!.lessonScores,
        );
        lessonScores[lessonId] = score;
        _currentProgress = _currentProgress!.copyWith(
          lessonScores: lessonScores,
        );
        emit(ProgressLoaded(_currentProgress!));
      }
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<List<String>> getCompletedLessons(String userId) async {
    return getCompletedLessonsUseCase(userId);
  }

  bool isLessonCompleted(String lessonId) {
    return _currentProgress?.isLessonCompleted(lessonId) ?? false;
  }

  Future<void> resetProgress(String userId) async {
    emit(ProgressLoading());
    try {
      await resetProgressUseCase(userId);
      final progress = await getProgressUseCase(userId);
      _currentProgress = progress;
      if (progress != null) {
        emit(ProgressLoaded(progress));
      }
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
