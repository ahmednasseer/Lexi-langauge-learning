class AppAssets {
  AppAssets._();

  // ── Logo ─────────────────────────────────────────────────────────
  static const String appLogo = 'assets/images/app_logo.jpg';

  // ── Badges (Level Icons) ────────────────────────────────────────
  static const String badgeA1 = 'assets/images/icons/a1 level icon.png';
  static const String badgeA2 = 'assets/images/icons/a2 level icon.png';
  static const String badgeB1 = 'assets/images/icons/b1 level icon.png';
  static const String badgeB2 = 'assets/images/icons/b2 level icon.png';
  static const String badgeC1 = 'assets/images/icons/c1 level icon.png';
  static const String badgeC2 = 'assets/images/icons/c2 level icon.png';

  static String badgeForLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1': return badgeA1;
      case 'A2': return badgeA2;
      case 'B1': return badgeB1;
      case 'B2': return badgeB2;
      case 'C1': return badgeC1;
      case 'C2': return badgeC2;
      default: return badgeA1;
    }
  }

  // ── Achievements ─────────────────────────────────────────────────
  static const String achievementFirstWord =
      'assets/images/avatars/achievement_first_word-removebg-preview.png';
  static const String achievementStreak7 =
      'assets/images/avatars/achievement_streak_7-removebg-preview.png';
  static const String achievementStreak30 =
      'assets/images/avatars/achievement_streak_30-removebg-preview.png';
  static const String achievement100Words =
      'assets/images/avatars/achievement_first_word-removebg-preview.png';

  // ── UI Icons ────────────────────────────────────────────────────
  static const String iconStudy = 'assets/images/icons/icon_study.png';
  static const String iconListening = 'assets/images/icons/lexi_listening.png';
  static const String iconGems = 'assets/images/icons/lot_of_gems.png';
  static const String iconPrize = 'assets/images/icons/prize icon.png';
  static const String iconXP = 'assets/images/icons/xp_learning_icon.png';
  static const String iconDiamond = 'assets/images/icons/diamond_icon.png';
  static const String iconDeutsch = 'assets/images/icons/deutsch icon.png';
  static const String lexiHappy = 'assets/images/icons/icon_study.png';
  static const String lexiDefault = 'assets/images/icons/icon_study.png';
  static const String lexiTeacherHappy =
      'assets/images/icons/lexi_listening.png';

  // ── Lottie Animations ────────────────────────────────────────────
  static const String lottieConfetti = 'assets/lottie/lottie_confetti.json';
  static const String lottieSuccessCheck =
      'assets/lottie/lottie_success_check.json';
}
