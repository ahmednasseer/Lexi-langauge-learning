import 'package:flutter/material.dart';
import 'package:lexi/features/goethe/models/exam_models.dart';
import 'goethe_exam_service.dart';
import 'goethe_repository.dart';

class GoetheExamController extends ChangeNotifier {
  final GoetheExamService _service = GoetheExamService();
  final GoetheRepository _repository = GoetheRepository();
  final String? _userId;
  List<ExamLevelModel> _levels = [];
  ExamLevelModel? _selectedLevel;
  List<ExamSection> _currentSections = [];
  MockExam? _currentExam;
  int _currentSectionIndex = 0;
  int _currentQuestionIndex = 0;
  Map<String, String> _answers = {};
  bool _isLoading = false;
  bool _levelsLoading = false;
  bool _levelsError = false;
  bool _examCompleted = false;
  bool _sectionsLoading = false;
  bool _sectionsError = false;
  UserExamProgress? _userProgress;
  List<ExamLevelModel> get levels => _levels;
  ExamLevelModel? get selectedLevel => _selectedLevel;
  List<ExamSection> get currentSections => _currentSections;
  MockExam? get currentExam => _currentExam;
  int get currentSectionIndex => _currentSectionIndex;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get answers => _answers;
  bool get isLoading => _isLoading;
  bool get levelsLoading => _levelsLoading;
  bool get levelsError => _levelsError;
  bool get examCompleted => _examCompleted;
  bool get sectionsLoading => _sectionsLoading;
  bool get sectionsError => _sectionsError;
  UserExamProgress? get userProgress => _userProgress;
  ExamSection? get currentSection => _currentSections.isNotEmpty
      ? _currentSections[_currentSectionIndex]
      : null;
  ExamQuestion? get currentQuestion =>
      currentSection != null && currentSection!.questions.isNotEmpty
      ? currentSection!.questions[_currentQuestionIndex]
      : null;
  int get totalQuestions =>
      _currentSections.fold(0, (sum, s) => sum + s.questions.length);
  int get answeredQuestions => _answers.length;
  double get progress =>
      totalQuestions > 0 ? answeredQuestions / totalQuestions : 0;
  GoetheExamController([this._userId]) {
    _loadLevels();
  }
  Future<void> _loadLevels() async {
    _levelsLoading = true;
    _levelsError = false;
    notifyListeners();
    try {
      final data = await _repository.getLevels();
      _levels = data.map((e) => ExamLevelModel.fromJson(e)).toList();
      if (_levels.isEmpty) _levels = _service.getExamLevels();
    } catch (e) {
      _levelsError = true;
      _levels = _service.getExamLevels();
    }
    _levelsLoading = false;
    notifyListeners();
  }

  Future<void> reloadLevels() => _loadLevels();
   Future<void> selectLevel(ExamLevelModel level) async {
    _selectedLevel = level;
    _sectionsLoading = true;
    _sectionsError = false;
    notifyListeners();
    try {
      _currentSections = await _service.getSectionsForLevel(
        ExamLevel.values.firstWhere(
          (e) => e.name.toUpperCase() == level.cefrLevel,
          orElse: () => ExamLevel.a1,
        ),
      );
    } catch (e) {
      _sectionsError = true;
      _currentSections = [];
    }
    _sectionsLoading = false;
    notifyListeners();
  }

  Future<void> startMockExam(ExamLevel level, String userId) async {
    if (_currentSections.isEmpty && _sectionsError) {
      return;
    }
    if (_currentSections.isEmpty) {
      return;
    }
    final totalPoints = _currentSections.fold<int>(0, (sum, s) => sum + s.totalPoints);
    _currentExam = _service.createMockExam(level, userId);
    _currentExam = _currentExam!.copyWith(totalPoints: totalPoints);
    _currentSectionIndex = 0;
    _currentQuestionIndex = 0;
    _answers = {};
    _examCompleted = false;
    notifyListeners();
  }

  void answerQuestion(String questionId, String answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentSection == null) return;
    if (_currentQuestionIndex < currentSection!.questions.length - 1) {
      _currentQuestionIndex++;
    } else if (_currentSectionIndex < _currentSections.length - 1) {
      _currentSectionIndex++;
      _currentQuestionIndex = 0;
    }
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
    } else if (_currentSectionIndex > 0) {
      _currentSectionIndex--;
      _currentQuestionIndex =
          _currentSections[_currentSectionIndex].questions.length - 1;
    }
    notifyListeners();
  }

  void goToSection(int index) {
    if (index >= 0 && index < _currentSections.length) {
      _currentSectionIndex = index;
      _currentQuestionIndex = 0;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (currentSection != null &&
        index >= 0 &&
        index < currentSection!.questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  ExamResult completeExam() {
    if (_currentExam == null) {
      return const ExamResult(
        passed: false,
        scorePercentage: 0,
        grade: 'F',
        feedback: 'No exam in progress',
        strengths: [],
        weaknesses: [],
        recommendation: 'Start an exam first',
      );
    }
    final result = _service.evaluateExam(_currentExam!, _answers);
    _examCompleted = true;
    notifyListeners();
    return result;
  }

  void resetExam() {
    _currentExam = null;
    _currentSectionIndex = 0;
    _currentQuestionIndex = 0;
    _answers = {};
    _examCompleted = false;
    notifyListeners();
  }

  List<ExamQuestion> getQuestionsForSection(ExamSectionType type) {
    final section = _currentSections.firstWhere(
      (s) => s.type == type,
      orElse: () => _currentSections.first,
    );
    return section.questions;
  }

  Map<String, dynamic> getExamStats() {
    int correct = 0;
    int total = 0;
    for (final section in _currentSections) {
      for (final question in section.questions) {
        total++;
        if (_answers[question.id] == question.correctAnswer) {
          correct++;
        }
      }
    }
    return {
      'correct': correct,
      'total': total,
      'percentage': total > 0 ? (correct / total * 100) : 0,
      'answered': _answers.length,
    };
  }

  List<ExamQuestion> getIncorrectQuestions() {
    final incorrect = <ExamQuestion>[];
    for (final section in _currentSections) {
      for (final question in section.questions) {
        if (_answers.containsKey(question.id) &&
            _answers[question.id] != question.correctAnswer) {
          incorrect.add(question);
        }
      }
    }
    return incorrect;
  }

  List<ExamQuestion> getUnansweredQuestions() {
    final unanswered = <ExamQuestion>[];
    for (final section in _currentSections) {
      for (final question in section.questions) {
        if (!_answers.containsKey(question.id)) {
          unanswered.add(question);
        }
      }
    }
    return unanswered;
  }
}
