enum NotificationType {
  streak,
  achievement,
  challenge,
  social,
  premium,
  reminder,
  event,
  personal,
}

enum NotificationPriority { low, medium, high, urgent }

class PushNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  const PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.scheduledAt,
    this.sentAt,
    this.isRead = false,
    this.data,
    this.imageUrl,
  });

  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? scheduledAt,
    DateTime? sentAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'priority': priority.name,
    'scheduledAt': scheduledAt.toIso8601String(),
    'sentAt': sentAt?.toIso8601String(),
    'isRead': isRead,
    'data': data,
    'imageUrl': imageUrl,
  };

  factory PushNotification.fromJson(Map<String, dynamic> json) =>
      PushNotification(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.reminder,
        ),
        priority: NotificationPriority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => NotificationPriority.medium,
        ),
        scheduledAt: DateTime.parse(
          json['scheduledAt'] ?? DateTime.now().toIso8601String(),
        ),
        sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
        isRead: json['isRead'] ?? false,
        data: json['data'],
        imageUrl: json['imageUrl'],
      );
}

class NotificationTemplate {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final List<String> variables;
  final String condition;

  const NotificationTemplate({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.medium,
    this.variables = const [],
    this.condition = '',
  });

  String render(Map<String, String> values) {
    var renderedTitle = title;
    var renderedBody = body;

    for (final entry in values.entries) {
      renderedTitle = renderedTitle.replaceAll('{${entry.key}}', entry.value);
      renderedBody = renderedBody.replaceAll('{${entry.key}}', entry.value);
    }

    return '$renderedTitle/n$renderedBody';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'priority': priority.name,
    'variables': variables,
    'condition': condition,
  };

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      NotificationTemplate(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.reminder,
        ),
        priority: NotificationPriority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => NotificationPriority.medium,
        ),
        variables: List<String>.from(json['variables'] ?? []),
        condition: json['condition'] ?? '',
      );
}

class UserEngagement {
  final String userId;
  final DateTime lastActiveAt;
  final int currentStreak;
  final int longestStreak;
  final int totalMinutes;
  final int lessonsCompleted;
  final int wordsLearned;
  final double averageScore;
  final List<String> weakAreas;
  final Map<String, int> dailyActivity;

  const UserEngagement({
    required this.userId,
    required this.lastActiveAt,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalMinutes,
    required this.lessonsCompleted,
    required this.wordsLearned,
    required this.averageScore,
    this.weakAreas = const [],
    this.dailyActivity = const {},
  });

  int get daysSinceActive => DateTime.now().difference(lastActiveAt).inDays;
  bool get isInactive => daysSinceActive > 3;
  bool get isAtRisk => daysSinceActive > 1 && daysSinceActive <= 3;

  UserEngagement copyWith({
    String? userId,
    DateTime? lastActiveAt,
    int? currentStreak,
    int? longestStreak,
    int? totalMinutes,
    int? lessonsCompleted,
    int? wordsLearned,
    double? averageScore,
    List<String>? weakAreas,
    Map<String, int>? dailyActivity,
  }) {
    return UserEngagement(
      userId: userId ?? this.userId,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      averageScore: averageScore ?? this.averageScore,
      weakAreas: weakAreas ?? this.weakAreas,
      dailyActivity: dailyActivity ?? this.dailyActivity,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalMinutes': totalMinutes,
    'lessonsCompleted': lessonsCompleted,
    'wordsLearned': wordsLearned,
    'averageScore': averageScore,
    'weakAreas': weakAreas,
    'dailyActivity': dailyActivity,
  };

  factory UserEngagement.fromJson(Map<String, dynamic> json) => UserEngagement(
    userId: json['userId'] ?? '',
    lastActiveAt: DateTime.parse(
      json['lastActiveAt'] ?? DateTime.now().toIso8601String(),
    ),
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    totalMinutes: json['totalMinutes'] ?? 0,
    lessonsCompleted: json['lessonsCompleted'] ?? 0,
    wordsLearned: json['wordsLearned'] ?? 0,
    averageScore: (json['averageScore'] ?? 0).toDouble(),
    weakAreas: List<String>.from(json['weakAreas'] ?? []),
    dailyActivity: Map<String, int>.from(json['dailyActivity'] ?? {}),
  );
}
