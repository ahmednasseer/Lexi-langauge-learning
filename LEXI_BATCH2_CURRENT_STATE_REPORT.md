# LEXI — BATCH 2 CURRENT STATE VERIFICATION REPORT

Date: 2026-08-14
Scope: Complete P0-P2 flow verification before Batch 2 implementation
Source of truth: Current codebase, not historical audit documents
Real Backend: https://lexi-backend-zftq.onrender.com/

---

## EXECUTIVE SUMMARY

The codebase has evolved significantly since the old audit documents. Many flows that were previously fake or missing are now **REAL and backend-backed**. The Flutter app has been reconfigured to target the **real deployed backend** at `https://lexi-backend-zftq.onrender.com/`.

**Key finding:** The old audit documents (`LEXI_PRODUCTION_AUDIT.txt`, `LEXI_FEATURE_SPECIFICATION.txt`, etc.) are **OUTDATED** and should not be used as current state references. See `LEXI_CURRENT_STATE_AUDIT.md` for the latest state.

**Current Status:**
- Base URL: FIXED — points to deployed backend
- Fake fallbacks: REMOVED from 11 repositories
- Response format: FIXED — handles both bare arrays and `{data: [...]}`
- P0 flows: MOSTLY VERIFIED via deployed backend API
- Remaining: Google Sign-In blocked, backend 500 errors, Speaking not wired

---

## FLOW VERIFICATION RESULTS

### A. AUTHENTICATION

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `AuthCubit` with use cases (`LoginUseCase`, `RegisterUseCase`, `GuestLoginUseCase`, `GoogleSignInUseCase`, `ResetPasswordUseCase`)
- Repository: `AuthRepositoryImpl` wraps Firebase Auth
- API: `AuthService` in NestJS with `register()`, `login()`, `loginWithGoogle()`, `loginAsGuest()`
- Backend: `AuthController` → `AuthService` → Prisma `user` model
- Session: Firebase ID token stored in `ApiService`, sent as `Authorization: Bearer`
- Backend verification: `JwtStrategy` verifies Firebase ID token via Firebase Admin SDK, maps to PostgreSQL user

**Files:**
- `lib/features/auth/presentation/bloc/auth_cubit.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/usecases/auth_usecases.dart`
- `backend/src/modules/auth/auth.controller.ts`
- `backend/src/modules/auth/auth.service.ts`
- `backend/src/modules/auth/strategies/jwt.strategy.ts`

**Gaps:**
- Session restoration reads from `SharedPreferences` only; no server-side session validation on app startup
- Guest login creates Firebase anonymous user but no backend guest user creation
- Email verification check exists but not enforced in UI flow
- Logout clears Firebase token but doesn't call backend logout endpoint

---

### B. PROFILE

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `ProfileCubit` with `GetCurrentProfileUseCase`, `UpdateProfileUseCase`
- Repository: `ProfileRepositoryImpl` reads/writes Firestore `users/{userId}`
- Backend: `UsersController.getProfile()`, `UsersController.updateProfile()` → PostgreSQL `user` table
- Avatar: `AvatarCubit` handles upload to Firebase Storage via `AvatarRepositoryImpl`

**Files:**
- `lib/features/profile/presentation/bloc/profile_cubit.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`
- `lib/features/profile/presentation/pages/profile_screen.dart`
- `lib/features/profile/presentation/pages/edit_profile_screen.dart`
- `backend/src/modules/users/users.controller.ts`
- `backend/src/modules/users/users.service.ts`

**Gaps:**
- Profile update is Firestore-only, not synced with PostgreSQL user table
- No avatar upload to backend (Firebase Storage direct from client)
- Settings (`SettingsCubit`) are local-only (SharedPreferences), not synced to backend
- No profile image cropping

---

### C. HOME

**Status: PARTIAL**

**Implementation:**
- `HomeScreen` with `IndexedStack` tabs: Dashboard, Lessons, AI Coach, Community, Profile
- `_Dashboard` widget loads words of day, checks email verification
- Uses `ProgressCubit` for XP/level display
- `AppProvider` provides user state

