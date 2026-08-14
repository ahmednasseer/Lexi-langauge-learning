import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIdx = 0;
  bool _showAnswer = false;
  final FlutterTts _tts = FlutterTts();
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  final List<Map<String, String>> _words = [
    {
      'german': 'lernen',
      'arabic': 'يتعلم',
      'example': 'Ich lerne Deutsch.',
      'exampleAr': 'أنا أتعلم الألمانية.',
    },
    {
      'german': 'Haus',
      'arabic': 'بيت',
      'example': 'Das Haus ist groß.',
      'exampleAr': 'البيت كبير.',
    },
    {
      'german': 'gehen',
      'arabic': 'يذهب',
      'example': 'Ich gehe zur Schule.',
      'exampleAr': 'أنا أذهب إلى المدرسة.',
    },
    {
      'german': 'schön',
      'arabic': 'جميل',
      'example': 'Das ist schön!',
      'exampleAr': 'هذا جميل!',
    },
    {
      'german': 'Freund',
      'arabic': 'صديق',
      'example': 'Er ist mein Freund.',
      'exampleAr': 'هو صديقي.',
    },
    {
      'german': 'trinken',
      'arabic': 'يشرب',
      'example': 'Ich trinke Wasser.',
      'exampleAr': 'أنا أشرب الماء.',
    },
    {
      'german': 'essen',
      'arabic': 'يأكل',
      'example': 'Wir essen zu Abend.',
      'exampleAr': 'نتعشى.',
    },
    {
      'german': 'schlafen',
      'arabic': 'ينام',
      'example': 'Das Baby schläft.',
      'exampleAr': 'الطفل ينام.',
    },
    {
      'german': 'arbeiten',
      'arabic': 'يعمل',
      'example': 'Er arbeitet viel.',
      'exampleAr': 'هو يعمل كثيراً.',
    },
    {
      'german': 'Spielen',
      'arabic': 'يلعب',
      'example': 'Die Kinder spielen.',
      'exampleAr': 'الأطفال يلعبون.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.4);
    await _tts.speak(text);
  }

  void _flipCard() {
    setState(() => _showAnswer = !_showAnswer);
    if (_showAnswer) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _rateCard(String rating) {
    if (_currentIdx < _words.length - 1) {
      _flipController.reset();
      setState(() {
        _currentIdx++;
        _showAnswer = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressSection(),
            Expanded(child: Center(child: _buildFlashcard())),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _close,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'التفلكات',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildProgressSection() {
    final progress = (_currentIdx + 1) / _words.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIdx + 1} من ${_words.length}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: -0.2);
  }

  Widget _buildFlashcard() {
    return GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * math.pi;
              final isFront = angle < math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(isFront ? angle : angle),
                child: isFront
                    ? _buildFront()
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildBack(),
                      ),
              );
            },
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildFront() {
    final word = _words[_currentIdx];
    return GlowCard(
      glowColor: AppColors.primary,
      height: 360,
      width: 300,
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.surfaceLight.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                  onTap: () => _speak(word['german']!),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowPrimary,
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 1200.ms,
                ),
            const SizedBox(height: 28),
            Text(
              word['german']!,
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'اضغط للكشف',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    final word = _words[_currentIdx];
    return GlowCard(
      glowColor: AppColors.warning,
      height: 360,
      width: 300,
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.cardLight.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word['arabic']!,
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                word['example']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word['exampleAr']!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _speak(word['german']!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.warningGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowGold,
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'استمع',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildDifficultyButton(
              label: 'صعب',
              color: AppColors.error,
              glowColor: AppColors.glowError,
              gradient: AppColors.errorGradient,
              onTap: () => _rateCard('hard'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDifficultyButton(
              label: 'متردد',
              color: AppColors.warning,
              glowColor: AppColors.glowGold,
              gradient: AppColors.warningGradient,
              onTap: () => _rateCard('medium'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDifficultyButton(
              label: 'سهل',
              color: AppColors.success,
              glowColor: AppColors.glowSuccess,
              gradient: AppColors.successGradient,
              onTap: () => _rateCard('easy'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.3);
  }

  Widget _buildDifficultyButton({
    required String label,
    required Color color,
    required Color glowColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: 16,
              spreadRadius: -3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
