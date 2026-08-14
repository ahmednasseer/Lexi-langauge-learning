class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? correction;
  final String? explanation;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.correction,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'correction': correction,
    'explanation': explanation,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    content: json['content'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: DateTime.parse(
      json['timestamp'] ?? DateTime.now().toIso8601String(),
    ),
    correction: json['correction'],
    explanation: json['explanation'],
  );
}
