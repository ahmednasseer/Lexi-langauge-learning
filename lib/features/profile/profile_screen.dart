import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import '../../services/auth_service.dart';
import 'profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 4;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    if (!AuthService.instance.isAuthenticated) return;
    final repo = ProfileRepository();
    final updated = await repo.getProfile();
    if (updated != null && mounted) {
      AuthService.instance.updateProfile(
        name: updated.name,
        level: updated.level,
        xp: updated.xp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Guest';
    final userLevel = user?.level ?? 'B1';
    final userXp = user?.xp ?? 1250;
    final streak = user?.streak ?? 20;
    final lessons = 12;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(userName, userLevel),
              const SizedBox(height: 24),
              _buildStatsRow(lessons, userXp, streak),
              const SizedBox(height: 28),
              _buildMenuItems(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProfileHeader(String name, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.heroGradient,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'L',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                left: -4,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🇩🇪',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn().scale(
                begin: const Offset(0.9, 0.9),
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.getLevelGradient(level),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getLevelColor(level)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  level,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          const SizedBox(height: 4),
          Text(
            '🇩🇪 ألماني',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int lessons, int points, int streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.menu_book_rounded,
              value: '$lessons',
              label: 'الدروس',
              gradient: AppColors.blueGradient,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              icon: Icons.star_rounded,
              value: '$points',
              label: 'النقاط',
              gradient: AppColors.goldGradient,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_fire_department_rounded,
              value: '$streak',
              label: 'أيام متتالية',
              gradient: AppColors.orangeGradient,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.emoji_events_rounded,
        'title': 'الإنجازات',
        'color': AppColors.warning,
        'route': '/achievements',
      },
      {
        'icon': Icons.military_tech_rounded,
        'title': 'الشارات',
        'color': AppColors.gold,
        'route': '/gamification',
      },
      {
        'icon': Icons.library_books_rounded,
        'title': 'دراستي المعروضية',
        'color': AppColors.secondary,
        'route': '/lessons',
      },
      {
        'icon': Icons.bar_chart_rounded,
        'title': 'نشاطي',
        'color': AppColors.success,
        'route': '/growth',
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'الإعدادات',
        'color': AppColors.textSecondary,
        'route': '/settings',
      },
      {
        'icon': Icons.person_outline,
        'title': 'الملف الشخصي',
        'color': AppColors.primary,
        'route': '/avatar-editor',
      },
      {
        'icon': Icons.store_outlined,
        'title': 'المتجر',
        'color': AppColors.primary,
        'route': '/store',
      },
      {
        'icon': Icons.diamond_outlined,
        'title': 'الماس',
        'color': AppColors.secondary,
        'route': '/gem-store',
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'الاشتراكات',
        'color': AppColors.gold,
        'route': '/premium',
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'title': 'الشهادات',
        'color': AppColors.success,
        'route': '/certificates',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            final isLast = index == menuItems.length - 1;
            return _buildMenuItem(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              color: item['color'] as Color,
              showDivider: !isLast,
              onTap: () {
                final route = item['route'] as String;
                if (route.isNotEmpty) {
                  Navigator.pushNamed(context, route);
                }
              },
            );
          }),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textHint,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 74,
            color: AppColors.divider,
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
          currentIndex: _currentNavIndex,
          onTap: (i) => setState(() => _currentNavIndex = i),
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
    );
  }
}
