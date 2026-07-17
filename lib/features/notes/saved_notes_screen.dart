import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class SavedNotesScreen extends StatelessWidget {
  const SavedNotesScreen({super.key});

  final List<_SavedWord> _words = const [
    _SavedWord(german: 'Reise', arabic: 'رحلة', stars: 3, gems: 120),
    _SavedWord(german: 'Auto', arabic: 'سيارة', stars: 2, gems: 80),
    _SavedWord(german: 'Wichtig', arabic: 'مهم', stars: 3, gems: 150),
    _SavedWord(german: 'Familie', arabic: 'عائلة', stars: 2, gems: 90),
    _SavedWord(german: 'Arbeit', arabic: 'عمل', stars: 2, gems: 100),
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: _words.length,
                itemBuilder: (context, index) => _buildWordCard(_words[index], index),
              ),
            ),
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
              'المذكرات المحفوظة',
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
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildWordCard(_SavedWord word, int index) {
    final cardGlow = word.stars == 3 ? AppColors.gold : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlowCard(
        glowColor: cardGlow,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: word.stars == 3 ? AppColors.goldGradient : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  word.german[0],
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.german,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.arabic,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < word.stars ? Icons.star : Icons.star_border,
                      color: i < word.stars ? AppColors.gold : AppColors.textHint,
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${word.gems} نقطة',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gem,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 80)).slideX(begin: 0.15);
  }
}

class _SavedWord {
  final String german;
  final String arabic;
  final int stars;
  final int gems;

  const _SavedWord({
    required this.german,
    required this.arabic,
    required this.stars,
    required this.gems,
  });
}
