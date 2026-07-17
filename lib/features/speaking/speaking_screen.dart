import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'speaking_controller.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen>
    with SingleTickerProviderStateMixin {
  late SpeakingController _controller;
  int _bottomIndex = 0;
  late AnimationController _glowRingController;
  late Animation<double> _glowRingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = SpeakingController(level: 'A1');
    _controller.addListener(_onControllerUpdate);

    _glowRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowRingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowRingController, curve: Curves.easeInOut),
    );

    _glowRingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _glowRingController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  int get _currentExerciseIndex {
    final exercise = _controller.currentExercise;
    if (exercise == null) return 0;
    return _controller.exercises.indexOf(exercise);
  }

  int get _totalExercises =>
      _controller.exercises.isNotEmpty ? _controller.exercises.length : 1;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF6C63FF),
                  onRefresh: () async {
                    _controller.resetExercise();
                    if (mounted) setState(() {});
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 8),
                        _buildProgressBar(),
                        const SizedBox(height: 16),
                        _buildTitle(),
                        const SizedBox(height: 40),
                        _buildMicrophone(),
                        const SizedBox(height: 32),
                        _buildPlaybackControls(),
                        const SizedBox(height: 24),
                        _buildExerciseCounter(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF21262D)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${_controller.totalXp} XP',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProgressBar() {
    final progress = (_currentExerciseIndex + 1) / _totalExercises;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الدرس ${_currentExerciseIndex + 1} من $_totalExercises',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF21262D),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\u0641\u064A \u0627\u0644\u0645\u0637\u0639\u0645',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\u062A\u0645\u0631\u064A\u0646 \u0627\u0644\u062A\u062D\u062F\u062B',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildMicrophone() {
    final isActive = _controller.speakingMode == SpeakingMode.listening ||
        _controller.speakingMode == SpeakingMode.processing;
    final exercise = _controller.currentExercise;

    return Center(
      child: Column(
        children: [
          if (exercise != null &&
              _controller.speakingMode == SpeakingMode.idle)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Text(
                    '\u0642\u0644 \u0647\u0630\u0647 \u0627\u0644\u062C\u0645\u0644\u0629:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.sentence,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.translation,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (_controller.speakingMode == SpeakingMode.result &&
              _controller.lastResult != null)
            _buildResultInline(),
          AnimatedBuilder(
            animation: _glowRingAnimation,
            builder: (context, _) {
              return SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isActive)
                      Container(
                        width: 180 + (_glowRingAnimation.value * 20),
                        height: 180 + (_glowRingAnimation.value * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(
                              alpha: 0.1 +
                                  (_glowRingAnimation.value * 0.1),
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    if (isActive)
                      Container(
                        width: 160 + (_glowRingAnimation.value * 30),
                        height: 160 + (_glowRingAnimation.value * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(
                              alpha:
                                  0.08 + (_glowRingAnimation.value * 0.12),
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                    if (isActive)
                      Container(
                        width: 145 + (_glowRingAnimation.value * 10),
                        height: 145 + (_glowRingAnimation.value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(
                                alpha: 0.05 +
                                    (_glowRingAnimation.value * 0.08),
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _handleMicTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 130.0 : 120.0,
                        height: isActive ? 130.0 : 120.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isActive
                                ? [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                    const Color(0xFF6D28D9),
                                  ]
                                : [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF0F172A),
                                  ],
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4 +
                                          (_glowRingAnimation.value * 0.2),
                                    ),
                                    blurRadius: 30 +
                                        (_glowRingAnimation.value * 15),
                                    spreadRadius: 5 +
                                        (_glowRingAnimation.value * 5),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryDark
                                        .withValues(alpha: 0.2),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : const Color(0xFF334155),
                            width: isActive ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isActive ? Icons.mic : Icons.mic_none,
                            size: 48,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            _getMicLabel(),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildResultInline() {
    final result = _controller.lastResult!;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: result.isPerfect
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (result.isPerfect
                    ? AppColors.success
                    : AppColors.primary)
                .withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                result.isPerfect
                    ? Icons.emoji_events_rounded
                    : Icons.trending_up_rounded,
                color: result.isPerfect ? AppColors.gold : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                result.isPerfect
                    ? '\u0645\u0645\u062A\u0627\u0632!'
                    : '\u0623\u062D\u0633\u0646\u062A!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatMini(
                '\u0627\u0644\u062F\u0642\u0629',
                '${result.accuracy.toInt()}%',
                AppColors.success,
              ),
              _buildStatMini(
                '\u0627\u0644\u0637\u0644\u0627\u0639\u0629',
                '${result.fluency.toInt()}%',
                AppColors.secondary,
              ),
              _buildStatMini(
                '\u0627\u0644\u0642\u0648\u0627\u0639\u062F',
                '${result.grammar.toInt()}%',
                AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${result.xpEarned} XP',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatMini(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    final isActive = _controller.speakingMode == SpeakingMode.listening ||
        _controller.speakingMode == SpeakingMode.processing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.replay_rounded,
          size: 48,
          onTap: _controller.speakingMode != SpeakingMode.idle
              ? _controller.resetExercise
              : null,
        ),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
          size: 56,
          isMain: true,
          isActive: isActive,
          onTap: _handleMicTap,
        ),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          size: 48,
          onTap: _controller.speakingMode == SpeakingMode.result
              ? (_controller.hasNextExercise
                  ? _controller.nextExercise
                  : null)
              : null,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 300.ms);
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    bool isMain = false,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isMain && isActive
              ? AppColors.primaryGradient
              : isMain
                  ? const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    )
                  : null,
          color: isMain
              ? null
              : (enabled
                  ? const Color(0xFF161B22)
                  : const Color(0xFF111520)),
          border: Border.all(
            color: isMain && isActive
                ? AppColors.primary
                : enabled
                    ? const Color(0xFF334155)
                    : const Color(0xFF1E293B),
            width: isMain ? 2 : 1,
          ),
          boxShadow: isMain && isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: enabled
              ? (isMain ? Colors.white : AppColors.textPrimary)
              : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildExerciseCounter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262D)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.record_voice_over,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '\u0627\u0644\u062A\u0645\u0631\u064A\u0646 ${_currentExerciseIndex + 1} \u0645\u0646 $_totalExercises',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 300.ms);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(
          top: BorderSide(color: Color(0xFF21262D), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomItem(
              icon: Icons.fitness_center,
              label: '\u062A\u0645\u0631\u064A\u0646',
              index: 0,
            ),
            _buildBottomItem(
              icon: Icons.chat_bubble_outline,
              label: '\u0645\u062D\u0627\u062F\u062B\u0629',
              index: 1,
            ),
            _buildBottomItem(
              icon: Icons.quiz_outlined,
              label: '\u0627\u062E\u062A\u0628\u0627\u0631',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _bottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _bottomIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMicTap() {
    final exercise = _controller.currentExercise;
    if (exercise == null) return;

    switch (_controller.speakingMode) {
      case SpeakingMode.idle:
        _controller.startSpeaking();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted &&
              _controller.speakingMode == SpeakingMode.listening) {
            _controller.processSpokenText(exercise.sentence);
          }
        });
        break;
      case SpeakingMode.listening:
        _controller.stopSpeaking();
        break;
      case SpeakingMode.processing:
      case SpeakingMode.result:
        break;
    }
  }

  String _getMicLabel() {
    switch (_controller.speakingMode) {
      case SpeakingMode.idle:
        return '\u0627\u0636\u063A\u0637 \u0648\u0623\u0646\u0627 \u0623\u0633\u0645\u0639';
      case SpeakingMode.listening:
        return '\u0623\u0633\u0645\u0639\u0643... \u062A\u0643\u0644\u0645 \u0628\u0635\u0648\u062A \u0639\u0627\u0644\u064A';
      case SpeakingMode.processing:
        return '\u062C\u0627\u0631\u064A \u0627\u0644\u062A\u062D\u0644\u064A\u0644...';
      case SpeakingMode.result:
        return '\u0623\u062D\u0633\u0646\u062A!';
    }
  }
}
