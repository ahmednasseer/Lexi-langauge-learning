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
    // TODO: Replace with real API call
    return [
      LeaderboardEntry(userId: '1', name: 'Ahmad', avatar: '👨', xp: 12500, rank: 1),
      LeaderboardEntry(userId: '2', name: 'Sara', avatar: '👩', xp: 11200, rank: 2),
      LeaderboardEntry(userId: '3', name: 'You', avatar: '😊', xp: 10800, rank: 3, isCurrentUser: true),
      LeaderboardEntry(userId: '4', name: 'Mohammed', avatar: '👨', xp: 9500, rank: 4),
      LeaderboardEntry(userId: '5', name: 'Fatima', avatar: '👩', xp: 8900, rank: 5),
      LeaderboardEntry(userId: '6', name: 'Omar', avatar: '👨', xp: 7200, rank: 6),
      LeaderboardEntry(userId: '7', name: 'Lina', avatar: '👩', xp: 6800, rank: 7),
    ];
  }
}
