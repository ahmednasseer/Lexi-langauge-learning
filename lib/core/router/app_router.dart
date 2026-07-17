import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/lessons/screens/lessons_screen.dart';
import '../../features/lessons/screens/lesson_detail_screen.dart';
import '../../features/ai_tutor/ai_tutor_screen.dart';
import '../../features/ai_coach/ai_coach_screen.dart';
import '../../features/pronunciation/pronunciation_screen.dart';
import '../../features/gamification/gamification_screen.dart';
import '../../features/subscription/premium_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings.dart';
import '../../features/roadmap/roadmap_screen.dart';
import '../../features/flashcards/flashcard_screen.dart';
import '../../features/speaking/speaking_screen.dart';
import '../../features/daily_missions/daily_missions_screen.dart';
import '../../features/passport/passport_screen.dart';
import '../../features/certificates/certificates_screen.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/ai_learning/ai_learning_screen.dart';
import '../../features/goethe/goethe_exam_screen.dart';
import '../../features/advanced_speaking/advanced_speaking_screen.dart';
import '../../features/live_learning/live_learning_screen.dart';
import '../../features/growth/growth_screen.dart';
import '../../features/avatar_shop/avatar_shop_screen.dart';
import '../../features/avatar_editor/avatar_editor_screen.dart';
import '../../features/workshop/frames_workshop_screen.dart';
import '../../features/workshop/backgrounds_shop_screen.dart';
import '../../features/friends/friends_screen.dart';
import '../../features/audio/audio_lessons_screen.dart';
import '../../features/accounts/active_accounts_screen.dart';
import '../../features/events/events_screen.dart';
import '../../features/streak/daily_streak_screen.dart';
import '../../features/quests/daily_quests_screen.dart';
import '../../features/character/character_selection_screen.dart';
import '../../features/store/gem_store_screen.dart';
import '../../features/payment/payment_methods_screen.dart';
import '../../features/payment/success_screen.dart';
import '../../features/account/account_screen.dart';
import '../../features/offers/limited_offer_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/language/language_mixer_screen.dart';
import '../../features/notes/saved_notes_screen.dart';
import '../../features/inbox/inbox_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/premium/premium_offer_screen.dart';
import '../../features/store/store_screen.dart';
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
  static const String aiCoach = '/ai-coach';
  static const String pronunciation = '/pronunciation';
  static const String gamification = '/gamification';
  static const String premium = '/premium';
  static const String profile = '/profile';
  static const String roadmap = '/roadmap';
  static const String flashcards = '/flashcards';
  static const String speaking = '/speaking';
  static const String dailyMissions = '/daily-missions';
  static const String passport = '/passport';
  static const String certificates = '/certificates';
  static const String achievements = '/achievements';
  static const String community = '/community';
  static const String aiLearning = '/ai-learning';
  static const String goethe = '/goethe';
  static const String advancedSpeaking = '/advanced-speaking';
  static const String liveLearning = '/live-learning';
  static const String growth = '/growth';
  static const String appSettings = '/settings';
  static const String avatarShop = '/avatar-shop';
  static const String avatarEditor = '/avatar-editor';
  static const String framesWorkshop = '/frames-workshop';
  static const String backgroundsShop = '/backgrounds-shop';
  static const String friends = '/friends';
  static const String audioLessons = '/audio-lessons';
  static const String activeAccounts = '/active-accounts';
  static const String events = '/events';
  static const String dailyStreak = '/daily-streak';
  static const String dailyQuests = '/daily-quests';
  static const String characterSelection = '/character-selection';
  static const String gemStore = '/gem-store';
  static const String paymentMethods = '/payment-methods';
  static const String success = '/success';
  static const String account = '/account';
  static const String limitedOffer = '/limited-offer';
  static const String support = '/support';
  static const String languageMixer = '/language-mixer';
  static const String savedNotes = '/saved-notes';
  static const String inbox = '/inbox';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String premiumOffer = '/premium-offer';
  static const String store = '/store';

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
      case aiCoach:
        return _buildRoute(const AiCoachScreen(), settings);
      case pronunciation:
        return _buildRoute(const PronunciationScreen(), settings);
      case gamification:
        return _buildRoute(const GamificationScreen(), settings);
      case premium:
        return _buildRoute(const PremiumScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      case roadmap:
        return _buildRoute(const RoadmapScreen(), settings);
      case flashcards:
        return _buildRoute(const FlashcardScreen(), settings);
      case speaking:
        return _buildRoute(const SpeakingScreen(), settings);
      case dailyMissions:
        return _buildRoute(const DailyMissionsScreen(), settings);
      case passport:
        return _buildRoute(const PassportScreen(), settings);
      case certificates:
        return _buildRoute(const CertificatesScreen(), settings);
      case achievements:
        return _buildRoute(const AchievementsScreen(), settings);
      case community:
        return _buildRoute(const CommunityScreen(), settings);
      case aiLearning:
        return _buildRoute(const AILearningScreen(), settings);
      case goethe:
        return _buildRoute(const GoetheExamScreen(), settings);
      case advancedSpeaking:
        return _buildRoute(const AdvancedSpeakingScreen(), settings);
      case liveLearning:
        return _buildRoute(const LiveLearningScreen(), settings);
      case growth:
        return _buildRoute(const GrowthScreen(), settings);
      case appSettings:
        return _buildRoute(const SettingsScreen(), settings);
      case avatarShop:
        return _buildRoute(const AvatarShopScreen(), settings);
      case avatarEditor:
        return _buildRoute(const AvatarEditorScreen(), settings);
      case framesWorkshop:
        return _buildRoute(const FramesWorkshopScreen(), settings);
      case backgroundsShop:
        return _buildRoute(const BackgroundsShopScreen(), settings);
      case friends:
        return _buildRoute(const FriendsScreen(), settings);
      case audioLessons:
        return _buildRoute(const AudioLessonsScreen(), settings);
      case activeAccounts:
        return _buildRoute(const ActiveAccountsScreen(), settings);
      case events:
        return _buildRoute(const EventsScreen(), settings);
      case dailyStreak:
        return _buildRoute(const DailyStreakScreen(), settings);
      case dailyQuests:
        return _buildRoute(const DailyQuestsScreen(), settings);
      case characterSelection:
        return _buildRoute(const CharacterSelectionScreen(), settings);
      case gemStore:
        return _buildRoute(const GemStoreScreen(), settings);
      case paymentMethods:
        return _buildRoute(const PaymentMethodsScreen(), settings);
      case success:
        return _buildRoute(const SuccessScreen(), settings);
      case account:
        return _buildRoute(const AccountScreen(), settings);
      case limitedOffer:
        return _buildRoute(const LimitedOfferScreen(), settings);
      case support:
        return _buildRoute(const SupportScreen(), settings);
      case languageMixer:
        return _buildRoute(const LanguageMixerScreen(), settings);
      case savedNotes:
        return _buildRoute(const SavedNotesScreen(), settings);
      case inbox:
        return _buildRoute(const InboxScreen(), settings);
      case search:
        return _buildRoute(const SearchScreen(), settings);
      case notifications:
        return _buildRoute(const NotificationsScreen(), settings);
      case premiumOffer:
        return _buildRoute(const PremiumOfferScreen(), settings);
      case store:
        return _buildRoute(const StoreScreen(), settings);
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
