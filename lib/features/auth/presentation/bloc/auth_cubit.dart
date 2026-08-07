import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.id];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;
  late final LogoutUseCase logoutUseCase;
  late final GuestLoginUseCase guestLoginUseCase;
  late final ResetPasswordUseCase resetPasswordUseCase;
  late final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthCubit(this.repository) : super(AuthInitial()) {
    loginUseCase = LoginUseCase(repository);
    registerUseCase = RegisterUseCase(repository);
    logoutUseCase = LogoutUseCase(repository);
    guestLoginUseCase = GuestLoginUseCase(repository);
    resetPasswordUseCase = ResetPasswordUseCase(repository);
    getCurrentUserUseCase = GetCurrentUserUseCase(repository);
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        const AuthError('Login failed');
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(name, email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        const AuthError('Registration failed');
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> signInAsGuest() async {
    emit(AuthLoading());
    try {
      final user = await guestLoginUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        const AuthError('Guest login failed');
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await resetPasswordUseCase(email);
      emit(AuthInitial());
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> checkCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
