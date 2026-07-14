import 'package:flutter/material.dart';
import 'user_preferences.dart';
import '../../shared/models/user_model.dart';
import '../../services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  final UserPreferences _prefs;
  final AuthService _authService;

  ProfileController(this._prefs, this._authService);

  bool _isDarkMode = false;
  String _learningLanguage = 'English';
  String _nativeLanguage = '';
  bool _notificationsEnabled = true;
  int _dailyGoal = 50;

  bool get isDarkMode => _isDarkMode;
  String get learningLanguage => _learningLanguage;
  String get nativeLanguage => _nativeLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  int get dailyGoal => _dailyGoal;
  UserModel? get currentUser => _authService.currentUser;

  Future<void> loadPreferences() async {
    _isDarkMode = await _prefs.getDarkMode();
    _learningLanguage = await _prefs.getLearningLanguage();
    _nativeLanguage = await _prefs.getNativeLanguage();
    _notificationsEnabled = await _prefs.getNotificationsEnabled();
    _dailyGoal = await _prefs.getDailyGoal();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setLearningLanguage(String lang) async {
    _learningLanguage = lang;
    await _prefs.setLearningLanguage(lang);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _prefs.setNotificationsEnabled(_notificationsEnabled);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
