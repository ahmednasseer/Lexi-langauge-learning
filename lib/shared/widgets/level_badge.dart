import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';

class LevelBadge extends StatelessWidget {
  final String level;
  final double size;
  final bool showLabel;
  final bool showGlow;
  final bool isActive;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 60,
    this.showLabel = true,
    this.showGlow = true,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final asset = _badgeAsset(level);
    final levelColor = AppColors.getLevelColor(level);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        if (asset != null)
          Container(
            width: size,
            height: size,
            decoration: showGlow
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withValues(alpha: 0.4),
                        blurRadius: isActive ? 20 : 10,
                        spreadRadius: isActive ? 2 : 0,
                      ),
                    ],
                  )
                : null,
            child: ClipOval(
              child: Image.asset(
                asset,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: size),
              ),
            ),
          )
        else
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.getLevelGradient(level),
            ),
            child: Center(
              child: Text(
                level,
                style: GoogleFonts.poppins(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        // Label
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            _getLevelName(level),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isActive ? levelColor : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }

  String _getLevelName(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return 'Beginner';
      case 'A2':
        return 'Elementary';
      case 'B1':
        return 'Intermediate';
      case 'B2':
        return 'Upper-Int.';
      case 'C1':
        return 'Advanced';
      case 'C2':
        return 'Mastery';
      default:
        return level;
    }
  }

  static String? _badgeAsset(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return AppAssets.badgeA1;
      case 'A2':
        return AppAssets.badgeA2;
      case 'B1':
        return AppAssets.badgeB1;
      case 'B2':
        return AppAssets.badgeB2;
      case 'C1':
        return AppAssets.badgeC1;
      case 'C2':
        return AppAssets.badgeC1;
      default:
        return null;
    }
  }
}

class LevelBadgeSmall extends StatelessWidget {
  final String level;

  const LevelBadgeSmall({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final levelGradient = AppColors.getLevelGradient(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: levelGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class LevelBadgeIcon extends StatelessWidget {
  final String level;
  final double size;

  const LevelBadgeIcon({super.key, required this.level, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final levelGradient = AppColors.getLevelGradient(level);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: levelGradient,
      ),
      child: Center(
        child: Text(
          level,
          style: GoogleFonts.poppins(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
