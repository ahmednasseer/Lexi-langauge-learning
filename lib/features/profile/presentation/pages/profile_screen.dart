import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileError) {
          return Center(
            child: Text(
              state.message,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        final profile = state is ProfileLoaded ? state.profile : null;
        final userName = profile?.name ?? 'Guest';
        final userLevel = _getLevelFromXp(profile?.xp ?? 0);
        final userXp = profile?.xp ?? 0;
        final streak = profile?.streak ?? 0;
        final lessons = 12;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(context, userName, userLevel),
                  const SizedBox(height: 24),
                  _buildStatsRow(lessons, userXp, streak),
                  const SizedBox(height: 28),
                  _buildMenuItems(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLevelFromXp(int xp) {
    if (xp >= 1000) return 'C1';
    if (xp >= 500) return 'B2';
    if (xp >= 300) return 'B1';
    if (xp >= 100) return 'A2';
    return 'A1';
  }

  Widget _buildProfileHeader(BuildContext context, String name, String level) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'L',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn().scale(
              begin: const Offset(0.9, 0.9),
              duration: 400.ms,
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
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Center(child: Text('🇩🇪', style: TextStyle(fontSize: 18))),
              ),
            ),
          ],
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
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
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
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 4),
        Text(
          '🇩🇪 ألماني',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildStatsRow(int lessons, int points, int streak) {
    return Row(
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
    ).animate().fadeIn(delay: 200.ms);
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

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.emoji_events_rounded,
        'title': 'الإنجازات',
        'route': '/achievements',
      },
      {
        'icon': Icons.military_tech_rounded,
        'title': 'الشارات',
        'route': '/gamification',
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'الإعدادات',
        'route': '/settings',
      },
    ];

    return GlassCard(
      glowColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 22),
                ),
                title: Text(
                  item['title'] as String,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
                onTap: () => Navigator.pushNamed(context, item['route'] as String),
              ),
              if (!isLast) Divider(height: 1, indent: 74, color: AppColors.divider),
            ],
          );
        }),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
