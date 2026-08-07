import '../../core/services/api_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    body: json['body'] ?? json['message'] ?? '',
    type: json['type'] ?? 'system',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    isRead: json['isRead'] ?? json['read'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };
}

class NotificationsRepository {
  final ApiService _api = ApiService();

  Future<List<AppNotification>> getNotifications({int page = 1}) async {
    try {
      final result = await _api.getNotifications(page: page);
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _sampleNotifications();
  }

  Future<void> markRead(String id) async {
    try {
      await _api.markNotificationRead(id);
    } catch (_) {}
  }

  List<AppNotification> _sampleNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(id: 'n1', title: 'Daily Streak! 🔥', body: 'You are on a 7-day streak. Keep it up!', type: 'streak', createdAt: now.subtract(const Duration(hours: 2))),
      AppNotification(id: 'n2', title: 'New Achievement 🏆', body: 'You unlocked the "100 Words" badge!', type: 'achievement', createdAt: now.subtract(const Duration(days: 1))),
      AppNotification(id: 'n3', title: 'Friend Request', body: 'Sarah wants to be your study buddy.', type: 'friend', createdAt: now.subtract(const Duration(days: 2))),
    ];
  }
}
