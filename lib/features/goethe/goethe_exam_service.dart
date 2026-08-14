import 'package:lexi/core/services/api_service.dart';
import 'package:lexi/features/goethe/models/exam_models.dart';

class GoetheExamService {
  final ApiService _api = ApiService();

  List<ExamLevelModel> getExamLevels() {
    return ExamLevelModel.getDefaultLevels();
  }

  ExamLevelModel? getExamLevel(ExamLevel level) {
    try {
      return ExamLevelModel.getDefaultLevels().firstWhere(
        (l) => l.cefrLevel == level.name.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<ExamSection> getReadingSection(ExamLevel level) async {
    final count = _getQuestionCount(level, ExamSectionType.reading);
    final questions = await _fetchQuestionsFromApi(level, 'reading', count);
    return ExamSection(
      id: '${level.name}_reading',
      type: ExamSectionType.reading,
      name: 'Lesen (Reading)',
      description: 'Test your reading comprehension with real curriculum questions',
      questionCount: questions.length,
      timeLimitMinutes: _getTimeLimit(level, ExamSectionType.reading),
      totalPoints: questions.length * 2,
      questions: questions,
    );
  }

  Future<ExamSection> getListeningSection(ExamLevel level) async {
    final count = _getQuestionCount(level, ExamSectionType.listening);
    final questions = await _fetchQuestionsFromApi(level, 'listening', count);
    return ExamSection(
      id: '${level.name}_listening',
      type: ExamSectionType.listening,
      name: 'Hören (Listening)',
      description: 'Test your listening comprehension',
      questionCount: questions.length,
      timeLimitMinutes: _getTimeLimit(level, ExamSectionType.listening),
      totalPoints: questions.length * 2,
      questions: questions,
    );
  }

  Future<List<ExamSection>> getSectionsForLevel(ExamLevel level) async {
    return [
      await getReadingSection(level),
      await getListeningSection(level),
    ];
  }

  Future<List<ExamQuestion>> _fetchQuestionsFromApi(
    ExamLevel level,
    String section,
    int count,
  ) async {
    final levelStr = level.name.toUpperCase();
    try {
      final response = await _api.getQuestionsForLevel(levelStr);
      if (response.isSuccess && response.data != null) {
        final questions = (response.data as List)
            .map((e) => _mapApiQuestionToExamQuestion(
                e as Map<String, dynamic>, level, section))
            .toList();
        if (questions.isNotEmpty) {
          return questions.take(count).toList();
        }
      }
    } catch (e) {
      throw ApiException(
        message: 'Failed to load exam questions: $e',
        statusCode: 0,
      );
    }

    return <ExamQuestion>[];
  }

  ExamQuestion _mapApiQuestionToExamQuestion(
    Map<String, dynamic> json,
    ExamLevel level,
    String section,
  ) {
    final typeStr = json['type'] as String? ?? 'multipleChoice';
    final questionType = switch (typeStr) {
      'multipleChoice' => QuestionType.multipleChoice,
      'trueFalse' => QuestionType.trueFalse,
      'essay' => QuestionType.essay,
      'shortAnswer' => QuestionType.shortAnswer,
      'translation' => QuestionType.multipleChoice,
      _ => QuestionType.multipleChoice,
    };

    final options = (json['options'] as List?)?.cast<String>() ?? [];
    if (questionType == QuestionType.trueFalse && options.isEmpty) {
      options.addAll(['true', 'false']);
    }

    return ExamQuestion(
      id: json['id'] ?? '${section}_${level.name}_${json.hashCode}',
      sectionId: '${level.name}_$section',
      type: questionType,
      question: json['question'] as String? ?? '',
      options: options,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      difficulty: DifficultyLevel.medium,
      points: section == 'reading' || section == 'listening' ? 2 : 5,
    );
  }

  int _getQuestionCount(ExamLevel level, ExamSectionType section) {
    final counts = {
      ExamLevel.a1: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
      },
      ExamLevel.a2: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
      },
      ExamLevel.b1: {
        ExamSectionType.reading: 20,
        ExamSectionType.listening: 20,
      },
      ExamLevel.b2: {
        ExamSectionType.reading: 20,
        ExamSectionType.listening: 20,
      },
    };
    return counts[level]?[section] ?? 10;
  }

  int _getTimeLimit(ExamLevel level, ExamSectionType section) {
    final times = {
      ExamLevel.a1: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
      },
      ExamLevel.a2: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
      },
      ExamLevel.b1: {
        ExamSectionType.reading: 20,
        ExamSectionType.listening: 20,
      },
      ExamLevel.b2: {
        ExamSectionType.reading: 25,
        ExamSectionType.listening: 25,
      },
    };
    return times[level]?[section] ?? 20;
  }

  MockExam createMockExam(ExamLevel level, String userId) {
    return MockExam(
      id: 'exam_${level.name}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      level: level,
      score: 0,
      totalPoints: 0,
      timeSpentSeconds: 0,
      completedSections: [],
      result: ExamResult(
        passed: false,
        scorePercentage: 0,
        grade: '-',
        feedback: 'Exam not yet completed',
        strengths: [],
        weaknesses: [],
        recommendation: 'Complete the exam to see your results',
      ),
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  ExamResult evaluateExam(MockExam exam, Map<String, String> answers) {
    int totalScore = 0;
    int totalPoints = exam.totalPoints;
    final sectionResults = <SectionResult>[];
    for (final section in exam.completedSections) {
      totalScore += section.score;
      sectionResults.add(section);
    }
    final percentage = totalPoints > 0
        ? (totalScore / totalPoints * 100).toDouble()
        : 0.0;
    final passed = percentage >= 60;
    final grade = _calculateGrade(percentage);
    final strengths = _identifyStrengths(sectionResults);
    final weaknesses = _identifyWeaknesses(sectionResults);
    final recommendation = _generateRecommendation(percentage, weaknesses);
    return ExamResult(
      passed: passed,
      scorePercentage: percentage,
      grade: grade,
      feedback: _generateFeedback(percentage, strengths, weaknesses),
      strengths: strengths,
      weaknesses: weaknesses,
      recommendation: recommendation,
    );
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  List<String> _identifyStrengths(List<SectionResult> results) {
    final strengths = <String>[];
    for (final result in results) {
      if (result.percentage >= 80) {
        strengths.add(_getSectionName(result.type));
      }
    }
    return strengths;
  }

  List<String> _identifyWeaknesses(List<SectionResult> results) {
    final weaknesses = <String>[];
    for (final result in results) {
      if (result.percentage < 60) {
        weaknesses.add(_getSectionName(result.type));
      }
    }
    return weaknesses;
  }

  String _generateRecommendation(double percentage, List<String> weaknesses) {
    if (percentage >= 80) return 'You are well-prepared! Continue practicing to maintain your level.';
    if (percentage >= 60) return 'Review your weak areas: ${weaknesses.join(', ')}. Focus on targeted practice.';
    return 'Continue studying and complete more lessons to build your foundation.';
  }

  String _generateFeedback(double percentage, List<String> strengths, List<String> weaknesses) {
    if (percentage >= 80) {
      return 'Strong performance! Continue with advanced practice to maintain your skills.';
    }
    if (percentage >= 60) {
      if (weaknesses.isNotEmpty) {
        return 'You passed. Focus on improving: ${weaknesses.join(', ')}.';
      }
      return 'Good job! Keep practicing to improve your score.';
    }
    return 'Review the material and complete more lessons before retaking this exam.';
  }

  String _getSectionName(ExamSectionType type) {
    switch (type) {
      case ExamSectionType.reading:
        return 'Reading';
      case ExamSectionType.listening:
        return 'Listening';
      case ExamSectionType.writing:
        return 'Writing';
      case ExamSectionType.speaking:
        return 'Speaking';
    }
  }
}
