import 'package:flutter/material.dart';
import 'models/lesson_model.dart';
import 'lesson_repository.dart';

class LessonController extends ChangeNotifier {
  final LessonRepository _repository;

  LessonController(this._repository);

  List<LessonModel> _lessons = [];
  String _selectedLevel = 'A1';
  String _selectedCategory = 'Vocabulary';
  bool _isLoading = false;

  List<LessonModel> get lessons => _lessons;
  String get selectedLevel => _selectedLevel;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<LessonModel> get filtered =>
      _lessons.where((l) => l.level == _selectedLevel && l.category == _selectedCategory).toList();

  void setLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void loadLessons(String language) {
    _isLoading = true;
    notifyListeners();
    _lessons = _repository.getAllLessons(language);
    _isLoading = false;
    notifyListeners();
  }

  void completeLesson(String lessonId, double score) {
    _repository.completeLesson(lessonId, score);
    final i = _lessons.indexWhere((l) => l.id == lessonId);
    if (i != -1) {
      _lessons[i] = _lessons[i].copyWith(isCompleted: true, progress: score);
      notifyListeners();
    }
  }
}
