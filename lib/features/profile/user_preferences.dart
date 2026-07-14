import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _darkModeKey = 'dark_mode';
  static const _languageKey = 'learning_language';
  static const _nativeLanguageKey = 'native_language';
  static const _notificationsKey = 'notifications_enabled';
  static const _dailyGoalKey = 'daily_goal';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<String> getLearningLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  Future<void> setLearningLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  Future<String> getNativeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nativeLanguageKey) ?? '';
  }

  Future<void> setNativeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nativeLanguageKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? 50;
  }

  Future<void> setDailyGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, value);
  }
}
