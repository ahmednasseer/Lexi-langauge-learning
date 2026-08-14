# LEXI — BATCH 1 HANDOVER ACCEPTANCE

## 1. Overall Verdict

**ACCEPTED WITH BLOCKERS**

BATCH 1 security lockdown code changes are verified and correct. All client-side XP mutation paths are neutralized or proven dead/no-op. Backend rules and hardening are in place.

However, one active security incident remains unresolved: **the Firebase Admin service-account private key is still present in the git history (HEAD)**. The working-tree deletion was staged but never committed, and the key must be rotated externally regardless.

## 2. P0 Security Status

| ID | Issue | Actual State | Status | Evidence | Required Action |
|---|---|---|---|---|---|
| P0-01 | Service-account JSON in git history | File `scripts/lexi-33b14-firebase-adminsdk-fbsvc-133d5568e2.json` is present in HEAD blob. `git rm --cached` was run and the deletion is staged (`D ` in `git status --short`), but the removal has **not been committed**. The physical file still exists on disk. `.gitignore` has `scripts/*.json`. | **MANUAL ACTION REQUIRED** | `git ls-tree -r HEAD -- scripts/lexi-...json` returns blob. `git diff --cached` shows staged deletion. `git status --short` shows `D `. | Commit the staged deletion. Then purge history with `git filter-repo` or BFG. Then **rotate Firebase Admin key externally** in Firebase Console. |
| P0-02 | backend/.env tracking | File exists on disk. `git ls-files backend/.env` returns nothing. `git check-ignore -v backend/.env` confirms `.gitignore:8:.env backend/.env`. | **VERIFIED** | Untracked and ignored. | Rotate credentials externally. |
| P0-03 | JWT_SECRET fail-fast | `backend/src/main.ts:7-12` throws if `JWT_SECRET` is missing, contains `change-this`, or is shorter than 32 chars. | **CODE-VERIFIED** | Read main.ts. | Configure real `JWT_SECRET` in backend/.env externally. |
| P0-04 | express.json body limit | `backend/src/main.ts:24` sets `express.json({ limit: '1mb' })`. | **CODE-VERIFIED** | Read main.ts. | None. |
| P0-05 | Swagger disabled in production | `backend/src/main.ts:68-69` gates Swagger behind `!isProduction`. | **CODE-VERIFIED** | Read main.ts. | None. |
| P0-06 | Production stack traces hidden | `exception.filter.ts:44` omits `stack` field when `isProduction`. | **CODE-VERIFIED** | Read exception.filter.ts. | None. |
| P0-07 | Client-side XP mutation — Lesson completion | `lesson_detail_screen.dart:580` calls `AuthService.instance.addXp(xp)`. `addXp()` is now a documented no-op. Backend `POST /progress/complete` server-calculates XP from `lesson.xpReward * (clampedScore / 100)` with first-completion-only atomic transaction. | **FIXED / SERVER-AUTHORITATIVE** | Read auth_service.dart, lesson_detail_screen.dart, backend progress.service.ts. | None. |
| P0-08 | Client-side XP mutation — AI Coach | `ai_coach_controller.dart:78` calls `AuthService.instance.addXp(response.xpEarned!)`. `addXp()` is now a no-op. Backend `POST /ai-coach/chat` server-determines `xpEarned` (5 or 10). Local `_todayXp`/`_totalXp` are ChangeNotifier display state only. | **FIXED / SERVER-AUTHORITATIVE** | Read ai_coach_controller.dart, backend ai-coach.service.ts. | None. |
| P0-09 | Client-side XP mutation — Speaking | `speaking_controller.dart:64` previously mutated `_totalXp += result.xpEarned`. **This session removed the mutation.** `_streak` remains local session state. Backend `POST /speaking/pronunciation/analyze` exists but is not wired in Flutter (Batch 2 task). | **FIXED (local mutation removed)** | Read speaking_controller.dart before/after. | Wire speaking to backend in Batch 2. |
| P0-10 | Client-side XP mutation — Growth/UserProgressService | `home_controller.dart` addXp removed. `app_provider.dart` addXp removed. `user_progress_service.dart` addXp converted to no-op. `growth_service.dart` addXp is dead code (no reachable callers). `completeLesson`/`saveQuizScore` on `UserProgressService` have no external callers. | **FIXED / DEAD CODE** | Read home_controller.dart, app_provider.dart, user_progress_service.dart, growth_service.dart. | Safe to remove dead code in cleanup pass. |
| P0-11 | FCM token debug logging | `notification_service.dart` does not debugPrint `_fcmToken`. Remaining debugPrint calls print notification titles/errors, not secrets. | **CODE-VERIFIED** | Read notification_service.dart. | None. |

