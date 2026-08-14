class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final String level;
  final String? imageUrl;
  final int memberCount;
  final int postCount;
  final bool isJoined;
  final DateTime createdAt;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    this.imageUrl,
    this.memberCount = 0,
    this.postCount = 0,
    this.isJoined = false,
    required this.createdAt,
  });

  CommunityGroup copyWith({bool? isJoined, int? memberCount}) {
    return CommunityGroup(
      id: id,
      name: name,
      description: description,
      level: level,
      imageUrl: imageUrl,
      memberCount: memberCount ?? this.memberCount,
      postCount: postCount,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'level': level,
    'imageUrl': imageUrl,
    'memberCount': memberCount,
    'postCount': postCount,
    'isJoined': isJoined,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CommunityGroup.fromJson(Map<String, dynamic> json) => CommunityGroup(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    level: json['level'] ?? 'A1',
    imageUrl: json['imageUrl'],
    memberCount: json['memberCount'] ?? 0,
    postCount: json['postCount'] ?? 0,
    isJoined: json['isJoined'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  static List<CommunityGroup> getDefaultGroups() {
    return [
      CommunityGroup(
        id: 'g1',
        name: 'German Beginners A1',
        description: 'Perfect for those just starting their German journey',
        level: 'A1',
        memberCount: 1250,
        postCount: 340,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      CommunityGroup(
        id: 'g2',
        name: 'German A2 Practice',
        description: 'Practice and improve your elementary German',
        level: 'A2',
        memberCount: 890,
        postCount: 210,
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
      ),
      CommunityGroup(
        id: 'g3',
        name: 'Goethe B1 Preparation',
        description: 'Prepare for the Goethe B1 exam together',
        level: 'B1',
        memberCount: 650,
        postCount: 180,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      CommunityGroup(
        id: 'g4',
        name: 'Speaking Club',
        description: 'Practice speaking with fellow learners',
        level: 'All',
        memberCount: 1100,
        postCount: 420,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      CommunityGroup(
        id: 'g5',
        name: 'Grammar Masters',
        description: 'Master German grammar rules together',
        level: 'B1+',
        memberCount: 420,
        postCount: 150,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }
}
