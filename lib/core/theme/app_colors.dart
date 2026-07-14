import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFFFA726);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color background = Color(0xFFF5F5F9);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1A1A2E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFE65100)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF00838F)],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
  );
}
