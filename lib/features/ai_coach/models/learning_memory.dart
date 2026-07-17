class LearningMemory {
  final String id;
  final String userId;
  final String mistakeType;
  final String wrongSentence;
  final String correctSentence;
  final String explanation;
  final String languageLevel;
  final DateTime createdAt;

  const LearningMemory({
    required this.id,
    required this.userId,
    required this.mistakeType,
    required this.wrongSentence,
    required this.correctSentence,
    required this.explanation,
    required this.languageLevel,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'mistakeType': mistakeType,
    'wrongSentence': wrongSentence,
    'correctSentence': correctSentence,
    'explanation': explanation,
    'languageLevel': languageLevel,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LearningMemory.fromJson(Map<String, dynamic> json) => LearningMemory(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    mistakeType: json['mistakeType'] ?? '',
    wrongSentence: json['wrongSentence'] ?? '',
    correctSentence: json['correctSentence'] ?? '',
    explanation: json['explanation'] ?? '',
    languageLevel: json['languageLevel'] ?? 'A1',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}
