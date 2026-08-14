import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/analytics_service.dart';
import '../features/ai_tutor/chat_model.dart';

class AiService {
  final ApiService _api = ApiService();
  final List<ChatMessage> _localHistory = [];
  int _remainingMessages = 20;
  final int _dailyLimit = 20;
  bool _isOffline = false;
  String? _lastError;

  List<ChatMessage> get history => List.unmodifiable(_localHistory);
  int get remainingMessages => _remainingMessages;
  int get dailyLimit => _dailyLimit;
  bool get canSendMessages =>
      _remainingMessages > 0 || _remainingMessages == -1;
  bool get isOffline => _isOffline;
  String? get lastError => _lastError;

  Future<void> loadHistory() async {
    final result = await _api.getChatHistory();
    if (result.isSuccess && result.data != null) {
      final list = result.data!;
      _localHistory.clear();
      for (final item in list) {
        try {
          _localHistory.add(ChatMessage.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Failed to parse chat message: $e');
        }
      }
    }
  }

  Future<ChatMessage> sendMessage({
    required String message,
    required String learningLanguage,
    required String nativeLanguage,
  }) async {
    _lastError = null;
    _localHistory.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    final result = await _api.sendAiMessage(
      message,
      learningLanguage,
      nativeLanguage,
    );
    if (result.isSuccess) {
      final response = result.data!;
      _isOffline = false;
      _remainingMessages = response['remaining'] ?? _remainingMessages;

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response['response'] ?? response['message'] ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        correction: response['correction'],
        explanation: response['explanation'],
      );

      _localHistory.add(aiMsg);
      AnalyticsService.instance.logAiChatMessage(category: 'tutor');
      return aiMsg;
    } else {
      _isOffline = result.isOffline;
      _lastError = result.error;
      throw Exception(result.error ?? 'Failed to send message');
    }
  }

  Future<Map<String, dynamic>> getUsageStats() async {
    final result = await _api.getAiUsage();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.error ?? 'Failed to load AI usage stats');
  }

  Future<void> clearHistory() async {
    final result = await _api.clearChatHistory();
    if (result.isSuccess) _localHistory.clear();
  }
}
