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

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? json['message'] ?? '',
        type: json['type'] ?? 'system',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
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
    final result = await _api.getNotifications(page: page);
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load notifications');
    }
    return result.data!
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    final result = await _api.markNotificationRead(id);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to mark notification as read');
    }
  }
}