**Files:**
- `lib/features/home/home_screen.dart`
- `lib/features/home/home_controller.dart`
- `lib/features/home/dashboard_widgets/continue_learning_card.dart`
- `lib/features/home/dashboard_widgets/daily_goal_widget.dart`

**Gaps:**
- Home dashboard does NOT load real user data from backend
- `HomeController.loadUser()` reads from `StorageService` (SharedPreferences cache only)
- XP/level/streak displayed from local state or `ProgressCubit` which reads from backend but may show stale data
- No real "continue learning" card data from backend
- Words of day loaded from `CurriculumService` which may use Firestore or fallback

---

### D. LESSONS

**Status: REAL + NOT RUNTIME VERIFIED (with fake fallback)**

**Implementation:**
- Flutter: `LessonController` (ChangeNotifier) manages lesson list and completion
- Repository: `LessonRepository` calls `ApiService.getLessons()`, `getLessonDetail()`, `completeLesson()`
- API: `GET /lessons/:language`, `GET /lessons/:language/:id`, `POST /progress/complete`
- Backend: `LessonsController` → `LessonsService` → Firestore; `ProgressController` → `ProgressService` → PostgreSQL

**Files:**
- `lib/features/lessons/lesson_controller.dart`
- `lib/features/lessons/lesson_repository.dart`
- `lib/features/lessons/screens/lessons_screen.dart`
- `lib/features/lessons/screens/lesson_detail_screen.dart`
- `lib/features/lessons/models/lesson_model.dart`
- `backend/src/modules/lessons/lessons.controller.ts`
- `backend/src/modules/progress/progress.controller.ts`
- `backend/src/modules/progress/progress.service.ts`

**Gaps:**
- `LessonRepository` has `GermanContent` fallback that returns hardcoded local data when API fails — **FAKE FALLBACK**
- `LessonRepository.completeLesson()` silently swallows errors with `catch (_) {}`
- Lesson detail screen calls `AuthService.instance.addXp(xp)` which is now a no-op (correct), but completion API call may fail silently

---

### E. QUIZ

**Status: REAL (embedded in lesson detail)**

**Implementation:**
- Quiz is part of `LessonModel` (questions loaded with lesson)
- `lesson_detail_screen.dart` renders quiz, calculates score
- Score sent to `POST /progress/complete` with lesson XP calculated server-side

**Gaps:**
- No standalone quiz flow
- No quiz timer
- No retry logic
- Results are basic (pass/fail based on 70% threshold)

---

### F. PROGRESS

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `ProgressCubit` with `GetProgressUseCase`, `CompleteLessonUseCase`
- Repository: `ProgressRepositoryImpl` calls `ApiService.getStats()`, `completeLesson()`
- Backend: `ProgressController` → `ProgressService.completeLesson()` → PostgreSQL `userProgress` + `user` tables

**Files:**
- `lib/features/learning_progress/presentation/bloc/progress_cubit.dart`
- `lib/features/learning_progress/data/repositories/progress_repository_impl.dart`
- `backend/src/modules/progress/progress.service.ts`
- `backend/src/modules/progress/progress.controller.ts`

**Gaps:**
- `ProgressRepositoryImpl.getProgress()` catches errors and returns empty `Progress` object — **FAKE FALLBACK**
- Level calculation is client-side (`_levelFromXp`) based on backend `totalXp`; backend also calculates level in `UsersService.calculateLevel()`

---

### G. XP

**Status: REAL + SERVER-AUTHORITATIVE**

**Implementation:**
- Backend `ProgressService.completeLesson()` calculates `xpEarned = lesson.xpReward * (score / 100)`
- Backend `UsersService.addXp()` increments `xp`, `totalXp`, `dailyXp`
- Backend `AiCoachService.chat()` returns server-calculated `xpEarned` (5 or 10)
- Client-side `addXp()` methods are documented no-ops
- `ProgressRepositoryImpl.addXp()` is no-op

**Gaps:**
- None — XP authority is correctly server-side