## 3. P1 Security Status

| ID | Issue | Actual State | Status | Evidence | Required Action |
|---|---|---|---|---|---|
| P1-01 | iOS Firebase configuration | `ios/Runner/GoogleService-Info.plist` is **MISSING**. | **MANUAL ACTION REQUIRED** | `Test-Path ios/Runner/GoogleService-Info.plist` returns False. | Download from Firebase Console and add to iOS project. |
| P1-02 | External secret rotation | Real credentials exist in `backend/.env` (PostgreSQL, Stripe, OpenAI, JWT_SECRET). Firebase Admin key in git history. | **MANUAL ACTION REQUIRED** | backend/.env present on disk. Service-account JSON in HEAD. | Rotate all secrets externally after history purge. |
| P1-03 | Firestore rules — email verification | `isVerifiedUser()` helper requires `email_verified == true` on sensitive client writes (users, posts, comments). Server-authoritative collections (progress, wallet, inventory, achievements, streaks, missions, premium) remain `allow write: if false`. | **CODE-VERIFIED** | Read firestore.rules. | Runtime validation blocked (emulator unavailable); static review passed. |
| P1-04 | Storage rules — avatar uploads | `storage.rules` enforces 5MB limit and `image/.*` content type on `/avatars/{userId}/**`. Default deny for all other paths. | **CODE-VERIFIED** | Read storage.rules. | Runtime validation blocked (emulator unavailable); static review passed. |
| P1-05 | Firebase public API key exposure | `google-services.json`, `backend/firebase-config.json`, and `lib/firebase_options.dart` contain the same Firebase public client API key (`AIza...`). This is **not a secret** — Firebase API keys are public identifiers. | **SAFE** | Static scan. | None. |

## 4. XP Authority Audit

### Server-Authoritative Paths

| Feature | Backend Endpoint | XP Calculation | Double-Award Protection | Status |
|---|---|---|---|---|
| Lesson completion | `POST /progress/complete` | `lesson.xpReward * (clampedScore / 100)` — derived from server-known lesson metadata | Unique constraint `userId_lessonId`; atomic transaction; P2002 race handling | **SAFE / SERVER-AUTHORITATIVE** |
| AI Coach | `POST /ai-coach/chat` | Hardcoded server-side: 10 for corrections, 5 for normal messages | Daily rate limit (20/day); auth guard | **SAFE / SERVER-AUTHORITATIVE** |
| Speaking (backend exists, not wired) | `POST /speaking/pronunciation/analyze` | Server-calculated from pronunciation metrics | Auth guard | **UNVERIFIED (not wired in Flutter)** |

### Client-Side Neutralized

| Feature | Client Call | Current Behavior | Authoritative XP Affected |
|---|---|---|---|
| Lesson detail screen | `AuthService.instance.addXp(xp)` | No-op | NO |
| AI Coach screen | `AuthService.instance.addXp(response.xpEarned!)` | No-op | NO |
| AI Coach screen | `_todayXp += response.xpEarned!` | Local ChangeNotifier display state only | NO |
| AI Coach screen | `_totalXp += response.xpEarned!` | Local ChangeNotifier display state only | NO |
| Speaking | `_totalXp += result.xpEarned` | **Removed this session** | NO |
| Speaking | `_totalXp += currentQuestion!.xpReward` | Dead code (no callers), removed this session | NO |

### Dead / Unreachable Code

| Code | Reachable | Persists XP | Status |
|---|---|---|---|
| `UserProgressService.completeLesson()` | NO | SharedPreferences (stale cache) | DEAD CODE |
| `UserProgressService.saveQuizScore()` | NO | SharedPreferences (stale cache) | DEAD CODE |
| `GrowthService.addXp()` | NO | SharedPreferences (local display cache) | DEAD CODE |
| `GrowthController.addXp()` | NO | Delegates to GrowthService | DEAD CODE |
| `auth_service.dart` `addXp()` | YES (legacy callers) | None (no-op) | SAFE / LEGACY NO-OP |

### Summary

**No client-controlled XP mutation can alter authoritative XP.**

All reachable production XP flows either:
- Call backend endpoints that server-calculate XP, OR
- Invoke documented no-ops, OR
- Update local UI display state only

