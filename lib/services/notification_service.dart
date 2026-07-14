class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    _initialized = true;
  }

  Future<void> showReminder(String title, String body) async {
    if (!_initialized) await init();
    // TODO: Integrate flutter_local_notifications
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // TODO: Implement scheduled notifications
  }
}
