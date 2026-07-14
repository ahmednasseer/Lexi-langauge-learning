import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'pronunciation_result.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  String _lastRecognizedWords = '';

  String get lastRecognizedWords => _lastRecognizedWords;

  Future<bool> init() async {
    _initialized = await _speech.initialize(onError: (e) {}, onStatus: (s) {});
    return _initialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onDone,
    String localeId = 'en_US',
  }) async {
    if (!_initialized) await init();
    await _speech.listen(
      onResult: (result) {
        _lastRecognizedWords = result.recognizedWords;
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
    );
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') onDone();
    };
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  PronunciationResult evaluate(String target, String spoken) {
    if (spoken.isEmpty) return PronunciationResult(word: target, score: 0);

    final t = target.toLowerCase().replaceAll(RegExp(r'[?!.,]'), '');
    final s = spoken.toLowerCase().replaceAll(RegExp(r'[?!.,]'), '');

    int match = 0;
    for (int i = 0; i < t.length && i < s.length; i++) {
      if (t[i] == s[i]) match++;
    }

    double score = (match / (t.length > s.length ? t.length : s.length)) * 100;
    return PronunciationResult(word: target, score: score, spokenText: spoken);
  }
}
