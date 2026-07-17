enum MissionType { vocabulary, grammar, speaking, listening, aiChat, flashcards, lesson }
enum MissionDifficulty { easy, medium, hard }

class DailyMission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int target;
  final int progress;
  final int rewardXp;
  final int rewardGems;
  final MissionDifficulty difficulty;
  final bool isCompleted;
  final bool isClaimed;
  final String icon;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.progress = 0,
    required this.rewardXp,
    this.rewardGems = 0,
    this.difficulty = MissionDifficulty.medium,
    this.isCompleted = false,
    this.isClaimed = false,
    required this.icon,
  });

  double get progressPercent => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
  bool get canClaim => isCompleted && !isClaimed;

  DailyMission copyWith({
    int? progress,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return DailyMission(
      id: id,
      title: title,
      description: description,
      type: type,
      target: target,
      progress: progress ?? this.progress,
      rewardXp: rewardXp,
      rewardGems: rewardGems,
      difficulty: difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'target': target,
    'progress': progress,
    'rewardXp': rewardXp,
    'rewardGems': rewardGems,
    'difficulty': difficulty.name,
    'isCompleted': isCompleted,
    'isClaimed': isClaimed,
    'icon': icon,
  };

  factory DailyMission.fromJson(Map<String, dynamic> json) => DailyMission(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    type: MissionType.values.firstWhere((e) => e.name == json['type'], orElse: () => MissionType.vocabulary),
    target: json['target'] ?? 1,
    progress: json['progress'] ?? 0,
    rewardXp: json['rewardXp'] ?? 0,
    rewardGems: json['rewardGems'] ?? 0,
    difficulty: MissionDifficulty.values.firstWhere((e) => e.name == json['difficulty'], orElse: () => MissionDifficulty.medium),
    isCompleted: json['isCompleted'] ?? false,
    isClaimed: json['isClaimed'] ?? false,
    icon: json['icon'] ?? '🎯',
  );

  static List<DailyMission> getTodayMissions() {
    return [
      const DailyMission(
        id: 'm1',
        title: 'Learn Vocabulary',
        description: 'Learn 15 new vocabulary words',
        type: MissionType.vocabulary,
        target: 15,
        rewardXp: 50,
        rewardGems: 5,
        difficulty: MissionDifficulty.easy,
        icon: '📚',
      ),
      const DailyMission(
        id: 'm2',
        title: 'Grammar Lesson',
        description: 'Complete 1 grammar lesson',
        type: MissionType.grammar,
        target: 1,
        rewardXp: 75,
        rewardGems: 10,
        difficulty: MissionDifficulty.medium,
        icon: '📝',
      ),
      const DailyMission(
        id: 'm3',
        title: 'Speaking Practice',
        description: 'Practice speaking for 5 minutes',
        type: MissionType.speaking,
        target: 5,
        rewardXp: 100,
        rewardGems: 15,
        difficulty: MissionDifficulty.hard,
        icon: '🎤',
      ),
      const DailyMission(
        id: 'm4',
        title: 'AI Coach Chat',
        description: 'Complete an AI Coach conversation',
        type: MissionType.aiChat,
        target: 1,
        rewardXp: 50,
        rewardGems: 5,
        difficulty: MissionDifficulty.easy,
        icon: '🤖',
      ),
      const DailyMission(
        id: 'm5',
        title: 'Listening Exercise',
        description: 'Finish 1 listening exercise',
        type: MissionType.listening,
        target: 1,
        rewardXp: 50,
        rewardGems: 5,
        difficulty: MissionDifficulty.easy,
        icon: '🎧',
      ),
    ];
  }
}
