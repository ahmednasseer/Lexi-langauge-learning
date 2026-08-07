import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/coach_message.dart';
import 'models/learning_memory.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';

class AiCoachRepository {
  final ApiService _api = ApiService();
  final List<CoachMessage> _localHistory = [];
  final List<LearningMemory> _memories = [];
  int _remainingMessages = 20;
  final int _dailyLimit = 20;

  List<CoachMessage> get history => List.unmodifiable(_localHistory);
  List<LearningMemory> get memories => List.unmodifiable(_memories);
  int get remainingMessages => _remainingMessages;
  int get dailyLimit => _dailyLimit;
  bool get canSendMessages => _remainingMessages > 0 || _remainingMessages == -1;

  Future<void> init() async {
    await _loadLocalHistory();
    await _loadMemories();
  }

  Future<void> _loadLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('ai_coach_history') ?? [];
    _localHistory.clear();
    for (final json in historyJson) {
      try {
        _localHistory.add(CoachMessage.fromJson(jsonDecode(json)));
      } catch (e) {
        // Skip invalid entries
      }
    }
  }

  Future<void> _saveLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _localHistory.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('ai_coach_history', historyJson);
  }

  Future<void> _loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final memoriesJson = prefs.getStringList('ai_coach_memories') ?? [];
    _memories.clear();
    for (final json in memoriesJson) {
      try {
        _memories.add(LearningMemory.fromJson(jsonDecode(json)));
      } catch (e) {
        // Skip invalid entries
      }
    }
  }

  Future<void> _saveMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final memoriesJson = _memories.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('ai_coach_memories', memoriesJson);
  }

  Future<CoachMessage> sendMessage({
    required String message,
    required String category,
    required String level,
  }) async {
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Student';

    // Add user message
    final userMsg = CoachMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _localHistory.add(userMsg);
    await _saveLocalHistory();

    try {
      // Build context with learning memory
      _buildContext(level, userName);

      final result = await _api.aiCoachChat(message, category: category, level: level);

      if (!result.isSuccess) {
        // Offline fallback with local AI simulation
        final fallback = _generateLocalResponse(message, category, level);
        _localHistory.add(fallback);
        await _saveLocalHistory();
        return fallback;
      }

      final response = result.data!;
      _remainingMessages = response['remaining'] ?? _remainingMessages;

      // Parse correction if present
      String? correction = response['correction'];
      String? originalSentence;
      String? correctSentence;
      String? explanation;
      String? betterAlternative;
      int xpEarned = 0;

      if (response['correction'] != null || response['corrected'] == true) {
        originalSentence = response['original'] ?? message;
        correctSentence = response['correctedSentence'] ?? response['correction'] ?? '';
        explanation = response['explanation'] ?? response['tip'] ?? '';
        betterAlternative = response['betterAlternative'];
        xpEarned = 10;

        // Save to learning memory
        _memories.add(LearningMemory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user?.id ?? '',
          mistakeType: response['mistakeType'] ?? 'grammar',
          wrongSentence: originalSentence ?? message,
          correctSentence: correctSentence ?? '',
          explanation: explanation ?? '',
          languageLevel: level,
          createdAt: DateTime.now(),
        ));
        await _saveMemories();
      } else {
        xpEarned = 5;
      }

      final aiMsg = CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response['response'] ?? response['message'] ?? 'I understand. Keep practicing!',
        isUser: false,
        timestamp: DateTime.now(),
        correction: correction,
        originalSentence: originalSentence,
        correctSentence: correctSentence,
        explanation: explanation,
        betterAlternative: betterAlternative,
        xpEarned: xpEarned,
        messageType: correction != null ? 'correction' : 'text',
      );

      _localHistory.add(aiMsg);
      await _saveLocalHistory();
      return aiMsg;
    } catch (e) {
      // Offline fallback with local AI simulation
      final fallback = _generateLocalResponse(message, category, level);
      _localHistory.add(fallback);
      await _saveLocalHistory();
      return fallback;
    }
  }

  CoachMessage _generateLocalResponse(String message, String category, String level) {
    final msgLower = message.toLowerCase();

    // Check for common mistakes and provide corrections
    if (msgLower.contains('ich habe gehen') || msgLower.contains('ich habe gehe')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Good attempt! Let me help you with that. 🎯',
        isUser: false,
        timestamp: DateTime.now(),
        originalSentence: message,
        correctSentence: 'Ich bin gegangen',
        explanation: 'When using "gehen" (to go), use "sein" (not "haben") as the auxiliary verb in Perfekt.',
        betterAlternative: 'Ich bin nach Hause gegangen.',
        xpEarned: 10,
        messageType: 'correction',
      );
    }

    if (msgLower.contains('ich bin gut') || msgLower.contains('mir geht')) {
      return CoachMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sehr gut! 👏 That\'s correct!',
        isUser: false,
        timestamp: DateTime.now(),
        xpEarned: 5,
        messageType: 'text',
      );
    }

    // Default encouraging response
    final responses = [
      'Interesting! Can you tell me more about that? 🤔',
      'Great vocabulary! Try using a longer sentence next time. 💪',
      'I understand! Let\'s practice with a new topic. What do you think about daily routines?',
      'Nice try! Remember to pay attention to article genders (der, die, das). 📚',
      'That\'s a good sentence structure! Keep practicing! 🌟',
    ];

    return CoachMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responses[DateTime.now().millisecond % responses.length],
      isUser: false,
      timestamp: DateTime.now(),
      xpEarned: 5,
      messageType: 'text',
    );
  }

  String _buildContext(String level, String userName) {
    final recentMistakes = _memories
        .where((m) => m.languageLevel == level)
        .take(5)
        .map((m) => 'Mistake: ${m.wrongSentence} -> ${m.correctSentence}')
        .join('\n');

    return '''
Student: $userName
Level: $level
Recent mistakes to watch for:
$recentMistakes
''';
  }

  Future<void> clearHistory() async {
    _localHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ai_coach_history');
  }

  Future<void> clearMemories() async {
    _memories.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ai_coach_memories');
  }

  List<LearningMemory> getMistakesByType(String type) {
    return _memories.where((m) => m.mistakeType == type).toList();
  }

  Map<String, int> getMistakeStats() {
    final stats = <String, int>{};
    for (final memory in _memories) {
      stats[memory.mistakeType] = (stats[memory.mistakeType] ?? 0) + 1;
    }
    return stats;
  }
}
