import 'package:flutter/material.dart';
import 'chat_model.dart';
import 'ai_repository.dart';

class AiTutorController extends ChangeNotifier {
  final AiRepository _repository;
  final TextEditingController _messageController = TextEditingController();

  AiTutorController(this._repository);

  TextEditingController get messageController => _messageController;
  List<ChatMessage> get messages => _repository.history;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void init() {
    if (_repository.history.isEmpty) {
      _repository.sendMessage(
        message: 'hello',
        learningLanguage: 'English',
        nativeLanguage: 'Arabic',
      );
    }
  }

  Future<void> sendMessage(String learningLanguage, String nativeLanguage) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _isLoading = true;
    notifyListeners();

    await _repository.sendMessage(
      message: text,
      learningLanguage: learningLanguage,
      nativeLanguage: nativeLanguage,
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _repository.clearHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