## 5. Verification Evidence

| Command | Result |
|---|---|
| `git status --short` | Shows `D ` for service-account JSON (staged deletion); many working-tree modifications unrelated to BATCH 1 |
| `git diff --stat` | 235 files changed, 14736 insertions(+), 8073 deletions(-) — large working tree diff unrelated to BATCH 1 |
| `git log --oneline -10` | Recent commits: Render deployment fixes, Prisma migrations, Supabase fixes |
| `git ls-files scripts/*.json` | Returns only `scripts/package-lock.json`, `scripts/package.json` — service-account JSON NOT in current index |
| `git ls-tree -r HEAD -- scripts/lexi-...json` | **BLOB PRESENT** — key is in HEAD git history |
| `git ls-files backend/.env` | Empty — not tracked |
| `git check-ignore -v backend/.env` | `.gitignore:8:.env backend/.env` — ignored |
| `git grep addXp lib/` | 8 results — all no-ops, dead code, or local display state |
| `git grep _totalXp lib/` | 4 results — all local display state only |
| `git grep totalXp lib/` | Results in models only — no authoritative writes |
| `flutter analyze --no-pub` | Main `lib/` package: **0 errors**. `admin_dashboard` has 119 pre-existing errors (unrelated). |
| `npx tsc --noEmit` (backend) | **exit 0** |
| Secret scan (tracked files) | Only public Firebase client API keys found (`AIza...`). No passwords, tokens, or private keys. |
| `firestore.rules` static review | `isVerifiedUser()` enforced; server-authoritative collections write-blocked |
| `storage.rules` static review | 5MB + `image/*` restriction on avatars; default deny |

## 6. Files Actually Changed During YOUR Session

| File | Change |
|---|---|
| `lib/features/speaking/speaking_controller.dart` | Removed `_totalXp += result.xpEarned` (line 64) and `_totalXp += currentQuestion!.xpReward` (line 88) — neutralized client-side XP mutations discovered during audit |

No other files were modified in this session. BATCH 1 changes from the previous agent were verified but not re-applied.

## 7. Remaining Blockers

1. **Service-account private key in git history (P0)**
   - File: `scripts/lexi-33b14-firebase-adminsdk-fbsvc-133d5568e2.json`
   - Current state: Present in HEAD blob. `git rm --cached` was run and deletion is staged (`D ` in git status), but **not committed**. Physical file still exists on disk.
   - Required: Commit the staged deletion. Then purge history with `git filter-repo` or BFG; force-push. Then **rotate Firebase Admin key externally** in Firebase Console.

2. **External secret rotations (P0/P1)**
   - PostgreSQL/Supabase password
   - Stripe secret key
   - OpenAI API key
   - Real `JWT_SECRET` in backend/.env
   - Firebase Admin key (after history purge)

3. **Missing iOS Firebase configuration (P1)**
   - `ios/Runner/GoogleService-Info.plist` is absent.
   - Required: Download from Firebase Console and add to iOS project.

4. **Speaking backend not wired (P1)**
   - Backend endpoint `POST /speaking/pronunciation/analyze` exists and is server-authoritative.
   - Flutter client uses local `PronunciationResult.analyze()` only.
   - Speaking XP/streak are not persisted to PostgreSQL.
   - **Batch 2 task.**

## 8. Things You DID NOT TOUCH

- SaaS/multi-tenancy architecture
- BATCH 2 feature work
- P2 features
- Fake fallbacks (`GermanContent`, `_getDefaultItems`, silent `catch (_) {}`, mock data)
- UI redesign
- State management refactoring
- Billing/payment architecture
- Database schema migrations
- `admin_dashboard` package (119 pre-existing errors)

## 9. Next Phase

**BATCH 1 status: ACCEPTED WITH BLOCKERS**

The security lockdown code changes are verified and correct. Proceeding to Batch 2 requires explicit approval and should address:

1. Resolve P0 blocker: purge service-account JSON from git history and rotate all external secrets.
2. Resolve P1 blocker: add iOS Firebase plist.
3. Then begin **BATCH 2 — REAL CORE FLOWS**:
   - Authentication runtime verification
   - Profile runtime verification
   - Home/Lessons/Progress runtime verification
   - Wire Speaking to backend
   - Remove fake fallbacks
   - Connect real backend data

Do not proceed to Batch 2 until the P0 history-purge blocker is resolved.
