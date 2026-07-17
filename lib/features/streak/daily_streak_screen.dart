import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class DailyStreakScreen extends StatelessWidget {
  const DailyStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildStreakCard(),
              const SizedBox(height: 28),
              _buildWeeklyCalendar(),
              const SizedBox(height: 24),
              _buildMotivationText(),
              const SizedBox(height: 24),
              _buildStreakStats(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'الستريك اليومي',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildStreakCard() {
    return GlowCard(
      glowColor: AppColors.streak,
      gradient: AppColors.orangeGradient,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 16),
            Text(
              '45 يوم متتالي',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().scale(delay: 200.ms, begin: const Offset(0.6, 0.6)),
            const SizedBox(height: 8),
            Text(
              'أنت على الطريق الصحيح!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9));
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: day.isActive ? AppColors.orangeGradient : null,
                      color: day.isActive ? null : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: day.isActive ? AppColors.streak : AppColors.border,
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
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              day.abbr[0],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day.abbr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: day.isActive ? AppColors.streak : AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildMotivationText() {
    return Center(
      child: GlowCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          'استمر في الحفاظ على متسلسلتك!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryLight,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildStreakStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات المتسلسلة',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'أطول متسلسلة',
                value: '67 يوم',
                color: AppColors.streak,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                label: 'المجموع الكلي',
                value: '450 يوم',
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'معدل هذا الشهر',
                value: '92%',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                label: 'نقاط المتسلسلة',
                value: '450',
                color: AppColors.gem,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlowCard(
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 700 + _statLabels.indexOf(label) * 80));
  }

  static const _statLabels = ['أطول متسلسلة', 'المجموع الكلي', 'معدل هذا الشهر', 'نقاط المتسلسلة'];
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
