enum ConversationState {
  idle,
  listening,
  processing,
  aiSpeaking,
  userSpeaking,
  ended,
}

enum ConversationScenario {
  restaurant,
  travel,
  jobInterview,
  university,
  doctorVisit,
  shopping,
  dailyLife,
  goetheSpeakingExam,
}

extension ConversationScenarioExtension on ConversationScenario {
  String get displayName {
    switch (this) {
      case ConversationScenario.restaurant:
        return 'Restaurant';
      case ConversationScenario.travel:
        return 'Travel';
      case ConversationScenario.jobInterview:
        return 'Job Interview';
      case ConversationScenario.university:
        return 'University';
      case ConversationScenario.doctorVisit:
        return 'Doctor Visit';
      case ConversationScenario.shopping:
        return 'Shopping';
      case ConversationScenario.dailyLife:
        return 'Daily Life';
      case ConversationScenario.goetheSpeakingExam:
        return 'Goethe Speaking Exam';
    }
  }

  String get description {
    switch (this) {
      case ConversationScenario.restaurant:
        return 'Practice ordering food, asking about dishes, and handling restaurant situations';
      case ConversationScenario.travel:
        return 'Practice booking hotels, asking for directions, and travel conversations';
      case ConversationScenario.jobInterview:
        return 'Practice introducing yourself, describing skills, and job interview scenarios';
      case ConversationScenario.university:
        return 'Practice academic conversations, asking professors, and campus life';
      case ConversationScenario.doctorVisit:
        return 'Practice describing symptoms, asking about health, and medical conversations';
      case ConversationScenario.shopping:
        return 'Practice asking about products, sizes, prices, and shopping situations';
      case ConversationScenario.dailyLife:
        return 'Practice everyday conversations, greetings, and daily routines';
      case ConversationScenario.goetheSpeakingExam:
        return 'Practice Goethe exam speaking section with timed responses';
    }
  }

  String get emoji {
    switch (this) {
      case ConversationScenario.restaurant:
        return '🍽️';
      case ConversationScenario.travel:
        return '✈️';
      case ConversationScenario.jobInterview:
        return '💼';
      case ConversationScenario.university:
        return '🎓';
      case ConversationScenario.doctorVisit:
        return '🏥';
      case ConversationScenario.shopping:
        return '🛍️';
      case ConversationScenario.dailyLife:
        return '🏠';
      case ConversationScenario.goetheSpeakingExam:
        return '📝';
    }
  }

  String get difficulty {
    switch (this) {
      case ConversationScenario.dailyLife:
        return 'A1';
      case ConversationScenario.restaurant:
        return 'A1';
      case ConversationScenario.shopping:
        return 'A1';
      case ConversationScenario.travel:
        return 'A2';
      case ConversationScenario.doctorVisit:
        return 'A2';
      case ConversationScenario.university:
        return 'B1';
      case ConversationScenario.jobInterview:
        return 'B1';
      case ConversationScenario.goetheSpeakingExam:
        return 'B2';
    }
  }
}

class ConversationMessage {
  final String id;
  final String role;
  final String content;
  final String? germanText;
  final DateTime timestamp;
  final bool isCorrected;
  final String? correction;
  final PronunciationAnalysis? pronunciationAnalysis;

  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.germanText,
    required this.timestamp,
    this.isCorrected = false,
    this.correction,
    this.pronunciationAnalysis,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'germanText': germanText,
    'timestamp': timestamp.toIso8601String(),
    'isCorrected': isCorrected,
    'correction': correction,
    'pronunciationAnalysis': pronunciationAnalysis?.toJson(),
  };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        id: json['id'] ?? '',
        role: json['role'] ?? '',
        content: json['content'] ?? '',
        germanText: json['germanText'],
        timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
        isCorrected: json['isCorrected'] ?? false,
        correction: json['correction'],
        pronunciationAnalysis: json['pronunciationAnalysis'] != null
            ? PronunciationAnalysis.fromJson(json['pronunciationAnalysis'])
            : null,
      );
}

class PronunciationAnalysis {
  final double pronunciation;
  final double accent;
  final double speakingSpeed;
  final double pauses;
  final double confidence;
  final double wordAccuracy;
  final List<String> mispronouncedWords;
  final List<String> suggestions;

  const PronunciationAnalysis({
    required this.pronunciation,
    required this.accent,
    required this.speakingSpeed,
    required this.pauses,
    required this.confidence,
    required this.wordAccuracy,
    required this.mispronouncedWords,
    required this.suggestions,
  });

  double get overallScore =>
      (pronunciation +
          accent +
          speakingSpeed +
          pauses +
          confidence +
          wordAccuracy) /
      6;

