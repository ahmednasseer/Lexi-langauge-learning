import 'package:flutter/material.dart';
import '../../shared/models/user_model.dart';
import '../../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService;

  LoginController(this._authService);

  bool _isLoading = false;
  bool _isLogin = true;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLogin => _isLogin;
  String? get error => _error;
  UserModel? get currentUser => _authService.currentUser;

  void toggleMode() {
    _isLogin = !_isLogin;
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(name, email, password);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInAsGuest() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signInAsGuest();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
