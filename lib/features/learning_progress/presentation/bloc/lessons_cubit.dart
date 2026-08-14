import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../lessons/models/lesson_model.dart';
import '../../../lessons/lesson_repository.dart';
import 'progress_cubit.dart';

// States
abstract class LessonsState extends Equatable {
  const LessonsState();

  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {}

class LessonsLoading extends LessonsState {}

class LessonsLoaded extends LessonsState {
  final List<LessonModel> lessons;
  final String level;
  final String category;

  const LessonsLoaded({
    required this.lessons,
    required this.level,
    required this.category,
  });

  @override
  List<Object?> get props => [lessons, level, category];
}

class LessonsError extends LessonsState {
  final String message;

  const LessonsError(this.message);

  @override
  List<Object?> get props => [message];
}

class LessonsEmpty extends LessonsState {
  final String level;
  final String category;

  const LessonsEmpty({required this.level, required this.category});

  @override
  List<Object?> get props => [level, category];
}

// Cubit
class LessonsCubit extends Cubit<LessonsState> {
  final LessonRepository repository;
  final ProgressCubit progressCubit;
  List<LessonModel> _allLessons = [];

  LessonsCubit({required this.repository, required this.progressCubit})
    : super(LessonsInitial());

  Future<void> loadLessons(
    String level,
    String category,
    String language,
  ) async {
    emit(LessonsLoading());
    try {
      final lessons = await repository.getLessons(level, category, language);
      final completedLessons = await progressCubit.getCompletedLessons(
        progressCubit.currentProgress?.userId ?? '',
      );

      _allLessons = lessons.map((lesson) {
        return lesson.copyWith(
          isCompleted: completedLessons.contains(lesson.id),
        );
      }).toList();

      if (_allLessons.isEmpty) {
        emit(LessonsEmpty(level: level, category: category));
      } else {
        emit(
          LessonsLoaded(lessons: _allLessons, level: level, category: category),
        );
      }
    } catch (e) {
      emit(LessonsError('Failed to load lessons: $e'));
    }
  }

  Future<void> refreshCompletionStatus(String userId) async {
    try {
      final completedLessons = await progressCubit.getCompletedLessons(userId);
      _allLessons = _allLessons.map((lesson) {
        return lesson.copyWith(
          isCompleted: completedLessons.contains(lesson.id),
        );
      }).toList();

      if (state is LessonsLoaded) {
        final currentState = state as LessonsLoaded;
        emit(
          LessonsLoaded(
            lessons: _allLessons,
            level: currentState.level,
            category: currentState.category,
          ),
        );
      }
     } catch (e) {
      debugPrint('Failed to refresh lessons: $e');
    }
  }

  bool isLessonCompleted(String lessonId) {
    return _allLessons
        .firstWhere(
          (l) => l.id == lessonId,
          orElse: () => LessonModel(
            id: '',
            title: '',
            description: '',
            level: '',
            language: '',
            category: '',
          ),
        )
        .isCompleted;
  }
}
