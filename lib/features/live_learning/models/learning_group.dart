enum GroupStatus { active, inactive, archived }

enum SessionFrequency { daily, weekly, biweekly, monthly }

extension SessionFrequencyExtension on SessionFrequency {
  String get displayName {
    switch (this) {
      case SessionFrequency.daily:
        return 'Daily';
      case SessionFrequency.weekly:
        return 'Weekly';
      case SessionFrequency.biweekly:
        return 'Bi-weekly';
      case SessionFrequency.monthly:
        return 'Monthly';
    }
  }
}

class LearningGroup {
  final String id;
  final String name;
  final String description;
  final String level;
  final String category;
  final GroupStatus status;
  final int maxMembers;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime? lastSessionAt;
  final SessionFrequency frequency;
  final List<GroupSession> sessions;
  final String? teacherId;
  final String teacherName;
  final List<String> tags;
  final double averageRating;
  final int totalSessions;

  const LearningGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.category,
    this.status = GroupStatus.active,
    this.maxMembers = 50,
    this.members = const [],
    required this.createdAt,
    this.lastSessionAt,
    this.frequency = SessionFrequency.weekly,
    this.sessions = const [],
    this.teacherId,
    this.teacherName = 'Lexi AI',
    this.tags = const [],
    this.averageRating = 0.0,
    this.totalSessions = 0,
  });

  int get currentMembers => members.length;
  bool get isFull => currentMembers >= maxMembers;
  bool get canJoin => !isFull && status == GroupStatus.active;

  LearningGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? level,
    String? category,
    GroupStatus? status,
    int? maxMembers,
    List<GroupMember>? members,
    DateTime? createdAt,
    DateTime? lastSessionAt,
    SessionFrequency? frequency,
    List<GroupSession>? sessions,
    String? teacherId,
    String? teacherName,
    List<String>? tags,
    double? averageRating,
    int? totalSessions,
  }) {
    return LearningGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      category: category ?? this.category,
      status: status ?? this.status,
      maxMembers: maxMembers ?? this.maxMembers,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
      frequency: frequency ?? this.frequency,
      sessions: sessions ?? this.sessions,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'level': level,
    'category': category,
    'status': status.name,
    'maxMembers': maxMembers,
    'members': members.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastSessionAt': lastSessionAt?.toIso8601String(),
    'frequency': frequency.name,
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'teacherId': teacherId,
    'teacherName': teacherName,
    'tags': tags,
    'averageRating': averageRating,
    'totalSessions': totalSessions,
  };

  factory LearningGroup.fromJson(Map<String, dynamic> json) => LearningGroup(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    level: json['level'] ?? 'A1',
    category: json['category'] ?? '',
    status: GroupStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => GroupStatus.active,
    ),
    maxMembers: json['maxMembers'] ?? 50,
    members:
        (json['members'] as List?)
            ?.map((m) => GroupMember.fromJson(m))
            .toList() ??
        [],
    createdAt: DateTime.parse(
      json['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
    lastSessionAt: json['lastSessionAt'] != null
        ? DateTime.parse(json['lastSessionAt'])
        : null,
    frequency: SessionFrequency.values.firstWhere(
      (f) => f.name == json['frequency'],
      orElse: () => SessionFrequency.weekly,
    ),
    sessions:
        (json['sessions'] as List?)
            ?.map((s) => GroupSession.fromJson(s))
            .toList() ??
        [],
    teacherId: json['teacherId'],
    teacherName: json['teacherName'] ?? 'Lexi AI',
    tags: List<String>.from(json['tags'] ?? []),
    averageRating: (json['averageRating'] ?? 0).toDouble(),
    totalSessions: json['totalSessions'] ?? 0,
  );

  factory LearningGroup.demo() => LearningGroup(
    id: 'group_demo_${DateTime.now().millisecondsSinceEpoch}',
    name: 'B1 Speaking Club',
    description: 'Practice speaking German at B1 level with fellow learners',
    level: 'B1',
    category: 'Speaking',
    status: GroupStatus.active,
    maxMembers: 50,
    members: [],
    createdAt: DateTime.now(),
    frequency: SessionFrequency.weekly,
    teacherName: 'Lexi AI',
    tags: ['Speaking', 'B1', 'Practice'],
  );
}

class GroupMember {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String role;
  final DateTime joinedAt;
  final int attendanceCount;
  final int xpEarned;

  const GroupMember({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.role = 'member',
    required this.joinedAt,
    this.attendanceCount = 0,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'role': role,
    'joinedAt': joinedAt.toIso8601String(),
    'attendanceCount': attendanceCount,
    'xpEarned': xpEarned,
  };

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    avatarUrl: json['avatarUrl'],
    role: json['role'] ?? 'member',
    joinedAt: DateTime.parse(
      json['joinedAt'] ?? DateTime.now().toIso8601String(),
    ),
    attendanceCount: json['attendanceCount'] ?? 0,
    xpEarned: json['xpEarned'] ?? 0,
  );
}

class GroupSession {
  final String id;
  final String groupId;
  final String title;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final int participantsCount;
  final String? summary;
  final List<String> topics;

  const GroupSession({
    required this.id,
    required this.groupId,
    required this.title,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.durationMinutes = 60,
    this.participantsCount = 0,
    this.summary,
    this.topics = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'title': title,
    'scheduledAt': scheduledAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'participantsCount': participantsCount,
    'summary': summary,
    'topics': topics,
  };

  factory GroupSession.fromJson(Map<String, dynamic> json) => GroupSession(
    id: json['id'] ?? '',
    groupId: json['groupId'] ?? '',
    title: json['title'] ?? '',
    scheduledAt: DateTime.parse(
      json['scheduledAt'] ?? DateTime.now().toIso8601String(),
    ),
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'])
        : null,
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    durationMinutes: json['durationMinutes'] ?? 60,
    participantsCount: json['participantsCount'] ?? 0,
    summary: json['summary'],
    topics: List<String>.from(json['topics'] ?? []),
  );
}
