enum ExamLevel { a1, a2, b1, b2 }
enum ExamSectionType { reading, listening, writing, speaking }
enum QuestionType { multipleChoice, fillBlank, matching, trueFalse, shortAnswer, essay, audioResponse }
enum DifficultyLevel { easy, medium, hard }

class ExamLevelModel {
  final String id;
  final String name;
  final String cefrLevel;
  final String description;
  final int totalQuestions;
  final int passingScore;
  final int timeLimitMinutes;
  final List<ExamSection> sections;

  const ExamLevelModel({
    required this.id,
    required this.name,
    required this.cefrLevel,
    required this.description,
    required this.totalQuestions,
    required this.passingScore,
    required this.timeLimitMinutes,
    required this.sections,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cefrLevel': cefrLevel,
    'description': description,
    'totalQuestions': totalQuestions,
    'passingScore': passingScore,
    'timeLimitMinutes': timeLimitMinutes,
    'sections': sections.map((s) => s.toJson()).toList(),
  };

  factory ExamLevelModel.fromJson(Map<String, dynamic> json) => ExamLevelModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    cefrLevel: json['cefrLevel'] ?? 'A1',
    description: json['description'] ?? '',
    totalQuestions: json['totalQuestions'] ?? 0,
    passingScore: json['passingScore'] ?? 60,
    timeLimitMinutes: json['timeLimitMinutes'] ?? 60,
    sections: (json['sections'] as List? ?? []).map((s) => ExamSection.fromJson(s)).toList(),
  );

  static List<ExamLevelModel> getDefaultLevels() {
    return [
      const ExamLevelModel(
        id: 'goethe_a1',
        name: 'Goethe A1',
        cefrLevel: 'A1',
        description: 'Start Deutsch 1 - Basic language use for beginners',
        totalQuestions: 60,
        passingScore: 60,
        timeLimitMinutes: 60,
        sections: [],
      ),
      const ExamLevelModel(
        id: 'goethe_a2',
        name: 'Goethe A2',
        cefrLevel: 'A2',
        description: 'Start Deutsch 2 - Elementary language use',
        totalQuestions: 65,
        passingScore: 60,
        timeLimitMinutes: 70,
        sections: [],
      ),
      const ExamLevelModel(
        id: 'goethe_b1',
        name: 'Goethe B1',
        cefrLevel: 'B1',
        description: 'Zertifikat Deutsch - Intermediate language use',
        totalQuestions: 75,
        passingScore: 60,
        timeLimitMinutes: 90,
        sections: [],
      ),
      const ExamLevelModel(
        id: 'goethe_b2',
        name: 'Goethe B2',
        cefrLevel: 'B2',
        description: 'Zertifikat Deutsch - Upper intermediate language use',
        totalQuestions: 80,
        passingScore: 60,
        timeLimitMinutes: 105,
        sections: [],
      ),
    ];
  }
}

class ExamSection {
  final String id;
  final ExamSectionType type;
  final String name;
  final String description;
  final int questionCount;
  final int timeLimitMinutes;
  final int totalPoints;
  final List<ExamQuestion> questions;

