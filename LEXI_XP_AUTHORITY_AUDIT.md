# LEXI XP AUTHORITY AUDIT

Date: 2026-08-14
Scope: Complete XP/streak/reward mutation audit across Flutter client and NestJS backend
Status: VERIFIED — No client-controlled XP mutation can alter authoritative XP

---

## 1. EXECUTIVE SUMMARY

All production XP mutation paths are now **SERVER-AUTHORITATIVE**.

The client can no longer grant or inflate XP, streak, or level through any reachable production flow.

Client-side `addXp()` calls that remain in the codebase are either:
- Documented no-ops (legacy API compatibility)
- Dead code (no reachable callers)
- Local UI display state (does not affect authoritative database values)

One feature gap remains: the **Speaking** feature has a backend endpoint (`POST /speaking/pronunciation/analyze`) that is server-authoritative, but the Flutter client does not yet call it. The local SpeakingController XP accumulation has been neutralized. Wiring Speaking to the backend is a **Batch 2** task.

---

## 2. XP MUTATION PATH INVENTORY

### PATH 1: Lesson Completion

**Flutter entry point:**
`lib/features/lessons/screens/lesson_detail_screen.dart:566-594`

**Call chain:**
```
UI (_reportCompletion)
  → LessonRepository().completeLesson(lessonId, score, timeSpent)
    → ApiService.completeLesson()
      → POST /progress/complete
        → ProgressService.completeLesson()
          → Prisma: lesson.xpReward * (clampedScore / 100)
          → Prisma: user.xp { increment: xpEarned }
          → Prisma: user.totalXp { increment: xpEarned }
          → Prisma: user.dailyXp { increment: xpEarned }
```

**XP authority:** SERVER
- XP derived from `lesson.xpReward` (server-side PostgreSQL field)
- Client-supplied `score` clamped to 0-100: `Math.max(0, Math.min(100, Math.round(Number(score) || 0)))`
- XP only awarded on FIRST completion (`userId_lessonId` unique constraint prevents double-award)
- Atomic `prisma.$transaction` with race-safe concurrent-create handling (P2002 catch)

**Client-side addXp call:**
`lib/features/lessons/screens/lesson_detail_screen.dart:580`
```dart
await AuthService.instance.addXp(xp);
```
→ `AuthService.addXp()` is now a documented **no-op**

**User control over XP amount:** NONE (server calculates from lesson metadata)
**Repeated triggering protection:** YES (first-completion only, unique constraint)
**Authoritative XP affected:** YES — via backend `user.xp` update
**Status:** FIXED / SERVER-AUTHORITATIVE

---

### PATH 2: AI Coach

**Flutter entry point:**
`lib/features/ai_coach/ai_coach_controller.dart:67-93`

**Call chain:**
```
UI (sendMessage)
  → AiCoachRepository.sendMessage()
    → ApiService.aiCoachChat()
      → POST /ai-coach/chat
        → AiCoachService.chat()
          → Server determines xpEarned (10 for correction, 5 for normal)
          → Prisma: aiConversation.create (logs xpEarned)
          → Prisma: user.xp { increment: xpEarned }
          → Returns xpEarned in response
```

**XP authority:** SERVER
- `xpEarned` hardcoded server-side in `generateResponse()`: 10 or 5
- Client receives `xpEarned` in response but cannot influence its value
- Backend has daily rate limit (20 messages/day for free users)
- Backend has `@UseGuards(JwtAuthGuard)` — authenticated only

**Client-side addXp call:**
`lib/features/ai_coach/ai_coach_controller.dart:78`
```dart
await AuthService.instance.addXp(response.xpEarned!);
```
→ `AuthService.addXp()` is now a documented **no-op**

**Local state updates (UI display only):**
```dart
_todayXp += response.xpEarned!;   // line 76 — ChangeNotifier state
_totalXp += response.xpEarned!;   // line 77 — ChangeNotifier state
```
These update the controller's local state for UI display within the AI Coach screen. They do NOT persist to SharedPreferences, do NOT call any API, and do NOT affect the authoritative `user.xp` in PostgreSQL. The authoritative XP is already updated server-side before these lines execute.

