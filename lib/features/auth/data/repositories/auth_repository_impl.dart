import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _userKey = 'user_data';

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final model = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
      isPremium: user.isPremium,
      xp: user.xp,
      level: user.level,
      streak: user.streak,
    );
    await prefs.setString(_userKey, jsonEncode(model.toJson()));
  }

  @override
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      final user = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? email,
        photoUrl: firebaseUser.photoURL,
      );
      await saveUser(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<User?> signUp(String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      await firebaseUser.updateDisplayName(name);

      final user = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        photoUrl: firebaseUser.photoURL,
      );
      await saveUser(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<User?> signInAsGuest() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      final user = UserModel(id: firebaseUser.uid, name: 'Guest', email: '');
      await saveUser(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await deleteUser();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<User?> getCurrentFirebaseUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  @override
  User? getCurrentUserSync() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final user = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
      );
      await saveUser(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  @override
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  Exception _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Wrong password provided');
      case 'email-already-in-use':
        return Exception('Email is already registered');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'too-many-requests':
        return Exception('Too many attempts. Try again later');
      case 'user-disabled':
        return Exception('This account has been disabled');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
