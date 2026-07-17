import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  late TabController _badgeTabController;
  late TabController _leaderboardTabController;

  int _selectedBadgeTab = 0;
  int _selectedLeaderboardTab = 0;

  final List<String> _badgeTabs = ['الإنجازات', 'المفضلة', 'الشارات'];
  final List<String> _leaderboardTabs = ['الأعضاء', 'الأسبوع', 'الشهر'];

  final _badges = [
    _BadgeData(
      icon: '🌟',
      name: 'أول خطوة',
      description: 'أكمل درسك الأول',
      isUnlocked: true,
    ),
    _BadgeData(
      icon: '🔥',
      name: '7 أيام متتالية',
      description: 'حافظ على سلسلة 7 أيام',
      isUnlocked: true,
    ),
    _BadgeData(
      icon: '👩‍🏫',
      name: 'معلمة أول',
      description: 'ساعد زميلك في التعلم',
      isUnlocked: true,
    ),
    _BadgeData(
      icon: '📚',
      name: 'جامع الكلمات',
      description: 'تعلم 50 كلمة',
      isUnlocked: false,
    ),
    _BadgeData(
      icon: '🏆',
      name: 'بطل الاختبارات',
      description: 'احصل على درجة كاملة',
      isUnlocked: false,
    ),
    _BadgeData(
      icon: '💬',
      name: 'محادثة نشطة',
      description: 'أكمل 10 محادثات',
      isUnlocked: false,
    ),
    _BadgeData(
      icon: '🎤',
      name: 'نطق مثالي',
      description: 'احصل على 90%+ في النطق',
      isUnlocked: false,
    ),
    _BadgeData(
      icon: '⚡',
      name: 'سريع البرق',
      description: 'أكمل اختبار في دقيقة',
      isUnlocked: false,
    ),
  ];

  final _leaderboard = [
    _LeaderData(
      name: 'Lena',
      xp: 1580,
      gems: 150,
      rank: 1,
      avatar: '👩',
    ),
    _LeaderData(
      name: 'Ahmed',
      xp: 1250,
      gems: 0,
      rank: 2,
      avatar: '👨',
    ),
    _LeaderData(
      name: 'Paul',
      xp: 1100,
      gems: 0,
      rank: 3,
      avatar: '👦',
    ),
    _LeaderData(
      name: 'Anna',
      xp: 980,
      gems: 0,
      rank: 4,
      avatar: '👧',
    ),
    _LeaderData(
      name: 'Max',
      xp: 860,
      gems: 0,
      rank: 5,
      avatar: '🧑',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _badgeTabController = TabController(length: 3, vsync: this);
    _leaderboardTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _badgeTabController.dispose();
    _leaderboardTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBadgesSection(),
              const SizedBox(height: 16),
              _buildLeaderboardSection(),
              const SizedBox(height: 16),
              _buildStreakSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        'الgamification',
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ).animate().fadeIn().slideX(begin: -0.1),
    );
  }

  // ═══════════════════════════════════════════
  // BADGES SECTION
  // ═══════════════════════════════════════════
  Widget _buildBadgesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإنجازات',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          _buildBadgeTabs(),
          const SizedBox(height: 16),
          _buildBadgeGrid(),
        ],
      ),
    );
  }

  Widget _buildBadgeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_badgeTabs.length, (index) {
          final isSelected = _selectedBadgeTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedBadgeTab = index);
                _badgeTabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _badgeTabs[index],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildBadgeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _badges.length,
      itemBuilder: (context, index) {
        return _buildBadgeCard(_badges[index], index);
      },
    );
  }

  Widget _buildBadgeCard(_BadgeData badge, int index) {
    return GlowCard(
      glowColor: badge.isUnlocked ? AppColors.gold : AppColors.border,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        badge.isUnlocked ? AppColors.gold : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    badge.icon,
                    style: TextStyle(
                      fontSize: 28,
                      color: badge.isUnlocked ? null : AppColors.textHint,
                    ),
                  ),
                ),
              ),
              if (!badge.isUnlocked)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badge.isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (badge.isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'مكتمل',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'مقفل',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint,
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + index * 80))
        .scale(begin: const Offset(0.9, 0.9));
  }

  // ═══════════════════════════════════════════
  // LEADERBOARD SECTION
  // ═══════════════════════════════════════════
  Widget _buildLeaderboardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة المتصدرين',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          _buildLeaderboardTabs(),
          const SizedBox(height: 16),
          _buildLeaderboardList(),
          const SizedBox(height: 12),
          _buildShowMoreButton(),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_leaderboardTabs.length, (index) {
          final isSelected = _selectedLeaderboardTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedLeaderboardTab = index);
                _leaderboardTabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _leaderboardTabs[index],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildLeaderboardList() {
    return Column(
      children: List.generate(_leaderboard.length, (index) {
        return _buildLeaderboardItem(_leaderboard[index], index);
      }),
    );
  }

  Widget _buildLeaderboardItem(_LeaderData leader, int index) {
    final rankColors = {
      1: AppColors.gold,
      2: AppColors.textSecondary,
      3: const Color(0xFFCD7F32),
    };
    final rankColor = rankColors[leader.rank] ?? AppColors.textHint;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        glowColor: leader.rank == 1 ? AppColors.gold : AppColors.border,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: leader.rank <= 3
                    ? LinearGradient(
                        colors: [
                          rankColor,
                          rankColor.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: leader.rank <= 3 ? null : AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: rankColor,
                  width: leader.rank <= 3 ? 2 : 1,
                ),
              ),
              child: Center(
                child: leader.rank <= 3
                    ? Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        '${leader.rank}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: leader.rank == 1
                    ? AppColors.goldGradient
                    : AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  leader.avatar,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leader.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${leader.xp} XP',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (leader.gems > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${leader.gems} 💎',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gem,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (leader.rank == 1)
              const Icon(
                Icons.workspace_premium,
                color: AppColors.gold,
                size: 24,
              )
            else if (leader.rank == 2)
              const Icon(
                Icons.workspace_premium,
                color: AppColors.textSecondary,
                size: 22,
              )
            else if (leader.rank == 3)
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFCD7F32),
                size: 20,
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + index * 100))
        .slideX(begin: 0.15);
  }

  Widget _buildShowMoreButton() {
    return Center(
      child: GlowCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Text(
          'عرض المزيد',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 900.ms);
  }

  // ═══════════════════════════════════════════
  // STREAK SECTION
  // ═══════════════════════════════════════════
  Widget _buildStreakSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الستريك اليومي',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 950.ms),
          const SizedBox(height: 12),
          _buildStreakCard(),
          const SizedBox(height: 12),
          _buildWeeklyCalendar(),
          const SizedBox(height: 12),
          _buildMotivationText(),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return GlowCard(
      glowColor: AppColors.streak,
      gradient: AppColors.orangeGradient,
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              '45 يوم متتالي',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().scale(begin: const Offset(0.6, 0.6)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildWeeklyCalendar() {
    final days = [
      _DayData(name: 'الإثنين', abbr: 'إثن', isActive: true),
      _DayData(name: 'الثلاثاء', abbr: 'ثلا', isActive: true),
      _DayData(name: 'الأربعاء', abbr: 'أرب', isActive: true),
      _DayData(name: 'الخميس', abbr: 'خمي', isActive: true),
      _DayData(name: 'الجمعة', abbr: 'جمع', isActive: true),
      _DayData(name: 'السبت', abbr: 'سبت', isActive: false),
      _DayData(name: 'الأحد', abbr: 'أحد', isActive: false),
    ];

    return GlassCard(
      glowColor: AppColors.streak,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هذا الأسبوع',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient:
                          day.isActive ? AppColors.orangeGradient : null,
                      color: day.isActive ? null : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: day.isActive
                            ? AppColors.streak
                            : AppColors.border,
                        width: day.isActive ? 2 : 1,
                      ),
                      boxShadow: day.isActive
                          ? [
                              BoxShadow(
                                color: AppColors.streak
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: day.isActive
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              day.abbr[0],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    day.abbr,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: day.isActive
                          ? AppColors.streak
                          : AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1);
  }

  Widget _buildMotivationText() {
    return Center(
      child: GlowCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          'استمر في الحفاظ على متسلسلتك!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryLight,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1200.ms);
  }
}

// ═══════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════
class _BadgeData {
  final String icon;
  final String name;
  final String description;
  final bool isUnlocked;

  const _BadgeData({
    required this.icon,
    required this.name,
    required this.description,
    required this.isUnlocked,
  });
}

class _LeaderData {
  final String name;
  final int xp;
  final int gems;
  final int rank;
  final String avatar;

  const _LeaderData({
    required this.name,
    required this.xp,
    required this.gems,
    required this.rank,
    required this.avatar,
  });
}

class _DayData {
  final String name;
  final String abbr;
  final bool isActive;

  const _DayData({
    required this.name,
    required this.abbr,
    required this.isActive,
  });
}
