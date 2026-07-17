import 'conversation_models.dart';

class SpeakingProgress {
  final int totalSpeakingMinutes;
  final int totalWordsSpoken;
  final double averagePronunciationScore;
  final double averageFluencyScore;
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final int totalXpEarned;
  final String currentLevel;
  final List<MistakePattern> commonMistakes;
  final Map<String, int> scenarioPracticeCount;
  final List<WeeklyProgress> weeklyProgress;

  const SpeakingProgress({
    required this.totalSpeakingMinutes,
    required this.totalWordsSpoken,
    required this.averagePronunciationScore,
    required this.averageFluencyScore,
    required this.totalSessions,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXpEarned,
    required this.currentLevel,
    required this.commonMistakes,
    required this.scenarioPracticeCount,
    required this.weeklyProgress,
  });

  SpeakingProgress copyWith({
    int? totalSpeakingMinutes,
    int? totalWordsSpoken,
    double? averagePronunciationScore,
    double? averageFluencyScore,
    int? totalSessions,
    int? currentStreak,
    int? longestStreak,
    int? totalXpEarned,
    String? currentLevel,
    List<MistakePattern>? commonMistakes,
    Map<String, int>? scenarioPracticeCount,
    List<WeeklyProgress>? weeklyProgress,
  }) {
    return SpeakingProgress(
      totalSpeakingMinutes: totalSpeakingMinutes ?? this.totalSpeakingMinutes,
      totalWordsSpoken: totalWordsSpoken ?? this.totalWordsSpoken,
      averagePronunciationScore: averagePronunciationScore ?? this.averagePronunciationScore,
      averageFluencyScore: averageFluencyScore ?? this.averageFluencyScore,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      currentLevel: currentLevel ?? this.currentLevel,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      scenarioPracticeCount: scenarioPracticeCount ?? this.scenarioPracticeCount,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSpeakingMinutes': totalSpeakingMinutes,
    'totalWordsSpoken': totalWordsSpoken,
    'averagePronunciationScore': averagePronunciationScore,
    'averageFluencyScore': averageFluencyScore,
    'totalSessions': totalSessions,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalXpEarned': totalXpEarned,
    'currentLevel': currentLevel,
    'commonMistakes': commonMistakes.map((m) => m.toJson()).toList(),
    'scenarioPracticeCount': scenarioPracticeCount,
    'weeklyProgress': weeklyProgress.map((w) => w.toJson()).toList(),
  };

  factory SpeakingProgress.fromJson(Map<String, dynamic> json) => SpeakingProgress(
    totalSpeakingMinutes: json['totalSpeakingMinutes'] ?? 0,
    totalWordsSpoken: json['totalWordsSpoken'] ?? 0,
    averagePronunciationScore: (json['averagePronunciationScore'] ?? 0).toDouble(),
    averageFluencyScore: (json['averageFluencyScore'] ?? 0).toDouble(),
    totalSessions: json['totalSessions'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    totalXpEarned: json['totalXpEarned'] ?? 0,
    currentLevel: json['currentLevel'] ?? 'A1',
    commonMistakes: (json['commonMistakes'] as List?)
        ?.map((m) => MistakePattern.fromJson(m))
        .toList() ?? [],
    scenarioPracticeCount: Map<String, int>.from(json['scenarioPracticeCount'] ?? {}),
    weeklyProgress: (json['weeklyProgress'] as List?)
        ?.map((w) => WeeklyProgress.fromJson(w))
        .toList() ?? [],
  );

  factory SpeakingProgress.empty() => const SpeakingProgress(
    totalSpeakingMinutes: 0,
    totalWordsSpoken: 0,
    averagePronunciationScore: 0,
    averageFluencyScore: 0,
    totalSessions: 0,
    currentStreak: 0,
    longestStreak: 0,
    totalXpEarned: 0,
    currentLevel: 'A1',
    commonMistakes: [],
    scenarioPracticeCount: {},
    weeklyProgress: [],
  );
}

class MistakePattern {
  final String pattern;
  final String description;
  final int frequency;
  final String suggestion;

  const MistakePattern({
    required this.pattern,
    required this.description,
    required this.frequency,
    required this.suggestion,
  });

  Map<String, dynamic> toJson() => {
    'pattern': pattern,
    'description': description,
    'frequency': frequency,
    'suggestion': suggestion,
  };

  factory MistakePattern.fromJson(Map<String, dynamic> json) => MistakePattern(
    pattern: json['pattern'] ?? '',
    description: json['description'] ?? '',
    frequency: json['frequency'] ?? 0,
    suggestion: json['suggestion'] ?? '',
  );
}

class WeeklyProgress {
  final String day;
  final int minutes;
  final int wordsSpoken;
  final double averageScore;

  const WeeklyProgress({
    required this.day,
    required this.minutes,
    required this.wordsSpoken,
    required this.averageScore,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'minutes': minutes,
    'wordsSpoken': wordsSpoken,
    'averageScore': averageScore,
  };

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) => WeeklyProgress(
    day: json['day'] ?? '',
    minutes: json['minutes'] ?? 0,
    wordsSpoken: json['wordsSpoken'] ?? 0,
    averageScore: (json['averageScore'] ?? 0).toDouble(),
  );
}

class SpeakingChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetDays;
  final int completedDays;
  final int currentDay;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final List<ChallengeDay> days;
  final ChallengeReward reward;

  const SpeakingChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetDays,
    required this.completedDays,
    required this.currentDay,
    required this.isActive,
    required this.startDate,
    this.endDate,
    required this.days,
    required this.reward,
  });

  double get progress => targetDays > 0 ? completedDays / targetDays : 0;
  bool get isCompleted => completedDays >= targetDays;

  SpeakingChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    int? targetDays,
    int? completedDays,
    int? currentDay,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    List<ChallengeDay>? days,
    ChallengeReward? reward,
  }) {
    return SpeakingChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetDays: targetDays ?? this.targetDays,
      completedDays: completedDays ?? this.completedDays,
      currentDay: currentDay ?? this.currentDay,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
      reward: reward ?? this.reward,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'targetDays': targetDays,
    'completedDays': completedDays,
    'currentDay': currentDay,
    'isActive': isActive,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
    'reward': reward.toJson(),
  };

  factory SpeakingChallenge.fromJson(Map<String, dynamic> json) => SpeakingChallenge(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    type: ChallengeType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => ChallengeType.daily,
    ),
    targetDays: json['targetDays'] ?? 1,
    completedDays: json['completedDays'] ?? 0,
    currentDay: json['currentDay'] ?? 1,
    isActive: json['isActive'] ?? false,
    startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    days: (json['days'] as List?)
        ?.map((d) => ChallengeDay.fromJson(d))
        .toList() ?? [],
    reward: ChallengeReward.fromJson(json['reward'] ?? {}),
  );
}

