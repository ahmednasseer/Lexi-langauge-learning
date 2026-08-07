import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/user_model.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  UserModel _user = UserModel.empty();
  bool _isDarkMode = false;
  bool _isOnboarded = false;
  bool _isLoading = false;

  UserModel get user => _user;
  bool get isDarkMode => _isDarkMode;
  bool get isOnboarded => _isOnboarded;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.isAuthenticated;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.init();
      _isOnboarded = await _authService.getOnboarded();
      _isDarkMode = await StorageService.read<bool>('dark_mode') ?? false;

      if (_authService.currentUser != null) {
        _user = _authService.currentUser!;
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setUser(UserModel user) {
    _user = user;
    StorageService.save('current_user', user.toJson());
    notifyListeners();
  }

  void addXp(int amount) {
    _user = _user.copyWith(
      xp: _user.xp + amount,
      totalXp: _user.totalXp + amount,
      dailyXp: _user.dailyXp + amount,
    );
    StorageService.save('current_user', _user.toJson());
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    StorageService.save('dark_mode', _isDarkMode);
    notifyListeners();
  }

  void setOnboarded() {
    _isOnboarded = true;
    _authService.setOnboarded();
    notifyListeners();
  }
}
