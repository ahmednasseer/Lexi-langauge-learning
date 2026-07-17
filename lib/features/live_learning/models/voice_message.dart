enum VoiceMessageStatus {
  recording,
  sent,
  played,
  failed,
}

class VoiceMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? receiverId;
  final String? groupId;
  final String? roomId;
  final int durationSeconds;
  final String? audioUrl;
  final VoiceMessageStatus status;
  final DateTime createdAt;
  final bool isPlayed;
  final DateTime? playedAt;
  final String? transcription;
  final int fileSize;

  const VoiceMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    this.receiverId,
    this.groupId,
    this.roomId,
    required this.durationSeconds,
    this.audioUrl,
    this.status = VoiceMessageStatus.sent,
    required this.createdAt,
    this.isPlayed = false,
    this.playedAt,
    this.transcription,
    this.fileSize = 0,
  });

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isDirect => receiverId != null;
  bool get isGroup => groupId != null;
  bool get isRoom => roomId != null;

  VoiceMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? receiverId,
    String? groupId,
    String? roomId,
    int? durationSeconds,
    String? audioUrl,
    VoiceMessageStatus? status,
    DateTime? createdAt,
    bool? isPlayed,
    DateTime? playedAt,
    String? transcription,
    int? fileSize,
  }) {
    return VoiceMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      roomId: roomId ?? this.roomId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isPlayed: isPlayed ?? this.isPlayed,
      playedAt: playedAt ?? this.playedAt,
      transcription: transcription ?? this.transcription,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatarUrl': senderAvatarUrl,
    'receiverId': receiverId,
    'groupId': groupId,
    'roomId': roomId,
    'durationSeconds': durationSeconds,
    'audioUrl': audioUrl,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'isPlayed': isPlayed,
    'playedAt': playedAt?.toIso8601String(),
    'transcription': transcription,
    'fileSize': fileSize,
  };

  factory VoiceMessage.fromJson(Map<String, dynamic> json) => VoiceMessage(
    id: json['id'] ?? '',
    senderId: json['senderId'] ?? '',
    senderName: json['senderName'] ?? '',
    senderAvatarUrl: json['senderAvatarUrl'],
    receiverId: json['receiverId'],
    groupId: json['groupId'],
    roomId: json['roomId'],
    durationSeconds: json['durationSeconds'] ?? 0,
    audioUrl: json['audioUrl'],
    status: VoiceMessageStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => VoiceMessageStatus.sent,
    ),
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    isPlayed: json['isPlayed'] ?? false,
    playedAt: json['playedAt'] != null ? DateTime.parse(json['playedAt']) : null,
    transcription: json['transcription'],
    fileSize: json['fileSize'] ?? 0,
  );
}
