import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/achievement_badge.dart';

class BadgeCard extends StatelessWidget {
  final AchievementBadge badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badge.isUnlocked ? AppColors.surface : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.isUnlocked ? Colors.amber.shade400 : AppColors.border,
          width: badge.isUnlocked ? 2 : 1,
        ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.isUnlocked
                  ? Colors.amber.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 30,
                  color: badge.isUnlocked ? Colors.amber.shade300 : AppColors.textHint,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Badge name
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badge.isUnlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Badge description
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: badge.isUnlocked ? AppColors.textSecondary : AppColors.textHint,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Status
          if (badge.isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'UNLOCKED',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${badge.rewardXp} XP',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
