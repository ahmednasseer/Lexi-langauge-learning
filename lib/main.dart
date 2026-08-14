import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/user_progress_service.dart';
import 'core/utils/error_logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorLogger.init();

  FlutterError.onError = (details) {
    ErrorLogger.logError(details.exceptionAsString(), stackTrace: details.stack);
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLogger.logError(error.toString(), stackTrace: stack);
    return true;
  };

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('Firebase init done');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    ErrorLogger.logError('Firebase init failed: $e');
  }

  // Setup Dependency Injection
  debugPrint('DI: starting');
  await setupDependencies();
  debugPrint('DI: done');

  // Initialize Services
  debugPrint('ConnectivityService: starting');
  await ConnectivityService().init();
  debugPrint('ConnectivityService: done');

  debugPrint('AuthService: starting');
  await AuthService.instance.init();
  debugPrint('AuthService: done');

  debugPrint('AnalyticsService: starting');
  await AnalyticsService.instance.init();
  debugPrint('AnalyticsService: done');

  debugPrint('NotificationService: starting');
  await NotificationService.instance.init();
  debugPrint('NotificationService: done');

  debugPrint('UserProgressService: starting');
  await UserProgressService().initialize();
  debugPrint('UserProgressService: done');

  debugPrint('All init done, running app');

  // App UI Settings
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LexiApp());
}

class LexiApp extends StatelessWidget {
  const LexiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