enum ChallengeType {
  daily,
  weekly,
  monthly,
}

extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.daily:
        return 'Daily Speaking Challenge';
      case ChallengeType.weekly:
        return '7-Day Speaking Challenge';
      case ChallengeType.monthly:
        return '30-Day Speaking Challenge';
    }
  }
}

class ChallengeDay {
  final int dayNumber;
  final String title;
  final String description;
  final ConversationScenario scenario;
  final int targetMinutes;
  final bool isCompleted;
  final DateTime? completedAt;

  const ChallengeDay({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.scenario,
    required this.targetMinutes,
    required this.isCompleted,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'title': title,
    'description': description,
    'scenario': scenario.name,
    'targetMinutes': targetMinutes,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory ChallengeDay.fromJson(Map<String, dynamic> json) => ChallengeDay(
    dayNumber: json['dayNumber'] ?? 1,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    scenario: ConversationScenario.values.firstWhere(
      (s) => s.name == json['scenario'],
      orElse: () => ConversationScenario.dailyLife,
    ),
    targetMinutes: json['targetMinutes'] ?? 5,
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );
}

class ChallengeReward {
  final int xp;
  final int gems;
  final String? badgeId;

  const ChallengeReward({
    required this.xp,
    required this.gems,
    this.badgeId,
  });

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'gems': gems,
    'badgeId': badgeId,
  };

  factory ChallengeReward.fromJson(Map<String, dynamic> json) => ChallengeReward(
    xp: json['xp'] ?? 0,
    gems: json['gems'] ?? 0,
    badgeId: json['badgeId'],
  );
}
