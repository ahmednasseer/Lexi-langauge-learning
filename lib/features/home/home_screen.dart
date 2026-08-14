import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../shared/widgets/widgets.dart';
import '../lessons/screens/lessons_screen.dart';
import '../ai_coach/ai_coach_screen.dart';
import '../profile/presentation/pages/profile_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../flashcards/flashcard_screen.dart';
import '../community/community_screen.dart';
import '../../core/services/api_service.dart';
import '../../features/learning_progress/presentation/bloc/progress_cubit.dart';
import '../../features/learning_progress/domain/repositories/progress_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProgressCubit(getIt<ProgressRepository>()),
        ),
      ],
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _idx,
        children: [
          _Dashboard(
            onNavigateToLessons: () => setState(() => _idx = 1),
            onNavigateToAI: () => setState(() => _idx = 2),
          ),
          const LessonsScreen(),
          const AiCoachScreen(),
          const CommunityScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _idx,
            onTap: (i) => setState(() => _idx = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textHint,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'الاكتشاف',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'التعلم',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'المجتمع',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'الملف',
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _Dashboard extends StatefulWidget {
  final VoidCallback onNavigateToLessons;
  final VoidCallback onNavigateToAI;

  const _Dashboard({
    required this.onNavigateToLessons,
    required this.onNavigateToAI,
  });

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  List<Map<String, dynamic>> _wordsOfDay = [];
  bool _emailVerified = true;
  bool _checkedVerification = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _checkEmailVerification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = AuthService.instance.currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<ProgressCubit>().loadProgress(userId);
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    final authCubit = getIt<AuthCubit>();
    final verified = await authCubit.checkEmailVerified();
    if (mounted) {
      setState(() {
        _emailVerified = verified;
        _checkedVerification = true;
      });
    }
  }

  Future<void> _sendVerificationEmail() async {
    final authCubit = getIt<AuthCubit>();
    await authCubit.sendEmailVerification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification email sent! Check your inbox.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _loadWords() async {
    final api = ApiService();
    final result = await api.getLessons('de');
    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      final lesson = result.data!.first as Map<String, dynamic>;
      final vocabulary = lesson['vocabulary'] as List<dynamic>? ?? [];
      if (vocabulary.isNotEmpty) {
        final words = vocabulary.take(6).map((v) {
          final vocab = v as Map<String, dynamic>;
          return {
            'german': vocab['german'] ?? '',
            'english': vocab['arabic'] ?? '',
            'icon': Icons.menu_book_outlined,
            'color': AppColors.primary,
          };
        }).toList();
        if (mounted) {
          setState(() => _wordsOfDay = words);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = getIt<AuthRepository>();
    final currentUser = authRepo.getCurrentUserSync();
    final userName = currentUser?.name ?? 'Learner';

    return BlocProvider<ProgressCubit>(
      create: (_) => ProgressCubit(getIt<ProgressRepository>()),
      child: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, progressState) {
          int userXp = 0;
          String userLevel = 'A1';
          int streak = 0;
          int completedLessons = 0;
          double completionRate = 0.0;

            if (progressState is ProgressLoaded) {
            userXp = progressState.progress.totalXp;
            userLevel = progressState.progress.levelLabel;
            streak = progressState.progress.streak;
            completedLessons = progressState.progress.completedLessons.length;
            completionRate = progressState.progress.completionPercentage;
          } else if (progressState is ProgressLoading) {
            return _buildLoadingState();
          } else if (progressState is ProgressError) {
            return _buildErrorState(progressState.message);
          }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, userName, userLevel, streak),
                const SizedBox(height: 16),
                if (_checkedVerification && !_emailVerified)
                  _buildEmailVerificationBanner(),
                if (_checkedVerification && !_emailVerified)
                  const SizedBox(height: 16),
                _buildSubtitle(),
                const SizedBox(height: 20),
                _buildTodayGoalCard(context, userXp, completedLessons, streak, completionRate),
                const SizedBox(height: 16),
                _buildStartLearningButton(context),
                const SizedBox(height: 20),
                _buildContinueLearningCard(context, completedLessons, completionRate),
                const SizedBox(height: 20),
                _buildLearningRoadmapCard(
                  context,
                  userXp: userXp,
                  userLevel: userLevel,
                  streak: streak,
                  completedLessons: completedLessons,
                  completionRate: completionRate,
                ),
                const SizedBox(height: 20),
                _buildWordsOfDayCard(context),
                const SizedBox(height: 20),
                _buildQuickActionsGrid(context),
                const SizedBox(height: 20),
                _buildStatsOverview(userXp, streak, userLevel),
              ],
            ),
          ),
        );
      },
    ),
  );
  }

  Widget _buildLoadingState() {
    return const SafeArea(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String message) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final userId = AuthService.instance.currentUser?.id ?? '';
                if (userId.isNotEmpty) {
                  context.read<ProgressCubit>().loadProgress(userId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String name,
    String level,
    int streak,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lexi Character + Speech bubble
        Column(
          children: [
            // Character
            ClipOval(
              child: Image.asset(
                AppAssets.lexiHappy,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 80),
              ),
            ).animate().scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(height: 6),
            // Speech bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
                child: Text(
                'Willkommen zurück!',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Greeting + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Hallo!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn().slideX(begin: 0.1),
              const SizedBox(height: 4),
              Text(
                'Bereit für heute?',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms),
            ],
          ),
        ),
        // German flag badge
        Container(
          width: 36,
          height: 24,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Expanded(child: Container(color: const Color(0xFF000000))),
              Expanded(child: Container(color: const Color(0xFFDD0000))),
              Expanded(child: Container(color: const Color(0xFFFFCC00))),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(width: 10),
        // Notification bell
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/notifications'),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildEmailVerificationBanner() {
    return GestureDetector(
      onTap: _sendVerificationEmail,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify your email',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap here to send verification email',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSubtitle() {
    return Text(
      'Weiterhin Deutsch lernen - Schritt für Schritt',
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildTodayGoalCard(
    BuildContext context,
    int userXp,
    int completedLessons,
    int streak,
    double completionRate,
  ) {
    return GlassCard(
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'هدف اليوم',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
           // Progress bar
           Row(
             children: [
               Expanded(
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(10),
                   child: LinearProgressIndicator(
                     value: userXp > 0 ? (userXp % 50) / 50.0 : 0.0,
                     backgroundColor: AppColors.border,
                     valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                     minHeight: 10,
                   ),
                 ),
               ),
               const SizedBox(width: 12),
                Text(
                  '$userXp XP',
                 style: GoogleFonts.poppins(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                   color: AppColors.primary,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 20),
           // Stats row
           Row(
             children: [
               Expanded(
                 child: _goalStatItem(
                   icon: Icons.book_outlined,
                    value: completedLessons.toString(),
                   label: 'دروس مكتملة',
                   color: AppColors.primary,
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: _goalStatItem(
                   icon: Icons.stars_outlined,
                   value: '$streak',
                   label: 'يوم متواصل',
                   color: AppColors.secondary,
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: _goalStatItem(
                   icon: Icons.show_chart_outlined,
                   value: '${completionRate.toInt()}%',
                   label: 'إنجاز',
                   color: AppColors.accent,
                 ),
               ),
             ],
           ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _goalStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStartLearningButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/lessons'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
         child: Center(
          child: Text(
            'Jetzt lernen',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

   Widget _buildContinueLearningCard(
    BuildContext context,
    int completedLessons,
    double completionRate,
  ) {
    return GestureDetector(
      onTap: widget.onNavigateToLessons,
      child: GlowCard(
        glowColor: AppColors.primary,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     'Weiter lernen',
                     style: GoogleFonts.poppins(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                       color: AppColors.textPrimary,
                     ),
                   ),
                  const SizedBox(height: 6),
                  Text(
                    completedLessons > 0
                        ? '$completedLessons ${completedLessons == 1 ? "درس مكتمل" : "دروس مكتملة"}'
                        : 'ليس لديك شيء للمتابعة بعد',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: completionRate > 0 ? completionRate / 100.0 : 0.0,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(
                              completionRate > 0 ? AppColors.primary : AppColors.textHint,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                      '${completionRate.toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: completionRate > 0 ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'استمرار',
                    onPressed: widget.onNavigateToLessons,
                    isSmall: true,
                    width: 120,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Character illustration placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('📚', style: TextStyle(fontSize: 50)),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

   Widget _buildLearningRoadmapCard(
    BuildContext context, {
    required int userXp,
    required String userLevel,
    required int streak,
    required int completedLessons,
    required double completionRate,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const RoadmapScreen())),
      child: GlassCard(
        glowColor: AppColors.secondary,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'مسار التعلم',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHint,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'المستوى الحالي: $userLevel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (completionRate / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                completionRate > 0 ? AppColors.primary : AppColors.textHint,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${completionRate.toInt()}% مكتمل',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  Widget _buildWordsOfDayCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'كلمات اليوم',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FlashcardScreen()),
              ),
              child: Text(
                'عرض الكل',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: _wordsOfDay.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _wordsOfDay.length,
                  itemBuilder: (context, i) {
                    final w = _wordsOfDay[i];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      child: GlowCard(
                        glowColor: w['color'] as Color,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              w['icon'] as IconData,
                              color: w['color'] as Color,
                              size: 28,
                            ),
                            const Spacer(),
                            Text(
                              w['german'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              w['english'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 300 + i * 100),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        'icon': Icons.school_outlined,
        'label': 'Lessons',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/lessons'),
      },
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'AI Tutor',
        'gradient': AppColors.cyanGradient,
        'onTap': () => Navigator.pushNamed(context, '/ai-tutor'),
      },
      {
        'icon': Icons.quiz_outlined,
        'label': 'Goethe Practice',
        'gradient': AppColors.accentGradient,
        'onTap': () => Navigator.pushNamed(context, '/goethe'),
      },
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Flashcards',
        'gradient': AppColors.purpleGradient,
        'onTap': () => Navigator.pushNamed(context, '/flashcards'),
      },
      {
        'icon': Icons.record_voice_over_outlined,
        'label': 'Speaking',
        'gradient': AppColors.successGradient,
        'onTap': () => Navigator.pushNamed(context, '/speaking'),
      },
      {
        'icon': Icons.emoji_events_outlined,
        'label': 'Achievements',
        'gradient': AppColors.goldGradient,
        'onTap': () => Navigator.pushNamed(context, '/achievements'),
      },
      {
        'icon': Icons.store_outlined,
        'label': 'Store',
        'gradient': AppColors.purpleGradient,
        'onTap': () => Navigator.pushNamed(context, '/store'),
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profile',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/profile'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
           'Schnellzugriff',
           style: GoogleFonts.poppins(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: AppColors.textPrimary,
           ),
         ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: actions.length,
          itemBuilder: (context, i) {
            final a = actions[i];
            return GestureDetector(
              onTap: a['onTap'] as VoidCallback,
              child: GlowCard(
                glowColor: (a['gradient'] as LinearGradient).colors.first,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: a['gradient'] as Gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        a['icon'] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            a['label'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 400 + i * 50));
          },
        ),
      ],
    );
  }

   Widget _buildStatsOverview(int xp, int streak, String level) {
    return GlassCard(
      glowColor: AppColors.gold,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدمك',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  value: '$xp',
                  label: 'XP',
                  icon: Icons.star,
                  gradient: AppColors.goldGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statItem(
                  value: '$streak',
                  label: 'ايام متتالية',
                  icon: Icons.local_fire_department,
                  gradient: AppColors.orangeGradient,
                ),
              ),
              const SizedBox(width: 12),
               Expanded(
                 child: _statItem(
                    value: level,
                   label: 'المستوى',
                   icon: Icons.emoji_events,
                   gradient: AppColors.goldGradient,
                 ),
               ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _statItem({
    required String value,
    required String label,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
