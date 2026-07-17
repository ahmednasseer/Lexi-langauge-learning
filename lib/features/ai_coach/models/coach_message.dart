class CoachMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? correction;
  final String? originalSentence;
  final String? correctSentence;
  final String? explanation;
  final String? betterAlternative;
  final int? xpEarned;
  final String? messageType; // 'text', 'correction', 'suggestion', 'system'

  const CoachMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.correction,
    this.originalSentence,
    this.correctSentence,
    this.explanation,
    this.betterAlternative,
    this.xpEarned,
    this.messageType = 'text',
  });

  bool get hasCorrection => correction != null || correctSentence != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'correction': correction,
    'originalSentence': originalSentence,
    'correctSentence': correctSentence,
    'explanation': explanation,
    'betterAlternative': betterAlternative,
    'xpEarned': xpEarned,
    'messageType': messageType,
  };

  factory CoachMessage.fromJson(Map<String, dynamic> json) => CoachMessage(
    id: json['id'] ?? '',
    content: json['content'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    correction: json['correction'],
    originalSentence: json['originalSentence'],
    correctSentence: json['correctSentence'],
    explanation: json['explanation'],
    betterAlternative: json['betterAlternative'],
    xpEarned: json['xpEarned'],
    messageType: json['messageType'] ?? 'text',
  );

  CoachMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? correction,
    String? originalSentence,
    String? correctSentence,
    String? explanation,
    String? betterAlternative,
    int? xpEarned,
    String? messageType,
  }) {
    return CoachMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      correction: correction ?? this.correction,
      originalSentence: originalSentence ?? this.originalSentence,
      correctSentence: correctSentence ?? this.correctSentence,
      explanation: explanation ?? this.explanation,
      betterAlternative: betterAlternative ?? this.betterAlternative,
      xpEarned: xpEarned ?? this.xpEarned,
      messageType: messageType ?? this.messageType,
    );
  }
}
