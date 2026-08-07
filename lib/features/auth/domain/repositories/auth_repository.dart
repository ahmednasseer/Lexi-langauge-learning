import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User?> getCurrentFirebaseUser();
  Future<void> saveUser(User user);
  Future<void> deleteUser();
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUp(String name, String email, String password);
  Future<User?> signInAsGuest();
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
