import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lexi/main.dart';
import 'package:lexi/core/di/injection_container.dart';
import 'package:lexi/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lexi/features/auth/domain/repositories/auth_repository.dart';
import 'package:lexi/features/auth/domain/entities/user.dart';

class _MockAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;
  @override
  Future<User?> getCurrentFirebaseUser() async => null;
  @override
  User? getCurrentUserSync() => null;
  @override
  Future<void> saveUser(User user) async {}
  @override
  Future<void> deleteUser() async {}
  @override
  Future<User?> signInWithEmail(String email, String password) async => null;
  @override
  Future<User?> signUp(String name, String email, String password) async => null;
  @override
  Future<User?> signInAsGuest() async => null;
  @override
  Future<User?> signInWithGoogle() async => null;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<bool> isEmailVerified() async => false;
  @override
  Future<void> reloadUser() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    getIt.registerLazySingleton<AuthRepository>(() => _MockAuthRepository());
    getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  });

  tearDownAll(() {
    getIt.reset();
  });

  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const LexiApp());
    expect(find.text('Lexi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
