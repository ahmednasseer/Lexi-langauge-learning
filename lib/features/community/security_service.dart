import 'package:flutter/material.dart';
import 'models/message.dart';

class SecurityService extends ChangeNotifier {
  final List<BlockedUser> _blockedUsers = [];
  final List<UserReport> _reports = [];
  final Map<String, List<DateTime>> _messageRateLimits = {};
  final Map<String, int> _dailyMessageCounts = {};

  static const int _freeUserDailyLimit = 10;
  static const int _premiumUserDailyLimit = 50;
  static const int _rateLimitWindowMinutes = 1;
  static const int _maxMessagesPerMinute = 5;

  List<BlockedUser> get blockedUsers => List.unmodifiable(_blockedUsers);
  List<UserReport> get reports => List.unmodifiable(_reports);

  bool isBlocked(String currentUserId, String targetUserId) {
    return _blockedUsers.any((b) =>
      (b.blockerId == currentUserId && b.blockedId == targetUserId) ||
      (b.blockerId == targetUserId && b.blockedId == currentUserId)
    );
  }

  bool canSendRequest(String senderId, String receiverId, UserProfile receiverProfile, bool isPremium) {
    if (isBlocked(senderId, receiverId)) return false;
    if (!receiverProfile.canSendRequest && !receiverProfile.canMessage) return false;
    if (!_checkRateLimit(senderId)) return false;
    if (!_checkDailyLimit(senderId, isPremium)) return false;
    return true;
  }

  bool canSendMessage(String senderId, String receiverId, bool isPremium) {
    if (isBlocked(senderId, receiverId)) return false;
    if (!_checkRateLimit(senderId)) return false;
    if (!_checkDailyLimit(senderId, isPremium)) return false;
    return true;
  }

  bool _checkRateLimit(String userId) {
    final now = DateTime.now();
    final timestamps = _messageRateLimits[userId] ?? [];
    final recentTimestamps = timestamps.where(
      (t) => now.difference(t).inMinutes < _rateLimitWindowMinutes,
    ).toList();
    _messageRateLimits[userId] = recentTimestamps;
    return recentTimestamps.length < _maxMessagesPerMinute;
  }

  bool _checkDailyLimit(String userId, bool isPremium) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = '${userId}_$today';
    final currentCount = _dailyMessageCounts[key] ?? 0;
    final limit = isPremium ? _premiumUserDailyLimit : _freeUserDailyLimit;
    return currentCount < limit;
  }

  void recordMessageSent(String userId) {
    final now = DateTime.now();
    _messageRateLimits.putIfAbsent(userId, () => []).add(now);
    final today = now.toIso8601String().substring(0, 10);
    final key = '${userId}_$today';
    _dailyMessageCounts[key] = (_dailyMessageCounts[key] ?? 0) + 1;
    notifyListeners();
  }

  int getRemainingDailyMessages(String userId, bool isPremium) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = '${userId}_$today';
    final currentCount = _dailyMessageCounts[key] ?? 0;
    final limit = isPremium ? _premiumUserDailyLimit : _freeUserDailyLimit;
    return (limit - currentCount).clamp(0, limit);
  }

  bool blockUser(String blockerId, String blockedId) {
    if (isBlocked(blockerId, blockedId)) return false;
    _blockedUsers.add(BlockedUser(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      blockerId: blockerId,
      blockedId: blockedId,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  bool unblockUser(String blockerId, String blockedId) {
    final initialLength = _blockedUsers.length;
    _blockedUsers.removeWhere((b) =>
      b.blockerId == blockerId && b.blockedId == blockedId
    );
    final removed = _blockedUsers.length < initialLength;
    if (removed) notifyListeners();
    return removed;
  }

  UserReport reportUser({
    required String reporterId,
    required String reportedUserId,
    String? messageId,
    required ReportReason reason,
    String? description,
  }) {
    final report = UserReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      messageId: messageId,
      reason: reason,
      description: description,
      createdAt: DateTime.now(),
    );
    _reports.add(report);
    notifyListeners();
    return report;
  }

  bool hasUserReported(String reporterId, String reportedUserId) {
    return _reports.any((r) =>
      r.reporterId == reporterId && r.reportedUserId == reportedUserId
    );
  }

  List<UserReport> getReportsForUser(String userId) {
    return _reports.where((r) => r.reportedUserId == userId).toList();
  }

  static String getReportReasonText(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.other:
        return 'Other';
    }
  }
}
