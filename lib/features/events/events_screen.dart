import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

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
              const SizedBox(height: 24),
              _buildLiveSectionTitle(),
              const SizedBox(height: 12),
              _buildLiveSessionCard(
                title: 'Conversation Class',
                arabicTitle: 'حصص المحادثة',
                time: '18:00',
                icon: '💬',
                gradient: AppColors.primaryGradient,
                index: 0,
              ),
              const SizedBox(height: 12),
              _buildLiveSessionCard(
                title: 'Grammar Deep Dive',
                arabicTitle: 'تعمق في القواعد',
                time: '19:00',
                icon: '📚',
                gradient: AppColors.secondaryGradient,
                index: 1,
              ),
              const SizedBox(height: 28),
              _buildRecentActivityTitle(),
              const SizedBox(height: 12),
              _buildRecentActivityItem(
                icon: Icons.check_circle,
                color: AppColors.success,
                title: 'أكملت درس المحادثة',
                time: 'منذ ساعتين',
                index: 0,
              ),
              const SizedBox(height: 10),
              _buildRecentActivityItem(
                icon: Icons.star,
                color: AppColors.gold,
                title: 'حصلت على 50 نقطة',
                time: 'منذ 3 ساعات',
                index: 1,
              ),
              const SizedBox(height: 10),
              _buildRecentActivityItem(
                icon: Icons.local_fire_department,
                color: AppColors.streak,
                title: 'حافظت على سلسلتك اليومية',
                time: 'منذ 5 ساعات',
                index: 2,
              ),
              const SizedBox(height: 10),
              _buildRecentActivityItem(
                icon: Icons.emoji_events,
                color: AppColors.accent,
                title: 'أنجزت شارة جديدة',
                time: 'أمس',
                index: 3,
              ),
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
              'الحديث والأحداث',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildLiveSectionTitle() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'جلسات مباشرة',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildLiveSessionCard({
    required String title,
    required String arabicTitle,
    required String time,
    required String icon,
    required LinearGradient gradient,
    required int index,
  }) {
    return GlowCard(
      glowColor: gradient.colors.first,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabicTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: gradient.colors.first),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: gradient.colors.first,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'مباشر',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'إضافة للمفضلة',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 100)).slideX(begin: 0.15);
  }

  Widget _buildRecentActivityTitle() {
    return Text(
      'النشاط الأخير',
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRecentActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required int index,
  }) {
    return GlowCard(
      glowColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: AppColors.textHint, size: 20),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 500 + index * 80)).slideX(begin: 0.1);
  }
}