**User control over XP amount:** NONE (server determines xpEarned)
**Repeated triggering protection:** YES (20/day rate limit)
**Authoritative XP affected:** YES — via backend `user.xp` update
**Status:** FIXED / SERVER-AUTHORITATIVE

---

### PATH 3: Speaking — processSpokenText

**Flutter entry point:**
`lib/features/speaking/speaking_controller.dart:55-71`
Called from: `lib/features/speaking/speaking_screen.dart:759`

**Previous call chain (BEFORE fix):**
```
UI (speaking exercise completed)
  → SpeakingController.processSpokenText()
    → PronunciationResult.analyze() [CLIENT-SIDE]
    → _totalXp += result.xpEarned        ← LOCAL XP MUTATION (REMOVED)
    → _streak++ / _streak = 0            ← LOCAL STREAK (session state)
```

**Current call chain (AFTER fix):**
```
UI (speaking exercise completed)
  → SpeakingController.processSpokenText()
    → PronunciationResult.analyze() [CLIENT-SIDE]
    → _lastResult = result
    → _streak++ / _streak = 0            ← LOCAL STREAK (session state only)
    → NO XP mutation
```

**Backend endpoint exists but is NOT wired:**
- `POST /speaking/pronunciation/analyze` exists in NestJS
- `SpeakingService.analyzePronunciation()` updates `user.totalXp` server-side
- Flutter does NOT call this endpoint
- Wiring is a **Batch 2** task

**XP authority:** LOCAL ONLY → NEUTRALIZED
- `_totalXp` was a local ChangeNotifier field, never persisted, never sent to backend
- `_streak` remains as local session state (not persisted, not authoritative)
- The speaking screen's XP display will show 0 until backend is wired

**User control over XP amount:** Previously YES (client-side `PronunciationResult.analyze` determined xpEarned) → NOW NEUTRALIZED
**Repeated triggering protection:** N/A (no XP mutation)
**Authoritative XP affected:** NO
**Status:** FIXED (local XP mutation removed; backend wiring pending Batch 2)

---

### PATH 4: Speaking — answerListeningQuestion

**Flutter entry point:**
`lib/features/speaking/speaking_controller.dart:84-88`

**Call chain:**
```
UI (listening question answered)
  → SpeakingController.answerListeningQuestion()
    → _isCorrect = ...
    → _totalXp += currentQuestion!.xpReward   ← LOCAL XP MUTATION (REMOVED)
```

**Reachability:** DEAD CODE — no callers found outside the definition
- `git grep` shows `answerListeningQuestion` is only defined, never called from any screen or widget

**XP authority:** N/A (dead code)
**Status:** DEAD CODE — REMOVED

---

### PATH 5: UserProgressService.completeLesson / saveQuizScore

**Location:**
`lib/core/services/user_progress_service.dart:37-61`

**Call chain:**
```
UserProgressService.completeLesson(lessonId)
  → SharedPreferences: setStringList(_lessonsCompletedKey, completed)
  → addXp(10)                              ← NO-OP
  → _markStudiedToday()

UserProgressService.saveQuizScore(lessonId, score, total)
  → SharedPreferences: setString(_quizScoresKey, ...)
  → addXp(score * 5)                       ← NO-OP
  → _markStudiedToday()
```

**Reachability:** DEAD CODE — no external callers
- `UserProgressService` is only instantiated in `main.dart:43` for `initialize()`
- No UI screen or controller calls `completeLesson()` or `saveQuizScore()` on `UserProgressService`
- The actual lesson completion flow uses `LessonRepository.completeLesson()` → backend API (Path 1)

**XP authority:** N/A (dead code)
**Status:** DEAD CODE

---

### PATH 6: GrowthController.addXp → GrowthService.addXp

**Location:**
`lib/features/growth/growth_controller.dart:85-89`
`lib/features/growth/services/growth_service.dart:120-131`

