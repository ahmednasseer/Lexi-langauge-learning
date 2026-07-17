class PronunciationResult {
  final double accuracy;
  final double fluency;
  final double grammar;
  final List<String> mistakes;
  final List<String> suggestions;
  final String spokenText;
  final String targetText;
  final int xpEarned;

  const PronunciationResult({
    required this.accuracy,
    required this.fluency,
    required this.grammar,
    required this.mistakes,
    required this.suggestions,
    required this.spokenText,
    required this.targetText,
    this.xpEarned = 0,
  });

  double get overallScore => (accuracy + fluency + grammar) / 3;
  bool get isPerfect => accuracy >= 95 && fluency >= 90 && grammar >= 95;
  bool get isGood => overallScore >= 70;
  bool get needsImprovement => overallScore < 50;

  String get grade {
    if (overallScore >= 90) return 'A+';
    if (overallScore >= 80) return 'A';
    if (overallScore >= 70) return 'B';
    if (overallScore >= 60) return 'C';
    if (overallScore >= 50) return 'D';
    return 'F';
  }

  String get feedback {
    if (isPerfect) return 'Perfect! Amazing pronunciation!';
    if (isGood) return 'Great job! Keep practicing!';
    if (needsImprovement) return 'Keep trying! Practice makes perfect!';
    return 'Good effort! Focus on the suggestions below.';
  }

  factory PronunciationResult.analyze(String spoken, String target) {
    final spokenLower = spoken.toLowerCase().trim();
    final targetLower = target.toLowerCase().trim();

    final accuracy = _calculateSimilarity(spokenLower, targetLower);
    final grammar = _checkGrammar(spokenLower, targetLower);
    final fluency = _calculateFluency(spokenLower, targetLower);
    final mistakes = _findMistakes(spokenLower, targetLower);
    final suggestions = _generateSuggestions(accuracy, grammar, mistakes);

    final overallScore = (accuracy + fluency + grammar) / 3;
    final xp = overallScore >= 90 ? 100 : (overallScore >= 70 ? 50 : 20);

    return PronunciationResult(
      accuracy: accuracy,
      fluency: fluency,
      grammar: grammar,
      mistakes: mistakes,
      suggestions: suggestions,
      spokenText: spoken,
      targetText: target,
      xpEarned: xp,
    );
  }

  static double _calculateSimilarity(String a, String b) {
    if (a == b) return 100.0;
    final aWords = a.split(' ');
    final bWords = b.split(' ');
    int matches = 0;
    for (final word in aWords) {
      if (bWords.contains(word)) matches++;
    }
    if (bWords.isEmpty) return 0.0;
    return (matches / bWords.length * 100).clamp(0.0, 100.0);
  }

  static double _checkGrammar(String spoken, String target) {
    double score = 100;
    if (target.contains(' ist ') && !spoken.contains(' ist ')) score -= 10;
    if (target.contains(' habe ') && !spoken.contains(' habe ')) score -= 10;
    if (target.contains(' werden ') && !spoken.contains(' werden ')) score -= 10;
    if (target.contains(' der ') && !spoken.contains(' der ')) score -= 5;
    if (target.contains(' die ') && !spoken.contains(' die ')) score -= 5;
    if (target.contains(' das ') && !spoken.contains(' das ')) score -= 5;
    return score.clamp(0.0, 100.0);
  }

  static double _calculateFluency(String spoken, String target) {
    if (spoken.isEmpty) return 0.0;
    final hasPunctuation = spoken.contains('.') || spoken.contains('!') || spoken.contains('?');
    final lengthRatio = spoken.length / target.length;
    double score = 80;
    if (hasPunctuation) score += 10;
    if (lengthRatio > 0.7 && lengthRatio < 1.3) score += 10;
    return score.clamp(0.0, 100.0);
  }

  static List<String> _findMistakes(String spoken, String target) {
    final mistakes = <String>[];
    final targetWords = target.split(' ');
    final spokenWords = spoken.split(' ');
    for (int i = 0; i < targetWords.length && i < spokenWords.length; i++) {
      if (targetWords[i] != spokenWords[i]) {
        mistakes.add('Expected "${targetWords[i]}" but said "${spokenWords[i]}"');
      }
    }
    if (spokenWords.length < targetWords.length) {
      mistakes.add('Sentence incomplete');
    } else if (spokenWords.length > targetWords.length) {
      mistakes.add('Too many words');
    }
    return mistakes;
  }

  static List<String> _generateSuggestions(double accuracy, double grammar, List<String> mistakes) {
    final suggestions = <String>[];
    if (accuracy < 70) suggestions.add('Focus on pronunciation of each word');
    if (grammar < 80) suggestions.add('Review sentence structure');
    if (mistakes.length > 2) suggestions.add('Try speaking slower');
    if (suggestions.isEmpty) suggestions.add('Great job! Keep practicing!');
    return suggestions;
  }

  Map<String, dynamic> toJson() => {
    'accuracy': accuracy,
    'fluency': fluency,
    'grammar': grammar,
    'mistakes': mistakes,
    'suggestions': suggestions,
    'spokenText': spokenText,
    'targetText': targetText,
    'xpEarned': xpEarned,
  };

  factory PronunciationResult.fromJson(Map<String, dynamic> json) => PronunciationResult(
    accuracy: (json['accuracy'] ?? 0).toDouble(),
    fluency: (json['fluency'] ?? 0).toDouble(),
    grammar: (json['grammar'] ?? 0).toDouble(),
    mistakes: List<String>.from(json['mistakes'] ?? []),
    suggestions: List<String>.from(json['suggestions'] ?? []),
    spokenText: json['spokenText'] ?? '',
    targetText: json['targetText'] ?? '',
    xpEarned: json['xpEarned'] ?? 0,
  );
}
