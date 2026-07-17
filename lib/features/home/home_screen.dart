import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/widgets.dart';
import '../lessons/screens/lessons_screen.dart';
import '../ai_coach/ai_coach_screen.dart';
import '../profile/profile_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../flashcards/flashcard_screen.dart';
import '../community/community_screen.dart';
import '../wallet/transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class _Dashboard extends StatelessWidget {
  final VoidCallback onNavigateToLessons;
  final VoidCallback onNavigateToAI;

  const _Dashboard({
    required this.onNavigateToLessons,
    required this.onNavigateToAI,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Learner';
    final userXp = user?.xp ?? 0;
    final userLevel = user?.level ?? 'A1';
    final streak = user?.streak ?? 0;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName, userLevel, streak),
            const SizedBox(height: 16),
            _buildSubtitle(),
            const SizedBox(height: 20),
            _buildTodayGoalCard(),
            const SizedBox(height: 16),
            _buildStartLearningButton(),
            const SizedBox(height: 20),
            _buildContinueLearningCard(context),
            const SizedBox(height: 20),
            _buildLearningRoadmapCard(context),
            const SizedBox(height: 20),
            _buildWordsOfDayCard(context),
            const SizedBox(height: 20),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 20),
            _buildStatsOverview(userXp, streak),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String level, int streak) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lexi Character + Speech bubble
        Column(
          children: [
            // Character
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Lexi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                'مرحباً بك',
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
                'مستنيك للتمام اليوم?',
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
        Container(
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
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'مرحباً بك في تعلم اللغة بطريقة ممتعة ومباشرة',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildTodayGoalCard() {
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
                child: const Icon(Icons.flag_outlined, color: Colors.white, size: 20),
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
                    value: 1.0,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '4/4',
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
                  value: '12',
                  label: 'كلمة جديدة',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _goalStatItem(
                  icon: Icons.timer_outlined,
                  value: '15',
                  label: 'دقيقة اليوم',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _goalStatItem(
                  icon: Icons.fitness_center_outlined,
                  value: '10',
                  label: 'تمرين',
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

  Widget _buildStartLearningButton() {
    return GestureDetector(
      onTap: () {},
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
            'ابدأ التعلم',
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

  Widget _buildContinueLearningCard(BuildContext context) {
    return GestureDetector(
      onTap: onNavigateToLessons,
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
                    'المسار التعليمي',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الدرس 3',
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
                            value: 0.72,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '72%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'استمرار',
                    onPressed: onNavigateToLessons,
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
                child: Text(
                  '📚',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildLearningRoadmapCard(BuildContext context) {
    final skills = [
      {'name': 'المستويات', 'icon': Icons.book_outlined, 'progress': 0.8, 'color': AppColors.primary},
      {'name': 'القواعد', 'icon': Icons.rule_outlined, 'progress': 0.6, 'color': AppColors.success},
      {'name': 'الاستماع', 'icon': Icons.headphones_outlined, 'progress': 0.75, 'color': AppColors.secondary},
      {'name': 'التحدث', 'icon': Icons.mic_outlined, 'progress': 0.4, 'color': AppColors.accent},
      {'name': 'الكتابة', 'icon': Icons.edit_outlined, 'progress': 0.3, 'color': AppColors.warning},
    ];

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RoadmapScreen()),
      ),
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
                  child: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
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
            ...skills.map((s) => _skillItem(
              s['name'] as String,
              s['icon'] as IconData,
              s['progress'] as double,
              s['color'] as Color,
            )),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _skillItem(String name, IconData icon, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsOfDayCard(BuildContext context) {
    final words = [
      {'german': 'Haus', 'english': 'منزل', 'icon': Icons.home_outlined, 'color': AppColors.primary},
      {'german': 'gehen', 'english': 'يذهب', 'icon': Icons.directions_walk, 'color': AppColors.secondary},
      {'german': 'schön', 'english': 'جميل', 'icon': Icons.star_outline, 'color': AppColors.accent},
      {'german': 'lernen', 'english': 'يتعلم', 'icon': Icons.school_outlined, 'color': AppColors.success},
    ];

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
              child: const Icon(Icons.menu_book_outlined, color: Colors.white, size: 20),
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: words.length,
            itemBuilder: (context, i) {
              final w = words[i];
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
        'icon': Icons.store_outlined,
        'label': 'المتجر',
        'gradient': AppColors.purpleGradient,
        'onTap': () => Navigator.pushNamed(context, '/store'),
      },
      {
        'icon': Icons.headphones_outlined,
        'label': 'الاستماع',
        'gradient': AppColors.blueGradient,
        'onTap': () => Navigator.pushNamed(context, '/audio-lessons'),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'المحادثة',
        'gradient': AppColors.successGradient,
        'onTap': () => Navigator.pushNamed(context, '/speaking'),
      },
      {
        'icon': Icons.edit_outlined,
        'label': 'الكتابة',
        'gradient': AppColors.orangeGradient,
        'onTap': () => Navigator.pushNamed(context, '/advanced-speaking'),
      },
      {
        'icon': Icons.quiz_outlined,
        'label': 'بيت الاسئلة',
        'gradient': AppColors.accentGradient,
        'onTap': () => Navigator.pushNamed(context, '/goethe'),
      },
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'AI Coach',
        'gradient': AppColors.cyanGradient,
        'onTap': () => Navigator.pushNamed(context, '/ai-coach'),
      },
      {
        'icon': Icons.diamond_outlined,
        'label': 'الماس',
        'gradient': AppColors.blueGradient,
        'onTap': () => Navigator.pushNamed(context, '/gem-store'),
      },
      {
        'icon': Icons.flag_outlined,
        'label': 'المهمات',
        'gradient': AppColors.orangeGradient,
        'onTap': () => Navigator.pushNamed(context, '/daily-missions'),
      },
      {
        'icon': Icons.emoji_events_outlined,
        'label': 'الإنجازات',
        'gradient': AppColors.goldGradient,
        'onTap': () => Navigator.pushNamed(context, '/achievements'),
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'label': 'الشهادات',
        'gradient': AppColors.successGradient,
        'onTap': () => Navigator.pushNamed(context, '/certificates'),
      },
      {
        'icon': Icons.person_add_outlined,
        'label': 'الأصدقاء',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/friends'),
      },
      {
        'icon': Icons.mail_outlined,
        'label': 'الرسائل',
        'gradient': AppColors.cyanGradient,
        'onTap': () => Navigator.pushNamed(context, '/inbox'),
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'الاشعارات',
        'gradient': AppColors.orangeGradient,
        'onTap': () => Navigator.pushNamed(context, '/notifications'),
      },
      {
        'icon': Icons.local_fire_department_outlined,
        'label': 'السلسلة',
        'gradient': AppColors.orangeGradient,
        'onTap': () => Navigator.pushNamed(context, '/daily-streak'),
      },
      {
        'icon': Icons.event_outlined,
        'label': 'الاحداث',
        'gradient': AppColors.blueGradient,
        'onTap': () => Navigator.pushNamed(context, '/events'),
      },
      {
        'icon': Icons.language_outlined,
        'label': 'اللغات',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/language-mixer'),
      },
      {
        'icon': Icons.bookmark_outline,
        'label': 'المحفوظات',
        'gradient': AppColors.secondaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/saved-notes'),
      },
      {
        'icon': Icons.live_tv_outlined,
        'label': 'Live',
        'gradient': AppColors.errorGradient,
        'onTap': () => Navigator.pushNamed(context, '/live-learning'),
      },
      {
        'icon': Icons.trending_up_outlined,
        'label': 'النمو',
        'gradient': AppColors.successGradient,
        'onTap': () => Navigator.pushNamed(context, '/growth'),
      },
      {
        'icon': Icons.star_outline,
        'label': 'المكافآت',
        'gradient': AppColors.goldGradient,
        'onTap': () => Navigator.pushNamed(context, '/daily-quests'),
      },
      {
        'icon': Icons.military_tech_outlined,
        'label': 'الشارات',
        'gradient': AppColors.goldGradient,
        'onTap': () => Navigator.pushNamed(context, '/gamification'),
      },
      {
        'icon': Icons.record_voice_over_outlined,
        'label': 'النطق',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/pronunciation'),
      },
      {
        'icon': Icons.card_travel_outlined,
        'label': 'جواز اللغة',
        'gradient': AppColors.blueGradient,
        'onTap': () => Navigator.pushNamed(context, '/passport'),
      },
      {
        'icon': Icons.psychology_outlined,
        'label': 'تحليل التعلم',
        'gradient': AppColors.cyanGradient,
        'onTap': () => Navigator.pushNamed(context, '/ai-learning'),
      },
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'المعلم الذكي',
        'gradient': AppColors.successGradient,
        'onTap': () => Navigator.pushNamed(context, '/ai-tutor'),
      },
      {
        'icon': Icons.face_outlined,
        'label': 'متجر الشخصيات',
        'gradient': AppColors.purpleGradient,
        'onTap': () => Navigator.pushNamed(context, '/avatar-shop'),
      },
      {
        'icon': Icons.crop_outlined,
        'label': 'إطارات',
        'gradient': AppColors.accentGradient,
        'onTap': () => Navigator.pushNamed(context, '/frames-workshop'),
      },
      {
        'icon': Icons.wallpaper_outlined,
        'label': 'الخلفيات',
        'gradient': AppColors.secondaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/backgrounds-shop'),
      },
      {
        'icon': Icons.person_pin_outlined,
        'label': 'اختيار الشخصية',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/character-selection'),
      },
      {
        'icon': Icons.payment_outlined,
        'label': 'طرق الدفع',
        'gradient': AppColors.goldGradient,
        'onTap': () => Navigator.pushNamed(context, '/payment-methods'),
      },
      {
        'icon': Icons.account_circle_outlined,
        'label': 'حسابي',
        'gradient': AppColors.primaryGradient,
        'onTap': () => Navigator.pushNamed(context, '/account'),
      },
      {
        'icon': Icons.people_alt_outlined,
        'label': 'الحسابات النشطة',
        'gradient': AppColors.blueGradient,
        'onTap': () => Navigator.pushNamed(context, '/active-accounts'),
      },
      {
        'icon': Icons.local_offer_outlined,
        'label': 'عرض محدود',
        'gradient': AppColors.orangeGradient,
        'onTap': () => Navigator.pushNamed(context, '/limited-offer'),
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'label': 'عرض مميز',
        'gradient': AppColors.goldGradient,
        'onTap': () => Navigator.pushNamed(context, '/premium-offer'),
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'سجل المعاملات',
        'gradient': AppColors.successGradient,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TransactionHistoryScreen(),
          ),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اجراءات سريعة',
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
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 400 + i * 50),
                );
          },
        ),
      ],
    );
  }

  Widget _buildStatsOverview(int xp, int streak) {
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
                  value: '24',
                  label: 'كلمات',
                  icon: Icons.menu_book,
                  gradient: AppColors.purpleGradient,
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
