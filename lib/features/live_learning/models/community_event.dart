enum EventStatus {
  upcoming,
  active,
  ended,
  cancelled,
}

enum EventType {
  challenge,
  workshop,
  meetup,
  competition,
  celebration,
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.challenge:
        return 'Challenge';
      case EventType.workshop:
        return 'Workshop';
      case EventType.meetup:
        return 'Meetup';
      case EventType.competition:
        return 'Competition';
      case EventType.celebration:
        return 'Celebration';
    }
  }
}

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final List<EventParticipant> participants;
  final EventReward reward;
  final List<String> rules;
  final List<String> tags;
  final String? imageUrl;
  final int totalXpAwarded;
  final DateTime createdAt;

  const CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = EventStatus.upcoming,
    required this.startDate,
    required this.endDate,
    this.maxParticipants = 10000,
    this.participants = const [],
    required this.reward,
    this.rules = const [],
    this.tags = const [],
    this.imageUrl,
    this.totalXpAwarded = 0,
    required this.createdAt,
  });

  int get currentParticipants => participants.length;
  bool get isFull => currentParticipants >= maxParticipants;
  bool get canJoin => !isFull && status != EventStatus.ended && status != EventStatus.cancelled;
  bool get isOngoing => status == EventStatus.active;

  CommunityEvent copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    List<EventParticipant>? participants,
    EventReward? reward,
    List<String>? rules,
    List<String>? tags,
    String? imageUrl,
    int? totalXpAwarded,
    DateTime? createdAt,
  }) {
    return CommunityEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      reward: reward ?? this.reward,
      rules: rules ?? this.rules,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      totalXpAwarded: totalXpAwarded ?? this.totalXpAwarded,
      createdAt: createdAt ?? this.createdAt,
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
    'maxParticipants': maxParticipants,
    'participants': participants.map((p) => p.toJson()).toList(),
    'reward': reward.toJson(),
    'rules': rules,
    'tags': tags,
    'imageUrl': imageUrl,
    'totalXpAwarded': totalXpAwarded,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CommunityEvent.fromJson(Map<String, dynamic> json) => CommunityEvent(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    type: EventType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => EventType.challenge,
    ),
    status: EventStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => EventStatus.upcoming,
    ),
    startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
    maxParticipants: json['maxParticipants'] ?? 10000,
    participants: (json['participants'] as List?)
        ?.map((p) => EventParticipant.fromJson(p))
        .toList() ?? [],
    reward: EventReward.fromJson(json['reward'] ?? {}),
    rules: List<String>.from(json['rules'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
    imageUrl: json['imageUrl'],
    totalXpAwarded: json['totalXpAwarded'] ?? 0,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );

  factory CommunityEvent.demo() => CommunityEvent(
    id: 'event_demo_${DateTime.now().millisecondsSinceEpoch}',
    title: '30 Days German Challenge',
    description: 'Practice German every day for 30 days and earn exclusive rewards!',
    type: EventType.challenge,
    status: EventStatus.upcoming,
    startDate: DateTime.now().add(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 31)),
    maxParticipants: 10000,
    participants: [],
    reward: const EventReward(
      xp: 5000,
      gems: 500,
      badgeId: 'german_master_30',
      badgeName: 'German Master 30',
    ),
    rules: [
      'Practice at least 15 minutes daily',
      'Complete daily missions',
      'Share your progress',
    ],
    tags: ['Challenge', '30 Days', 'German'],
    createdAt: DateTime.now(),
  );
}

class EventParticipant {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final DateTime joinedAt;
  final int progress;
  final bool completed;
  final DateTime? completedAt;

  const EventParticipant({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.joinedAt,
    this.progress = 0,
    this.completed = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'joinedAt': joinedAt.toIso8601String(),
    'progress': progress,
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory EventParticipant.fromJson(Map<String, dynamic> json) => EventParticipant(
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    avatarUrl: json['avatarUrl'],
    joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    progress: json['progress'] ?? 0,
    completed: json['completed'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );
}

class EventReward {
  final int xp;
  final int gems;
  final String? badgeId;
  final String? badgeName;

  const EventReward({
    required this.xp,
    required this.gems,
    this.badgeId,
    this.badgeName,
  });

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'gems': gems,
    'badgeId': badgeId,
    'badgeName': badgeName,
  };

  factory EventReward.fromJson(Map<String, dynamic> json) => EventReward(
    xp: json['xp'] ?? 0,
    gems: json['gems'] ?? 0,
    badgeId: json['badgeId'],
    badgeName: json['badgeName'],
  );
}
