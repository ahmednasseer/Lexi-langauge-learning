import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../data/german_content.dart';
import '../lessons/screens/lessons_screen.dart';
import '../ai_tutor/ai_tutor_screen.dart';
import '../pronunciation/pronunciation_screen.dart';
import '../gamification/gamification_screen.dart';
import '../profile/profile_screen.dart';

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
      body: IndexedStack(
        index: _idx,
        children: [
          _Dashboard(
            onNavigateToLessons: () => setState(() => _idx = 1),
            onNavigateToAI: () => setState(() => _idx = 2),
          ),
          const LessonsScreen(),
          const AiTutorScreen(),
          const GamificationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))]),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _idx,
            onTap: (i) => setState(() => _idx = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Lessons'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'AI Tutor'),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), activeIcon: Icon(Icons.emoji_events), label: 'Rewards'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
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

  const _Dashboard({required this.onNavigateToLessons, required this.onNavigateToAI});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Learner';
    final userXp = user?.xp ?? 0;
    final userLevel = user?.level ?? 'A1';
    final streak = user?.streak ?? 0;
    final dailyXp = user?.dailyXp ?? 0;
    final dailyGoal = user?.dailyGoal ?? 50;
    final dailyProgress = dailyGoal > 0 ? (dailyXp / dailyGoal).clamp(0.0, 1.0) : 0.0;

    final allLessons = GermanContent.getAllLessons();
    final completedLessons = 0; // TODO: Track completed lessons

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(userName, userLevel, streak),
          const SizedBox(height: 24),
          _statsRow(userXp, allLessons.length, completedLessons),
          const SizedBox(height: 24),
          _dailyGoal(dailyProgress, dailyXp, dailyGoal),
          const SizedBox(height: 24),
          _continueCard(context),
          const SizedBox(height: 24),
          _quickActions(context),
          const SizedBox(height: 24),
          _germanLevels(context),
        ]),
      ),
    );
  }

  Widget _header(String name, String level, int streak) {
    return Row(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('🇩🇪', style: TextStyle(fontSize: 28))),
      ).animate().scale(begin: const Offset(0.5, 0.5)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hello, $name!', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)).animate().fadeIn().slideX(begin: 0.1),
        Text('Level $level • German Learner', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)).animate().fadeIn(delay: 100.ms),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$streak', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
        ]),
      ).animate().fadeIn(delay: 200.ms),
    ]);
  }

  Widget _statsRow(int xp, int totalLessons, int completed) {
    return Row(children: [
      _stat('⭐', '$xp', 'XP Points', AppColors.goldGradient),
      const SizedBox(width: 12),
      _stat('📚', '$totalLessons', 'Lessons', AppColors.blueGradient),
      const SizedBox(width: 12),
      _stat('✅', '$completed', 'Completed', AppColors.purpleGradient),
    ]);
  }

  Widget _stat(String icon, String val, String label, LinearGradient g) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: g.colors.first.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
        ]),
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }

  Widget _dailyGoal(double progress, int current, int goal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Row(children: [
        CircularPercentIndicator(
          radius: 40, lineWidth: 8,
          percent: progress,
          center: Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          progressColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daily Goal', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$current/$goal XP today', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: AppColors.primary.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.primary), borderRadius: BorderRadius.circular(4)),
        ])),
      ]),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _continueCard(BuildContext context) {
    return GestureDetector(
      onTap: onNavigateToLessons,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Continue Learning', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Start with A1 German lessons', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text('Start Now', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ])),
          const Text('📖', style: TextStyle(fontSize: 60)),
        ]),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      {'icon': '🎤', 'label': 'Practice\nPronunciation', 'color': const Color(0xFFFF6B9D), 'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PronunciationScreen()))},
      {'icon': '📝', 'label': 'Take a\nQuiz', 'color': AppColors.success, 'onTap': onNavigateToLessons},
      {'icon': '💬', 'label': 'Chat with\nAI', 'color': const Color(0xFF00BCD4), 'onTap': onNavigateToAI},
      {'icon': '🎲', 'label': 'Play a\nGame', 'color': AppColors.warning, 'onTap': () {}},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 300.ms),
      const SizedBox(height: 16),
      Row(children: actions.map((a) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: a['onTap'] as VoidCallback,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Text(a['icon'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(a['label'] as String, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: a['color'] as Color)),
            ]),
          ),
        ),
      ))).toList()),
    ]);
  }

  Widget _germanLevels(BuildContext context) {
    final levels = [
      {'level': 'A1', 'name': 'Beginner', 'icon': '🌱', 'color': AppColors.success},
      {'level': 'A2', 'name': 'Elementary', 'icon': '🌿', 'color': AppColors.info},
      {'level': 'B1', 'name': 'Intermediate', 'icon': '🌳', 'color': AppColors.primary},
      {'level': 'B2', 'name': 'Upper Intermediate', 'icon': '🏔️', 'color': AppColors.warning},
      {'level': 'C1', 'name': 'Advanced', 'icon': '🎓', 'color': AppColors.secondary},
      {'level': 'C2', 'name': 'Mastery', 'icon': '👑', 'color': AppColors.error},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('German Levels', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton(onPressed: onNavigateToLessons, child: Text('View All', style: GoogleFonts.poppins(color: AppColors.primary))),
      ]).animate().fadeIn(delay: 400.ms),
      const SizedBox(height: 12),
      SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: levels.length,
          itemBuilder: (context, i) {
            final l = levels[i];
            final lessons = GermanContent.getLessonsByLevel(l['level'] as String);
            return GestureDetector(
              onTap: onNavigateToLessons,
              child: Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (l['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (l['color'] as Color).withValues(alpha: 0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(l['icon'] as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(l['level'] as String, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: l['color'] as Color)),
                  ]),
                  const SizedBox(height: 4),
                  Text(l['name'] as String, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  const Spacer(),
                  Text('${lessons.length} lessons', style: GoogleFonts.poppins(fontSize: 11, color: l['color'] as Color)),
                ]),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 400 + i * 50));
          },
        ),
      ),
    ]);
  }
}
