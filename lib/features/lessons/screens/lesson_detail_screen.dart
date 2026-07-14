import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/lesson_model.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _quizIdx = 0;
  int _score = 0;
  bool _quizDone = false;
  String? _answer;
  bool _showExplanation = false;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _initTts();
  }

  @override
  void dispose() {
    _tab.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
            child: Column(children: [
              Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
                Expanded(child: Column(children: [
                  Text(widget.lesson.title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${widget.lesson.level} • German', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${widget.lesson.xpReward} XP', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 16),
              TabBar(controller: _tab, labelColor: AppColors.primary, unselectedLabelColor: Colors.grey, indicatorColor: AppColors.primary, tabs: const [Tab(text: 'Vocabulary'), Tab(text: 'Grammar'), Tab(text: 'Quiz')]),
            ]),
          ),
          Expanded(child: TabBarView(controller: _tab, children: [_vocabTab(), _grammarTab(), _quizTab()])),
        ]),
      ),
    );
  }

  Widget _vocabTab() {
    if (widget.lesson.vocabulary.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📝', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No vocabulary for this lesson'),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.lesson.vocabulary.length,
      itemBuilder: (context, i) {
        final v = widget.lesson.vocabulary[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.word, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(v.translation, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ])),
              IconButton(
                onPressed: () => _speak(v.word),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.volume_up, color: AppColors.primary, size: 20),
                ),
              ),
            ]),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.example, style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(v.exampleTranslation, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
              ]),
            ),
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 100));
      },
    );
  }

  Widget _grammarTab() {
    if (widget.lesson.grammar.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📖', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No grammar rules'),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.lesson.grammar.length,
      itemBuilder: (context, i) {
        final g = widget.lesson.grammar[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g.title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(g.explanation, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
            const SizedBox(height: 16),
            ...g.examples.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(e, style: GoogleFonts.poppins(fontSize: 14))),
              ]),
            )),
            if (g.tip != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.lightbulb, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(g.tip!, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.warning))),
                ]),
              ),
            ],
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 100));
      },
    );
  }

  Widget _quizTab() {
    if (widget.lesson.quiz.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('🎯', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No quiz available'),
      ]));
    }
    if (_quizDone) return _quizResult();
    final q = widget.lesson.quiz[_quizIdx];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LinearProgressIndicator(value: (_quizIdx + 1) / widget.lesson.quiz.length, backgroundColor: AppColors.primary.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
        const SizedBox(height: 16),
        Text('Question ${_quizIdx + 1} of ${widget.lesson.quiz.length}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
          child: Text(q.question, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        const SizedBox(height: 24),
        ...q.options.map((o) {
          final isSel = _answer == o;
          final isCorrect = o == q.correctAnswer;
          Color? bg;
          Color? bd;
          if (_showExplanation && isCorrect) { bg = AppColors.success.withValues(alpha: 0.1); bd = AppColors.success; }
          else if (_showExplanation && isSel && !isCorrect) { bg = AppColors.error.withValues(alpha: 0.1); bd = AppColors.error; }
          return GestureDetector(
            onTap: _showExplanation ? null : () { setState(() { _answer = o; _showExplanation = true; if (isCorrect) _score++; }); },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bg ?? Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: bd ?? Colors.grey.shade200, width: 2)),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: isSel ? AppColors.primary : Colors.grey.shade100, shape: BoxShape.circle),
                  child: Center(child: Text(String.fromCharCode(65 + q.options.indexOf(o)), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSel ? Colors.white : Colors.grey.shade600))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(o, style: GoogleFonts.poppins(fontSize: 16))),
                if (_showExplanation && isCorrect) const Icon(Icons.check_circle, color: AppColors.success),
                if (_showExplanation && isSel && !isCorrect) const Icon(Icons.cancel, color: AppColors.error),
              ]),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: q.options.indexOf(o) * 100));
        }),
        if (_showExplanation) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: (_answer == q.correctAnswer ? AppColors.success : AppColors.error).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
            child: Text(_answer == q.correctAnswer ? 'Correct! 🎉' : 'Incorrect 😕', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _answer == q.correctAnswer ? AppColors.success : AppColors.error)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _nextQ,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(_quizIdx < widget.lesson.quiz.length - 1 ? 'Next' : 'Results', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ]),
    );
  }

  void _nextQ() {
    if (_quizIdx < widget.lesson.quiz.length - 1) {
      setState(() { _quizIdx++; _answer = null; _showExplanation = false; });
    } else {
      setState(() => _quizDone = true);
    }
  }

  Widget _quizResult() {
    final pct = (_score / widget.lesson.quiz.length * 100).toInt();
    final pass = pct >= 70;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(gradient: pass ? AppColors.successGradient : AppColors.errorGradient, shape: BoxShape.circle),
            child: Center(child: Text(pass ? '🎉' : '😢', style: const TextStyle(fontSize: 50))),
          ).animate().scale(begin: const Offset(0.5, 0.5)),
          const SizedBox(height: 32),
          Text(pass ? 'Congratulations!' : 'Keep Practicing!', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text('$pct%', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: pass ? AppColors.success : AppColors.error)),
          const SizedBox(height: 8),
          Text('$_score out of ${widget.lesson.quiz.length}', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          if (pass) Text('+${widget.lesson.xpReward} XP', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text('Back to Lessons', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
