import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/services/api_service.dart';

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

  final ApiService _api = ApiService();
  List<dynamic> _badges = [];
  List<dynamic> _leaderboard = [];
  int _streak = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _badgeTabController = TabController(length: 3, vsync: this);
    _leaderboardTabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _badgeTabController.dispose();
    _leaderboardTabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileResult = await _api.getProfile();
      final achievementsResult = await _api.getAchievements();
      final leaderboardResult = await _api.getLeaderboard(period: 'weekly');

      if (profileResult.isSuccess && profileResult.data != null) {
        _streak = profileResult.data!['streak'] ?? 0;
      }
      if (achievementsResult.isSuccess && achievementsResult.data != null) {
        _badges = achievementsResult.data!;
      }
      if (leaderboardResult.isSuccess && leaderboardResult.data != null) {
        _leaderboard = leaderboardResult.data!;
      }
    } catch (e) {
      _error = e.toString();
    }

    setState(() {
      _isLoading = false;
    });
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

  Widget _buildLoadingOverlay() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load gamification data',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // BADGES SECTION
  // ═══════════════════════════════════════════
  Widget _buildBadgesSection() {
    if (_isLoading) {
      return _buildLoadingOverlay();
    }
    if (_error != null && _badges.isEmpty) {
      return _buildErrorOverlay();
    }

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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
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
    if (_badges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No achievements yet',
            style: GoogleFonts.poppins(color: AppColors.textHint),
          ),
        ),
      );
    }

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
        final achievement = _badges[index];
        return _buildBadgeCard(achievement, index);
      },
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> achievement, int index) {
    final isUnlocked = achievement['unlocked'] == true ||
        achievement['isUnlocked'] == true ||
        achievement['status'] == 'completed';
    final icon = achievement['icon'] ?? achievement['emoji'] ?? '🏆';
    final name = achievement['name'] ?? achievement['title'] ?? 'Achievement';
    final description = achievement['description'] ?? '';

    return GlowCard(
          glowColor: isUnlocked ? AppColors.gold : AppColors.border,
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
                      color: isUnlocked
                          ? AppColors.gold.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked
                            ? AppColors.gold
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        icon is String ? icon : '🏆',
                        style: TextStyle(
                          fontSize: 28,
                          color: isUnlocked ? null : AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                  if (!isUnlocked)
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
                name is String ? name : 'Achievement',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description is String ? description : '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
    if (_isLoading) {
      return _buildLoadingOverlay();
    }
    if (_error != null && _leaderboard.isEmpty) {
      return _buildErrorOverlay();
    }

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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
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
    if (_leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No leaderboard data available',
            style: GoogleFonts.poppins(color: AppColors.textHint),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_leaderboard.length, (index) {
        final entry = _leaderboard[index];
        return _buildLeaderboardItem(entry, index);
      }),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> entry, int index) {
    final rank = entry['rank'] ?? entry['position'] ?? index + 1;
    final name = entry['name'] ?? entry['userName'] ?? 'User';
    final xp = entry['xp'] ?? entry['totalXp'] ?? 0;
    final gems = entry['gems'] ?? 0;
    final avatar = entry['avatar'] ?? entry['emoji'] ?? '👤';
    final rankInt = rank is int ? rank : int.tryParse(rank.toString()) ?? index + 1;

    final rankColors = {
      1: AppColors.gold,
      2: AppColors.textSecondary,
      3: const Color(0xFFCD7F32),
    };
    final rankColor = rankColors[rankInt] ?? AppColors.textHint;

    return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlowCard(
            glowColor: rankInt == 1 ? AppColors.gold : AppColors.border,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: rankInt <= 3
                        ? LinearGradient(
                            colors: [
                              rankColor,
                              rankColor.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: rankInt <= 3 ? null : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rankColor,
                      width: rankInt <= 3 ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: rankInt <= 3
                        ? const Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            '$rankInt',
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
                    gradient: rankInt == 1
                        ? AppColors.goldGradient
                        : AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatar is String ? avatar : '👤',
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
                        name is String ? name : 'User',
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
                            '$xp XP',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          if (gems > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$gems 💎',
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
                if (rankInt == 1)
                  const Icon(
                    Icons.workspace_premium,
                    color: AppColors.gold,
                    size: 24,
                  )
                else if (rankInt == 2)
                  const Icon(
                    Icons.workspace_premium,
                    color: AppColors.textSecondary,
                    size: 22,
                  )
                else if (rankInt == 3)
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
    if (_isLoading) {
      return _buildLoadingOverlay();
    }

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
    final streakText = _streak > 0 ? '$_streak يوم متتالي' : '0 يوم متتالي';

    return GlowCard(
      glowColor: AppColors.streak,
      gradient: AppColors.orangeGradient,
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              streakText,
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
                      gradient: day.isActive ? AppColors.orangeGradient : null,
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
                                color: AppColors.streak.withValues(alpha: 0.3),
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
