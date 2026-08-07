import 'package:flutter/material.dart';
import 'models/coach_message.dart';
import 'models/conversation_category.dart';
import 'ai_coach_repository.dart';
import '../../core/services/auth_service.dart';

class AiCoachController extends ChangeNotifier {
  final AiCoachRepository _repository = AiCoachRepository();

  List<CoachMessage> get history => _repository.history;
  int get remainingMessages => _repository.remainingMessages;
  int get dailyLimit => _repository.dailyLimit;
  bool get canSendMessages => _repository.canSendMessages;

  ConversationCategory? _selectedCategory;
  ConversationCategory? get selectedCategory => _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _currentLevel = 'A1';
  String get currentLevel => _currentLevel;

  int _todayXp = 0;
  int get todayXp => _todayXp;

  int _totalXp = 0;
  int get totalXp => _totalXp;

  Future<void> init() async {
    await _repository.init();
    final user = AuthService.instance.currentUser;
    _currentLevel = user?.level ?? 'A1';
    _totalXp = user?.xp ?? 0;
    notifyListeners();
  }

  void selectCategory(ConversationCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }

  Future<CoachMessage> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return CoachMessage(
        id: '',
        content: '',
        isUser: true,
        timestamp: DateTime.now(),
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.sendMessage(
        message: message,
        category: _selectedCategory?.id ?? 'free',
        level: _currentLevel,
      );

      // Update XP
      if (response.xpEarned != null) {
        _todayXp += response.xpEarned!;
        _totalXp += response.xpEarned!;
        await AuthService.instance.addXp(response.xpEarned!);
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  void startSpeaking() {
    _isListening = true;
    notifyListeners();
  }

  void stopSpeaking() {
    _isListening = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _todayXp = 0;
    notifyListeners();
  }

  List<Map<String, dynamic>> getMistakeStats() {
    final stats = _repository.getMistakeStats();
    return stats.entries.map((e) => {
      'type': e.key,
      'count': e.value,
    }).toList();
  }

  String getGreeting() {
    final user = AuthService.instance.currentUser;
    final name = user?.name ?? 'Student';
    return 'Hallo $name 👋';
  }

  String getSubtext() {
    return 'Ich bin Lexi, your German AI Coach';
  }
}