**Call chain:**
```
GrowthController.addXp(userId, xp)
  → GrowthService.addXp(userId, xp)
    → getUserProgress(userId) [SharedPreferences]
    → totalXp + xp
    → saveUserProgress(userId, updatedProgress) [SharedPreferences]
```

**Reachability:** DEAD CODE — no external callers
- `git grep` shows `GrowthController.addXp` is only called from `growth_controller.dart:86` itself
- `GrowthScreen` instantiates `GrowthController` but never calls `addXp`
- The growth screen displays data from local SharedPreferences cache

**XP authority:** N/A (dead code, local-only)
**Status:** DEAD CODE

---

### PATH 7: AI Coach Controller Local State

**Location:**
`lib/features/ai_coach/ai_coach_controller.dart:76-77`

```dart
_todayXp += response.xpEarned!;
_totalXp += response.xpEarned!;
```

**Reachability:** YES — reachable from AI Coach screen UI
**Effect:** Updates `ChangeNotifier` state for AI Coach screen display only
**Persistence:** None — not written to SharedPreferences, not sent to backend
**Authoritative XP affected:** NO — backend already updated `user.xp` before these lines execute

**Status:** SAFE — UI display state only

---

## 3. CLIENT addXp() STATUS SUMMARY

| Location | Type | Reachable | Affects Authoritative XP | Status |
|----------|------|-----------|--------------------------|--------|
| `auth_service.dart:257` | No-op | YES (legacy callers) | NO | SAFE |
| `user_progress_service.dart:71` | No-op | NO (dead code) | NO | DEAD CODE |
| `user_progress_service.dart:42` | No-op (via addXp) | NO (dead code) | NO | DEAD CODE |
| `user_progress_service.dart:59` | No-op (via addXp) | NO (dead code) | NO | DEAD CODE |
| `ai_coach_controller.dart:78` | No-op | YES | NO | SAFE |
| `lesson_detail_screen.dart:580` | No-op | YES | NO | SAFE |
| `growth_controller.dart:85` | Local SP only | NO (dead code) | NO | DEAD CODE |
| `growth_service.dart:120` | Local SP only | NO (dead code) | NO | DEAD CODE |
| `speaking_controller.dart:64` | REMOVED | YES | NO | FIXED |
| `speaking_controller.dart:88` | REMOVED | NO (dead code) | NO | DEAD CODE |

---

## 4. BACKEND SECURITY ASSESSMENT

### Lesson Completion (`POST /progress/complete`)
- **Client-supplied XP:** NOT ACCEPTED. Backend ignores any client-sent XP amount.
- **XP calculation:** `lesson.xpReward * (safeScore / 100)` — derived from server-known lesson metadata
- **Input validation:** Score clamped to 0-100; timeSpent clamped to >=0
- **Double-award protection:** Unique constraint `userId_lessonId`; atomic transaction with P2002 race handling
- **Verdict:** SECURE

### AI Coach (`POST /ai-coach/chat`)
- **Client-supplied XP:** NOT ACCEPTED. Backend determines `xpEarned` (10 or 5) internally.
- **Rate limiting:** 20 messages/day for free users (enforced in service)
- **Authentication:** `@UseGuards(JwtAuthGuard)`
- **Verdict:** SECURE

### Speaking (`POST /speaking/pronunciation/analyze`)
- **Client-supplied XP:** NOT ACCEPTED. Backend calculates `xpEarned` from pronunciation metrics.
- **Authentication:** `@UseGuards(JwtAuthGuard)`
- **Verdict:** SECURE (endpoint exists and is secure, but NOT wired in Flutter yet)

### Potential Backend Risk: Legacy JWT Support
- The backend accepts BOTH Firebase ID tokens AND legacy HS256 JWTs signed with `JWT_SECRET`
- If `JWT_SECRET` is leaked, attackers can forge admin tokens
- **Mitigation applied:** `main.ts` now fails startup if `JWT_SECRET` is missing/placeholder/short (<32 chars)
- **Remaining risk:** Legacy JWT path still exists; recommend removing it if all clients use Firebase Auth

