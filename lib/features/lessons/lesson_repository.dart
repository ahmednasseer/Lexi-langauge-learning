import 'models/lesson_model.dart';

class LessonRepository {
  List<LessonModel> getLessons(String level, String category, String language) {
    return _allLessons.where((l) => l.level == level && l.category == category && l.language == language).toList();
  }

  List<LessonModel> getAllLessons(String language) {
    return _allLessons.where((l) => l.language == language).toList();
  }

  void completeLesson(String lessonId, double score) {
    final i = _allLessons.indexWhere((l) => l.id == lessonId);
    if (i != -1) _allLessons[i] = _allLessons[i].copyWith(isCompleted: true, progress: score);
  }

  List<LessonModel> _allLessons = [
    LessonModel(id: '1', title: 'Greetings', description: 'Learn basic greetings', level: 'A1', language: 'English', category: 'Vocabulary', vocabulary: [], quiz: [], xpReward: 50),
    LessonModel(id: '2', title: 'Numbers 1-10', description: 'Learn to count', level: 'A1', language: 'English', category: 'Vocabulary', vocabulary: [], quiz: [], xpReward: 50),
    LessonModel(id: '3', title: 'Sentence Structure', description: 'Learn SVO order', level: 'A1', language: 'English', category: 'Grammar', grammar: [], quiz: [], xpReward: 75),
    LessonModel(id: '4', title: 'Listening Practice', description: 'Improve listening skills', level: 'A1', language: 'English', category: 'Listening', quiz: [], xpReward: 60),
  ];
}