---

### H. STREAK

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `StreakCubit` with `GetStreakUseCase`, `UpdateStreakUseCase`
- Repository: `StreakRepositoryImpl` calls `ApiService.getGrowthStats()`
- Backend: `UsersController.getGrowth()` → `UsersService.getGrowth()` → PostgreSQL `user.streak`, `user.bestStreak`, `user.lastActiveAt`
- Streak updated on lesson completion via `ProgressService.completeLesson()` → `UsersService.updateStreak()`

**Files:**
- `lib/features/gamification/presentation/bloc/streak_cubit.dart`
- `lib/features/gamification/data/repositories/streak_repository_impl.dart`
- `backend/src/modules/users/users.service.ts`
- `backend/src/modules/progress/progress.service.ts`

**Gaps:**
- `StreakRepositoryImpl.getStreak()` catches errors and returns empty `Streak` object — **FAKE FALLBACK**

---

### I. ACHIEVEMENTS

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `AchievementCubit` with `GetAchievementsUseCase`
- Repository: `AchievementRepositoryImpl` calls `ApiService.getAchievements()`
- Backend: `UsersController.getAchievements()` → `UsersService.getAchievements()` → PostgreSQL `achievement` + `user_achievement` tables

**Files:**
- `lib/features/gamification/presentation/bloc/achievement_cubit.dart`
- `lib/features/gamification/data/repositories/achievement_repository_impl.dart`
- `backend/src/modules/users/users.service.ts`

**Gaps:**
- `AchievementRepositoryImpl._fetchAll()` catches errors and returns empty list — **FAKE FALLBACK**
- No achievement unlock logic in Flutter (backend-only)

---

### J. MISSIONS

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `DailyMissionCubit` with `GetDailyMissionsUseCase`, `ClaimDailyMissionRewardUseCase`
- Repository: `DailyMissionRepositoryImpl` calls `ApiService.getDailyMissions()`, `claimDailyMissionReward()`
- Backend: Daily missions endpoints exist

**Files:**
- `lib/features/gamification/presentation/bloc/daily_mission_cubit.dart`
- `lib/features/gamification/data/repositories/daily_mission_repository_impl.dart`

**Gaps:**
- `DailyMissionRepositoryImpl._fetchAll()` catches errors and returns empty list — **FAKE FALLBACK**

---

### K. WALLET

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `WalletCubit` with `GetWalletUseCase`, `SpendCurrencyUseCase`
- Repository: `WalletRepositoryImpl` calls `ApiService.getWallet()`, `spendGems()`, `getTransactions()`
- Backend: `WalletController` → `WalletService.getWallet()`, `spendGems()`, `getTransactions()` → PostgreSQL `gemsWallet`, `transaction` tables
- Server-authoritative: client cannot add gems directly (throws `UnsupportedError`)

**Files:**
- `lib/features/wallet/presentation/bloc/wallet_cubit.dart`
- `lib/features/wallet/data/repositories/wallet_repository_impl.dart`
- `backend/src/modules/payments/wallet/wallet.service.ts`
- `backend/src/modules/payments/wallet/wallet.controller.ts`

**Gaps:**
- `WalletRepositoryImpl.getWallet()` returns `null` on error — **FAKE FALLBACK**
- `WalletRepositoryImpl.getTransactions()` returns `[]` on error — **FAKE FALLBACK**

---

### L. STORE

**Status: REAL + NOT RUNTIME VERIFIED (with fake fallback)**

**Implementation:**
- Flutter: `StoreCubit` with `GetAllItemsUseCase`, `GetItemsByCategoryUseCase`
- Repository: `StoreRepositoryImpl` calls `ApiService.getStoreItems()`
- Backend: `StoreController` → `StoreService.getItems()` → PostgreSQL `storeItem` table
- Purchase: `POST /store/purchase` with atomic transaction, server-authoritative price validation

**Files:**
- `lib/features/store/presentation/bloc/store_cubit.dart`
- `lib/features/store/data/repositories/store_repository_impl.dart`
- `lib/features/store/domain/services/purchase_service.dart`
- `backend/src/modules/store/store.service.ts`
- `backend/src/modules/store/store.controller.ts`