  Map<String, dynamic> toJson() => {
    'pronunciation': pronunciation,
    'accent': accent,
    'speakingSpeed': speakingSpeed,
    'pauses': pauses,
    'confidence': confidence,
    'wordAccuracy': wordAccuracy,
    'mispronouncedWords': mispronouncedWords,
    'suggestions': suggestions,
  };

  factory PronunciationAnalysis.fromJson(Map<String, dynamic> json) =>
      PronunciationAnalysis(
        pronunciation: (json['pronunciation'] ?? 0).toDouble(),
        accent: (json['accent'] ?? 0).toDouble(),
        speakingSpeed: (json['speakingSpeed'] ?? 0).toDouble(),
        pauses: (json['pauses'] ?? 0).toDouble(),
        confidence: (json['confidence'] ?? 0).toDouble(),
        wordAccuracy: (json['wordAccuracy'] ?? 0).toDouble(),
        mispronouncedWords: List<String>.from(json['mispronouncedWords'] ?? []),
        suggestions: List<String>.from(json['suggestions'] ?? []),
      );
}

class ConversationSession {
  final String id;
  final ConversationScenario scenario;
  final List<ConversationMessage> messages;
  final DateTime startedAt;
  final DateTime? endedAt;
  final ConversationState state;
  final int totalScore;
  final int xpEarned;
  final int wordsSpoken;
  final int durationSeconds;

  const ConversationSession({
    required this.id,
    required this.scenario,
    required this.messages,
    required this.startedAt,
    this.endedAt,
    this.state = ConversationState.idle,
    this.totalScore = 0,
    this.xpEarned = 0,
    this.wordsSpoken = 0,
    this.durationSeconds = 0,
  });

  ConversationSession copyWith({
    String? id,
    ConversationScenario? scenario,
    List<ConversationMessage>? messages,
    DateTime? startedAt,
    DateTime? endedAt,
    ConversationState? state,
    int? totalScore,
    int? xpEarned,
    int? wordsSpoken,
    int? durationSeconds,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      scenario: scenario ?? this.scenario,
      messages: messages ?? this.messages,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      state: state ?? this.state,
      totalScore: totalScore ?? this.totalScore,
      xpEarned: xpEarned ?? this.xpEarned,
      wordsSpoken: wordsSpoken ?? this.wordsSpoken,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scenario': scenario.name,
    'messages': messages.map((m) => m.toJson()).toList(),
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'state': state.name,
    'totalScore': totalScore,
    'xpEarned': xpEarned,
    'wordsSpoken': wordsSpoken,
    'durationSeconds': durationSeconds,
  };

  factory ConversationSession.fromJson(Map<String, dynamic> json) =>
      ConversationSession(
        id: json['id'] ?? '',
        scenario: ConversationScenario.values.firstWhere(
          (s) => s.name == json['scenario'],
          orElse: () => ConversationScenario.dailyLife,
        ),
        messages:
            (json['messages'] as List?)
                ?.map((m) => ConversationMessage.fromJson(m))
                .toList() ??
            [],
        startedAt: DateTime.parse(
          json['startedAt'] ?? DateTime.now().toIso8601String(),
        ),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'])
            : null,
        state: ConversationState.values.firstWhere(
          (s) => s.name == json['state'],
          orElse: () => ConversationState.idle,
        ),
        totalScore: json['totalScore'] ?? 0,
        xpEarned: json['xpEarned'] ?? 0,
        wordsSpoken: json['wordsSpoken'] ?? 0,
        durationSeconds: json['durationSeconds'] ?? 0,
      );
}

class ConversationFeedback {
  final String sessionId;
  final List<String> whatYouDidWell;
  final List<String> mistakes;
  final List<String> betterSentences;
  final String nextPractice;
  final double overallScore;
  final int xpEarned;

  const ConversationFeedback({
    required this.sessionId,
    required this.whatYouDidWell,
    required this.mistakes,
    required this.betterSentences,
    required this.nextPractice,
    required this.overallScore,
    required this.xpEarned,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'whatYouDidWell': whatYouDidWell,
    'mistakes': mistakes,
    'betterSentences': betterSentences,
    'nextPractice': nextPractice,
    'overallScore': overallScore,
    'xpEarned': xpEarned,
  };

  factory ConversationFeedback.fromJson(Map<String, dynamic> json) =>
      ConversationFeedback(
        sessionId: json['sessionId'] ?? '',
        whatYouDidWell: List<String>.from(json['whatYouDidWell'] ?? []),
        mistakes: List<String>.from(json['mistakes'] ?? []),
        betterSentences: List<String>.from(json['betterSentences'] ?? []),
        nextPractice: json['nextPractice'] ?? '',
        overallScore: (json['overallScore'] ?? 0).toDouble(),
        xpEarned: json['xpEarned'] ?? 0,
      );
}
