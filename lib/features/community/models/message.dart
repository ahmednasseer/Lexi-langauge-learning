enum MessageRequestStatus { pending, accepted, rejected, blocked }

enum PrivacySetting { everyone, friendsOnly, groupMembersOnly, disabled }

enum ReportReason { spam, harassment, inappropriateContent, other }

enum ReportStatus { pending, reviewed, resolved, dismissed }

class MessageRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final MessageRequestStatus status;
  final DateTime createdAt;

  const MessageRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    this.status = MessageRequestStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'receiverId': receiverId,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MessageRequest.fromJson(Map<String, dynamic> json) => MessageRequest(
    id: json['id'] ?? '',
    senderId: json['senderId'] ?? '',
    senderName: json['senderName'] ?? '',
    senderAvatar: json['senderAvatar'],
    receiverId: json['receiverId'] ?? '',
    status: MessageRequestStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MessageRequestStatus.pending,
    ),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'content': content,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] ?? '',
    senderId: json['senderId'] ?? '',
    receiverId: json['receiverId'] ?? '',
    content: json['content'] ?? '',
    isRead: json['isRead'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final Message? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'otherUserId': otherUserId,
    'otherUserName': otherUserName,
    'otherUserAvatar': otherUserAvatar,
    'lastMessage': lastMessage?.toJson(),
    'unreadCount': unreadCount,
  };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] ?? '',
    otherUserId: json['otherUserId'] ?? '',
    otherUserName: json['otherUserName'] ?? '',
    otherUserAvatar: json['otherUserAvatar'],
    lastMessage: json['lastMessage'] != null
        ? Message.fromJson(json['lastMessage'])
        : null,
    unreadCount: json['unreadCount'] ?? 0,
  );
}

class UserProfile {
  final String id;
  final String name;
  final String? avatar;
  final String level;
  final int xp;
  final int streak;
  final bool isPremium;
  final PrivacySetting privacySetting;
  final bool isFriend;
  final bool hasPendingRequest;
  final bool isBlocked;
  final List<String> commonGroupIds;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatar,
    required this.level,
    required this.xp,
    this.streak = 0,
    this.isPremium = false,
    this.privacySetting = PrivacySetting.friendsOnly,
    this.isFriend = false,
    this.hasPendingRequest = false,
    this.isBlocked = false,
    this.commonGroupIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'level': level,
    'xp': xp,
    'streak': streak,
    'isPremium': isPremium,
    'privacySetting': privacySetting.name,
    'isFriend': isFriend,
    'hasPendingRequest': hasPendingRequest,
    'isBlocked': isBlocked,
    'commonGroupIds': commonGroupIds,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    avatar: json['avatar'],
    level: json['level'] ?? 'A1',
    xp: json['xp'] ?? 0,
    streak: json['streak'] ?? 0,
    isPremium: json['isPremium'] ?? false,
    privacySetting: PrivacySetting.values.firstWhere(
      (e) => e.name == json['privacySetting'],
      orElse: () => PrivacySetting.friendsOnly,
    ),
    isFriend: json['isFriend'] ?? false,
    hasPendingRequest: json['hasPendingRequest'] ?? false,
    isBlocked: json['isBlocked'] ?? false,
    commonGroupIds: List<String>.from(json['commonGroupIds'] ?? []),
  );

  bool get canMessage {
    if (isBlocked) return false;
    if (isFriend) return true;
    if (privacySetting == PrivacySetting.disabled) return false;
    if (privacySetting == PrivacySetting.everyone) return true;
    if (privacySetting == PrivacySetting.groupMembersOnly) {
      return commonGroupIds.isNotEmpty;
    }
    return false;
  }

  bool get canSendRequest {
    if (isBlocked) return false;
    if (isFriend) return false;
    if (hasPendingRequest) return false;
    if (privacySetting == PrivacySetting.disabled) return false;
    return true;
  }
}

class UserReport {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String? messageId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    this.messageId,
    required this.reason,
    this.description,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporterId': reporterId,
    'reportedUserId': reportedUserId,
    'messageId': messageId,
    'reason': reason.name,
    'description': description,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
  };

  factory UserReport.fromJson(Map<String, dynamic> json) => UserReport(
    id: json['id'] ?? '',
    reporterId: json['reporterId'] ?? '',
    reportedUserId: json['reportedUserId'] ?? '',
    messageId: json['messageId'],
    reason: ReportReason.values.firstWhere(
      (e) => e.name == json['reason'],
      orElse: () => ReportReason.other,
    ),
    description: json['description'],
    status: ReportStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ReportStatus.pending,
    ),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    reviewedAt: json['reviewedAt'] != null
        ? DateTime.parse(json['reviewedAt'])
        : null,
  );
}

class BlockedUser {
  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;

  const BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'blockerId': blockerId,
    'blockedId': blockedId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BlockedUser.fromJson(Map<String, dynamic> json) => BlockedUser(
    id: json['id'] ?? '',
    blockerId: json['blockerId'] ?? '',
    blockedId: json['blockedId'] ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}