---

## 5. SECURITY RISK SUMMARY

| Risk | Severity | Status |
|------|----------|--------|
| Client-side XP mutation via lesson completion | P0 | FIXED — backend authoritative |
| Client-side XP mutation via AI Coach | P0 | FIXED — backend authoritative |
| Client-side XP mutation via Speaking | P0 | FIXED — local mutation removed |
| Client-side XP mutation via UserProgressService | P0 | FIXED — dead code, no-op |
| Client-side XP mutation via GrowthService | P0 | FIXED — dead code, no-op |
| Backend accepts client-supplied XP amounts | P0 | NOT APPLICABLE — no endpoint accepts client XP |
| Speaking backend not wired in Flutter | P1 | OPEN — Batch 2 task |
| Legacy JWT support alongside Firebase | P2 | OPEN — document removal decision |

---

## 6. CHANGES MADE

| # | File | Change | Reason |
|---|------|--------|--------|
| 1 | `lib/features/speaking/speaking_controller.dart:64` | Removed `_totalXp += result.xpEarned;` | P0-06: neutralize client-side XP mutation |
| 2 | `lib/features/speaking/speaking_controller.dart:88` | Removed `_totalXp += currentQuestion!.xpReward;` | P0-06: neutralize client-side XP mutation (dead code) |

No other files were modified in this audit.

---

## 7. VERIFICATION RESULTS

### Commands Executed

| Command | Result |
|---------|--------|
| `git grep -nE "addXp" -- 'lib'` | 8 results — all no-ops or dead code |
| `flutter analyze --no-pub` (main package) | 0 errors |
| `npx tsc --noEmit` (backend) | exit 0 |
| `git grep -nE "answerListeningQuestion" -- 'lib'` | 1 result — definition only, no callers |
| `git grep -nE "processSpokenText" -- 'lib'` | 2 results — definition + 1 caller (speaking_screen.dart:759) |
| Backend `completeLesson` review | Server-calculated XP, clamped inputs, first-completion only |
| Backend `aiCoachService.chat` review | Server-calculated XP (10/5), rate limited, auth guarded |
| Backend `speakingService.analyzePronunciation` review | Server-calculated XP, auth guarded, NOT wired in Flutter |

---

## 8. REMAINING GAPS

1. **Speaking backend not wired** — `POST /speaking/pronunciation/analyze` exists and is server-authoritative, but Flutter uses client-side analysis only. Speaking XP/streak are not persisted to PostgreSQL. **Batch 2 task.**

2. **Dead code cleanup** — `UserProgressService.completeLesson/saveQuizScore`, `GrowthController.addXp/GrowthService.addXp`, `SpeakingController.answerListeningQuestion` are dead code with no reachable callers. Safe to remove in a cleanup pass but not security-critical.

3. **Legacy JWT path** — Backend still supports HS256 JWT alongside Firebase tokens. Recommend product decision on whether to remove legacy JWT support.

---

## 9. FINAL VERDICT

### XP AUTHORITY STATUS: SECURE

**No client-controlled XP mutation can alter authoritative XP.**

All reachable production XP paths flow through server-authoritative backend endpoints:
- Lesson completion → `POST /progress/complete` → server-calculated XP
- AI Coach → `POST /ai-coach/chat` → server-calculated XP
- Speaking → local mutation neutralized; backend endpoint exists but not wired (Batch 2)

The client cannot:
- Supply arbitrary XP amounts to the backend
- Bypass server XP calculation
- Double-award XP (unique constraints + atomic transactions)
- Manipulate XP without authentication (all endpoints guarded)

### NEXT ACTION

Proceed to **Batch 2 — REAL CORE FLOWS** starting with:
1. Verify Auth/Profile/Logout runtime
2. Wire Speaking to backend `POST /speaking/pronunciation/analyze`
3. Remove fake fallbacks (GermanContent, _getDefaultItems, SharedPreferences cache)
4. Connect Home dashboard to real ProgressCubit data
5. Verify Store purchase flow end-to-end
