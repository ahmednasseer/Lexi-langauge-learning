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
  bool _isOffline = false;
  String? _error;

  List<LessonModel> get lessons => _lessons;
  String get selectedLevel => _selectedLevel;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get error => _error;

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

  Future<void> loadLessons(String language) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _isOffline = false;
    try {
      _lessons = await _repository.getAllLessons(language);
    } catch (e) {
      _error = 'Failed to load lessons.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLessonsByLevelCategory(String level, String category, String language) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _lessons = await _repository.getLessons(level, category, language);
    } catch (e) {
      _error = 'Failed to load lessons.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId, double score, int timeSpent) async {
    await _repository.completeLesson(lessonId, score, timeSpent);
    final i = _lessons.indexWhere((l) => l.id == lessonId);
    if (i != -1) {
      _lessons[i] = _lessons[i].copyWith(isCompleted: true, progress: score);
      notifyListeners();
    }
  }
}
