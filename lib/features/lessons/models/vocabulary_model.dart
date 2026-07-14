class VocabularyItem {
  final String word;
  final String translation;
  final String example;
  final String exampleTranslation;
  final String? audioUrl;

  const VocabularyItem({
    required this.word,
    required this.translation,
    required this.example,
    required this.exampleTranslation,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'translation': translation,
    'example': example,
    'exampleTranslation': exampleTranslation,
    'audioUrl': audioUrl,
  };

  factory VocabularyItem.fromJson(Map<String, dynamic> json) => VocabularyItem(
    word: json['word'] ?? '',
    translation: json['translation'] ?? '',
    example: json['example'] ?? '',
    exampleTranslation: json['exampleTranslation'] ?? '',
    audioUrl: json['audioUrl'],
  );
}
