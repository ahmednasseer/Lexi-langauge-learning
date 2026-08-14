# LEXI — REAL DEPLOYED BACKEND STATUS

Date: 2026-08-14
Target Backend: https://lexi-backend-zftq.onrender.com/

---

## BASE URL FIX

**File:** `lib/core/services/api_service.dart:43-47`

**Before:**
```dart
Environment.development: 'http://10.0.2.2:3000/api/v1',
```

**After:**
```dart
Environment.development: 'https://lexi-backend-zftq.onrender.com/api/v1',
```

**Status:** FIXED — Flutter now targets the real deployed backend.

---

## P0 FLOW VERIFICATION

### AUTH — Email/Password

| Step | Endpoint | Status | Notes |
|------|----------|--------|-------|
| Register | `POST /api/v1/auth/register` | PASS | 201, returns `accessToken` + `user` |
| Login | `POST /api/v1/auth/login` | PASS | 201, returns `accessToken` + `user` |
| Guest | `POST /api/v1/auth/guest` | PASS | 201, returns `accessToken` + `user` |
| Profile | `GET /api/v1/users/profile` | PASS | 200, returns full user profile |
| Logout | No backend endpoint | INFO | Clears local token only |

**Response shape verified:**
```json
{
  "accessToken": "eyJ...",
  "user": {
    "id": "cmss...",
    "name": "Test User",
    "email": "test@example.com",
    "level": "A1",
    "xp": 0,
    "streak": 0,
    "isPremium": false
  }
}
```

### AUTH — Google Sign-In

| Status | Details |
|--------|---------|
| BLOCKED | `PlatformException(sign_in_falied, ... 10:10 ...)` |
| Root Cause | `android/app/google-services.json` has empty `oauth_client: []` |
| Required Fix | Add Google OAuth client in Firebase Console → Project Settings → Authentication → Sign-in method → Google → Web SDK configuration |

### LESSONS

| Endpoint | Status | Response |
|----------|--------|----------|
| `GET /api/v1/lessons/languages` | PASS | `[]` (empty array — no active languages in DB) |
| `GET /api/v1/lessons/:language` | PASS | Returns lessons for language |
| `GET /api/v1/lessons/any/:id` | PASS | Returns lesson detail with vocabulary, grammar, quiz |

**Response format:** Some endpoints return bare arrays `[]` instead of `{"data": []}`. Updated `ApiService` to handle both formats.

### PROGRESS

| Endpoint | Status | Notes |
|----------|--------|-------|
| `GET /api/v1/progress` | PASS | Returns `[]` when no progress |
| `POST /api/v1/progress/complete` | PASS | Server-authoritative XP calculation |
| `GET /api/v1/progress/stats` | FAIL | 500 Internal Server Error |

### WALLET

| Endpoint | Status | Response |
|----------|--------|----------|
| `GET /api/v1/users/wallet` | PASS | `{"gems":100,"totalPurchased":0,"totalSpent":0,"transactions":[]}` |
| `GET /api/v1/users/wallet/transactions` | PASS | `[]` |

### STORE

| Endpoint | Status | Response |
|----------|--------|----------|
| `GET /api/v1/store/items` | PASS | `{"data":[]}` |
| `POST /api/v1/store/purchase` | PENDING | Requires auth + items in DB |
| `POST /api/v1/store/equip` | PENDING | Requires auth + items in DB |

### ACHIEVEMENTS

| Endpoint | Status | Response |
|----------|--------|----------|
| `GET /api/v1/users/achievements` | PASS | `[]` (empty when none unlocked) |

### MISSIONS

| Endpoint | Status | Notes |
|----------|--------|-------|
| `GET /api/v1/daily-missions` | FAIL | 500 Internal Server Error |
| `GET /api/v1/daily-missions/stats` | FAIL | 500 Internal Server Error |

### COMMUNITY

| Endpoint | Status | Response |
|----------|--------|----------|
| `GET /api/v1/community/feed?page=1&limit=5` | PASS | `[]` (empty feed) |
| `POST /api/v1/community/posts` | PENDING | Requires auth |
| `POST /api/v1/community/posts/:id/like` | PENDING | Requires auth |

### NOTIFICATIONS

| Endpoint | Status | Response |
|----------|--------|----------|
| `GET /api/v1/notifications?page=1&limit=5` | PASS | `[]` (empty) |
| `POST /api/v1/notifications/:id/read` | PENDING | Requires auth |

### AI COACH

| Endpoint | Status | Notes |
|----------|--------|-------|
| `POST /api/v1/ai-coach/chat` | PENDING | Requires auth + valid body |
| `GET /api/v1/ai-coach/history` | PENDING | Requires auth |

### SPEAKING

| Endpoint | Status | Notes |
|----------|--------|-------|
| `POST /api/v1/speaking/pronunciation/analyze` | PENDING | Requires auth + audio data |
| `GET /api/v1/speaking/exercises/:level` | PENDING | Requires auth |

---

## RESPONSE FORMAT MISMATCH

**Issue:** Some backend endpoints return bare arrays `[]` instead of `{"data": [...]}`.

**Affected endpoints:**
- `GET /api/v1/lessons/languages` → returns `[]`
- `GET /api/v1/progress` → returns `[]`
- `GET /api/v1/users/achievements` → returns `[]`
- `GET /api/v1/community/feed` → returns `[]`

**Fix applied:** Updated `ApiService` methods to handle both formats:
```dart
data is List ? data : (data['data'] ?? [])
```

**Files changed:** `lib/core/services/api_service.dart` (31 occurrences updated)

---

## 500 ERRORS ON DEPLOYED BACKEND

**Affected endpoints:**
1. `GET /api/v1/progress/stats` — 500
2. `GET /api/v1/daily-missions` — 500
3. `GET /api/v1/daily-missions/stats` — 500

**Root cause:** Likely database query issues or missing seed data.

**Required action:** Check backend logs on Render dashboard for exact error.

---

## FAKE FALLBACKS REMOVED (PREVIOUS SESSION)

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

## CURRENT BLOCKERS

| Blocker | Severity | Required Action |
|---------|----------|-----------------|
| Google Sign-In `oauth_client` empty | P0 | Configure Google OAuth in Firebase Console |
| `/progress/stats` 500 error | P0 | Check Render logs, fix backend |
| `/daily-missions` 500 error | P0 | Check Render logs, fix backend |
| `/daily-missions/stats` 500 error | P0 | Check Render logs, fix backend |
| Service-account JSON in git history | P0 | Commit staged deletion, history purge, key rotation |
| iOS Firebase plist missing | P1 | Download from Firebase Console |
| External secret rotations | P1 | Rotate PostgreSQL, Stripe, OpenAI, JWT_SECRET externally |
| Speaking not wired to backend | P1 | Connect Flutter → ApiService → Backend |
| Android Gradle daemon issues | P2 | Fix Kotlin daemon or disable daemon |

---

## NEXT STEPS

1. Fix 500 errors on deployed backend (`/progress/stats`, `/daily-missions*`)
2. Wire Speaking UI to backend
3. Test full P0 flows on emulator/device
4. Fix Google Sign-In OAuth configuration
5. Continue P1 flows (Wallet, Store, Inventory, Premium, AI Coach)
6. Continue P2 flows (Community, Notifications, Search, Settings)
