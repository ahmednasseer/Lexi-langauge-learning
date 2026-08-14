import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../bloc/progress_cubit.dart';

// States
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizAnswering extends QuizState {
  final int currentQuestionIndex;
  final int totalQuestions;
  final int score;
  final String? selectedAnswer;
  final bool showExplanation;

  const QuizAnswering({
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.score = 0,
    this.selectedAnswer,
    this.showExplanation = false,
  });

  @override
  List<Object?> get props => [
    currentQuestionIndex,
    totalQuestions,
    score,
    selectedAnswer,
    showExplanation,
  ];
}

class QuizCompleted extends QuizState {
  final int score;
  final int totalQuestions;
  final double percentage;
  final int xpEarned;
  final bool passed;

  const QuizCompleted({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.xpEarned,
    required this.passed,
  });

  @override
  List<Object?> get props => [
    score,
    totalQuestions,
    percentage,
    xpEarned,
    passed,
  ];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class QuizCubit extends Cubit<QuizState> {
  final ProgressCubit progressCubit;
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<String> _correctAnswers = [];
  List<String> _userAnswers = [];
  String? _selectedAnswer;
  bool _showExplanation = false;

  QuizCubit(this.progressCubit) : super(QuizInitial());

  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;

  void answerQuestion(String answer, String correctAnswer) {
    _selectedAnswer = answer;
    _showExplanation = true;
    _userAnswers.add(answer);
    _correctAnswers.add(correctAnswer);

    if (answer == correctAnswer) {
      _score++;
    }

    emit(
      QuizAnswering(
        currentQuestionIndex: _currentQuestionIndex,
        totalQuestions: _correctAnswers.length,
        score: _score,
        selectedAnswer: _selectedAnswer,
        showExplanation: _showExplanation,
      ),
    );
  }

  void nextQuestion() {
    _currentQuestionIndex++;
    _selectedAnswer = null;
    _showExplanation = false;

    emit(
      QuizAnswering(
        currentQuestionIndex: _currentQuestionIndex,
        totalQuestions: _correctAnswers.length,
        score: _score,
      ),
    );
  }

  void completeQuiz({
    required String userId,
    required String lessonId,
    required String category,
    required int totalQuestions,
  }) {
    final percentage = totalQuestions > 0 ? _score / totalQuestions : 0.0;
    final xpEarned = _calculateXp(percentage, 50);
    final passed = percentage >= 0.7;

    emit(
      QuizCompleted(
        score: _score,
        totalQuestions: totalQuestions,
        percentage: percentage,
        xpEarned: xpEarned,
        passed: passed,
      ),
    );

    progressCubit.completeLesson(
      userId: userId,
      lessonId: lessonId,
      category: category,
      quizScore: percentage,
    );
  }

  int _calculateXp(double percentage, int baseXp) {
    int xp = (baseXp * percentage).round();
    if (percentage >= 0.9)
      xp += 20;
    else if (percentage >= 0.7)
      xp += 10;
    return xp;
  }

  void reset() {
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswers = [];
    _userAnswers = [];
    _selectedAnswer = null;
    _showExplanation = false;
    emit(QuizInitial());
  }
}
