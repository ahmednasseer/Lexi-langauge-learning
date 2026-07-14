import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/lessons/screens/lessons_screen.dart';
import '../../features/lessons/screens/lesson_detail_screen.dart';
import '../../features/ai_tutor/ai_tutor_screen.dart';
import '../../features/pronunciation/pronunciation_screen.dart';
import '../../features/gamification/gamification_screen.dart';
import '../../features/subscription/premium_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/lessons/models/lesson_model.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson-detail';
  static const String aiTutor = '/ai-tutor';
  static const String pronunciation = '/pronunciation';
  static const String gamification = '/gamification';
  static const String premium = '/premium';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case auth:
        return _buildRoute(const AuthScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case lessons:
        return _buildRoute(const LessonsScreen(), settings);
      case lessonDetail:
        final lesson = settings.arguments as LessonModel;
        return _buildRoute(LessonDetailScreen(lesson: lesson), settings);
      case aiTutor:
        return _buildRoute(const AiTutorScreen(), settings);
      case pronunciation:
        return _buildRoute(const PronunciationScreen(), settings);
      case gamification:
        return _buildRoute(const GamificationScreen(), settings);
      case premium:
        return _buildRoute(const PremiumScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
