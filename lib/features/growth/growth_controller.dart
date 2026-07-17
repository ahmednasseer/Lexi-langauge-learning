import 'package:flutter/material.dart';
import 'models/referral_models.dart';
import 'models/gamification_models.dart';
import 'models/seasonal_event.dart';
import 'models/push_notification.dart';
import 'models/ab_testing.dart';
import 'models/premium_conversion.dart';
import 'services/growth_service.dart';
import 'growth_repository.dart';

class GrowthController extends ChangeNotifier {
  final GrowthService _service = GrowthService();
  final GrowthRepository _repository = GrowthRepository();

  ReferralCode? _referralCode;
  ReferralStats _referralStats = ReferralStats.empty();
  UserProgress _userProgress = UserProgress.empty();
  List<SeasonalEvent> _seasonalEvents = [];
  List<PushNotification> _notifications = [];
  List<ABTest> _abTests = [];
  SmartPaywall? _paywall;
  FreeTrial? _freeTrial;
  bool _isLoading = false;

  ReferralCode? get referralCode => _referralCode;
  ReferralStats get referralStats => _referralStats;
  UserProgress get userProgress => _userProgress;
  List<SeasonalEvent> get seasonalEvents => _seasonalEvents;
  List<PushNotification> get notifications => _notifications;
  List<ABTest> get abTests => _abTests;
  SmartPaywall? get paywall => _paywall;
  FreeTrial? get freeTrial => _freeTrial;
  bool get isLoading => _isLoading;

  List<UserLevel> get allLevels => _service.getAllLevels();
  List<AchievementBadge> get allBadges => _service.getAllBadges();
  List<NotificationTemplate> get smartTemplates => _service.getSmartTemplates();

  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _referralCode = await _service.generateReferralCode(userId);
      _referralStats = await _service.getReferralStats(userId);
      _userProgress = await _service.getUserProgress(userId);
      _seasonalEvents = await _service.getSeasonalEvents();
      _notifications = await _service.getNotifications(userId);
      _abTests = await _service.getABTests();
      _paywall = await _service.getSmartPaywall(userId);

      final stats = await _repository.getGrowthStats();
      _userProgress = _userProgress.copyWith(
        totalXp: stats['totalXp'] ?? _userProgress.totalXp,
        currentLevel: _safeInt(stats['level']) ?? _userProgress.currentLevel,
        streak: stats['currentStreak'] ?? _userProgress.streak,
      );
    } catch (e) {
      debugPrint('Error initializing growth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyReferralCode(String code, String userId, String userName) async {
    _isLoading = true;
    notifyListeners();

    final referral = await _service.applyReferralCode(code, userId, userName);
    if (referral != null) {
      _referralStats = ReferralStats(
        totalReferrals: _referralStats.totalReferrals + 1,
        successfulReferrals: _referralStats.successfulReferrals + 1,
        totalGemsEarned: _referralStats.totalGemsEarned + 500,
        totalPremiumDaysEarned: _referralStats.totalPremiumDaysEarned + 7,
        referrals: [..._referralStats.referrals, referral],
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addXp(String userId, int xp) async {
    await _service.addXp(userId, xp);
    _userProgress = await _service.getUserProgress(userId);
    notifyListeners();
  }

  Future<void> joinEvent(String eventId) async {
    final index = _seasonalEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _seasonalEvents[index] = _seasonalEvents[index].copyWith(isJoined: true);
      await _service.saveSeasonalEvents(_seasonalEvents);
      notifyListeners();
    }
  }

  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  ABTestVariant getVariant(String testId, String userId) {
    return _service.getVariant(testId, userId);
  }

  Future<void> startFreeTrial(String userId) async {
    _isLoading = true;
    notifyListeners();

    _freeTrial = await _service.startFreeTrial(userId);

    _isLoading = false;
    notifyListeners();
  }

  int? _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
