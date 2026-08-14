import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
          if (badge.assetPath != null)
            ClipOval(
              child: Image.asset(
                badge.assetPath!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 60),
              ),
            )
          else
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
                    color: badge.isUnlocked
                        ? Colors.amber.shade300
                        : AppColors.textHint,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: badge.isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
