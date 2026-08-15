import 'vocabulary_model.dart';

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String level;
  final String language;
  final String category;
  final List<VocabularyItem> vocabulary;
  final List<GrammarRule> grammar;
  final List<QuizQuestion> quiz;
  final int xpReward;
  final int orderIndex;
  final bool isLocked;
  final bool isCompleted;
  final double progress;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.language,
    required this.category,
    this.vocabulary = const [],
    this.grammar = const [],
    this.quiz = const [],
    this.xpReward = 50,
    this.orderIndex = 0,
    this.isLocked = false,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? level,
    String? language,
    String? category,
    List<VocabularyItem>? vocabulary,
    List<GrammarRule>? grammar,
    List<QuizQuestion>? quiz,
    int? xpReward,
    int? orderIndex,
    bool? isLocked,
    bool? isCompleted,
    double? progress,
  }) => LessonModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    level: level ?? this.level,
    language: language ?? this.language,
    category: category ?? this.category,
    vocabulary: vocabulary ?? this.vocabulary,
    grammar: grammar ?? this.grammar,
    quiz: quiz ?? this.quiz,
    xpReward: xpReward ?? this.xpReward,
    orderIndex: orderIndex ?? this.orderIndex,
    isLocked: isLocked ?? this.isLocked,
    isCompleted: isCompleted ?? this.isCompleted,
    progress: progress ?? this.progress,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'level': level,
    'language': language,
    'category': category,
    'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
    'grammar': grammar.map((g) => g.toJson()).toList(),
    'quiz': quiz.map((q) => q.toJson()).toList(),
    'xpReward': xpReward,
    'orderIndex': orderIndex,
    'isLocked': isLocked,
    'isCompleted': isCompleted,
    'progress': progress,
  };

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final vocabularyList = json['vocabulary'] as List? ??
        (json['content']?['body'] as List?) ??
        [];
    
    final grammarList = json['grammar'] as List? ?? [];
    final quizList = json['quiz'] as List? ?? [];
    
    return LessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 'A1',
      language: json['language'] ?? json['languageId'] ?? '',
      category: json['category'] ?? '',
      vocabulary: vocabularyList
          .map((v) => VocabularyItem.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
      grammar: grammarList
          .map((g) => GrammarRule.fromJson(Map<String, dynamic>.from(g)))
          .toList(),
      quiz: quizList
          .map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q)))
          .toList(),
      xpReward: json['xpReward'] ?? 50,
      orderIndex: json['orderIndex'] ?? 0,
      isLocked: json['isLocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }
}

class GrammarRule {
  final String title;
  final String explanation;
  final List<String> examples;
  final String? tip;

  const GrammarRule({
    required this.title,
    required this.explanation,
    required this.examples,
    this.tip,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'explanation': explanation,
    'examples': examples,
    'tip': tip,
  };

  factory GrammarRule.fromJson(Map<String, dynamic> json) => GrammarRule(
    title: json['title'] ?? '',
    explanation: json['explanation'] ?? '',
    examples: List<String>.from(json['examples'] ?? []),
    tip: json['tip'],
  );
}

class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String? explanation;
  final String type;

  const QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.explanation,
    this.type = 'multiple_choice',
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'correctAnswer': correctAnswer,
    'options': options,
    'explanation': explanation,
    'type': type,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    question: json['question'] ?? '',
    correctAnswer: json['correctAnswer'] ?? '',
    options: List<String>.from(json['options'] ?? []),
    explanation: json['explanation'],
    type: json['type'] ?? 'multiple_choice',
  );
}
