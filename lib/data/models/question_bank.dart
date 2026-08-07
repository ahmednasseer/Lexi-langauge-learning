class QuestionBank {
  final String version;
  final String language;
  final String level;
  final List<String> questionTypes;
  final List<Question> questions;

  QuestionBank({
    required this.version,
    required this.language,
    required this.level,
    required this.questionTypes,
    required this.questions,
  });

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
      version: json['version'] ?? '',
      language: json['language'] ?? '',
      level: json['level'] ?? '',
      questionTypes: List<String>.from(json['questionTypes'] ?? []),
      questions: (json['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String lessonId;
  final String type;
  final String question;
  final String questionArabic;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final bool? boolAnswer;

  Question({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.questionArabic,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.boolAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      questionArabic: json['questionArabic'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
      boolAnswer: json['correctAnswer'] is bool ? json['correctAnswer'] : null,
    );
  }

  bool get isTrueFalse => type == 'trueFalse';
  bool get isMultipleChoice => type == 'multipleChoice';
}
