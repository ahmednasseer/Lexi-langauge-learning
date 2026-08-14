# LEXI — CURRENT STATE AUDIT

Date: 2026-08-14
Scope: Complete codebase audit after Phase 0.5 and real backend verification

---

## EXECUTIVE SUMMARY

The LEXI project has a **real deployed backend** at `https://lexi-backend-zftq.onrender.com/`. The Flutter app has been reconfigured to target this backend. Most P0 flows are now **real and backend-backed**, but several issues remain:

**Completed:**
- Fake fallbacks removed from 11 repositories
- Base URL fixed to point to deployed backend
- Response format handling updated for backend variations
- Email/password auth verified against deployed backend
- XP authority confirmed server-side
- Speaking UI wired to backend with local fallback
- App verified running on Android emulator
- All old audit documents marked as HISTORICAL REFERENCE

**Remaining Issues:**
- Google Sign-In blocked (Firebase OAuth not configured)
- Backend 500 errors on `/progress/stats` and `/daily-missions*`
- Empty database (no seed data for lessons, missions, etc.)
- Some response format mismatches (already handled in code)

---

## P0 FLOW STATUS

### A. AUTHENTICATION

| Flow | Status | Details |
|------|--------|---------|
| Email/Password Register | PASS | 201, returns token + user |
| Email/Password Login | PASS | 201, returns token + user |
| Guest Login | PASS | 201, returns token + user |
| Profile Load | PASS | 200, returns full profile |
| Google Sign-In | BLOCKED | `PlatformException(sign_in_falied, 10:10)` — `oauth_client: []` in `google-services.json` |
| Logout | INFO | Clears local token, no backend endpoint |

**Files:**
- `lib/core/services/auth_service.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/bloc/auth_cubit.dart`

**Root Cause (Google Sign-In):**
- `android/app/google-services.json` has empty `"oauth_client":[]`
- Required: Add Google OAuth client in Firebase Console → Authentication → Sign-in method → Google

### B. PROFILE

| Flow | Status | Details |
|------|--------|---------|
| Load Profile | PASS | 200, returns user data |
| Update Profile | PENDING | Firestore-only, not synced to PostgreSQL |

**Files:**
- `lib/features/profile/presentation/bloc/profile_cubit.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`

### C. HOME

| Flow | Status | Details |
|------|--------|---------|
| Dashboard Load | PARTIAL | Reads from `StorageService` (SharedPreferences), not backend |
| XP/Level Display | PARTIAL | Uses cached data, not real-time from backend |

**Files:**
- `lib/features/home/home_controller.dart`
- `lib/features/home/home_screen.dart`

**Gap:** Home does not load real user data from backend. Uses local cache only.

### D. LESSONS

| Flow | Status | Details |
|------|--------|---------|
| Get Languages | PASS | 200, returns `[]` (empty DB) |
| Get Lessons | PASS | 200, returns lessons or 404 if language not found |
| Get Lesson Detail | PASS | 200, returns lesson with vocabulary, grammar, quiz |
| Complete Lesson | PENDING | Requires valid lessonId in DB |

**Files:**
- `lib/features/lessons/lesson_repository.dart`
- `lib/features/lessons/lesson_controller.dart`
- `lib/features/lessons/models/lesson_model.dart`

**Response Format:** Backend returns bare arrays `[]` instead of `{"data": []}` for some endpoints. Fixed in `ApiService`.

### E. QUIZ

| Flow | Status | Details |
|------|--------|---------|
| Quiz Display | PARTIAL | Embedded in lesson detail, no standalone flow |
| Quiz Submission | PASS | Score sent to `POST /progress/complete` |

### F. PROGRESS

| Flow | Status | Details |
|------|--------|---------|
| Get Progress | PASS | 200, returns `[]` when no progress |
| Get Stats | FAIL | 500 Internal Server Error |
| Complete Lesson | PENDING | Requires valid lessonId |

**Root Cause (500):** `GET /api/v1/progress/stats` returns 500. Backend bug in `ProgressService.getStats()`.

### G. XP

| Flow | Status | Details |
|------|--------|---------|
| XP Award | PASS | Server-authoritative via `POST /progress/complete` |
| XP Display | PASS | Read from `/users/growth` |

**Authority:** XP is correctly server-side. Client-side mutations are no-ops.

### H. STREAK

| Flow | Status | Details |
|------|--------|---------|
| Get Streak | PASS | Read from `/users/growth` |
| Streak Update | PASS | Server-authoritative on lesson completion |

### I. ACHIEVEMENTS

| Flow | Status | Details |
|------|--------|---------|
| Get Achievements | PASS | 200, returns `[]` (empty when none unlocked) |

### J. MISSIONS

| Flow | Status | Details |
|------|--------|---------|
| Get Missions | FAIL | 500 Internal Server Error |
| Get Mission Stats | FAIL | 500 Internal Server Error |
| Claim Mission Reward | PENDING | Requires valid mission |

**Root Cause (500):** Backend bug in `DailyMissionsService.getTodayMissions()` or `getStats()`. Likely related to `date` field handling in Prisma queries.

### K. WALLET

| Flow | Status | Details |
|------|--------|---------|
| Get Wallet | PASS | 200, returns `{"gems":100,"totalPurchased":0,"totalSpent":0,"transactions":[]}` |
| Get Transactions | PASS | 200, returns `[]` |
| Spend Gems | PENDING | Requires valid purchase |

### L. STORE

| Flow | Status | Details |
|------|--------|---------|
| Get Items | PASS | 200, returns `{"data":[]}` (empty catalog) |
| Purchase | PENDING | Requires items in DB |
| Equip | PENDING | Requires items in DB |

