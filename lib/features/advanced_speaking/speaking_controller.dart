import 'package:flutter/material.dart';
import 'models/conversation_models.dart';
import 'models/ai_character.dart';
import 'models/speaking_progress.dart';
import 'services/voice_service.dart';
import 'services/ai_conversation_service.dart';
import 'services/conversation_memory_service.dart';

class SpeakingController extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();
  final AIConversationService _aiService = AIConversationService();
  final ConversationMemoryService _memoryService = ConversationMemoryService();

  ConversationSession? _currentSession;
  ConversationContext? _currentContext;
  ConversationMemory _memory = ConversationMemory.empty();
  SpeakingProgress _progress = SpeakingProgress.empty();
  List<SpeakingChallenge> _challenges = [];
  ConversationState _state = ConversationState.idle;
  bool _isLoading = false;
  String _currentText = '';
  PronunciationAnalysis? _lastAnalysis;
  ConversationFeedback? _feedback;

  ConversationSession? get currentSession => _currentSession;
  ConversationContext? get currentContext => _currentContext;
  ConversationMemory get memory => _memory;
  SpeakingProgress get progress => _progress;
  List<SpeakingChallenge> get challenges => _challenges;
  ConversationState get state => _state;
  bool get isLoading => _isLoading;
  String get currentText => _currentText;
  PronunciationAnalysis? get lastAnalysis => _lastAnalysis;
  ConversationFeedback? get feedback => _feedback;
  VoiceService get voiceService => _voiceService;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _voiceService.initialize();
      _memory = await _memoryService.getMemory();
      _progress = await _memoryService.getProgress();
      _challenges = await _memoryService.getChallenges();

      if (_challenges.isEmpty) {
        _challenges = _memoryService.getAvailableChallenges();
        await _memoryService.saveChallenges(_challenges);
      }
    } catch (e) {
      debugPrint('Error initializing speaking controller: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startConversation(ConversationScenario scenario) async {
    _isLoading = true;
    _state = ConversationState.processing;
    notifyListeners();

    try {
      final character = AICharacter.lexi();
      _currentContext = _memoryService.buildContext(
        scenario: scenario,
        character: character,
        userLevel: _progress.currentLevel,
      );

      final initialMessage = _aiService.getInitialMessage(scenario, character);

      _currentSession = ConversationSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        scenario: scenario,
        messages: [
          ConversationMessage(
            id: 'msg_0',
            role: 'ai',
            content: initialMessage,
            timestamp: DateTime.now(),
          ),
        ],
        startedAt: DateTime.now(),
        state: ConversationState.aiSpeaking,
      );

      _state = ConversationState.aiSpeaking;
      _isLoading = false;
      notifyListeners();

      await _voiceService.speak(initialMessage);
    } catch (e) {
      debugPrint('Error starting conversation: $e');
      _state = ConversationState.idle;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    if (_currentSession == null) return;

    _state = ConversationState.listening;
    notifyListeners();

    await _voiceService.startListening(
      onResult: (text) {
        _currentText = text;
        notifyListeners();
      },
      onError: (error) {
        _state = ConversationState.idle;
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    _state = ConversationState.processing;
    notifyListeners();

    if (_currentText.isNotEmpty) {
      await _processUserResponse(_currentText);
    }
  }

  Future<void> _processUserResponse(String userText) async {
    if (_currentSession == null || _currentContext == null) return;

    _state = ConversationState.processing;
    notifyListeners();

    final analysis = _aiService.analyzePronunciation(
      spokenText: userText,
      targetText: _currentSession!.messages.last.content,
    );

    _lastAnalysis = analysis;

    final userMessage = ConversationMessage(
      id: 'msg_${_currentSession!.messages.length}',
      role: 'user',
      content: userText,
      germanText: userText,
      timestamp: DateTime.now(),
      pronunciationAnalysis: analysis,
    );

    final updatedMessages = List<ConversationMessage>.from(_currentSession!.messages)
      ..add(userMessage);

    _currentSession = _currentSession!.copyWith(
      messages: updatedMessages,
      wordsSpoken: _currentSession!.wordsSpoken + userText.split(' ').length,
    );

    await _updateMemory(userText, analysis);

    final aiResponse = _aiService.getAIResponse(
      scenario: _currentSession!.scenario,
      messages: updatedMessages,
      context: _currentContext!,
      userResponse: userText,
    );

    final aiMessage = ConversationMessage(
      id: 'msg_${updatedMessages.length}',
      role: 'ai',
      content: aiResponse,
      timestamp: DateTime.now(),
    );

    _currentSession = _currentSession!.copyWith(
      messages: [...updatedMessages, aiMessage],
      state: ConversationState.aiSpeaking,
    );

    _state = ConversationState.aiSpeaking;
    notifyListeners();

    await _voiceService.speak(aiResponse);
  }

  Future<void> _updateMemory(String userText, PronunciationAnalysis analysis) async {
    if (_currentContext == null) return;

    if (analysis.overallScore < 70) {
      await _memoryService.recordMistake(_memory, userText);
    }

    if (analysis.wordAccuracy < 80) {
      final words = userText.split(' ');
      for (final word in words) {
        if (word.length > 3) {
          await _memoryService.recordVocabularyProblem(_memory, word);
        }
      }
    }

    await _memoryService.updateScenarioScore(
      _memory,
      _currentContext!.scenario,
      analysis.overallScore.toInt(),
    );

    _memory = await _memoryService.getMemory();
  }

  Future<void> endConversation() async {
    if (_currentSession == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _voiceService.stopSpeaking();

      _feedback = _aiService.generateFeedback(_currentSession!);

      _currentSession = _currentSession!.copyWith(
        endedAt: DateTime.now(),
        state: ConversationState.ended,
        totalScore: _feedback!.overallScore.toInt(),
        xpEarned: _feedback!.xpEarned,
      );

      await _memoryService.updateProgress(
        current: _progress,
        minutes: _currentSession!.durationSeconds ~/ 60,
        words: _currentSession!.wordsSpoken,
        pronunciationScore: _feedback!.overallScore,
        fluencyScore: _lastAnalysis?.speakingSpeed ?? 0,
        scenario: _currentSession!.scenario,
      );

      _progress = await _memoryService.getProgress();
    } catch (e) {
      debugPrint('Error ending conversation: $e');
    }

    _state = ConversationState.ended;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> speakText(String text) async {
    await _voiceService.speak(text);
  }

  void resetSession() {
    _currentSession = null;
    _currentContext = null;
    _lastAnalysis = null;
    _feedback = null;
    _currentText = '';
    _state = ConversationState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
