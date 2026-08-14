import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User?> getCurrentFirebaseUser();
  User? getCurrentUserSync();
  Future<void> saveUser(User user);
  Future<void> deleteUser();
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUp(String name, String email, String password);
  Future<User?> signInAsGuest();
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  Future<void> reloadUser();
}
