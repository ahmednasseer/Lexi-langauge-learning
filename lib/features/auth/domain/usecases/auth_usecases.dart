import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User?> call(String email, String password) async {
    return await repository.signInWithEmail(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> call(String name, String email, String password) async {
    return await repository.signUp(name, email, password);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}

class GuestLoginUseCase {
  final AuthRepository repository;

  GuestLoginUseCase(this.repository);

  Future<User?> call() async {
    return await repository.signInAsGuest();
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    await repository.resetPassword(email);
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentFirebaseUser();
  }
}

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<User?> call() async {
    return await repository.signInWithGoogle();
  }
}

class SendEmailVerificationUseCase {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  Future<void> call() async {
    await repository.sendEmailVerification();
  }
}

class CheckEmailVerifiedUseCase {
  final AuthRepository repository;

  CheckEmailVerifiedUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isEmailVerified();
  }
}

class ReloadUserUseCase {
  final AuthRepository repository;

  ReloadUserUseCase(this.repository);

  Future<void> call() async {
    await repository.reloadUser();
  }
}
