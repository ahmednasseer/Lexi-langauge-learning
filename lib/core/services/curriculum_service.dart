import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/curriculum.dart';
import '../../data/models/question_bank.dart';

class CurriculumService {
  static final CurriculumService _instance = CurriculumService._internal();
  factory CurriculumService() => _instance;
  CurriculumService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Curriculum? _curriculum;
  QuestionBank? _questionBank;
  bool _firebaseAvailable = false;

  Curriculum? get curriculum => _curriculum;
  QuestionBank? get questionBank => _questionBank;

  Future<void> initialize() async {
    await _tryLoadFromFirebase();
    if (!_firebaseAvailable) {
      await _loadFromLocal();
    }
  }

  Future<void> _tryLoadFromFirebase() async {
    try {
      final unitsSnapshot = await _db
          .collection('curriculum')
          .doc('a1')
          .collection('units')
          .orderBy('order')
          .get();

      if (unitsSnapshot.docs.isEmpty) {
        _firebaseAvailable = false;
        return;
      }

      final units = <Unit>[];
      for (final unitDoc in unitsSnapshot.docs) {
        final lessonsSnapshot = await unitDoc.reference
            .collection('lessons')
            .orderBy('order')
            .get();
        final lessons = lessonsSnapshot.docs
            .map((d) => Lesson.fromJson(d.data()))
            .toList();

        units.add(
          Unit(
            id: unitDoc.id,
            title: unitDoc.data()['title'] ?? '',
            titleArabic: unitDoc.data()['titleArabic'] ?? '',
            description: unitDoc.data()['description'] ?? '',
            order: unitDoc.data()['order'] ?? 0,
            lessons: lessons,
          ),
        );
      }

      _curriculum = Curriculum(
        version: '2.0',
        language: 'german',
        level: 'A1',
        title: 'Deutsch A1',
        description: 'A1 Kurs',
        units: units,
      );

      final questionsSnapshot = await _db
          .collection('questions')
          .doc('a1')
          .collection('questions')
          .get();

      final questions = questionsSnapshot.docs
          .map((d) => Question.fromJson(d.data()))
          .toList();

      _questionBank = QuestionBank(
        version: '2.0',
        language: 'german',
        level: 'A1',
        questionTypes: ['multipleChoice', 'trueFalse'],
        questions: questions,
      );

      _firebaseAvailable = true;
    } catch (e, st) {
      debugPrint('Failed to load from Firebase: $e\n$st');
      _firebaseAvailable = false;
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/curriculum_a1.json',
      );
      _curriculum = Curriculum.fromJson(jsonDecode(jsonString));

      final questionsJson = await rootBundle.loadString(
        'assets/data/questions_a1.json',
      );
      _questionBank = QuestionBank.fromJson(jsonDecode(questionsJson));
    } catch (e, st) {
      debugPrint('Failed to load local curriculum: $e\n$st');
    }
  }

  List<Unit> get units => _curriculum?.units ?? [];

  List<Lesson> getLessonsForUnit(String unitId) {
    final unit = units.firstWhere(
      (u) => u.id == unitId,
      orElse: () => Unit(
        id: '',
        title: '',
        titleArabic: '',
        description: '',
        order: 0,
        lessons: [],
      ),
    );
    return unit.lessons;
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

  Future<List<String>> getAudioUrls(String lessonId) async {
    try {
      final snapshot = await _db
          .collection('audio')
          .where('lessonId', isEqualTo: lessonId)
          .get();
      return snapshot.docs
          .map((d) => d.data()['url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Failed to load audio URLs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPronunciation(String lessonId) async {
    try {
      final snapshot = await _db
          .collection('pronunciation')
          .where('lessonId', isEqualTo: lessonId)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('Failed to load pronunciation: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getConversation(String lessonId) async {
    try {
      final snapshot = await _db
          .collection('conversation')
          .where('lessonId', isEqualTo: lessonId)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('Failed to load conversation: $e');
      return [];
    }
  }
}
