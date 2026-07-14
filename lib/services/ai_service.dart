import 'api_service.dart';
import '../features/ai_tutor/chat_model.dart';

class AiService {
  final ApiService _api = ApiService();
  final List<ChatMessage> _localHistory = [];
  int _remainingMessages = 20;
  int _dailyLimit = 20;

  List<ChatMessage> get history => List.unmodifiable(_localHistory);
  int get remainingMessages => _remainingMessages;
  int get dailyLimit => _dailyLimit;
  bool get canSendMessages => _remainingMessages > 0 || _remainingMessages == -1;

  Future<ChatMessage> sendMessage({
    required String message,
    required String learningLanguage,
    required String nativeLanguage,
  }) async {
    _localHistory.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    try {
      final response = await _api.sendAiMessage(message, learningLanguage, nativeLanguage);

      _remainingMessages = response['remaining'] ?? _remainingMessages;

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response['response'],
        isUser: false,
        timestamp: DateTime.now(),
        correction: response['correction'],
        explanation: response['explanation'],
      );

      _localHistory.add(aiMsg);
      return aiMsg;
    } catch (e) {
      final fallback = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _localHistory.add(fallback);
      return fallback;
    }
  }

  Future<Map<String, dynamic>> getUsageStats() async {
    try {
      final response = await _api.getAiUsage();
      return response;
    } catch (e) {
      return {
        'today': {'messages': 0, 'tokens': 0},
        'thisMonth': {'totalMessages': 0, 'totalTokens': 0, 'activeDays': 0},
      };
    }
  }

  void clearHistory() {
    _localHistory.clear();
  }
}
