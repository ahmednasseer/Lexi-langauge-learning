import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum VoiceState { idle, listening, processing, speaking }

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  VoiceState _state = VoiceState.idle;
  String _lastRecognizedText = '';
  bool _isInitialized = false;
  bool _isListening = false;

  VoiceState get state => _state;
  String get lastRecognizedText => _lastRecognizedText;
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );

      await _flutterTts.setLanguage('de-DE');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _state = VoiceState.idle;
        debugPrint('TTS completed');
      });

      _isInitialized = true;
      debugPrint('Voice service initialized');
    } catch (e) {
      debugPrint('Voice service initialization failed: $e');
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
  }) async {
    if (!_isInitialized || _isListening) return;

    try {
      _state = VoiceState.listening;
      _isListening = true;

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _lastRecognizedText = result.recognizedWords;
            onResult(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
          localeId: 'de-DE',
        ),
      );
    } catch (e) {
      _state = VoiceState.idle;
      _isListening = false;
      onError(e.toString());
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _state = VoiceState.processing;
      _isListening = false;
    } catch (e) {
      debugPrint('Error stopping listening: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) return;

    try {
      _state = VoiceState.speaking;
      await _flutterTts.speak(text);
    } catch (e) {
      _state = VoiceState.idle;
      debugPrint('TTS error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _state = VoiceState.idle;
    } catch (e) {
      debugPrint('Error stopping speaking: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  void reset() {
    _state = VoiceState.idle;
    _lastRecognizedText = '';
    _isListening = false;
  }

  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}
