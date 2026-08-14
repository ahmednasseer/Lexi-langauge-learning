enum RoomStatus { waiting, active, ended }

enum RoomLevel { a1, a2, b1, b2, c1, c2, all }

extension RoomLevelExtension on RoomLevel {
  String get displayName {
    switch (this) {
      case RoomLevel.a1:
        return 'A1 Beginner';
      case RoomLevel.a2:
        return 'A2 Elementary';
      case RoomLevel.b1:
        return 'B1 Intermediate';
      case RoomLevel.b2:
        return 'B2 Upper Intermediate';
      case RoomLevel.c1:
        return 'C1 Advanced';
      case RoomLevel.c2:
        return 'C2 Mastery';
      case RoomLevel.all:
        return 'All Levels';
    }
  }
}

class LiveRoom {
  final String id;
  final String hostId;
  final String hostName;
  final String title;
  final String topic;
  final String description;
  final RoomLevel level;
  final RoomStatus status;
  final int maxParticipants;
  final List<RoomParticipant> participants;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final bool isRecording;
  final List<String> tags;
  final int totalXpAwarded;

  const LiveRoom({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.title,
    required this.topic,
    required this.description,
    required this.level,
    this.status = RoomStatus.waiting,
    this.maxParticipants = 10,
    this.participants = const [],
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.durationMinutes = 30,
    this.isRecording = false,
    this.tags = const [],
    this.totalXpAwarded = 0,
  });

  int get currentParticipants => participants.length;
  bool get isFull => currentParticipants >= maxParticipants;
  bool get canJoin => !isFull && status != RoomStatus.ended;
  bool get isHost => false;

  LiveRoom copyWith({
    String? id,
    String? hostId,
    String? hostName,
    String? title,
    String? topic,
    String? description,
    RoomLevel? level,
    RoomStatus? status,
    int? maxParticipants,
    List<RoomParticipant>? participants,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    bool? isRecording,
    List<String>? tags,
    int? totalXpAwarded,
  }) {
    return LiveRoom(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      level: level ?? this.level,
      status: status ?? this.status,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isRecording: isRecording ?? this.isRecording,
      tags: tags ?? this.tags,
      totalXpAwarded: totalXpAwarded ?? this.totalXpAwarded,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hostId': hostId,
    'hostName': hostName,
    'title': title,
    'topic': topic,
    'description': description,
    'level': level.name,
    'status': status.name,
    'maxParticipants': maxParticipants,
    'participants': participants.map((p) => p.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'isRecording': isRecording,
    'tags': tags,
    'totalXpAwarded': totalXpAwarded,
  };

  factory LiveRoom.fromJson(Map<String, dynamic> json) => LiveRoom(
    id: json['id'] ?? '',
    hostId: json['hostId'] ?? '',
    hostName: json['hostName'] ?? '',
    title: json['title'] ?? '',
    topic: json['topic'] ?? '',
    description: json['description'] ?? '',
    level: RoomLevel.values.firstWhere(
      (l) => l.name == json['level'],
      orElse: () => RoomLevel.all,
    ),
    status: RoomStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => RoomStatus.waiting,
    ),
    maxParticipants: json['maxParticipants'] ?? 10,
    participants:
        (json['participants'] as List?)
            ?.map((p) => RoomParticipant.fromJson(p))
            .toList() ??
        [],
    createdAt: DateTime.parse(
      json['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'])
        : null,
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    durationMinutes: json['durationMinutes'] ?? 30,
    isRecording: json['isRecording'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
    totalXpAwarded: json['totalXpAwarded'] ?? 0,
  );

  factory LiveRoom.demo() => LiveRoom(
    id: 'room_demo_${DateTime.now().millisecondsSinceEpoch}',
    hostId: 'host_1',
    hostName: 'Lexi AI',
    title: 'German Café',
    topic: 'Talking about Travel',
    description: 'Practice German conversation about travel experiences',
    level: RoomLevel.b1,
    status: RoomStatus.waiting,
    maxParticipants: 10,
    participants: [],
    createdAt: DateTime.now(),
    durationMinutes: 30,
    tags: ['Travel', 'Conversation', 'B1'],
  );
}

class RoomParticipant {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final bool isMuted;
  final bool isSpeaking;
  final bool isHost;
  final DateTime joinedAt;
  final int xpEarned;

  const RoomParticipant({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.isMuted = false,
    this.isSpeaking = false,
    this.isHost = false,
    required this.joinedAt,
    this.xpEarned = 0,
  });

  RoomParticipant copyWith({
    String? userId,
    String? userName,
    String? avatarUrl,
    bool? isMuted,
    bool? isSpeaking,
    bool? isHost,
    DateTime? joinedAt,
    int? xpEarned,
  }) {
    return RoomParticipant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMuted: isMuted ?? this.isMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isHost: isHost ?? this.isHost,
      joinedAt: joinedAt ?? this.joinedAt,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'isMuted': isMuted,
    'isSpeaking': isSpeaking,
    'isHost': isHost,
    'joinedAt': joinedAt.toIso8601String(),
    'xpEarned': xpEarned,
  };

  factory RoomParticipant.fromJson(Map<String, dynamic> json) =>
      RoomParticipant(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        avatarUrl: json['avatarUrl'],
        isMuted: json['isMuted'] ?? false,
        isSpeaking: json['isSpeaking'] ?? false,
        isHost: json['isHost'] ?? false,
        joinedAt: DateTime.parse(
          json['joinedAt'] ?? DateTime.now().toIso8601String(),
        ),
        xpEarned: json['xpEarned'] ?? 0,
      );
}
