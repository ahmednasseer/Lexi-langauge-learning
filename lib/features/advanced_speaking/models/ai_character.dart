import 'package:lexi/core/services/auth_service.dart';
import 'conversation_models.dart';

class AICharacter {
  final String id;
  final String name;
  final String personality;
  final String speakingStyle;
  final String? avatarUrl;
  final String? voiceId;
  final String language;
  final List<String> specialties;

  const AICharacter({
    required this.id,
    required this.name,
    required this.personality,
    required this.speakingStyle,
    this.avatarUrl,
    this.voiceId,
    this.language = 'de-DE',
    this.specialties = const [],
  });

  factory AICharacter.lexi() => const AICharacter(
    id: 'lexi',
    name: 'Lexi',
    personality:
        'Friendly, encouraging, and patient German teacher. Uses humor to make learning fun.',
    speakingStyle:
        'Clear, professional, and supportive. Adapts to student level.',
    language: 'de-DE',
    specialties: [
      'Grammar correction',
      'Pronunciation coaching',
      'Cultural context',
      'Conversation practice',
      'Exam preparation',
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'personality': personality,
    'speakingStyle': speakingStyle,
    'avatarUrl': avatarUrl,
    'voiceId': voiceId,
    'language': language,
    'specialties': specialties,
  };

  factory AICharacter.fromJson(Map<String, dynamic> json) => AICharacter(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    personality: json['personality'] ?? '',
    speakingStyle: json['speakingStyle'] ?? '',
    avatarUrl: json['avatarUrl'],
    voiceId: json['voiceId'],
    language: json['language'] ?? 'de-DE',
    specialties: List<String>.from(json['specialties'] ?? []),
  );
}

class ConversationContext {
  final String sessionId;
  final String userId;
  final ConversationScenario scenario;
  final AICharacter character;
  final String userLevel;
  final List<String> previousMistakes;
  final List<String> vocabularyProblems;
  final List<String> grammarProblems;
  final int turnCount;
  final String? topic;

  const ConversationContext({
    required this.sessionId,
    required this.userId,
    required this.scenario,
    required this.character,
    required this.userLevel,
    this.previousMistakes = const [],
    this.vocabularyProblems = const [],
    this.grammarProblems = const [],
    this.turnCount = 0,
    this.topic,
  });

  ConversationContext copyWith({
    String? sessionId,
    String? userId,
    ConversationScenario? scenario,
    AICharacter? character,
    String? userLevel,
    List<String>? previousMistakes,
    List<String>? vocabularyProblems,
    List<String>? grammarProblems,
    int? turnCount,
    String? topic,
  }) {
    return ConversationContext(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      scenario: scenario ?? this.scenario,
      character: character ?? this.character,
      userLevel: userLevel ?? this.userLevel,
      previousMistakes: previousMistakes ?? this.previousMistakes,
      vocabularyProblems: vocabularyProblems ?? this.vocabularyProblems,
      grammarProblems: grammarProblems ?? this.grammarProblems,
      turnCount: turnCount ?? this.turnCount,
      topic: topic ?? this.topic,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'userId': userId,
    'scenario': scenario.name,
    'character': character.toJson(),
    'userLevel': userLevel,
    'previousMistakes': previousMistakes,
    'vocabularyProblems': vocabularyProblems,
    'grammarProblems': grammarProblems,
    'turnCount': turnCount,
    'topic': topic,
  };

  factory ConversationContext.fromJson(Map<String, dynamic> json) =>
      ConversationContext(
        sessionId: json['sessionId'] ?? '',
        userId: json['userId'] ?? '',
        scenario: ConversationScenario.values.firstWhere(
          (s) => s.name == json['scenario'],
          orElse: () => ConversationScenario.dailyLife,
        ),
        character: AICharacter.fromJson(json['character'] ?? {}),
        userLevel: json['userLevel'] ?? 'A1',
        previousMistakes: List<String>.from(json['previousMistakes'] ?? []),
        vocabularyProblems: List<String>.from(json['vocabularyProblems'] ?? []),
        grammarProblems: List<String>.from(json['grammarProblems'] ?? []),
        turnCount: json['turnCount'] ?? 0,
        topic: json['topic'],
      );
}

class ConversationMemory {
  final String userId;
  final List<String> recentMistakes;
  final List<String> vocabularyProblems;
  final List<String> grammarProblems;
  final Map<String, int> scenarioScores;
  final DateTime lastPracticeDate;
  final String userLevel;
  final List<String> strengths;
  final List<String> weaknesses;

  const ConversationMemory({
    required this.userId,
    required this.recentMistakes,
    required this.vocabularyProblems,
    required this.grammarProblems,
    required this.scenarioScores,
    required this.lastPracticeDate,
    required this.userLevel,
    required this.strengths,
    required this.weaknesses,
  });

  ConversationMemory copyWith({
    String? userId,
    List<String>? recentMistakes,
    List<String>? vocabularyProblems,
    List<String>? grammarProblems,
    Map<String, int>? scenarioScores,
    DateTime? lastPracticeDate,
    String? userLevel,
    List<String>? strengths,
    List<String>? weaknesses,
  }) {
    return ConversationMemory(
      userId: userId ?? this.userId,
      recentMistakes: recentMistakes ?? this.recentMistakes,
      vocabularyProblems: vocabularyProblems ?? this.vocabularyProblems,
      grammarProblems: grammarProblems ?? this.grammarProblems,
      scenarioScores: scenarioScores ?? this.scenarioScores,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      userLevel: userLevel ?? this.userLevel,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'recentMistakes': recentMistakes,
    'vocabularyProblems': vocabularyProblems,
    'grammarProblems': grammarProblems,
    'scenarioScores': scenarioScores,
    'lastPracticeDate': lastPracticeDate.toIso8601String(),
    'userLevel': userLevel,
    'strengths': strengths,
    'weaknesses': weaknesses,
  };

  factory ConversationMemory.fromJson(Map<String, dynamic> json) =>
      ConversationMemory(
        userId: json['userId'] ?? '',
        recentMistakes: List<String>.from(json['recentMistakes'] ?? []),
        vocabularyProblems: List<String>.from(json['vocabularyProblems'] ?? []),
        grammarProblems: List<String>.from(json['grammarProblems'] ?? []),
        scenarioScores: Map<String, int>.from(json['scenarioScores'] ?? {}),
        lastPracticeDate: DateTime.parse(
          json['lastPracticeDate'] ?? DateTime.now().toIso8601String(),
        ),
        userLevel: json['userLevel'] ?? 'A1',
        strengths: List<String>.from(json['strengths'] ?? []),
        weaknesses: List<String>.from(json['weaknesses'] ?? []),
      );

  factory ConversationMemory.empty() => ConversationMemory(
    userId: AuthService.instance.currentUser?.id ?? '',
    recentMistakes: [],
    vocabularyProblems: [],
    grammarProblems: [],
    scenarioScores: {},
    lastPracticeDate: DateTime.now(),
    userLevel: 'A1',
    strengths: [],
    weaknesses: [],
  );

  String get memoryMessage {
    if (recentMistakes.isNotEmpty) {
      return 'Last time you had trouble with: ${recentMistakes.first}. Let\'s practice them today.';
    }
    if (vocabularyProblems.isNotEmpty) {
      return 'You had some vocabulary issues with: ${vocabularyProblems.first}. Let\'s review.';
    }
    return 'Great progress! Keep up the good work!';
  }
}
