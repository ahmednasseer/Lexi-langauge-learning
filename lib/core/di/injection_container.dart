import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/profile/presentation/bloc/settings_cubit.dart';
import '../../features/profile/presentation/bloc/avatar_cubit.dart';
import '../../features/learning_progress/data/repositories/progress_repository_impl.dart';
import '../../features/learning_progress/domain/repositories/progress_repository.dart';
import '../../features/learning_progress/presentation/bloc/progress_cubit.dart';
import '../../features/lessons/lesson_repository.dart';
import '../../features/gamification/data/repositories/streak_repository_impl.dart';
import '../../features/gamification/data/repositories/achievement_repository_impl.dart';
import '../../features/gamification/data/repositories/daily_mission_repository_impl.dart';
import '../../features/gamification/domain/repositories/streak_repository.dart';
import '../../features/gamification/domain/repositories/achievement_repository.dart';
import '../../features/gamification/domain/repositories/daily_mission_repository.dart';
import '../../features/gamification/presentation/bloc/streak_cubit.dart';
import '../../features/gamification/presentation/bloc/achievement_cubit.dart';
import '../../features/gamification/presentation/bloc/daily_mission_cubit.dart';
import '../../features/gamification/presentation/bloc/gamification_cubit.dart';
import '../../features/social/data/repositories/post_repository_impl.dart';
import '../../features/social/data/repositories/like_repository_impl.dart';
import '../../features/social/data/repositories/comment_repository_impl.dart';
import '../../features/social/data/repositories/friend_repository_impl.dart';
import '../../features/social/domain/repositories/post_repository.dart';
import '../../features/social/domain/repositories/like_repository.dart';
import '../../features/social/domain/repositories/comment_repository.dart';
import '../../features/social/domain/repositories/friend_repository.dart';
import '../../features/social/presentation/bloc/feed_cubit.dart';
import '../../features/social/presentation/bloc/like_cubit.dart';
import '../../features/social/presentation/bloc/comment_cubit.dart';
import '../../features/social/presentation/bloc/friend_cubit.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/bloc/wallet_cubit.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/presentation/bloc/inventory_cubit.dart';
import '../../features/store/data/repositories/store_repository_impl.dart';
import '../../features/store/domain/repositories/store_repository.dart';
import '../../features/store/domain/services/purchase_service.dart';
import '../../features/store/presentation/bloc/store_cubit.dart';
import '../../features/premium/data/repositories/premium_repository_impl.dart';
import '../../features/premium/domain/repositories/premium_repository.dart';
import '../../features/premium/domain/services/premium_verification_service.dart';
import '../../features/premium/presentation/bloc/premium_cubit.dart';
import '../../features/speaking/speaking_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Auth Feature
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));

  // Profile Feature
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SharedPreferences>()),
  );
  getIt.registerFactory<AvatarCubit>(() => AvatarCubit());

  // Learning Progress Feature
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(),
  );
  getIt.registerLazySingleton<LessonRepository>(() => LessonRepository());
  getIt.registerFactory<ProgressCubit>(
    () => ProgressCubit(getIt<ProgressRepository>()),
  );

  // Gamification Feature
  getIt.registerLazySingleton<StreakRepository>(() => StreakRepositoryImpl());
  getIt.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(),
  );
  getIt.registerLazySingleton<DailyMissionRepository>(
    () => DailyMissionRepositoryImpl(),
  );
  getIt.registerFactory<StreakCubit>(
    () => StreakCubit(getIt<StreakRepository>()),
  );
  getIt.registerFactory<AchievementCubit>(
    () => AchievementCubit(getIt<AchievementRepository>()),
  );
  getIt.registerFactory<DailyMissionCubit>(
    () => DailyMissionCubit(getIt<DailyMissionRepository>()),
  );
  getIt.registerFactory<GamificationCubit>(
    () => GamificationCubit(
      progressRepository: getIt<ProgressRepository>(),
      streakCubit: getIt<StreakCubit>(),
      achievementCubit: getIt<AchievementCubit>(),
      dailyMissionCubit: getIt<DailyMissionCubit>(),
    ),
  );

  // Social Feature
  getIt.registerLazySingleton<PostRepository>(() => PostRepositoryImpl());
  getIt.registerLazySingleton<LikeRepository>(() => LikeRepositoryImpl());
  getIt.registerLazySingleton<CommentRepository>(() => CommentRepositoryImpl());
  getIt.registerLazySingleton<FriendRepository>(() => FriendRepositoryImpl());
  getIt.registerFactory<FeedCubit>(() => FeedCubit(getIt<PostRepository>()));
  getIt.registerFactory<LikeCubit>(() => LikeCubit(getIt<LikeRepository>()));
  getIt.registerFactory<CommentCubit>(
    () => CommentCubit(getIt<CommentRepository>()),
  );
  getIt.registerFactory<FriendCubit>(
    () => FriendCubit(getIt<FriendRepository>()),
  );

  // Wallet Feature
  getIt.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl());
  getIt.registerFactory<WalletCubit>(
    () => WalletCubit(getIt<WalletRepository>()),
  );

  // Inventory Feature
  getIt.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(),
  );
  getIt.registerFactory<InventoryCubit>(
    () => InventoryCubit(getIt<InventoryRepository>()),
  );

  // Store Feature
  getIt.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl());
  getIt.registerLazySingleton<PurchaseService>(() => PurchaseService());
  getIt.registerFactory<StoreCubit>(
    () => StoreCubit(
      storeRepository: getIt<StoreRepository>(),
      purchaseService: getIt<PurchaseService>(),
    ),
  );

  // Premium Feature
  getIt.registerLazySingleton<PremiumRepository>(() => PremiumRepositoryImpl());
  getIt.registerLazySingleton<PremiumVerificationService>(
    () => PremiumVerificationService(),
  );
  getIt.registerFactory<PremiumCubit>(
    () => PremiumCubit(getIt<PremiumRepository>()),
  );

  // Speaking Feature
  getIt.registerLazySingleton<SpeakingRepository>(
    () => SpeakingRepository(getIt<SharedPreferences>()),
  );
}
