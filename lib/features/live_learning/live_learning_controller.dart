import 'package:flutter/material.dart';
import 'package:lexi/core/services/auth_service.dart';
import 'package:lexi/features/live_learning/models/live_room.dart';
import 'package:lexi/features/live_learning/models/language_partner.dart';
import 'package:lexi/features/live_learning/models/learning_group.dart';
import 'package:lexi/features/live_learning/models/community_event.dart';
import 'package:lexi/features/live_learning/models/voice_message.dart';
import 'services/live_learning_service.dart';

class LiveLearningController extends ChangeNotifier {
  final LiveLearningService _service = LiveLearningService();
  List<LiveRoom> _rooms = [];
  List<LanguagePartner> _partners = [];
  List<LearningGroup> _groups = [];
  List<CommunityEvent> _events = [];
  List<VoiceMessage> _voiceMessages = [];
  LiveRoom? _currentRoom;
  bool _isLoading = false;
  String _error = '';
  List<LiveRoom> get rooms => _rooms;
  List<LanguagePartner> get partners => _partners;
  List<LearningGroup> get groups => _groups;
  List<CommunityEvent> get events => _events;
  List<VoiceMessage> get voiceMessages => _voiceMessages;
  LiveRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String get error => _error;
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _rooms = await _service.getRooms();
      _partners = await _service.getPartners();
      _groups = await _service.getGroups();
      _events = await _service.getEvents();
      _voiceMessages = await _service.getVoiceMessages(AuthService.instance.currentUser?.id ?? '');
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
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
    _isLoading = true;
    notifyListeners();
    try {
      final room = await _service.createRoom(
        hostId: hostId,
        hostName: hostName,
        title: title,
        topic: topic,
        description: description,
        level: level,
        maxParticipants: maxParticipants,
        durationMinutes: durationMinutes,
        tags: tags,
      );
      _rooms.insert(0, room);
      _isLoading = false;
      notifyListeners();
      return room;
    } catch (e) {
      debugPrint('Error creating room: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> joinRoom(String roomId, String userId, String userName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final room = await _service.joinRoom(roomId, userId, userName);
      if (room != null) {
        final index = _rooms.indexWhere((r) => r.id == roomId);
        if (index != -1) {
          _rooms[index] = room;
        }
        _currentRoom = room;
      }
    } catch (e) {
      debugPrint('Error joining room: $e');
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final room = await _service.leaveRoom(roomId, userId);
      if (room != null) {
        final index = _rooms.indexWhere((r) => r.id == roomId);
        if (index != -1) {
          _rooms[index] = room;
        }
        if (_currentRoom?.id == roomId) {
          _currentRoom = null;
        }
      }
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<PartnerMatch?> findPartnerMatch({
    required String userId,
    required String nativeLanguage,
    required String learningLanguage,
    required String level,
    required MatchingGoal goal,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final match = await _service.findMatch(
        userId: userId,
        nativeLanguage: nativeLanguage,
        learningLanguage: learningLanguage,
        level: level,
        goal: goal,
      );
      _isLoading = false;
      notifyListeners();
      return match;
    } catch (e) {
      debugPrint('Error finding partner match: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> joinGroup(String groupId, String userId, String userName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final group = await _service.joinGroup(groupId, userId, userName);
      if (group != null) {
        final index = _groups.indexWhere((g) => g.id == groupId);
        if (index != -1) {
          _groups[index] = group;
        }
      }
    } catch (e) {
      debugPrint('Error joining group: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> joinEvent(String eventId, String userId, String userName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final event = await _service.joinEvent(eventId, userId, userName);
      if (event != null) {
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          _events[index] = event;
        }
      }
    } catch (e) {
      debugPrint('Error joining event: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendVoiceMessage(VoiceMessage message) async {
    await _service.saveVoiceMessage(message);
    _voiceMessages.insert(0, message);
    notifyListeners();
  }

  void setCurrentRoom(LiveRoom? room) {
    _currentRoom = room;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
