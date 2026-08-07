import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/models/curriculum.dart';
import '../data/models/question_bank.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  Curriculum? _curriculum;
  QuestionBank? _questionBank;

  Curriculum? get curriculum => _curriculum;
  QuestionBank? get questionBank => _questionBank;

  Future<void> initialize() async {
    await _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    try {
      final curriculumJson = await rootBundle.loadString('assets/data/curriculum_a1.json');
      _curriculum = Curriculum.fromJson(jsonDecode(curriculumJson));

      final questionsJson = await rootBundle.loadString('assets/data/questions_a1.json');
      _questionBank = QuestionBank.fromJson(jsonDecode(questionsJson));
    } catch (e) {
      // ignore: avoid_print
      print('Error loading local data: $e');
    }
  }

  List<Unit> get units => _curriculum?.units ?? [];

  List<Lesson> getLessonsForUnit(String unitId) {
    return units.firstWhere(
      (u) => u.id == unitId,
      orElse: () => Unit(
        id: '',
        title: '',
        titleArabic: '',
        description: '',
        order: 0,
        lessons: [],
      ),
    ).lessons;
  }

  Lesson? getLesson(String lessonId) {
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  List<Question> getQuestionsForLesson(String lessonId) {
    return _questionBank?.questions
            .where((q) => q.lessonId == lessonId)
            .toList() ??
        [];
  }
}
