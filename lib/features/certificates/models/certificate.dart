class Certificate {
  final String id;
  final String userId;
  final String userName;
  final String level;
  final String levelTitle;
  final int totalXp;
  final int lessonsCompleted;
  final int vocabularyLearned;
  final double averageScore;
  final DateTime issuedAt;
  final String certificateCode;

  const Certificate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.level,
    required this.levelTitle,
    required this.totalXp,
    required this.lessonsCompleted,
    required this.vocabularyLearned,
    required this.averageScore,
    required this.issuedAt,
    required this.certificateCode,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'level': level,
    'levelTitle': levelTitle,
    'totalXp': totalXp,
    'lessonsCompleted': lessonsCompleted,
    'vocabularyLearned': vocabularyLearned,
    'averageScore': averageScore,
    'issuedAt': issuedAt.toIso8601String(),
    'certificateCode': certificateCode,
  };

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    level: json['level'] ?? 'A1',
    levelTitle: json['levelTitle'] ?? 'Beginner',
    totalXp: json['totalXp'] ?? 0,
    lessonsCompleted: json['lessonsCompleted'] ?? 0,
    vocabularyLearned: json['vocabularyLearned'] ?? 0,
    averageScore: (json['averageScore'] ?? 0).toDouble(),
    issuedAt: json['issuedAt'] != null ? DateTime.parse(json['issuedAt']) : DateTime.now(),
    certificateCode: json['certificateCode'] ?? '',
  );

  factory Certificate.generate({
    required String userId,
    required String userName,
    required String level,
    required String levelTitle,
    required int totalXp,
    required int lessonsCompleted,
    required int vocabularyLearned,
    required double averageScore,
  }) {
    final code = 'LEXI-$level-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    return Certificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      level: level,
      levelTitle: levelTitle,
      totalXp: totalXp,
      lessonsCompleted: lessonsCompleted,
      vocabularyLearned: vocabularyLearned,
      averageScore: averageScore,
      issuedAt: DateTime.now(),
      certificateCode: code,
    );
  }

  String get formattedDate => '${issuedAt.day}/${issuedAt.month}/${issuedAt.year}';
  String get levelDisplay => '$level - $levelTitle';
}