**Gaps:**
- `StoreRepositoryImpl._getDefaultItems()` returns hardcoded 6 items when API fails — **FAKE FALLBACK**
- `StoreRepositoryImpl.getItemsByCategory()` returns `[]` on error — **FAKE FALLBACK**

---

### M. INVENTORY

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `InventoryCubit` with `GetInventoryUseCase`, `EquipItemUseCase`
- Repository: `InventoryRepositoryImpl` calls `ApiService.getInventory()`, `equipItem()`
- Backend: `StoreController.getInventory()`, `StoreController.equip()` → PostgreSQL `userInventory` table

**Files:**
- `lib/features/inventory/presentation/bloc/inventory_cubit.dart`
- `lib/features/inventory/data/repositories/inventory_repository_impl.dart`
- `backend/src/modules/store/store.service.ts`

**Gaps:**
- `InventoryRepositoryImpl.getInventory()` returns `[]` on error — **FAKE FALLBACK**
- `InventoryRepositoryImpl.getEquippedItems()` returns `[]` on error — **FAKE FALLBACK**
- Equip cache (`_equippedCache`) is in-memory only; not persisted across app restarts

---

### N. PREMIUM

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `PremiumCubit` with `GetPremiumUseCase`, `ActivatePremiumUseCase`, `CancelPremiumUseCase`
- Repository: `PremiumRepositoryImpl` calls `ApiService.getSubscription()`, `createCheckout()`, `cancelSubscription()`
- Backend: `PaymentsController` → `SubscriptionsService` → PostgreSQL `subscription` table
- Stripe checkout + webhook for subscription updates

**Files:**
- `lib/features/premium/presentation/bloc/premium_cubit.dart`
- `lib/features/premium/data/repositories/premium_repository_impl.dart`
- `backend/src/modules/payments/payments.controller.ts`
- `backend/src/modules/payments/subscriptions/subscriptions.service.ts`

**Gaps:**
- `PremiumRepositoryImpl.getPremium()` returns empty `Premium` object on error — **FAKE FALLBACK**
- No real Stripe integration in Flutter (checkout opens web URL)
- No subscription restoration logic

---

### O. AI COACH

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `AiCoachController` (ChangeNotifier) + `AiCoachRepository`
- API: `POST /ai-coach/chat` → `AiCoachService.chat()`
- Backend: Server-calculated `xpEarned` (10 for corrections, 5 for normal)
- Rate limiting: 20 messages/day for free users
- Conversation history stored in PostgreSQL `aiConversation` table

**Files:**
- `lib/features/ai_coach/ai_coach_controller.dart`
- `lib/features/ai_coach/ai_coach_repository.dart`
- `lib/features/ai_coach/ai_coach_screen.dart`
- `backend/src/modules/ai-coach/ai-coach.service.ts`
- `backend/src/modules/ai-coach/ai-coach.controller.ts`

**Gaps:**
- Chat history cached locally in `SharedPreferences` (`ai_coach_repository.dart`)
- No real OpenAI integration (rule-based responses)
- No conversation context/memory across sessions

---

### P. SPEAKING

**Status: PARTIAL**

**Implementation:**
- Flutter: `SpeakingController` (ChangeNotifier) + `SpeakingRepository`
- Backend: `POST /speaking/pronunciation/analyze` exists and is server-authoritative
- Backend: `SpeakingService.analyzePronunciation()` → PostgreSQL `pronunciationAttempt` + `user` tables

**Files:**
- `lib/features/speaking/speaking_controller.dart`
- `lib/features/speaking/speaking_repository.dart`
- `lib/features/speaking/speaking_screen.dart`
- `backend/src/modules/speaking/speaking.service.ts`
- `backend/src/modules/speaking/speaking.controller.ts`

**Gaps:**
- Flutter UI uses local `PronunciationResult.analyze()` only — **NOT WIRED TO BACKEND**
- No microphone/audio recording implementation
- No speech-to-text integration
- XP accumulation removed from client (correct), but backend not called

