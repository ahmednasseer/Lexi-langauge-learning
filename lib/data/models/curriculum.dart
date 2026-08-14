class Curriculum {
  final String version;
  final String language;
  final String level;
  final String title;
  final String description;
  final List<Unit> units;

  Curriculum({
    required this.version,
    required this.language,
    required this.level,
    required this.title,
    required this.description,
    required this.units,
  });

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      version: json['version'] ?? '',
      language: json['language'] ?? '',
      level: json['level'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      units: (json['units'] as List? ?? [])
          .map((u) => Unit.fromJson(u))
          .toList(),
    );
  }
}

class Unit {
  final String id;
  final String title;
  final String titleArabic;
  final String description;
  final int order;
  final List<Lesson> lessons;

  Unit({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleArabic: json['titleArabic'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      lessons: (json['lessons'] as List? ?? [])
          .map((l) => Lesson.fromJson(l))
          .toList(),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String titleArabic;
  final int order;
  final List<VocabularyItem> vocabulary;
  final Grammar? grammar;
  final List<Phrase> phrases;

  Lesson({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.order,
    required this.vocabulary,
    this.grammar,
    required this.phrases,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleArabic: json['titleArabic'] ?? '',
      order: json['order'] ?? 0,
      vocabulary: (json['vocabulary'] as List? ?? [])
          .map((v) => VocabularyItem.fromJson(v))
          .toList(),
      grammar: json['grammar'] != null
          ? Grammar.fromJson(json['grammar'])
          : null,
      phrases: (json['phrases'] as List? ?? [])
          .map((p) => Phrase.fromJson(p))
          .toList(),
    );
  }
}

class VocabularyItem {
  final String german;
  final String arabic;
  final String? example;

  VocabularyItem({required this.german, required this.arabic, this.example});

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      german: json['german'] ?? '',
      arabic: json['arabic'] ?? '',
      example: json['example'],
    );
  }

  Map<String, dynamic> toJson() => {
    'german': german,
    'arabic': arabic,
    if (example != null) 'example': example,
  };
}

class Grammar {
  final String topic;
  final String topicArabic;
  final List<GrammarRule> rules;

  Grammar({
    required this.topic,
    required this.topicArabic,
    required this.rules,
  });

  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      topic: json['topic'] ?? '',
      topicArabic: json['topicArabic'] ?? '',
      rules: (json['rules'] as List? ?? [])
          .map((r) => GrammarRule.fromJson(r))
          .toList(),
    );
  }
}

class GrammarRule {
  final String? pronoun;
  final String? meaning;
  final String? article;
  final String? gender;
  final String? example;

  GrammarRule({
    this.pronoun,
    this.meaning,
    this.article,
    this.gender,
    this.example,
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      pronoun: json['pronoun'],
      meaning: json['meaning'],
      article: json['article'],
      gender: json['gender'],
      example: json['example'],
    );
  }
}

class Phrase {
  final String german;
  final String arabic;

  Phrase({required this.german, required this.arabic});

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(german: json['german'] ?? '', arabic: json['arabic'] ?? '');
  }
}
