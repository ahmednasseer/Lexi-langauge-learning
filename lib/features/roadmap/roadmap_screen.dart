import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  int _selectedLevel = 0;
  int _selectedNav = 2;

  final List<Map<String, dynamic>> _levels = [
    {'label': 'A2', 'color': AppColors.levelA2},
    {'label': 'B1', 'color': AppColors.levelB1},
    {'label': 'B2', 'color': AppColors.levelB2},
    {'label': 'C1', 'color': AppColors.levelC1},
  ];

  final List<Map<String, dynamic>> _skills = [
    {
      'name': 'المستويات',
      'progress': 0.80,
      'color': AppColors.levelA2,
      'icon': Icons.auto_stories_rounded,
    },
    {
      'name': 'القواعد',
      'progress': 0.60,
      'color': AppColors.success,
      'icon': Icons.rule_rounded,
    },
    {
      'name': 'الاستماع',
      'progress': 0.75,
      'color': AppColors.primary,
      'icon': Icons.headphones_rounded,
    },
    {
      'name': 'التحدث',
      'progress': 0.40,
      'color': AppColors.secondary,
      'icon': Icons.mic_rounded,
    },
    {
      'name': 'الكتابة',
      'progress': 0.30,
      'color': AppColors.accent,
      'icon': Icons.edit_note_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLevelTabs(),
            Expanded(
              child: _buildSkillsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            'مسار التعلم',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLevelTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(_levels.length, (index) {
          final level = _levels[index];
          final isSelected = _selectedLevel == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedLevel = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? level['color'] as Color
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (level['color'] as Color)
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    level['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildSkillsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _skills.length,
      itemBuilder: (context, index) {
        final skill = _skills[index];
        return _buildSkillCard(skill, index);
      },
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill, int index) {
    final name = skill['name'] as String;
    final progress = skill['progress'] as double;
    final color = skill['color'] as Color;
    final icon = skill['icon'] as IconData;
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 + index * 80), duration: 400.ms)
        .slideX(
          begin: 0.15,
          delay: Duration(milliseconds: 100 + index * 80),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'الرئيسية'},
      {'icon': Icons.explore_rounded, 'label': 'الاكتشاف'},
      {'icon': Icons.school_rounded, 'label': 'التعلم'},
      {'icon': Icons.leaderboard_rounded, 'label': 'المجتمع'},
      {'icon': Icons.person_rounded, 'label': 'الملف'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedNav,
          onTap: (i) => setState(() => _selectedNav = i),
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
          items: items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item['icon'] as IconData),
                  label: item['label'] as String,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
