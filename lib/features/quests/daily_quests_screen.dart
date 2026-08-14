import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class DailyQuestsScreen extends StatelessWidget {
  const DailyQuestsScreen({super.key});

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
              _buildQuestsList(),
              const SizedBox(height: 24),
              _buildTotalReward(),
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
              'المغامرات اليومية',
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

  Widget _buildQuestsList() {
    final quests = [
      _QuestData(
        name: 'تعلم 20 كلمة',
        current: 7,
        total: 10,
        icon: Icons.menu_book_rounded,
        color: AppColors.primary,
        gems: 50,
      ),
      _QuestData(
        name: 'حل 10 اختبار',
        current: 7,
        total: 10,
        icon: Icons.quiz_rounded,
        color: AppColors.secondary,
        gems: 80,
      ),
      _QuestData(
        name: 'اسماع 15 محادثة',
        current: 12,
        total: 15,
        icon: Icons.headphones_rounded,
        color: AppColors.success,
        gems: 60,
      ),
      _QuestData(
        name: 'تحدث 5 دقائق',
        current: 5,
        total: 8,
        icon: Icons.mic_rounded,
        color: AppColors.accent,
        gems: 70,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المهام اليومية',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        ...quests.asMap().entries.map((entry) {
          final index = entry.key;
          final quest = entry.value;
          return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildQuestCard(quest),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 300 + index * 100))
              .slideY(begin: 0.1);
        }),
      ],
    );
  }

  Widget _buildQuestCard(_QuestData quest) {
    final progress = quest.current / quest.total;

    return GlowCard(
      glowColor: quest.color,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [quest.color, quest.color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(quest.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: quest.color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(quest.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${quest.current}/${quest.total}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gem.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${quest.gems}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalReward() {
    return GlowCard(
      glowColor: AppColors.gold,
      gradient: AppColors.goldGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                'المكافأة الإجمالية',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    '260',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _QuestData {
  final String name;
  final int current;
  final int total;
  final IconData icon;
  final Color color;
  final int gems;

  const _QuestData({
    required this.name,
    required this.current,
    required this.total,
    required this.icon,
    required this.color,
    required this.gems,
  });
}
