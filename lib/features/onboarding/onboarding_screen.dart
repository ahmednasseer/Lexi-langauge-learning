import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedGoalIndex = -1;
  int _selectedOptionIndex = -1;

  final List<Map<String, dynamic>> _goals = [
    {
      'icon': Icons.flight_takeoff,
      'title': 'السفر',
      'subtitle': 'Travel',
      'color': AppColors.info,
    },
    {
      'icon': Icons.school,
      'title': 'الدراسة',
      'subtitle': 'Study',
      'color': AppColors.success,
    },
    {
      'icon': Icons.work,
      'title': 'العمل',
      'subtitle': 'Work',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.assignment,
      'title': 'امتحانات Goethe/TELC',
      'subtitle': 'Goethe/TELC Exams',
      'color': AppColors.warning,
    },
    {
      'icon': Icons.chat_bubble,
      'title': 'محادثة والتواصل',
      'subtitle': 'Conversation',
      'color': AppColors.accent,
    },
  ];

  final List<String> _options = ['gehe', 'gehst', 'geht', 'gehen'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await AuthService.instance.setOnboarded();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildGoalSelectionPage(),
                  _buildLevelTestPage(),
                  _buildResultPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: _previousPage,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 48),
          _buildPageIndicator(),
          TextButton(
            onPressed: _finish,
            child: Text(
              'تخطي',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = _currentPage == index;
        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.primaryGradient : null,
              color: isActive ? null : AppColors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════
  // BOTTOM BAR
  // ═══════════════════════════════════════════
  Widget _buildBottomBar() {
    final isLastPage = _currentPage == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GradientButton(
        text: isLastPage ? 'ابدأ رحلتك' : 'التالي',
        onPressed: isLastPage ? _finish : _nextPage,
        width: double.infinity,
        gradient: isLastPage ? AppColors.successGradient : AppColors.primaryGradient,
        height: 56,
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 1: WELCOME (ترحيب)
  // ═══════════════════════════════════════════
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // German flag badge (top-right style position)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      children: [
                        Expanded(flex: 1, child: Container(color: const Color(0xFF000000))),
                        Expanded(flex: 1, child: Container(color: Color(0xFFDD0000))),
                        Expanded(flex: 1, child: Container(color: Color(0xFFFFCC00))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DE',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),
          const SizedBox(height: 24),
          // Character illustration placeholder (gradient container)
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Character body (simplified cartoon)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                // Lexi text
                Text(
                  'Lexi',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // German flag circle at bottom
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: ClipOval(
                      child: Column(
                        children: [
                          Expanded(flex: 1, child: Container(color: const Color(0xFF000000))),
                          Expanded(flex: 1, child: Container(color: Color(0xFFDD0000))),
                          Expanded(flex: 1, child: Container(color: Color(0xFFFFCC00))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms),
          const SizedBox(height: 32),
          // Speech bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'مرحباً بك',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
          const SizedBox(height: 32),
          // Title
          Text(
            'Lexi',
            style: GoogleFonts.poppins(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              shadows: [
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 30,
                ),
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 60,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'تعلم الألمانية بطريقة ممتعة ومباشرة',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 2: GOAL SELECTION (اختر هدفك)
  // ═══════════════════════════════════════════
  Widget _buildGoalSelectionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'ما هدفك من تعلم اللغة؟',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'اختر ما يناسبك',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoalIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlowCard(
                    glowColor: isSelected ? goal['color'] as Color : AppColors.border,
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    onTap: () {
                      setState(() => _selectedGoalIndex = index);
                      _nextPage();
                    },
                    child: Row(
                      children: [
                        // Icon circle
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (goal['color'] as Color).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (goal['color'] as Color).withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            goal['icon'] as IconData,
                            color: goal['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                goal['subtitle'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Chevron
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.textHint,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 150 + index * 80));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 3: LEVEL TEST (اختبار تحديد المستوى)
  // ═══════════════════════════════════════════
  Widget _buildLevelTestPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title, counter, close button
          Row(
            children: [
              // Close button
              GestureDetector(
                onTap: _finish,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Text(
                'اختبار تحديد المستوى',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Counter badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '8/20',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.4,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ).animate().fadeIn(delay: 100.ms).scaleX(begin: 0, alignment: Alignment.centerLeft),
          const SizedBox(height: 24),
          // Question instruction
          Text(
            'Wähle die richtige Antwort.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),
          // Question card
          GlassCard(
            glowColor: AppColors.primary,
            borderRadius: 20,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ich ___ jeden Tag zur Arbeit.',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 20),
          // Options
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isCorrect = index == 0;
                final isSelected = _selectedOptionIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlowCard(
                    glowColor: isCorrect && isSelected
                        ? AppColors.success
                        : isSelected
                            ? AppColors.error
                            : AppColors.border,
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    onTap: () {
                      setState(() => _selectedOptionIndex = index);
                    },
                    child: Row(
                      children: [
                        // Number circle
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCorrect && isSelected
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.surfaceLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCorrect && isSelected
                                  ? AppColors.success
                                  : isSelected
                                      ? AppColors.error
                                      : AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCorrect && isSelected
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Option text
                        Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? AppColors.success : AppColors.error,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 250 + index * 80));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 4: RESULT (نتيجة المستوى)
  // ═══════════════════════════════════════════
  Widget _buildResultPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Trophy/celebration container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.3),
                  AppColors.gold.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                // Trophy emoji
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 60),
                ),
                // Celebration particles
                Positioned(
                  top: 5,
                  right: 15,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.2, 1.2),
                    duration: 800.ms,
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.5, 1.5),
                    duration: 1000.ms,
                  ),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.3, 0.3), duration: 600.ms),
          const SizedBox(height: 32),
          // Level badge B1
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.getLevelGradient('B1'),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.levelB1.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              'B1',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.5, 0.5)),
          const SizedBox(height: 16),
          // Level label
          Text(
            'متوسط',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          // Level description
          Text(
            'مستواك B1 - Intermediate',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 32),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('85%', 'الإجابات', AppColors.success),
                _buildDivider(),
                _buildStatItem('120', 'السؤال', AppColors.primary),
                _buildDivider(),
                _buildStatItem('15', 'دقيقة', AppColors.warning),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }
}
