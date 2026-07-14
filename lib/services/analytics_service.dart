class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final List<AnalyticsEvent> _events = [];
  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    _events.add(AnalyticsEvent(
      name: name,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    ));
  }

  void logScreenView(String screenName) => logEvent('screen_view', parameters: {'screen': screenName});
  void logLessonStart(String lessonId) => logEvent('lesson_start', parameters: {'lessonId': lessonId});
  void logLessonComplete(String lessonId, double score) => logEvent('lesson_complete', parameters: {'lessonId': lessonId, 'score': score});
  void logXpEarned(int amount) => logEvent('xp_earned', parameters: {'amount': amount});
  void logAiChatMessage() => logEvent('ai_chat_message');
  void logSubscription(String planId) => logEvent('subscription', parameters: {'plan': planId});
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const AnalyticsEvent({required this.name, required this.parameters, required this.timestamp});
}
