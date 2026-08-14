import '../entities/progress.dart';
import '../repositories/progress_repository.dart';

class GetProgressUseCase {
  final ProgressRepository repository;

  GetProgressUseCase(this.repository);

  Future<Progress?> call(String userId) async {
    return repository.getProgress(userId);
  }
}

class CompleteLessonUseCase {
  final ProgressRepository repository;

  CompleteLessonUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String lessonId,
    required String category,
    required double quizScore,
  }) async {
    await repository.completeLesson(
      userId: userId,
      lessonId: lessonId,
      category: category,
      score: quizScore,
      xpEarned: 0,
    );
  }
}

class AddXpUseCase {
  final ProgressRepository repository;

  AddXpUseCase(this.repository);

  Future<void> call(String userId, int amount) async {
    await repository.addXp(userId, amount);
  }
}

class UpdateLessonScoreUseCase {
  final ProgressRepository repository;

  UpdateLessonScoreUseCase(this.repository);

  Future<void> call(String userId, String lessonId, double score) async {
    await repository.updateLessonScore(userId, lessonId, score);
  }
}

class GetCompletedLessonsUseCase {
  final ProgressRepository repository;

  GetCompletedLessonsUseCase(this.repository);

  Future<List<String>> call(String userId) async {
    return repository.getCompletedLessons(userId);
  }
}

class ResetProgressUseCase {
  final ProgressRepository repository;

  ResetProgressUseCase(this.repository);

  Future<void> call(String userId) async {
    await repository.resetProgress(userId);
  }
}
