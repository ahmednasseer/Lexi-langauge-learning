import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class AudioLessonsScreen extends StatelessWidget {
  const AudioLessonsScreen({super.key});

  final List<_LessonCategory> _categories = const [
    _LessonCategory(
      icon: '🎓',
      name: 'German Beginner',
      arabicName: 'ألماني للمبتدئين',
      lessonCount: 24,
      gradient: AppColors.primaryGradient,
    ),
    _LessonCategory(
      icon: '✈️',
      name: 'Travel Talk',
      arabicName: 'محادثات السفر',
      lessonCount: 18,
      gradient: AppColors.secondaryGradient,
    ),
    _LessonCategory(
      icon: '📝',
      name: 'Exam Preparation',
      arabicName: 'تحضير للامتحانات',
      lessonCount: 16,
      gradient: AppColors.orangeGradient,
    ),
    _LessonCategory(
      icon: '💬',
      name: 'Daily Practice',
      arabicName: 'ممارسة يومية',
      lessonCount: 30,
      gradient: AppColors.accentGradient,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) => _buildCategoryCard(_categories[index], index),
              ),
            ),
            _buildBrowseAllButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 8),
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
              'قنف صوتية',
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
              Icons.headphones,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatChip(Icons.headphones, '88 درس', AppColors.primary),
          const SizedBox(width: 12),
          _buildStatChip(Icons.access_time, '42 ساعة', AppColors.secondary),
          const SizedBox(width: 12),
          _buildStatChip(Icons.trending_up, 'مستوى متوسط', AppColors.warning),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_LessonCategory category, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlowCard(
        glowColor: category.gradient.colors.first,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: category.gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.arabicName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.play_circle_outline, size: 14, color: category.gradient.colors.first),
                      const SizedBox(width: 4),
                      Text(
                        '${category.lessonCount} درس',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: category.gradient.colors.first,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: category.gradient.colors.first.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: category.gradient.colors.first,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 100)).slideX(begin: 0.15);
  }

  Widget _buildBrowseAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlowCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.all(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music, color: AppColors.primary, size: 20),
            SizedBox(width: 10),
            Text(
              'الدورة عرضة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _LessonCategory {
  final String icon;
  final String name;
  final String arabicName;
  final int lessonCount;
  final LinearGradient gradient;

  const _LessonCategory({
    required this.icon,
    required this.name,
    required this.arabicName,
    required this.lessonCount,
    required this.gradient,
  });
}
