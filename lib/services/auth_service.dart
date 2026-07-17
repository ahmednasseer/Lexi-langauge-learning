import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/user_model.dart';
import 'api_service.dart';
import 'analytics_service.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final ApiService _api = ApiService();
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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
    _firebaseAvailable = true;

    _api.onUnauthorized = _handleUnauthorizedRefresh;

    _firebaseAuth.authStateChanges().listen((fb.User? user) async {
      if (user != null && _currentUser != null && user.uid == _currentUser!.id) {
        try {
          final token = await user.getIdToken();
          if (token != null) _api.setToken(token);
        } catch (e) {
          debugPrint('Token refresh failed: $e');
        }
      }
    });
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      if (!_firebaseAvailable) return false;
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser != null) {
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? email.split('@').first,
          email: fbUser.email ?? email,
          level: 'A1',
          xp: 0,
          streak: 0,
          createdAt: DateTime.now(),
        );
        await _syncToken(fbUser);
        await _saveUser();
        AnalyticsService.instance.logLogin(method: 'email');
        return true;
      }
      return false;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      if (!_firebaseAvailable) return false;
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser != null) {
        await fbUser.updateDisplayName(name);
        _currentUser = UserModel(
          id: fbUser.uid,
          name: name,
          email: fbUser.email ?? email,
          level: 'A1',
          xp: 0,
          streak: 0,
          createdAt: DateTime.now(),
        );
        await _syncToken(fbUser);
        await _saveUser();
        AnalyticsService.instance.logLogin(method: 'email_signup');
        return true;
      }
      return false;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      if (!_firebaseAvailable) return false;

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;
      if (fbUser != null) {
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
          level: 'A1',
          xp: 0,
          streak: 0,
          createdAt: DateTime.now(),
        );
        await _syncToken(fbUser);
        await _saveUser();
        AnalyticsService.instance.logLogin(method: 'google');
        return true;
      }
      return false;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('Google sign-in Firebase error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      if (!_firebaseAvailable) return false;

      final appleProvider = fb.AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await _firebaseAuth.signInWithProvider(appleProvider);
      final fbUser = userCredential.user;
      if (fbUser != null) {
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
          level: 'A1',
          xp: 0,
          streak: 0,
          createdAt: DateTime.now(),
        );
        await _syncToken(fbUser);
        await _saveUser();
        AnalyticsService.instance.logLogin(method: 'apple');
        return true;
      }
      return false;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('Apple sign-in Firebase error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      return false;
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
    AnalyticsService.instance.logLogin(method: 'guest');
  }

  Future<void> signOut() async {
    try {
      if (_firebaseAvailable) {
        await _googleSignIn.signOut();
        await _firebaseAuth.signOut();
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
    _currentUser = null;
    _isGuest = false;
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('auth_token');
    await prefs.remove('is_guest');
  }

  Future<void> _syncToken(fb.User fbUser) async {
    try {
      final token = await fbUser.getIdToken();
      if (token != null) {
        _api.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }
    } catch (e) {
      debugPrint('Token sync failed: $e');
    }
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

  Future<void> refreshIdToken() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      try {
        final token = await fbUser.getIdToken(true);
        if (token != null) _api.setToken(token);
      } catch (e) {
        debugPrint('Token refresh failed: $e');
      }
    }
  }

  /// Called by ApiService on HTTP 401. Refreshes the Firebase ID token and
  /// returns true if a fresh token was obtained (so the request can be retried).
  Future<bool> _handleUnauthorizedRefresh() async {
    if (!_firebaseAvailable) return false;
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      _api.clearToken();
      return false;
    }
    try {
      final token = await fbUser.getIdToken(true);
      if (token != null) {
        _api.setToken(token);
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh on 401 failed: $e');
    }
    _api.clearToken();
    return false;
  }

  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
  }
}
