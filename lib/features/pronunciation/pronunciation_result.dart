class PronunciationResult {
  final String word;
  final double score;
  final String? spokenText;
  final String? feedback;
  final List<String>? suggestions;

  const PronunciationResult({
    required this.word,
    required this.score,
    this.spokenText,
    this.feedback,
    this.suggestions,
  });

  factory PronunciationResult.empty() =>
      const PronunciationResult(word: '', score: 0);

  String get grade {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Practice';
  }
}
