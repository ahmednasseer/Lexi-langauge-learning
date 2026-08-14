import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/live_room.dart';
import '../models/language_partner.dart';
import '../models/learning_group.dart';
import '../models/community_event.dart';
import '../models/voice_message.dart';

class LiveLearningService {
  static const String _roomsKey = 'live_rooms';
  static const String _partnersKey = 'language_partners';
  static const String _groupsKey = 'learning_groups';
  static const String _eventsKey = 'community_events';
  static const String _voiceMessagesKey = 'voice_messages';

  Future<List<LiveRoom>> getRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_roomsKey);
      if (roomsJson != null) {
        final List<dynamic> list = jsonDecode(roomsJson);
        return list.map((j) => LiveRoom.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached rooms: $e');
    }
    return [];
  }

  Future<void> saveRooms(List<LiveRoom> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _roomsKey,
      jsonEncode(rooms.map((r) => r.toJson()).toList()),
    );
  }

  Future<LiveRoom> createRoom({
    required String hostId,
    required String hostName,
    required String title,
    required String topic,
    required String description,
    required RoomLevel level,
    int maxParticipants = 10,
    int durationMinutes = 30,
    List<String> tags = const [],
  }) async {
    final rooms = await getRooms();
    final room = LiveRoom(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      hostId: hostId,
      hostName: hostName,
      title: title,
      topic: topic,
      description: description,
      level: level,
      maxParticipants: maxParticipants,
      createdAt: DateTime.now(),
      durationMinutes: durationMinutes,
      tags: tags,
    );

    rooms.insert(0, room);
    await saveRooms(rooms);
    return room;
  }

  Future<LiveRoom?> joinRoom(
    String roomId,
    String userId,
    String userName,
  ) async {
    final rooms = await getRooms();
    final roomIndex = rooms.indexWhere((r) => r.id == roomId);

    if (roomIndex == -1) return null;

    final room = rooms[roomIndex];
    if (room.isFull) return null;

    final participant = RoomParticipant(
      userId: userId,
      userName: userName,
      joinedAt: DateTime.now(),
    );

    final updatedRoom = room.copyWith(
      participants: [...room.participants, participant],
    );

    rooms[roomIndex] = updatedRoom;
    await saveRooms(rooms);
    return updatedRoom;
  }

  Future<LiveRoom?> leaveRoom(String roomId, String userId) async {
    final rooms = await getRooms();
    final roomIndex = rooms.indexWhere((r) => r.id == roomId);

    if (roomIndex == -1) return null;

    final room = rooms[roomIndex];
    final updatedParticipants = room.participants
        .where((p) => p.userId != userId)
        .toList();

    final updatedRoom = room.copyWith(participants: updatedParticipants);
    rooms[roomIndex] = updatedRoom;
    await saveRooms(rooms);
    return updatedRoom;
  }

  Future<List<LanguagePartner>> getPartners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partnersJson = prefs.getString(_partnersKey);
      if (partnersJson != null) {
        final List<dynamic> list = jsonDecode(partnersJson);
        return list.map((j) => LanguagePartner.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached partners: $e');
    }
    return [];
  }

  Future<void> savePartners(List<LanguagePartner> partners) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _partnersKey,
      jsonEncode(partners.map((p) => p.toJson()).toList()),
    );
  }

  Future<PartnerMatch?> findMatch({
    required String userId,
    required String nativeLanguage,
    required String learningLanguage,
    required String level,
    required MatchingGoal goal,
  }) async {
    final partners = await getPartners();

    final availablePartners = partners
        .where(
          (p) =>
              p.userId != userId &&
              p.status == PartnerStatus.pending &&
              p.nativeLanguage == learningLanguage &&
              p.learningLanguage == nativeLanguage,
        )
        .toList();

    if (availablePartners.isEmpty) return null;

    final bestMatch = availablePartners.first;
    final compatibilityScore = _calculateCompatibility(
      level: level,
      partnerLevel: bestMatch.level,
      goal: goal,
      partnerGoal: bestMatch.goal,
    );

    return PartnerMatch(
      user: LanguagePartner(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: 'You',
        nativeLanguage: nativeLanguage,
        learningLanguage: learningLanguage,
        level: level,
        goal: goal,
        createdAt: DateTime.now(),
      ),
      partner: bestMatch,
      compatibilityScore: compatibilityScore,
      commonInterests: [goal.displayName],
      matchReason: 'Mutual language exchange opportunity',
    );
  }

  double _calculateCompatibility({
    required String level,
    required String partnerLevel,
    required MatchingGoal goal,
    required MatchingGoal partnerGoal,
  }) {
    double score = 0.5;

    if (level == partnerLevel) score += 0.3;
    if (goal == partnerGoal) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  Future<List<LearningGroup>> getGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getString(_groupsKey);
      if (groupsJson != null) {
        final List<dynamic> list = jsonDecode(groupsJson);
        return list.map((j) => LearningGroup.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached groups: $e');
    }
    return [];
  }

  Future<void> saveGroups(List<LearningGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _groupsKey,
      jsonEncode(groups.map((g) => g.toJson()).toList()),
    );
  }

  Future<LearningGroup?> joinGroup(
    String groupId,
    String userId,
    String userName,
  ) async {
    final groups = await getGroups();
    final groupIndex = groups.indexWhere((g) => g.id == groupId);

    if (groupIndex == -1) return null;

    final group = groups[groupIndex];
    if (group.isFull) return null;

    final member = GroupMember(
      userId: userId,
      userName: userName,
      joinedAt: DateTime.now(),
    );

    final updatedGroup = group.copyWith(members: [...group.members, member]);

    groups[groupIndex] = updatedGroup;
    await saveGroups(groups);
    return updatedGroup;
  }

  Future<List<CommunityEvent>> getEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);
      if (eventsJson != null) {
        final List<dynamic> list = jsonDecode(eventsJson);
        return list.map((j) => CommunityEvent.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached events: $e');
    }
    return [];
  }

  Future<void> saveEvents(List<CommunityEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _eventsKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  Future<CommunityEvent?> joinEvent(
    String eventId,
    String userId,
    String userName,
  ) async {
    final events = await getEvents();
    final eventIndex = events.indexWhere((e) => e.id == eventId);

    if (eventIndex == -1) return null;

    final event = events[eventIndex];
    if (event.isFull) return null;

    final participant = EventParticipant(
      userId: userId,
      userName: userName,
      joinedAt: DateTime.now(),
    );

    final updatedEvent = event.copyWith(
      participants: [...event.participants, participant],
    );

    events[eventIndex] = updatedEvent;
    await saveEvents(events);
    return updatedEvent;
  }

  Future<List<VoiceMessage>> getVoiceMessages(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_voiceMessagesKey);
      if (messagesJson != null) {
        final List<dynamic> list = jsonDecode(messagesJson);
        return list.map((j) => VoiceMessage.fromJson(j)).toList();
      }
    } catch (e) {
      // Fall through to default
    }
    return [];
  }

  Future<void> saveVoiceMessage(VoiceMessage message) async {
    final messages = await getVoiceMessages(message.senderId);
    messages.insert(0, message);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _voiceMessagesKey,
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }

  List<LiveRoom> _getDemoRooms() {
    return [
      LiveRoom(
        id: 'room_1',
        hostId: 'host_1',
        hostName: 'Lexi AI',
        title: 'German Café',
        topic: 'Talking about Travel',
        description: 'Practice German conversation about travel experiences',
        level: RoomLevel.b1,
        status: RoomStatus.waiting,
        maxParticipants: 10,
        participants: [
          RoomParticipant(
            userId: 'user_1',
            userName: 'Ahmed',
            joinedAt: DateTime.now(),
            isHost: false,
          ),
          RoomParticipant(
            userId: 'user_2',
            userName: 'Lena',
            joinedAt: DateTime.now(),
          ),
          RoomParticipant(
            userId: 'user_3',
            userName: 'Marco',
            joinedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        durationMinutes: 30,
        tags: ['Travel', 'Conversation', 'B1'],
      ),
      LiveRoom(
        id: 'room_2',
        hostId: 'host_2',
        hostName: 'Maria',
        title: 'Grammar Workshop',
        topic: 'Perfect Tense',
        description: 'Learn and practice German perfect tense',
        level: RoomLevel.a2,
        status: RoomStatus.active,
        maxParticipants: 8,
        participants: List.generate(
          5,
          (i) => RoomParticipant(
            userId: 'user_${i + 10}',
            userName: ['Anna', 'Ben', 'Clara', 'David', 'Eva'][i],
            joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        durationMinutes: 45,
        tags: ['Grammar', 'A2', 'Perfect Tense'],
      ),
      LiveRoom(
        id: 'room_3',
        hostId: 'host_3',
        hostName: 'Thomas',
        title: 'Business German',
        topic: 'Job Interview Preparation',
        description: 'Practice job interview conversations in German',
        level: RoomLevel.b2,
        status: RoomStatus.waiting,
        maxParticipants: 6,
        participants: [],
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        durationMinutes: 60,
        tags: ['Business', 'B2', 'Interview'],
      ),
    ];
  }

  List<LanguagePartner> _getDemoPartners() {
    return [
      LanguagePartner(
        id: 'partner_1',
        userId: 'user_lena',
        userName: 'Lena',
        nativeLanguage: 'German',
        learningLanguage: 'Arabic',
        level: 'B2',
        goal: MatchingGoal.conversation,
        createdAt: DateTime.now(),
      ),
      LanguagePartner(
        id: 'partner_2',
        userId: 'user_marcus',
        userName: 'Marcus',
        nativeLanguage: 'German',
        learningLanguage: 'English',
        level: 'C1',
        goal: MatchingGoal.business,
        createdAt: DateTime.now(),
      ),
      LanguagePartner(
        id: 'partner_3',
        userId: 'user_sophie',
        userName: 'Sophie',
        nativeLanguage: 'German',
        learningLanguage: 'Spanish',
        level: 'A2',
        goal: MatchingGoal.pronunciation,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<LearningGroup> _getDemoGroups() {
    return [
      LearningGroup(
        id: 'group_1',
        name: 'B1 Speaking Club',
        description:
            'Practice speaking German at B1 level with fellow learners',
        level: 'B1',
        category: 'Speaking',
        status: GroupStatus.active,
        maxMembers: 50,
        members: List.generate(
          25,
          (i) => GroupMember(
            userId: 'user_${i + 1}',
            userName: 'Member ${i + 1}',
            joinedAt: DateTime.now().subtract(Duration(days: i)),
            attendanceCount: 10 - (i % 5),
          ),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        frequency: SessionFrequency.weekly,
        teacherName: 'Lexi AI',
        tags: ['Speaking', 'B1', 'Practice'],
        totalSessions: 12,
        averageRating: 4.5,
      ),
      LearningGroup(
        id: 'group_2',
        name: 'A1 Beginners Circle',
        description: 'Learn German basics in a supportive group environment',
        level: 'A1',
        category: 'General',
        status: GroupStatus.active,
        maxMembers: 30,
        members: List.generate(
          18,
          (i) => GroupMember(
            userId: 'user_${i + 100}',
            userName: 'Beginner ${i + 1}',
            joinedAt: DateTime.now().subtract(Duration(days: i * 2)),
            attendanceCount: 8 - (i % 3),
          ),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        frequency: SessionFrequency.weekly,
        teacherName: 'Lexi AI',
        tags: ['Beginner', 'A1', 'Support'],
        totalSessions: 20,
        averageRating: 4.8,
      ),
    ];
  }

  List<CommunityEvent> _getDemoEvents() {
    return [
      CommunityEvent(
        id: 'event_1',
        title: '30 Days German Challenge',
        description:
            'Practice German every day for 30 days and earn exclusive rewards!',
        type: EventType.challenge,
        status: EventStatus.upcoming,
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 31)),
        maxParticipants: 10000,
        participants: List.generate(
          500,
          (i) => EventParticipant(
            userId: 'user_${i + 1}',
            userName: 'Participant ${i + 1}',
            joinedAt: DateTime.now().subtract(Duration(hours: i)),
          ),
        ),
        reward: const EventReward(
          xp: 5000,
          gems: 500,
          badgeId: 'german_master_30',
          badgeName: 'German Master 30',
        ),
        rules: [
          'Practice at least 15 minutes daily',
          'Complete daily missions',
          'Share your progress',
        ],
        tags: ['Challenge', '30 Days', 'German'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CommunityEvent(
        id: 'event_2',
        title: 'Pronunciation Workshop',
        description: 'Improve your German pronunciation with expert guidance',
        type: EventType.workshop,
        status: EventStatus.active,
        startDate: DateTime.now().subtract(const Duration(hours: 2)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
        maxParticipants: 50,
        participants: List.generate(
          35,
          (i) => EventParticipant(
            userId: 'user_${i + 500}',
            userName: 'Learner ${i + 1}',
            joinedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ),
        reward: const EventReward(
          xp: 500,
          gems: 50,
          badgeId: 'pronunciation_pro',
          badgeName: 'Pronunciation Pro',
        ),
        rules: [
          'Attend the full workshop',
          'Complete pronunciation exercises',
          'Submit recording',
        ],
        tags: ['Workshop', 'Pronunciation', 'Live'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
