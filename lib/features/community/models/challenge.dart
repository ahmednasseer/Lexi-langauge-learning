enum ChallengeDuration { weekly, monthly }

class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ChallengeDuration duration;
  final int targetProgress;
  final int rewardXp;
  final int rewardGems;
  final String? badgeId;
  final int participantCount;
  final DateTime startDate;
  final DateTime endDate;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
    required this.targetProgress,
    required this.rewardXp,
    this.rewardGems = 0,
    this.badgeId,
    this.participantCount = 0,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'duration': duration.name,
    'targetProgress': targetProgress,
    'rewardXp': rewardXp,
    'rewardGems': rewardGems,
    'badgeId': badgeId,
    'participantCount': participantCount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '🏆',
    duration: ChallengeDuration.values.firstWhere(
      (e) => e.name == json['duration'],
      orElse: () => ChallengeDuration.weekly,
    ),
    targetProgress: json['targetProgress'] ?? 7,
    rewardXp: json['rewardXp'] ?? 100,
    rewardGems: json['rewardGems'] ?? 0,
    badgeId: json['badgeId'],
    participantCount: json['participantCount'] ?? 0,
    startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : DateTime.now(),
    endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'])
        : DateTime.now().add(const Duration(days: 7)),
  );

  static List<Challenge> getActiveChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: 'ch1',
        title: '7 Day Speaking Challenge',
        description: 'Practice speaking for 10 minutes every day for 7 days',
        icon: '🎤',
        duration: ChallengeDuration.weekly,
        targetProgress: 7,
        rewardXp: 200,
        rewardGems: 50,
        participantCount: 234,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      ),
      Challenge(
        id: 'ch2',
        title: '30 Words Challenge',
        description: 'Learn 30 new German words in 30 days',
        icon: '📚',
        duration: ChallengeDuration.monthly,
        targetProgress: 30,
        rewardXp: 500,
        rewardGems: 100,
        badgeId: 'b_word_master',
        participantCount: 189,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      ),
      Challenge(
        id: 'ch3',
        title: 'German Movie Challenge',
        description: 'Watch 5 German movies with subtitles',
        icon: '🎬',
        duration: ChallengeDuration.monthly,
        targetProgress: 5,
        rewardXp: 300,
        rewardGems: 75,
        participantCount: 156,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      ),
      Challenge(
        id: 'ch4',
        title: 'Grammar Sprint',
        description: 'Complete 10 grammar lessons in 7 days',
        icon: '📝',
        duration: ChallengeDuration.weekly,
        targetProgress: 10,
        rewardXp: 250,
        rewardGems: 60,
        participantCount: 178,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      ),
    ];
  }
}

class UserChallenge {
  final String userId;
  final String challengeId;
  final int progress;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime joinedAt;

  const UserChallenge({
    required this.userId,
    required this.challengeId,
    this.progress = 0,
    this.isCompleted = false,
    this.isClaimed = false,
    required this.joinedAt,
  });

  double get progressPercent =>
      progress > 0 ? progress.toDouble().clamp(0.0, 1.0) : 0.0;

  UserChallenge copyWith({int? progress, bool? isCompleted, bool? isClaimed}) {
    return UserChallenge(
      userId: userId,
      challengeId: challengeId,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      joinedAt: joinedAt,
    );
  }
}