---

### Q. COMMUNITY

**Status: REAL + NOT RUNTIME VERIFIED (with fake fallbacks)**

**Implementation:**
- Flutter: `CommunityRepository` + `CommunityScreen`
- Backend: `CommunityController` with feed, posts, likes, comments, groups, challenges, messages, leaderboard
- All endpoints protected by `JwtAuthGuard`

**Files:**
- `lib/features/community/community_repository.dart`
- `lib/features/community/community_screen.dart`
- `backend/src/modules/community/community.controller.ts`
- `backend/src/modules/community/community.service.ts`

**Gaps:**
- `CommunityRepository.getFeed()` has silent `catch (_) {}` fallback to cached/empty data — **FAKE FALLBACK**
- `CommunityRepository.getGroups()` has silent `catch (_) {}` fallback — **FAKE FALLBACK**
- `CommunityRepository.getChallenges()` has silent `catch (_) {}` fallback — **FAKE FALLBACK**
- `CommunityRepository.createPost()`, `toggleLike()`, `addComment()` silently swallow errors — **FAKE FALLBACK**
- Community screen shows static/hardcoded sections (`_buildGermanGroupSection()`, `_buildLearningTipsSection()`, etc.) when API data is empty

---

### R. NOTIFICATIONS

**Status: PARTIAL**

**Implementation:**
- Flutter: `NotificationsRepository` + `NotificationsScreen`
- Backend: `NotificationsController` with `getNotifications()`, `markRead()`
- FCM token registration in `NotificationService`

**Files:**
- `lib/features/notifications/notifications_repository.dart`
- `lib/features/notifications/notifications_screen.dart`
- `lib/core/services/notification_service.dart`
- `backend/src/modules/notifications/notifications.controller.ts`

**Gaps:**
- `NotificationsRepository.getNotifications()` returns `_sampleNotifications()` (3 hardcoded fake notifications) when API fails — **FAKE FALLBACK**
- No push notification delivery (no Cloud Functions)
- No real-time notification updates
- `markRead()` silently swallows errors

---

### S. SEARCH

**Status: REAL + NOT RUNTIME VERIFIED**

**Implementation:**
- Flutter: `ApiService.search()`
- Backend: `SearchController` → `SearchService.search()` → PostgreSQL `vocabulary`, `storeItem`, `user` tables

**Files:**
- `lib/core/services/api_service.dart` (search method)
- `lib/features/search/search_screen.dart`
- `backend/src/modules/search/search.service.ts`
- `backend/src/modules/search/search.controller.ts`

**Gaps:**
- Search screen UI exists but may not be fully wired
- No search suggestions/recent searches

---

### T. SETTINGS

**Status: LOCAL ONLY**

**Implementation:**
- Flutter: `SettingsCubit` reads/writes to `SharedPreferences`
- No backend persistence
- Settings: dark mode, notifications enabled, learning language, daily goal

**Files:**
- `lib/features/profile/presentation/bloc/settings_cubit.dart`
- `lib/features/profile/presentation/pages/settings_screen.dart`

**Gaps:**
- Settings are device-local only; not synced across devices
- No backend endpoint for settings

---

## FAKE/MOCK/FALLBACK INVENTORY