  const ExamSection({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.questionCount,
    required this.timeLimitMinutes,
    required this.totalPoints,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'description': description,
    'questionCount': questionCount,
    'timeLimitMinutes': timeLimitMinutes,
    'totalPoints': totalPoints,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory ExamSection.fromJson(Map<String, dynamic> json) => ExamSection(
    id: json['id'] ?? '',
    type: ExamSectionType.values.firstWhere((e) => e.name == json['type'], orElse: () => ExamSectionType.reading),
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    questionCount: json['questionCount'] ?? 0,
    timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
    totalPoints: json['totalPoints'] ?? 0,
    questions: (json['questions'] as List? ?? []).map((q) => ExamQuestion.fromJson(q)).toList(),
  );

  String get typeEmoji {
    switch (type) {
      case ExamSectionType.reading: return '📖';
      case ExamSectionType.listening: return '🎧';
      case ExamSectionType.writing: return '✍️';
      case ExamSectionType.speaking: return '🎤';
    }
  }
}

class ExamQuestion {
  final String id;
  final String sectionId;
  final QuestionType type;
  final String question;
  final String? passage;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? audioUrl;
  final DifficultyLevel difficulty;
  final int points;
  final Map<String, String>? matchingPairs;

  const ExamQuestion({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.question,
    this.passage,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.audioUrl,
    required this.difficulty,
    required this.points,
    this.matchingPairs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sectionId': sectionId,
    'type': type.name,
    'question': question,
    'passage': passage,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'audioUrl': audioUrl,
    'difficulty': difficulty.name,
    'points': points,
    'matchingPairs': matchingPairs,
  };

  factory ExamQuestion.fromJson(Map<String, dynamic> json) => ExamQuestion(
    id: json['id'] ?? '',
    sectionId: json['sectionId'] ?? '',
    type: QuestionType.values.firstWhere((e) => e.name == json['type'], orElse: () => QuestionType.multipleChoice),
    question: json['question'] ?? '',
    passage: json['passage'],
    options: List<String>.from(json['options'] ?? []),
    correctAnswer: json['correctAnswer'] ?? '',
    explanation: json['explanation'] ?? '',
    audioUrl: json['audioUrl'],
    difficulty: DifficultyLevel.values.firstWhere((e) => e.name == json['difficulty'], orElse: () => DifficultyLevel.medium),
    points: json['points'] ?? 1,
    matchingPairs: json['matchingPairs'] != null ? Map<String, String>.from(json['matchingPairs']) : null,
  );

  String get difficultyText {
    switch (difficulty) {
      case DifficultyLevel.easy: return 'Easy';
      case DifficultyLevel.medium: return 'Medium';
      case DifficultyLevel.hard: return 'Hard';
    }
  }
}

class MockExam {
  final String id;
  final String userId;
  final ExamLevel level;
  final int score;
  final int totalPoints;
  final int timeSpentSeconds;
  final List<SectionResult> completedSections;
  final ExamResult result;
  final DateTime startedAt;
  final DateTime completedAt;

  const MockExam({
    required this.id,
    required this.userId,
    required this.level,
    required this.score,
    required this.totalPoints,
    required this.timeSpentSeconds,
    required this.completedSections,
    required this.result,
    required this.startedAt,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'level': level.name,
    'score': score,
    'totalPoints': totalPoints,
    'timeSpentSeconds': timeSpentSeconds,
    'completedSections': completedSections.map((s) => s.toJson()).toList(),
    'result': result.toJson(),
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
  };

  factory MockExam.fromJson(Map<String, dynamic> json) => MockExam(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    level: ExamLevel.values.firstWhere((e) => e.name == json['level'], orElse: () => ExamLevel.a1),
    score: json['score'] ?? 0,
    totalPoints: json['totalPoints'] ?? 0,
    timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
    completedSections: (json['completedSections'] as List? ?? []).map((s) => SectionResult.fromJson(s)).toList(),
    result: ExamResult.fromJson(json['result'] ?? {}),
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : DateTime.now(),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : DateTime.now(),
  );

  double get scorePercentage => totalPoints > 0 ? (score / totalPoints * 100) : 0;
  bool get passed => scorePercentage >= 60;
}

class SectionResult {
  final ExamSectionType type;
  final int score;
  final int totalPoints;
  final int timeSpentSeconds;
  final int correctAnswers;
  final int totalQuestions;

  const SectionResult({
    required this.type,
    required this.score,
    required this.totalPoints,
    required this.timeSpentSeconds,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'score': score,
    'totalPoints': totalPoints,
    'timeSpentSeconds': timeSpentSeconds,
    'correctAnswers': correctAnswers,
    'totalQuestions': totalQuestions,
  };

  factory SectionResult.fromJson(Map<String, dynamic> json) => SectionResult(
    type: ExamSectionType.values.firstWhere((e) => e.name == json['type'], orElse: () => ExamSectionType.reading),
    score: json['score'] ?? 0,
    totalPoints: json['totalPoints'] ?? 0,
    timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
    correctAnswers: json['correctAnswers'] ?? 0,
    totalQuestions: json['totalQuestions'] ?? 0,
  );

  double get percentage => totalPoints > 0 ? (score / totalPoints * 100) : 0;
}

class ExamResult {
  final bool passed;
  final double scorePercentage;
  final String grade;
  final String feedback;
  final List<String> strengths;
  final List<String> weaknesses;
  final String recommendation;

  const ExamResult({
    required this.passed,
    required this.scorePercentage,
    required this.grade,
    required this.feedback,
    required this.strengths,
    required this.weaknesses,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
    'passed': passed,
    'scorePercentage': scorePercentage,
    'grade': grade,
    'feedback': feedback,
    'strengths': strengths,
    'weaknesses': weaknesses,
    'recommendation': recommendation,
  };

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
    passed: json['passed'] ?? false,
    scorePercentage: (json['scorePercentage'] ?? 0).toDouble(),
    grade: json['grade'] ?? 'F',
    feedback: json['feedback'] ?? '',
    strengths: List<String>.from(json['strengths'] ?? []),
    weaknesses: List<String>.from(json['weaknesses'] ?? []),
    recommendation: json['recommendation'] ?? '',
  );
}

class WritingSubmission {
  final String id;
  final String userId;
  final ExamLevel level;
  final String prompt;
  final String userText;
  final WritingEvaluation? evaluation;
  final DateTime submittedAt;

  const WritingSubmission({
    required this.id,
    required this.userId,
    required this.level,
    required this.prompt,
    required this.userText,
    this.evaluation,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'level': level.name,
    'prompt': prompt,
    'userText': userText,
    'evaluation': evaluation?.toJson(),
    'submittedAt': submittedAt.toIso8601String(),
  };

  factory WritingSubmission.fromJson(Map<String, dynamic> json) => WritingSubmission(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    level: ExamLevel.values.firstWhere((e) => e.name == json['level'], orElse: () => ExamLevel.a1),
    prompt: json['prompt'] ?? '',
    userText: json['userText'] ?? '',
    evaluation: json['evaluation'] != null ? WritingEvaluation.fromJson(json['evaluation']) : null,
    submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : DateTime.now(),
  );
}

class WritingEvaluation {
  final double grammarScore;
  final double vocabularyScore;
  final double structureScore;
  final double overallScore;
  final List<String> corrections;
  final List<String> suggestions;
  final String feedback;

  const WritingEvaluation({
    required this.grammarScore,
    required this.vocabularyScore,
    required this.structureScore,
    required this.overallScore,
    required this.corrections,
    required this.suggestions,
    required this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'grammarScore': grammarScore,
    'vocabularyScore': vocabularyScore,
    'structureScore': structureScore,
    'overallScore': overallScore,
    'corrections': corrections,
    'suggestions': suggestions,
    'feedback': feedback,
  };

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) => WritingEvaluation(
    grammarScore: (json['grammarScore'] ?? 0).toDouble(),
    vocabularyScore: (json['vocabularyScore'] ?? 0).toDouble(),
    structureScore: (json['structureScore'] ?? 0).toDouble(),
    overallScore: (json['overallScore'] ?? 0).toDouble(),
    corrections: List<String>.from(json['corrections'] ?? []),
    suggestions: List<String>.from(json['suggestions'] ?? []),
    feedback: json['feedback'] ?? '',
  );

  String get grade {
    if (overallScore >= 90) return 'A';
    if (overallScore >= 80) return 'B';
    if (overallScore >= 70) return 'C';
    if (overallScore >= 60) return 'D';
    return 'F';
  }
}

class SpeakingEvaluation {
  final double pronunciationScore;
  final double fluencyScore;
  final double grammarScore;
  final double vocabularyScore;
  final double overallScore;
  final List<String> mistakes;
  final List<String> suggestions;
  final String feedback;

  const SpeakingEvaluation({
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.overallScore,
    required this.mistakes,
    required this.suggestions,
    required this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'pronunciationScore': pronunciationScore,
    'fluencyScore': fluencyScore,
    'grammarScore': grammarScore,
    'vocabularyScore': vocabularyScore,
    'overallScore': overallScore,
    'mistakes': mistakes,
    'suggestions': suggestions,
    'feedback': feedback,
  };

  factory SpeakingEvaluation.fromJson(Map<String, dynamic> json) => SpeakingEvaluation(
    pronunciationScore: (json['pronunciationScore'] ?? 0).toDouble(),
    fluencyScore: (json['fluencyScore'] ?? 0).toDouble(),
    grammarScore: (json['grammarScore'] ?? 0).toDouble(),
    vocabularyScore: (json['vocabularyScore'] ?? 0).toDouble(),
    overallScore: (json['overallScore'] ?? 0).toDouble(),
    mistakes: List<String>.from(json['mistakes'] ?? []),
    suggestions: List<String>.from(json['suggestions'] ?? []),
    feedback: json['feedback'] ?? '',
  );
}

class UserExamProgress {
  final String userId;
  final Map<ExamLevel, LevelProgress> levelProgress;
  final int totalExamsTaken;
  final int examsPassed;
  final double averageScore;
  final DateTime lastExamDate;

  const UserExamProgress({
    required this.userId,
    required this.levelProgress,
    required this.totalExamsTaken,
    required this.examsPassed,
    required this.averageScore,
    required this.lastExamDate,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'levelProgress': levelProgress.map((k, v) => MapEntry(k.name, v.toJson())),
    'totalExamsTaken': totalExamsTaken,
    'examsPassed': examsPassed,
    'averageScore': averageScore,
    'lastExamDate': lastExamDate.toIso8601String(),
  };

  factory UserExamProgress.fromJson(Map<String, dynamic> json) => UserExamProgress(
    userId: json['userId'] ?? '',
    levelProgress: (json['levelProgress'] as Map? ?? {}).map(
      (k, v) => MapEntry(
        ExamLevel.values.firstWhere((e) => e.name == k, orElse: () => ExamLevel.a1),
        LevelProgress.fromJson(v),
      ),
    ),
    totalExamsTaken: json['totalExamsTaken'] ?? 0,
    examsPassed: json['examsPassed'] ?? 0,
    averageScore: (json['averageScore'] ?? 0).toDouble(),
    lastExamDate: json['lastExamDate'] != null ? DateTime.parse(json['lastExamDate']) : DateTime.now(),
  );
}

class LevelProgress {
  final int examsTaken;
  final int examsPassed;
  final double bestScore;
  final double averageScore;
  final Map<String, double> sectionScores;

  const LevelProgress({
    required this.examsTaken,
    required this.examsPassed,
    required this.bestScore,
    required this.averageScore,
    required this.sectionScores,
  });

  Map<String, dynamic> toJson() => {
    'examsTaken': examsTaken,
    'examsPassed': examsPassed,
    'bestScore': bestScore,
    'averageScore': averageScore,
    'sectionScores': sectionScores,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
    examsTaken: json['examsTaken'] ?? 0,
    examsPassed: json['examsPassed'] ?? 0,
    bestScore: (json['bestScore'] ?? 0).toDouble(),
    averageScore: (json['averageScore'] ?? 0).toDouble(),
    sectionScores: Map<String, double>.from(json['sectionScores'] ?? {}),
  );
}
