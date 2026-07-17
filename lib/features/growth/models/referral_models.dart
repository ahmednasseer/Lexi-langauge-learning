enum ReferralStatus {
  pending,
  accepted,
  rewarded,
  expired,
}

class ReferralCode {
  final String id;
  final String userId;
  final String code;
  final int maxUses;
  final int currentUses;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  const ReferralCode({
    required this.id,
    required this.userId,
    required this.code,
    this.maxUses = 10,
    this.currentUses = 0,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  int get remainingUses => maxUses - currentUses;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canUse => isActive && !isExpired && currentUses < maxUses;

  ReferralCode copyWith({
    String? id,
    String? userId,
    String? code,
    int? maxUses,
    int? currentUses,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return ReferralCode(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      code: code ?? this.code,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'code': code,
    'maxUses': maxUses,
    'currentUses': currentUses,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'isActive': isActive,
  };

  factory ReferralCode.fromJson(Map<String, dynamic> json) => ReferralCode(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    code: json['code'] ?? '',
    maxUses: json['maxUses'] ?? 10,
    currentUses: json['currentUses'] ?? 0,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
    isActive: json['isActive'] ?? true,
  );
}

class Referral {
  final String id;
  final String referrerId;
  final String referrerName;
  final String inviteeId;
  final String inviteeName;
  final String referralCode;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final ReferralReward? reward;

  const Referral({
    required this.id,
    required this.referrerId,
    required this.referrerName,
    required this.inviteeId,
    required this.inviteeName,
    required this.referralCode,
    this.status = ReferralStatus.pending,
    required this.createdAt,
    this.acceptedAt,
    this.reward,
  });

  Referral copyWith({
    String? id,
    String? referrerId,
    String? referrerName,
    String? inviteeId,
    String? inviteeName,
    String? referralCode,
    ReferralStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    ReferralReward? reward,
  }) {
    return Referral(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referrerName: referrerName ?? this.referrerName,
      inviteeId: inviteeId ?? this.inviteeId,
      inviteeName: inviteeName ?? this.inviteeName,
      referralCode: referralCode ?? this.referralCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      reward: reward ?? this.reward,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'referrerId': referrerId,
    'referrerName': referrerName,
    'inviteeId': inviteeId,
    'inviteeName': inviteeName,
    'referralCode': referralCode,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'acceptedAt': acceptedAt?.toIso8601String(),
    'reward': reward?.toJson(),
  };

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
    id: json['id'] ?? '',
    referrerId: json['referrerId'] ?? '',
    referrerName: json['referrerName'] ?? '',
    inviteeId: json['inviteeId'] ?? '',
    inviteeName: json['inviteeName'] ?? '',
    referralCode: json['referralCode'] ?? '',
    status: ReferralStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ReferralStatus.pending,
    ),
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
    reward: json['reward'] != null ? ReferralReward.fromJson(json['reward']) : null,
  );
}

class ReferralReward {
  final int gems;
  final int premiumDays;
  final String? badgeId;

  const ReferralReward({
    required this.gems,
    required this.premiumDays,
    this.badgeId,
  });

  Map<String, dynamic> toJson() => {
    'gems': gems,
    'premiumDays': premiumDays,
    'badgeId': badgeId,
  };

  factory ReferralReward.fromJson(Map<String, dynamic> json) => ReferralReward(
    gems: json['gems'] ?? 0,
    premiumDays: json['premiumDays'] ?? 0,
    badgeId: json['badgeId'],
  );
}

class ReferralStats {
  final int totalReferrals;
  final int successfulReferrals;
  final int totalGemsEarned;
  final int totalPremiumDaysEarned;
  final List<Referral> referrals;

  const ReferralStats({
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.totalGemsEarned,
    required this.totalPremiumDaysEarned,
    required this.referrals,
  });

  Map<String, dynamic> toJson() => {
    'totalReferrals': totalReferrals,
    'successfulReferrals': successfulReferrals,
    'totalGemsEarned': totalGemsEarned,
    'totalPremiumDaysEarned': totalPremiumDaysEarned,
    'referrals': referrals.map((r) => r.toJson()).toList(),
  };

  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
    totalReferrals: json['totalReferrals'] ?? 0,
    successfulReferrals: json['successfulReferrals'] ?? 0,
    totalGemsEarned: json['totalGemsEarned'] ?? 0,
    totalPremiumDaysEarned: json['totalPremiumDaysEarned'] ?? 0,
    referrals: (json['referrals'] as List?)
        ?.map((r) => Referral.fromJson(r))
        .toList() ?? [],
  );

  factory ReferralStats.empty() => const ReferralStats(
    totalReferrals: 0,
    successfulReferrals: 0,
    totalGemsEarned: 0,
    totalPremiumDaysEarned: 0,
    referrals: [],
  );
}
