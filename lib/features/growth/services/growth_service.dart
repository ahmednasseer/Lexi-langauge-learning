import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/referral_models.dart';
import '../models/gamification_models.dart';
import '../models/seasonal_event.dart';
import '../models/push_notification.dart';
import '../models/ab_testing.dart';
import '../models/premium_conversion.dart';

class GrowthService {
  static const String _referralKey = 'referral_data';
  static const String _progressKey = 'user_progress';
  static const String _eventsKey = 'seasonal_events';
  static const String _notificationsKey = 'push_notifications';
  static const String _abTestsKey = 'ab_tests';
  static const String _premiumKey = 'premium_data';

  // Referral System
  Future<ReferralCode> generateReferralCode(String userId) async {
    final code =
        'LEXI${userId.substring(0, min(4, userId.length)).toUpperCase()}${Random().nextInt(9999).toString().padLeft(4, '0')}';

    final referralCode = ReferralCode(
      id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      code: code,
      maxUses: 10,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_referralKey}_code_$userId',
      jsonEncode(referralCode.toJson()),
    );

    return referralCode;
  }

  Future<ReferralStats> getReferralStats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('${_referralKey}_stats_$userId');
      if (statsJson != null) {
        return ReferralStats.fromJson(jsonDecode(statsJson));
      }
    } catch (e) {
      // Fall through to default
    }
    return ReferralStats.empty();
  }

  Future<Referral?> applyReferralCode(
    String code,
    String inviteeId,
    String inviteeName,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Find the referral code
    final keys = prefs.getKeys().where(
      (k) => k.startsWith('${_referralKey}_code_'),
    );
    for (final key in keys) {
      final codeJson = prefs.getString(key);
      if (codeJson != null) {
        final referralCode = ReferralCode.fromJson(jsonDecode(codeJson));
        if (referralCode.code == code && referralCode.canUse) {
          // Create referral
          final referral = Referral(
            id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
            referrerId: referralCode.userId,
            referrerName: 'User',
            inviteeId: inviteeId,
            inviteeName: inviteeName,
            referralCode: code,
            status: ReferralStatus.accepted,
            createdAt: DateTime.now(),
            acceptedAt: DateTime.now(),
            reward: const ReferralReward(gems: 500, premiumDays: 7),
          );

          // Update code usage
          final updatedCode = referralCode.copyWith(
            currentUses: referralCode.currentUses + 1,
          );
          await prefs.setString(key, jsonEncode(updatedCode.toJson()));

          return referral;
        }
      }
    }
    return null;
  }

  // Gamification
  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('${_progressKey}_$userId');
      if (progressJson != null) {
        return UserProgress.fromJson(jsonDecode(progressJson));
      }
    } catch (e) {
      // Fall through to default
    }
    return UserProgress.empty();
  }

  Future<void> saveUserProgress(String userId, UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_progressKey}_$userId',
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> addXp(String userId, int xp) async {
    final progress = await getUserProgress(userId);
    final newTotalXp = progress.totalXp + xp;
    final newLevel = _calculateLevel(newTotalXp);

    final updatedProgress = progress.copyWith(
      totalXp: newTotalXp,
      currentLevel: newLevel,
    );

    await saveUserProgress(userId, updatedProgress);
  }

  int _calculateLevel(int xp) {
    int level = 1;
    int requiredXp = 100;

    while (xp >= requiredXp) {
      level++;
      requiredXp += (level * 50);
    }

    return level;
  }

  List<UserLevel> getAllLevels() {
    return [
      const UserLevel(
        level: 1,
        title: 'Beginner',
        minXp: 0,
        maxXp: 100,
        reward: LevelReward(gems: 0),
      ),
      const UserLevel(
        level: 5,
        title: 'Explorer',
        minXp: 500,
        maxXp: 1000,
        reward: LevelReward(gems: 100, frameId: 'explorer_frame'),
      ),
      const UserLevel(
        level: 10,
        title: 'Adventurer',
        minXp: 2000,
        maxXp: 3000,
        reward: LevelReward(gems: 200, frameId: 'adventurer_frame'),
      ),
      const UserLevel(
        level: 15,
        title: 'Scholar',
        minXp: 5000,
        maxXp: 7500,
        reward: LevelReward(gems: 300, badgeId: 'scholar_badge'),
      ),
      const UserLevel(
        level: 20,
        title: 'Expert',
        minXp: 10000,
        maxXp: 15000,
        reward: LevelReward(gems: 500, frameId: 'expert_frame'),
      ),
      const UserLevel(
        level: 25,
        title: 'German Student',
        minXp: 20000,
        maxXp: 30000,
        reward: LevelReward(gems: 750, badgeId: 'german_student_badge'),
      ),
      const UserLevel(
        level: 30,
        title: 'Linguist',
        minXp: 40000,
        maxXp: 60000,
        reward: LevelReward(gems: 1000, frameId: 'linguist_frame'),
      ),
      const UserLevel(
        level: 40,
        title: 'Master',
        minXp: 100000,
        maxXp: 150000,
        reward: LevelReward(gems: 2000, badgeId: 'master_badge'),
      ),
      const UserLevel(
        level: 50,
        title: 'Language Master',
        minXp: 250000,
        maxXp: 300000,
        reward: LevelReward(gems: 5000, frameId: 'master_frame'),
      ),
    ];
  }

  List<AchievementBadge> getAllBadges() {
    return [
      const AchievementBadge(
        id: 'first_lesson',
        name: 'First Steps',
        description: 'Complete your first lesson',
        icon: '🎯',
        rarity: BadgeRarity.common,
      ),
      const AchievementBadge(
        id: 'streak_7',
        name: 'Week Warrior',
        description: '7-day streak',
        icon: '🔥',
        rarity: BadgeRarity.uncommon,
      ),
      const AchievementBadge(
        id: 'streak_30',
        name: 'Monthly Master',
        description: '30-day streak',
        icon: '💪',
        rarity: BadgeRarity.rare,
      ),
      const AchievementBadge(
        id: 'words_100',
        name: 'Word Collector',
        description: 'Learn 100 words',
        icon: '📚',
        rarity: BadgeRarity.uncommon,
      ),
      const AchievementBadge(
        id: 'words_1000',
        name: 'Vocabulary Master',
        description: 'Learn 1000 words',
        icon: '🎓',
        rarity: BadgeRarity.epic,
      ),
      const AchievementBadge(
        id: 'speaking_100',
        name: 'Speaking Star',
        description: 'Practice speaking 100 minutes',
        icon: '🎤',
        rarity: BadgeRarity.rare,
      ),
      const AchievementBadge(
        id: 'goethe_a1',
        name: 'Goethe A1',
        description: 'Pass Goethe A1 exam',
        icon: '📝',
        rarity: BadgeRarity.uncommon,
      ),
      const AchievementBadge(
        id: 'goethe_b1',
        name: 'Goethe B1',
        description: 'Pass Goethe B1 exam',
        icon: '📝',
        rarity: BadgeRarity.rare,
      ),
      const AchievementBadge(
        id: 'referral_5',
        name: 'Social Butterfly',
        description: 'Invite 5 friends',
        icon: '🦋',
        rarity: BadgeRarity.epic,
      ),
      const AchievementBadge(
        id: 'summer_master',
        name: 'Summer Master',
        description: 'Complete Summer Challenge',
        icon: '☀️',
        rarity: BadgeRarity.legendary,
      ),
    ];
  }

  // Seasonal Events
  Future<List<SeasonalEvent>> getSeasonalEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);
      if (eventsJson != null) {
        final List<dynamic> list = jsonDecode(eventsJson);
        return list.map((j) => SeasonalEvent.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached seasonal events: $e');
    }
    return [];
  }

  Future<void> saveSeasonalEvents(List<SeasonalEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _eventsKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  // Push Notifications
  Future<List<PushNotification>> getNotifications(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('${_notificationsKey}_$userId');
      if (notificationsJson != null) {
        final List<dynamic> list = jsonDecode(notificationsJson);
        return list.map((j) => PushNotification.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached notifications: $e');
    }
    return [];
  }

  List<PushNotification> _getDemoNotifications() {
    return [
      PushNotification(
        id: 'notif_1',
        title: 'Streak Alert 🔥',
        body: 'Don\'t lose your 7-day streak! Practice for just 10 minutes.',
        type: NotificationType.streak,
        priority: NotificationPriority.high,
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PushNotification(
        id: 'notif_2',
        title: 'New Achievement! 🏆',
        body: 'You unlocked "Week Warrior" badge!',
        type: NotificationType.achievement,
        priority: NotificationPriority.medium,
        scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      PushNotification(
        id: 'notif_3',
        title: 'Challenge Available 🎯',
        body: 'Join the German Summer Challenge and win exclusive rewards!',
        type: NotificationType.challenge,
        priority: NotificationPriority.medium,
        scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  List<NotificationTemplate> getSmartTemplates() {
    return [
      const NotificationTemplate(
        id: 'template_streak_risk',
        title: '{name}, your streak is waiting 🔥',
        body:
            'Only {minutes} minutes today to continue your {streak}-day streak!',
        type: NotificationType.streak,
        priority: NotificationPriority.high,
        variables: ['name', 'minutes', 'streak'],
        condition: 'streak > 0 && daysSinceActive > 0',
      ),
      const NotificationTemplate(
        id: 'template_comeback',
        title: 'We miss you, {name}! 💙',
        body:
            'Your German learning is waiting. Just {minutes} minutes a day makes a difference.',
        type: NotificationType.reminder,
        priority: NotificationPriority.medium,
        variables: ['name', 'minutes'],
        condition: 'daysSinceActive > 3',
      ),
      const NotificationTemplate(
        id: 'template_achievement',
        title: 'Achievement Unlocked! 🏆',
        body: 'You earned "{badge_name}"! Keep up the great work.',
        type: NotificationType.achievement,
        priority: NotificationPriority.medium,
        variables: ['badge_name'],
        condition: 'newAchievement',
      ),
      const NotificationTemplate(
        id: 'template_premium_trial',
        title: 'Try Premium Free! ✨',
        body: '{name}, unlock all features with a {days}-day free trial.',
        type: NotificationType.premium,
        priority: NotificationPriority.low,
        variables: ['name', 'days'],
        condition: '!isPremium && trialAvailable',
      ),
    ];
  }

  // A/B Tests
  Future<List<ABTest>> getABTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final testsJson = prefs.getString(_abTestsKey);
      if (testsJson != null) {
        final List<dynamic> list = jsonDecode(testsJson);
        return list.map((j) => ABTest.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cached A/B tests: $e');
    }
    return [];
  }

  ABTestVariant getVariant(String testId, String userId) {
    final hash = (testId + userId).hashCode;
    return hash.isEven ? ABTestVariant.a : ABTestVariant.b;
  }

  // Premium
  Future<SmartPaywall> getSmartPaywall(String userId) async {
    final progress = await getUserProgress(userId);
    final context = {
      'lessonsCompleted': progress.stats['lessonsCompleted'] ?? 0,
      'wordsLearned': progress.stats['wordsLearned'] ?? 0,
      'streak': progress.streak,
      'totalMinutes': progress.stats['totalMinutes'] ?? 0,
    };

    return SmartPaywall.personalized(context);
  }

  Future<FreeTrial> startFreeTrial(String userId) async {
    final trial = FreeTrial(
      id: 'trial_${DateTime.now().millisecondsSinceEpoch}',
      durationDays: 7,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      planAfterTrial: PremiumPlan.yearly,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_premiumKey}_trial_$userId',
      jsonEncode(trial.toJson()),
    );

    return trial;
  }
}
