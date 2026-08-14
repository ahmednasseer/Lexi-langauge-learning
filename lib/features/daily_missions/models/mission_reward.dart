class MissionReward {
  final int xp;
  final int gems;
  final String? badgeId;
  final String? title;
  final bool isBonus;

  const MissionReward({
    required this.xp,
    this.gems = 0,
    this.badgeId,
    this.title,
    this.isBonus = false,
  });

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'gems': gems,
    'badgeId': badgeId,
    'title': title,
    'isBonus': isBonus,
  };

  factory MissionReward.fromJson(Map<String, dynamic> json) => MissionReward(
    xp: json['xp'] ?? 0,
    gems: json['gems'] ?? 0,
    badgeId: json['badgeId'],
    title: json['title'],
    isBonus: json['isBonus'] ?? false,
  );

  factory MissionReward.dailyComplete() => const MissionReward(
    xp: 100,
    gems: 20,
    title: 'Daily Mission Complete!',
    isBonus: true,
  );

  factory MissionReward.streakBonus(int days) {
    if (days >= 100)
      return const MissionReward(
        xp: 500,
        gems: 100,
        title: '100 Day Streak!',
        isBonus: true,
      );
    if (days >= 30)
      return const MissionReward(
        xp: 200,
        gems: 50,
        title: '30 Day Streak!',
        isBonus: true,
      );
    if (days >= 7)
      return const MissionReward(
        xp: 100,
        gems: 20,
        title: '7 Day Streak!',
        isBonus: true,
      );
    return MissionReward(xp: days * 10, gems: days * 2);
  }
}
