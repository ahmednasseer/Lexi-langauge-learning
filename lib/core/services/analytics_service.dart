import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  static AnalyticsService get instance => _instance;
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final List<AnalyticsEvent> _localEvents = [];
  bool _initialized = false;

  Future<void> init() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      _initialized = true;
    } catch (e) {
      debugPrint('Analytics init error: $e');
    }
  }

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    _localEvents.add(AnalyticsEvent(
      name: name,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    ));

    if (_initialized) {
      try {
        _analytics.logEvent(name: name, parameters: parameters?.cast<String, Object>());
      } catch (e) {
        debugPrint('Analytics log error: $e');
      }
    }
  }

  void logLogin({required String method}) {
    logEvent('login', parameters: {'method': method});
    if (_initialized) {
      try {
        _analytics.logLogin(loginMethod: method);
      } catch (_) {}
    }
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {'screen': screenName});
    if (_initialized) {
      try {
        _analytics.logScreenView(screenName: screenName);
      } catch (_) {}
    }
  }

  void logLessonStart(String lessonId, {String? level}) {
    logEvent('lesson_start', parameters: {'lessonId': lessonId, 'level': level});
  }

  void logLessonComplete(String lessonId, double score, {int? xpEarned}) {
    logEvent('lesson_complete', parameters: {'lessonId': lessonId, 'score': score, 'xpEarned': xpEarned});
  }

  void logXpEarned(int amount, {String? source}) {
    logEvent('xp_earned', parameters: {'amount': amount, 'source': source});
  }

  void logAiChatMessage({String? category}) {
    logEvent('ai_chat_message', parameters: {'category': category});
  }

  void logSubscription(String planId, {String? action}) {
    logEvent('subscription', parameters: {'plan': planId, 'action': action});
  }

  void logPremiumPurchase(String planId, double amount) {
    logEvent('premium_purchase', parameters: {'plan': planId, 'amount': amount});
  }

  void logStreakUpdate(int streak) {
    logEvent('streak_update', parameters: {'streak': streak});
  }

  void logFlashcardReview(String wordId, bool correct) {
    logEvent('flashcard_review', parameters: {'wordId': wordId, 'correct': correct});
  }

  void logSpeakingPractice({String? scenarioId, double? score}) {
    logEvent('speaking_practice', parameters: {'scenarioId': scenarioId, 'score': score});
  }

  void logCommunityPost(String postId) {
    logEvent('community_post', parameters: {'postId': postId});
  }

  void logLiveLearningJoin(String roomId) {
    logEvent('live_learning_join', parameters: {'roomId': roomId});
  }

  void logGemPurchase(String itemId, int gems) {
    logEvent('gem_purchase', parameters: {'itemId': itemId, 'gems': gems});
  }

  void logSearch({required String query, int? resultCount}) {
    logEvent('search', parameters: {'query': query, 'resultCount': resultCount});
  }

  void logError(String error, {String? screen, String? action}) {
    logEvent('error', parameters: {'error': error, 'screen': screen, 'action': action});
  }

  void setUserId(String? userId) {
    if (_initialized) {
      try {
        _analytics.setUserId(id: userId);
      } catch (_) {}
    }
  }

  void setUserProperty({required String name, required String? value}) {
    if (_initialized) {
      try {
        _analytics.setUserProperty(name: name, value: value);
      } catch (_) {}
    }
  }

  List<AnalyticsEvent> get events => List.unmodifiable(_localEvents);
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });
}