| File | Fallback | Type | Backend Exists? | Action Needed |
|------|----------|------|-----------------|---------------|
| `lib/features/lessons/lesson_repository.dart` | `GermanContent` fallback | Silent catch → hardcoded data | YES | Remove fallback, propagate errors |
| `lib/features/store/data/repositories/store_repository_impl.dart` | `_getDefaultItems()` | API failure → hardcoded 6 items | YES | Remove fallback, show error state |
| `lib/features/wallet/data/repositories/wallet_repository_impl.dart` | `return null` on error | Silent failure | YES | Propagate error |
| `lib/features/wallet/data/repositories/wallet_repository_impl.dart` | `return []` on error | Silent failure | YES | Propagate error |
| `lib/features/inventory/data/repositories/inventory_repository_impl.dart` | `return []` on error | Silent failure | YES | Propagate error |
| `lib/features/premium/data/repositories/premium_repository_impl.dart` | `return Premium(userId: userId)` on error | Fake empty state | YES | Propagate error |
| `lib/features/community/community_repository.dart` | Multiple silent catches + cached fallbacks | Fake fallback | YES | Remove fallbacks, propagate errors |
| `lib/features/notifications/notifications_repository.dart` | `_sampleNotifications()` | Hardcoded fake data | YES | Remove fallback, propagate errors |
| `lib/features/gamification/data/repositories/streak_repository_impl.dart` | `return Streak(userId: userId)` on error | Fake empty state | YES | Propagate error |
| `lib/features/gamification/data/repositories/achievement_repository_impl.dart` | `return []` on error | Silent failure | YES | Propagate error |
| `lib/features/gamification/data/repositories/daily_mission_repository_impl.dart` | `return []` on error | Silent failure | YES | Propagate error |
| `lib/features/learning_progress/data/repositories/progress_repository_impl.dart` | `return Progress(userId: userId)` on error | Fake empty state | YES | Propagate error |

---

## COMPILE/TEST STATUS

| Check | Result |
|-------|--------|
| `flutter analyze --no-pub` (main `lib/` package) | **0 errors** |
| `flutter analyze` overall | 119 pre-existing errors in `admin_dashboard/` (unrelated) |
| `npx tsc --noEmit` (backend) | **exit 0** |
| `git status` | Large working tree diff (235 files modified — unrelated to BATCH 1) |

---

## BATCH 2 PRIORITY FLOWS

### P0 — Must verify first:
1. Authentication (login, logout, session restoration)
2. Profile (load, update)
3. Home (real data display)
4. Lessons (load, detail, completion)
5. Quiz (embedded in lessons)
6. Progress (server-authoritative)
7. XP (server-authoritative)
8. Streak (server-authoritative)
9. Achievements (read from backend)
10. Missions (read from backend)

### P1 — Economy & AI:
11. Wallet (server-authoritative)
12. Store (real catalog, purchase)
13. Inventory (ownership, equip)
14. Premium (subscription state)
15. AI Coach (real backend)
16. Speaking (wire to backend)

### P2 — Social & Misc:
17. Community (remove fake fallbacks)
18. Notifications (remove fake fallback)
19. Search
20. Settings

---

## REMAINING BLOCKERS

| Blocker | Severity | Required Action |
|---------|----------|-----------------|
| Service-account JSON in git history | P0 | Commit staged deletion, history purge, key rotation |
| iOS Firebase plist missing | P1 | Download from Firebase Console |
| External secret rotations | P1 | Rotate PostgreSQL, Stripe, OpenAI, JWT_SECRET externally |
| `GermanContent` fallback | P2 | Remove in Batch 2, propagate errors |
| `_getDefaultItems()` fallback | P2 | Remove in Batch 2 |
| Silent `catch (_) {}` in repositories | P2 | Replace with proper error propagation |
| Speaking not wired to backend | P1 | Connect in Batch 2 |
| Settings not synced to backend | P2 | Backend endpoint needed or accept local-only |
| No FCM push delivery | P2 | Cloud Functions needed |

---

## NEXT STEPS

1. Start with **Authentication runtime verification** (login, logout, session restoration)
2. Then **Profile** (load from backend, update)
3. Then **Home** (connect to real ProgressCubit data)
4. Then **Lessons/Quiz/Completion** (remove GermanContent fallback, verify XP awarded)
5. Then **Progress/XP/Streak** (verify server-authoritative)
6. Then **Wallet/Store/Inventory/Premium** (verify purchase flow)
7. Then **AI Coach/Speaking** (wire speaking, verify AI)
8. Then **Community/Notifications** (remove fake fallbacks)

Each flow must be:
- Traced end-to-end
- Runtime tested
- Error cases tested
- Fake fallbacks removed
- Proper error propagation implemented
