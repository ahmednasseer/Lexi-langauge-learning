enum PartnerStatus {
  pending,
  matched,
  active,
  ended,
}

enum MatchingGoal {
  conversation,
  grammar,
  vocabulary,
  pronunciation,
  examPreparation,
  business,
  travel,
}

extension MatchingGoalExtension on MatchingGoal {
  String get displayName {
    switch (this) {
      case MatchingGoal.conversation:
        return 'Conversation Practice';
      case MatchingGoal.grammar:
        return 'Grammar Focus';
      case MatchingGoal.vocabulary:
        return 'Vocabulary Building';
      case MatchingGoal.pronunciation:
        return 'Pronunciation Practice';
      case MatchingGoal.examPreparation:
        return 'Exam Preparation';
      case MatchingGoal.business:
        return 'Business German';
      case MatchingGoal.travel:
        return 'Travel German';
    }
  }
}

class LanguagePartner {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String nativeLanguage;
  final String learningLanguage;
  final String level;
  final MatchingGoal goal;
  final PartnerStatus status;
  final DateTime createdAt;
  final DateTime? matchedAt;
  final int totalSessions;
  final int totalMinutes;
  final double averageRating;

  const LanguagePartner({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.nativeLanguage,
    required this.learningLanguage,
    required this.level,
    required this.goal,
    this.status = PartnerStatus.pending,
    required this.createdAt,
    this.matchedAt,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.averageRating = 0.0,
  });

  LanguagePartner copyWith({
    String? id,
    String? userId,
    String? userName,
    String? avatarUrl,
    String? nativeLanguage,
    String? learningLanguage,
    String? level,
    MatchingGoal? goal,
    PartnerStatus? status,
    DateTime? createdAt,
    DateTime? matchedAt,
    int? totalSessions,
    int? totalMinutes,
    double? averageRating,
  }) {
    return LanguagePartner(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      level: level ?? this.level,
      goal: goal ?? this.goal,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      matchedAt: matchedAt ?? this.matchedAt,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'nativeLanguage': nativeLanguage,
    'learningLanguage': learningLanguage,
    'level': level,
    'goal': goal.name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'matchedAt': matchedAt?.toIso8601String(),
    'totalSessions': totalSessions,
    'totalMinutes': totalMinutes,
    'averageRating': averageRating,
  };

  factory LanguagePartner.fromJson(Map<String, dynamic> json) => LanguagePartner(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    avatarUrl: json['avatarUrl'],
    nativeLanguage: json['nativeLanguage'] ?? '',
    learningLanguage: json['learningLanguage'] ?? '',
    level: json['level'] ?? 'A1',
    goal: MatchingGoal.values.firstWhere(
      (g) => g.name == json['goal'],
      orElse: () => MatchingGoal.conversation,
    ),
    status: PartnerStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PartnerStatus.pending,
    ),
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    matchedAt: json['matchedAt'] != null ? DateTime.parse(json['matchedAt']) : null,
    totalSessions: json['totalSessions'] ?? 0,
    totalMinutes: json['totalMinutes'] ?? 0,
    averageRating: (json['averageRating'] ?? 0).toDouble(),
  );
}

class PartnerMatch {
  final LanguagePartner user;
  final LanguagePartner partner;
  final double compatibilityScore;
  final List<String> commonInterests;
  final String matchReason;

  const PartnerMatch({
    required this.user,
    required this.partner,
    required this.compatibilityScore,
    required this.commonInterests,
    required this.matchReason,
  });

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'partner': partner.toJson(),
    'compatibilityScore': compatibilityScore,
    'commonInterests': commonInterests,
    'matchReason': matchReason,
  };

  factory PartnerMatch.fromJson(Map<String, dynamic> json) => PartnerMatch(
    user: LanguagePartner.fromJson(json['user'] ?? {}),
    partner: LanguagePartner.fromJson(json['partner'] ?? {}),
    compatibilityScore: (json['compatibilityScore'] ?? 0).toDouble(),
    commonInterests: List<String>.from(json['commonInterests'] ?? []),
    matchReason: json['matchReason'] ?? '',
  );
}

class ExchangeSession {
  final String id;
  final String userId;
  final String partnerId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final String languageUsed;
  final String? feedback;
  final double? rating;

  const ExchangeSession({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes = 0,
    required this.languageUsed,
    this.feedback,
    this.rating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'partnerId': partnerId,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'languageUsed': languageUsed,
    'feedback': feedback,
    'rating': rating,
  };

  factory ExchangeSession.fromJson(Map<String, dynamic> json) => ExchangeSession(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    partnerId: json['partnerId'] ?? '',
    startedAt: DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String()),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    durationMinutes: json['durationMinutes'] ?? 0,
    languageUsed: json['languageUsed'] ?? '',
    feedback: json['feedback'],
    rating: json['rating']?.toDouble(),
  );
}
