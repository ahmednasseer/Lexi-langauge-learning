enum SeasonalEventType {
  challenge,
  marathon,
  competition,
  celebration,
}

enum SeasonalEventStatus {
  upcoming,
  active,
  ended,
}

extension SeasonalEventTypeExtension on SeasonalEventType {
  String get displayName {
    switch (this) {
      case SeasonalEventType.challenge:
        return 'Challenge';
      case SeasonalEventType.marathon:
        return 'Marathon';
      case SeasonalEventType.competition:
        return 'Competition';
      case SeasonalEventType.celebration:
        return 'Celebration';
    }
  }
}

class SeasonalEvent {
  final String id;
  final String title;
  final String description;
  final SeasonalEventType type;
  final SeasonalEventStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final List<EventGoal> goals;
  final EventReward reward;
  final int participantsCount;
  final bool isJoined;
  final int userProgress;

  const SeasonalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = SeasonalEventStatus.upcoming,
    required this.startDate,
    required this.endDate,
    required this.goals,
    required this.reward,
    this.participantsCount = 0,
    this.isJoined = false,
    this.userProgress = 0,
  });

  int get durationDays => endDate.difference(startDate).inDays;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays.clamp(0, durationDays);
  bool get isActive => status == SeasonalEventStatus.active;
  bool get canJoin => status != SeasonalEventStatus.ended && !isJoined;

  double get overallProgress {
    if (goals.isEmpty) return 0.0;
    final totalProgress = goals.fold(0.0, (sum, goal) => sum + goal.progress);
    return totalProgress / goals.length;
  }

  SeasonalEvent copyWith({
    String? id,
    String? title,
    String? description,
    SeasonalEventType? type,
    SeasonalEventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<EventGoal>? goals,
    EventReward? reward,
    int? participantsCount,
    bool? isJoined,
    int? userProgress,
  }) {
    return SeasonalEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goals: goals ?? this.goals,
      reward: reward ?? this.reward,
      participantsCount: participantsCount ?? this.participantsCount,
      isJoined: isJoined ?? this.isJoined,
      userProgress: userProgress ?? this.userProgress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'status': status.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'goals': goals.map((g) => g.toJson()).toList(),
    'reward': reward.toJson(),
    'participantsCount': participantsCount,
    'isJoined': isJoined,
    'userProgress': userProgress,
  };

  factory SeasonalEvent.fromJson(Map<String, dynamic> json) => SeasonalEvent(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    type: SeasonalEventType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => SeasonalEventType.challenge,
    ),
    status: SeasonalEventStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => SeasonalEventStatus.upcoming,
    ),
    startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
    goals: (json['goals'] as List?)
        ?.map((g) => EventGoal.fromJson(g))
        .toList() ?? [],
    reward: EventReward.fromJson(json['reward'] ?? {}),
    participantsCount: json['participantsCount'] ?? 0,
    isJoined: json['isJoined'] ?? false,
    userProgress: json['userProgress'] ?? 0,
  );

  factory SeasonalEvent.demo() => SeasonalEvent(
    id: 'seasonal_1',
    title: 'German Summer Challenge',
    description: 'Master German this summer with daily practice!',
    type: SeasonalEventType.challenge,
    status: SeasonalEventStatus.active,
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 25)),
    goals: [
      const EventGoal(
        id: 'goal_1',
        title: 'Speaking Practice',
        description: 'Speak 100 minutes',
        targetValue: 100,
        currentValue: 35,
        unit: 'minutes',
      ),
      const EventGoal(
        id: 'goal_2',
        title: 'Vocabulary Building',
        description: 'Learn 500 words',
        targetValue: 500,
        currentValue: 180,
        unit: 'words',
      ),
      const EventGoal(
        id: 'goal_3',
        title: 'Goethe Tasks',
        description: 'Complete 20 Goethe exercises',
        targetValue: 20,
        currentValue: 8,
        unit: 'exercises',
      ),
    ],
    reward: const EventReward(
      xp: 5000,
      gems: 1000,
      badgeId: 'summer_master',
      badgeName: 'Summer Master',
      frameId: 'summer_frame',
    ),
    participantsCount: 8500,
    isJoined: true,
    userProgress: 35,
  );
}

class EventGoal {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final String unit;

  const EventGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentValue >= targetValue;

  EventGoal copyWith({
    String? id,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    String? unit,
  }) {
    return EventGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'unit': unit,
  };

  factory EventGoal.fromJson(Map<String, dynamic> json) => EventGoal(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    targetValue: json['targetValue'] ?? 0,
    currentValue: json['currentValue'] ?? 0,
    unit: json['unit'] ?? '',
  );
}

class EventReward {
  final int xp;
  final int gems;
  final String? badgeId;
  final String? badgeName;
  final String? frameId;

  const EventReward({
    required this.xp,
    required this.gems,
    this.badgeId,
    this.badgeName,
    this.frameId,
  });

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'gems': gems,
    'badgeId': badgeId,
    'badgeName': badgeName,
    'frameId': frameId,
  };

  factory EventReward.fromJson(Map<String, dynamic> json) => EventReward(
    xp: json['xp'] ?? 0,
    gems: json['gems'] ?? 0,
    badgeId: json['badgeId'],
    badgeName: json['badgeName'],
    frameId: json['frameId'],
  );
}
