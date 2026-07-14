import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final ApiService _api = ApiService();
  UserModel? _currentUser;
  bool _isGuest = false;
  bool _firebaseAvailable = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _isGuest;

  Future<void> init() async {
    await _api.init();
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        _isGuest = prefs.getBool('is_guest') ?? false;
      } catch (e) {
        await prefs.remove('current_user');
      }
    }
  }

  void setFirebaseAvailable(bool available) {
    _firebaseAvailable = available;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      if (_firebaseAvailable) {
        // Try Firebase Auth
        // TODO: Implement firebase_auth
      }
      // Fallback to API
      final result = await _api.login(email, password);
      _currentUser = UserModel.fromJson(result['user']);
      await _saveUser();
      _api.setToken(result['accessToken']);
      return true;
    } catch (e) {
      // Offline fallback - create local user
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@').first,
        email: email,
        level: 'A1',
        xp: 0,
        streak: 0,
        createdAt: DateTime.now(),
      );
      _isGuest = false;
      await _saveUser();
      return true;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      if (_firebaseAvailable) {
        // TODO: Implement firebase_auth
      }
      final result = await _api.register(name, email, password);
      _currentUser = UserModel.fromJson(result['user']);
      await _saveUser();
      _api.setToken(result['accessToken']);
      return true;
    } catch (e) {
      // Offline fallback
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        level: 'A1',
        xp: 0,
        streak: 0,
        createdAt: DateTime.now(),
      );
      _isGuest = false;
      await _saveUser();
      return true;
    }
  }

  Future<void> signInAsGuest() async {
    _currentUser = UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User',
      email: '',
      level: 'A1',
      xp: 0,
      streak: 0,
      createdAt: DateTime.now(),
    );
    _isGuest = true;
    await _saveUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
  }

  Future<void> signOut() async {
    _currentUser = null;
    _isGuest = false;
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('auth_token');
    await prefs.remove('is_guest');
  }

  Future<void> updateProfile({String? name, String? level, int? xp}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      level: level,
      xp: xp,
    );
    await _saveUser();
  }

  Future<void> addXp(int amount) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      xp: (_currentUser!.xp) + amount,
    );
    await _saveUser();
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
  }

  Future<bool> getOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarded') ?? false;
  }

  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
  }
}