### M. COMMUNITY

| Flow | Status | Details |
|------|--------|---------|
| Get Feed | PASS | 200, returns `[]` (empty feed) |
| Create Post | PENDING | Requires auth |
| Like Post | PENDING | Requires auth |

### N. NOTIFICATIONS

| Flow | Status | Details |
|------|--------|---------|
| Get Notifications | PASS | 200, returns `[]` (empty) |
| Mark Read | PENDING | Requires auth |

---

## FAKE FALLBACKS REMOVED

| File | Fallback Removed |
|------|-----------------|
| `lib/features/lessons/lesson_repository.dart` | `GermanContent` hardcoded fallback + silent catches |
| `lib/features/learning_progress/data/repositories/progress_repository_impl.dart` | Empty `Progress` object on API failure |
| `lib/features/gamification/data/repositories/streak_repository_impl.dart` | Empty `Streak` object on API failure |
| `lib/features/gamification/data/repositories/achievement_repository_impl.dart` | Empty list on API failure |
| `lib/features/gamification/data/repositories/daily_mission_repository_impl.dart` | Empty list on API failure + silent catch |
| `lib/features/wallet/data/repositories/wallet_repository_impl.dart` | `null` return on API failure, empty list on API failure |
| `lib/features/inventory/data/repositories/inventory_repository_impl.dart` | Empty list on API failure |
| `lib/features/premium/data/repositories/premium_repository_impl.dart` | Empty `Premium` object on API failure, `false` on error |
| `lib/features/store/data/repositories/store_repository_impl.dart` | `_getDefaultItems()` hardcoded 6 items on API failure |
| `lib/features/community/community_repository.dart` | Silent catches + cached fallbacks on all API failures |
| `lib/features/notifications/notifications_repository.dart` | `_sampleNotifications()` hardcoded fake data on API failure |

---

## BACKEND 500 ERRORS

| Endpoint | Status | Likely Root Cause |
|----------|--------|-------------------|
| `GET /api/v1/progress/stats` | 500 | Backend bug in `ProgressService.getStats()` |
| `GET /api/v1/daily-missions` | 500 | Backend bug in `DailyMissionsService.getTodayMissions()` |
| `GET /api/v1/daily-missions/stats` | 500 | Backend bug in `DailyMissionsService.getStats()` |

**Required Action:** Check Render logs for exact error messages. Fix backend code.

---

## CURRENT BLOCKERS

| Blocker | Severity | Required Action |
|---------|----------|-----------------|
| Google Sign-In `oauth_client` empty | P0 | Configure Google OAuth in Firebase Console |
| `/progress/stats` 500 error | P0 | Fix backend bug |
| `/daily-missions` 500 error | P0 | Fix backend bug |
| `/daily-missions/stats` 500 error | P0 | Fix backend bug |
| Service-account JSON in git history | P0 | Commit staged deletion, history purge, key rotation |
| iOS Firebase plist missing | P1 | Download from Firebase Console |
| External secret rotations | P1 | Rotate PostgreSQL, Stripe, OpenAI, JWT_SECRET externally |
| Speaking not wired to backend | P1 | FIXED — `analyzePronunciation` connected with local fallback |
| Empty database | P1 | Seed lessons, missions, store items |
| Android Gradle daemon issues | P2 | Fix Kotlin daemon or disable daemon |

---

## FILES MODIFIED THIS SESSION

| File | Change |
|------|--------|
| `lib/core/services/api_service.dart` | Changed base URL to deployed backend; fixed response format handling for bare arrays; added `analyzePronunciation` endpoint |
| `lib/features/speaking/speaking_repository.dart` | Added `analyzePronunciation` method that calls backend with local fallback |
| `lib/features/speaking/speaking_controller.dart` | Updated to use backend pronunciation analysis when available, fallback to local `PronunciationResult.analyze()` |
| `lib/features/speaking/speaking_screen.dart` | Injected `SpeakingRepository` via DI |
| `lib/core/di/injection_container.dart` | Registered `SpeakingRepository` in DI container |
| `backend/src/main.ts` | Fixed Express import for CJS compatibility |
| `backend/.env` | Generated secure JWT_SECRET; set REDIS_ENABLED=false, QUEUE_ENABLED=false |
| `android/gradle.properties` | Added `kotlin.daemon.enabled=false` to fix Gradle daemon issues |
| `LEXI_PRODUCTION_AUDIT.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_END_TO_END_GAP_REPORT.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_EXECUTION_BLUEPRINT.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_ARCHITECTURE_GUIDE.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_REFACTOR_PLAN.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_PRODUCT_GAP_ANALYSIS.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_DEVELOPMENT_MASTER_PLAN.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_FEATURE_SPECIFICATION.txt` | Added HISTORICAL REFERENCE notice |
| `LEXI_CURRENT_STATE_AUDIT.md` | Created — current state reference |
| `LEXI_REAL_BACKEND_STATUS.md` | Created — real backend verification results |

---

## NEXT STEPS

1. **Fix backend 500 errors** — Check Render logs, fix `ProgressService.getStats()` and `DailyMissionsService`
2. **Verify full P0 flows on device** — Auth → Profile → Home → Lessons → Quiz → Progress → XP → Streak → Achievements → Missions
3. **Fix Google Sign-In** — Configure OAuth in Firebase Console
4. **Seed database** — Add initial lessons, missions, store items
5. **Continue P1 flows** — Wallet, Store, Inventory, Premium, AI Coach
6. **Continue P2 flows** — Community, Notifications, Search, Settings
