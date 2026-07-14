import 'chat_model.dart';
import '../../services/ai_service.dart';

class AiRepository {
  final AiService _aiService;

  AiRepository(this._aiService);

  List<ChatMessage> get history => _aiService.history;

  Future<ChatMessage> sendMessage({
    required String message,
    required String learningLanguage,
    required String nativeLanguage,
  }) => _aiService.sendMessage(
    message: message,
    learningLanguage: learningLanguage,
    nativeLanguage: nativeLanguage,
  );

  void clearHistory() => _aiService.clearHistory();
}
