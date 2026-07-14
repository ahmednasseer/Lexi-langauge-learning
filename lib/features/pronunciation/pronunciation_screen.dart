import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import 'speech_service.dart';
import 'pronunciation_result.dart';

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  final SpeechService _speechService = SpeechService();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _showResult = false;
  PronunciationResult _result = PronunciationResult.empty();
  int _currentIdx = 0;

  final _words = const [
    {'word': 'Hallo', 'translation': 'مرحبا / Hello', 'phonetic': '/haˈloː/'},
    {'word': 'Danke', 'translation': 'شكرا / Thank you', 'phonetic': '/ˈdaŋkə/'},
    {'word': 'Bitte', 'translation': 'من فضلك / Please', 'phonetic': '/ˈbɪtə/'},
    {'word': 'Guten Morgen', 'translation': 'صباح الخير / Good morning', 'phonetic': '/ˌɡuːtən ˈmɔʁɡn/'},
    {'word': 'Tschüss', 'translation': 'مع السلامة / Goodbye', 'phonetic': '/tʃʏs/'},
    {'word': 'Entschuldigung', 'translation': 'عفوا / Excuse me', 'phonetic': '/ɛntˈʃʊldɪɡʊŋ/'},
    {'word': 'Ja', 'translation': 'نعم / Yes', 'phonetic': '/jaː/'},
    {'word': 'Nein', 'translation': 'لا / No', 'phonetic': '/naɪn/'},
  ];

  @override
  void initState() {
    super.initState();
    _speechService.init();
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(0.4);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String get _target => _words[_currentIdx]['word']!;

  Future<void> _speak() async => await _tts.speak(_target);

  Future<void> _listen() async {
    setState(() { _isListening = true; _showResult = false; });
    await _speechService.startListening(
      onResult: (text) => setState(() {}),
      onDone: () async {
        await _speechService.stop();
        final spoken = _speechService.evaluate(_target, _speechService.lastRecognizedWords);
        setState(() {
          _isListening = false;
          _result = PronunciationResult(word: _target, score: spoken.score, spokenText: spoken.spokenText);
          _showResult = true;
        });
      },
    );
  }

  void _next() {
    setState(() {
      _currentIdx = (_currentIdx + 1) % _words.length;
      _showResult = false;
      _result = PronunciationResult.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = _words[_currentIdx];
    final color = _result.score >= 80 ? AppColors.success : _result.score >= 50 ? AppColors.secondary : AppColors.error;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
              Expanded(child: Text('German Pronunciation', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold))),
            ]).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(children: [
                const Text('🇩🇪', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text(word['word']!, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(word['phonetic']!, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                Text(word['translation']!, style: GoogleFonts.poppins(fontSize: 20, color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _speak,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.volume_up, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Listen', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ]),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: _isListening ? null : _listen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isListening ? 120 : 100,
                  height: _isListening ? 120 : 100,
                  decoration: BoxDecoration(
                    gradient: _isListening ? AppColors.errorGradient : AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: _isListening
                        ? [BoxShadow(color: AppColors.error.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 10)]
                        : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 48),
                ),
              ).animate(onPlay: _isListening ? (c) => c.repeat() : null).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms),
            ),
            const SizedBox(height: 32),
            if (_showResult)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                child: Column(children: [
                  Text('${_result.score.toInt()}%', style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: color)).animate().scale(begin: const Offset(0.5, 0.5)),
                  const SizedBox(height: 8),
                  Text(_result.score >= 80 ? 'Excellent! 🎉' : _result.score >= 50 ? 'Good effort! 💪' : 'Try again! 🔊', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
                  if (_result.spokenText != null) ...[
                    const SizedBox(height: 16),
                    Text('You said:', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                    Text('"${_result.spokenText}"', style: GoogleFonts.poppins(fontSize: 18, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text('Next Word', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ]),
              ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 32),
            Text('Practice Words', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(_words.length, (i) {
              final w = _words[i];
              final isCur = i == _currentIdx;
              return GestureDetector(
                onTap: () => setState(() { _currentIdx = i; _showResult = false; }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCur ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isCur ? AppColors.primary : Colors.grey.shade200, width: 2),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: isCur ? AppColors.primary : Colors.grey.shade100, shape: BoxShape.circle),
                      child: Center(child: Text('${i + 1}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isCur ? Colors.white : Colors.grey.shade600))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(w['word']!, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(w['translation']!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                    ])),
                    IconButton(onPressed: () => _tts.speak(w['word']!), icon: const Icon(Icons.volume_up, color: AppColors.primary)),
                  ]),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 50)).slideX(begin: 0.1);
            }),
          ]),
        ),
      ),
    );
  }
}
