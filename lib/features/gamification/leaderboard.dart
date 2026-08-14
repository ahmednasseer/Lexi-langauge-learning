class LeaderboardEntry {
  final String userId;
  final String name;
  final String avatar;
  final int xp;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.xp,
    required this.rank,
    this.isCurrentUser = false,
  });
}

class LeaderboardRepository {
  List<LeaderboardEntry> getLeaderboard() {
    return [];
  }
}
