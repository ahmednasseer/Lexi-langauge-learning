import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════
  // CORE DARK BACKGROUND COLORS
  // ═══════════════════════════════════════════
  static const Color background = Color(0xFF0A0E21);
  static const Color backgroundSecondary = Color(0xFF111936);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF222244);
  static const Color card = Color(0xFF1A1A2E);
  static const Color cardLight = Color(0xFF252547);

  // ═══════════════════════════════════════════
  // ACCENT COLORS
  // ═══════════════════════════════════════════
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF2563EB);
  static const Color accent = Color(0xFFEC4899);
  static const Color accentDark = Color(0xFFDB2777);

  // ═══════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textHint = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF4B5563);

  // ═══════════════════════════════════════════
  // SPECIAL COLORS
  // ═══════════════════════════════════════════
  static const Color gold = Color(0xFFFBBF24);
  static const Color goldDark = Color(0xFFF59E0B);
  static const Color gem = Color(0xFFA855F7);
  static const Color xp = Color(0xFFFBBF24);
  static const Color streak = Color(0xFFF97316);

  // ═══════════════════════════════════════════
  // LEVEL COLORS
  // ═══════════════════════════════════════════
  static const Color levelA1 = Color(0xFF22C55E);
  static const Color levelA2 = Color(0xFF3B82F6);
  static const Color levelB1 = Color(0xFFFBBF24);
  static const Color levelB2 = Color(0xFFF97316);
  static const Color levelC1 = Color(0xFFEF4444);
  static const Color levelC2 = Color(0xFF8B5CF6);

  // ═══════════════════════════════════════════
  // BORDER & DIVIDER
  // ═══════════════════════════════════════════
  static const Color border = Color(0xFF2A2A4E);
  static const Color borderLight = Color(0xFF333366);
  static const Color divider = Color(0xFF1E1E3F);

  // ═══════════════════════════════════════════
  // GRADIENTS - PRIMARY
  // ═══════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════
  // GRADIENTS - STATUS
  // ═══════════════════════════════════════════
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════
  // GRADIENTS - SPECIAL
  // ═══════════════════════════════════════════
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gemGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════
  // GRADIENTS - COMPLEX (Multi-stop)
  // ═══════════════════════════════════════════
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEC4899), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════
  // CARD GRADIENTS (for glassmorphism cards)
  // ═══════════════════════════════════════════
  static LinearGradient cardGradient({double opacity = 0.1, Color? color}) {
    return LinearGradient(
      colors: [
        (color ?? primary).withValues(alpha: opacity),
        (color ?? primary).withValues(alpha: opacity * 0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ═══════════════════════════════════════════
  // GLOW COLORS
  // ═══════════════════════════════════════════
  static Color glowPrimary = const Color(0xFF8B5CF6).withValues(alpha: 0.3);
  static Color glowSecondary = const Color(0xFF3B82F6).withValues(alpha: 0.3);
  static Color glowAccent = const Color(0xFFEC4899).withValues(alpha: 0.3);
  static Color glowGold = const Color(0xFFFBBF24).withValues(alpha: 0.3);
  static Color glowSuccess = const Color(0xFF22C55E).withValues(alpha: 0.3);
  static Color glowError = const Color(0xFFEF4444).withValues(alpha: 0.3);

  // ═══════════════════════════════════════════
  // LEVEL GRADIENTS
  // ═══════════════════════════════════════════
  static const LinearGradient a1Gradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );
  static const LinearGradient a2Gradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  );
  static const LinearGradient b1Gradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  );
  static const LinearGradient b2Gradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
  );
  static const LinearGradient c1Gradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );
  static const LinearGradient c2Gradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );

  static LinearGradient getLevelGradient(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return a1Gradient;
      case 'A2':
        return a2Gradient;
      case 'B1':
        return b1Gradient;
      case 'B2':
        return b2Gradient;
      case 'C1':
        return c1Gradient;
      case 'C2':
        return c2Gradient;
      default:
        return primaryGradient;
    }
  }

  static Color getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return levelA1;
      case 'A2':
        return levelA2;
      case 'B1':
        return levelB1;
      case 'B2':
        return levelB2;
      case 'C1':
        return levelC1;
      case 'C2':
        return levelC2;
      default:
        return primary;
    }
  }

  static String getLevelLabel(String level) {
    switch (level.toUpperCase()) {
      case 'A1': return 'Anfänger';
      case 'A2': return 'Grundkenntnisse';
      case 'B1': return 'Mittelstufe';
      case 'B2': return ' Oberstufe';
      case 'C1': return 'Fortgeschritten';
      case 'C2': return 'Muttersprachlich';
      default: return 'Unbekannt';
    }
  }
}
