import 'package:flutter/material.dart';
import 'package:lexi/features/speaking/models/speaking_exercise.dart';
import 'package:lexi/features/speaking/models/pronunciation_result.dart';
import 'package:lexi/features/speaking/models/listening_question.dart';
import 'package:lexi/features/speaking/speaking_repository.dart';

enum SpeakingMode { idle, listening, processing, result }

enum ListeningMode { idle, playing, answered }

class SpeakingController extends ChangeNotifier {
  final List<SpeakingExercise> _exercises;
  final List<ListeningQuestion> _questions;
  final SpeakingRepository? _speakingRepository;
  SpeakingController({
    required String level,
    SpeakingRepository? speakingRepository,
  })  : _exercises = SpeakingExercise.getExercisesByLevel(level),
        _questions = ListeningQuestion.getQuestionsByLevel(level),
        _speakingRepository = speakingRepository;
  SpeakingMode _speakingMode = SpeakingMode.idle;
  ListeningMode _listeningMode = ListeningMode.idle;
  String _selectedLevel = 'A1';
  int _currentExerciseIndex = 0;
  int _currentQuestionIndex = 0;
  PronunciationResult? _lastResult;
  bool _isCorrect = false;
  int _totalXp = 0;
  int _streak = 0;
  SpeakingMode get speakingMode => _speakingMode;
  ListeningMode get listeningMode => _listeningMode;
  String get selectedLevel => _selectedLevel;
  List<SpeakingExercise> get exercises => _exercises;
  List<ListeningQuestion> get questions => _questions;
  SpeakingExercise? get currentExercise =>
      _exercises.isNotEmpty ? _exercises[_currentExerciseIndex] : null;
  ListeningQuestion? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  PronunciationResult? get lastResult => _lastResult;
  bool get isCorrect => _isCorrect;
  int get totalXp => _totalXp;
  int get streak => _streak;
  bool get hasNextExercise => _currentExerciseIndex < _exercises.length - 1;
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  void setLevel(String level) {
    _selectedLevel = level;
    _currentExerciseIndex = 0;
    _currentQuestionIndex = 0;
    _lastResult = null;
    _speakingMode = SpeakingMode.idle;
    _listeningMode = ListeningMode.idle;
    notifyListeners();
  }

  void startSpeaking() {
    _speakingMode = SpeakingMode.listening;
    notifyListeners();
  }

  Future<void> processSpokenText(String spokenText) async {
    if (currentExercise == null) return;
    _speakingMode = SpeakingMode.processing;
    notifyListeners();

    PronunciationResult result;
    if (_speakingRepository != null) {
      try {
        final data = await _speakingRepository.analyzePronunciation(
          spokenText: spokenText,
          targetText: currentExercise!.sentence,
          level: _selectedLevel,
        );
        result = PronunciationResult(
          accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
          fluency: (data['fluency'] as num?)?.toDouble() ?? 0.0,
          grammar: (data['grammar'] as num?)?.toDouble() ?? 0.0,
          mistakes: List<String>.from(data['mistakes'] ?? []),
          suggestions: List<String>.from(data['suggestions'] ?? []),
          spokenText: spokenText,
          targetText: currentExercise!.sentence,
          xpEarned: data['xpEarned'] ?? 0,
        );
      } catch (e) {
        result = PronunciationResult.analyze(spokenText, currentExercise!.sentence);
      }
    } else {
      result = PronunciationResult.analyze(spokenText, currentExercise!.sentence);
    }

    _lastResult = result;
    if (result.isGood) {
      _streak++;
    } else {
      _streak = 0;
    }
    _speakingMode = SpeakingMode.result;
    notifyListeners();
  }

  void stopSpeaking() {
    _speakingMode = SpeakingMode.idle;
    notifyListeners();
  }

  void startListening() {
    _listeningMode = ListeningMode.playing;
    notifyListeners();
  }

  void answerListeningQuestion(int selectedIndex) {
    if (currentQuestion == null) return;
    _isCorrect = selectedIndex == currentQuestion!.correctIndex;
    _listeningMode = ListeningMode.answered;
    notifyListeners();
  }

  void nextExercise() {
    if (hasNextExercise) {
      _currentExerciseIndex++;
      _lastResult = null;
      _speakingMode = SpeakingMode.idle;
      notifyListeners();
    }
  }

  void previousExercise() {
    if (_currentExerciseIndex > 0) {
      _currentExerciseIndex--;
      _lastResult = null;
      _speakingMode = SpeakingMode.idle;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (hasNextQuestion) {
      _currentQuestionIndex++;
      _listeningMode = ListeningMode.idle;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _listeningMode = ListeningMode.idle;
      notifyListeners();
    }
  }

  void resetExercise() {
    _lastResult = null;
    _speakingMode = SpeakingMode.idle;
    _listeningMode = ListeningMode.idle;
    notifyListeners();
  }
}
