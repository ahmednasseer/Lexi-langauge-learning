================================================================================
              LEXI REFACTOR PLAN
================================================================================
Document Type: Architectural Refactoring Plan
Status: APPROVED FOR IMPLEMENTATION
================================================================================

SECTION 1: CLASSIFICATION OF ALL FILES
================================================================================

CATEGORY: CORE SERVICES
--------------------------------------------------------------------------------
Current: lib/services/analytics_service.dart        → Target: lib/core/services/
Current: lib/services/connectivity_service.dart      → Target: lib/core/services/
Current: lib/services/notification_service.dart      → Target: lib/core/services/
Current: lib/services/storage_service.dart            → Target: lib/core/services/
Current: lib/services/api_service.dart                → Target: lib/core/services/

CATEGORY: CORE DATA SOURCES
--------------------------------------------------------------------------------
Current: lib/services/curriculum/curriculum_service.dart      → Target: lib/core/services/
Current: lib/services/curriculum/user_progress_service.dart   → Target: lib/core/services/

CATEGORY: FEATURE SERVICES (Stay in Features)
--------------------------------------------------------------------------------
Current: lib/features/advanced_speaking/services/ai_conversation_service.dart       → Stay
Current: lib/features/advanced_speaking/services/conversation_memory_service.dart   → Stay
Current: lib/features/advanced_speaking/services/voice_service.dart                 → Stay
Current: lib/features/ai_learning/ai_learning_service.dart                          → Stay
Current: lib/features/goethe/goethe_exam_service.dart                               → Stay
Current: lib/features/growth/growth_service.dart                                    → Stay
Current: lib/features/live_learning/live_learning_service.dart                      → Stay
Current: lib/features/pronunciation/speech_service.dart                             → Stay
Current: lib/features/subscription/payment_service.dart                             → Stay

CATEGORY: REPOSITORIES (Restructure within Features)
--------------------------------------------------------------------------------
Current: lib/features/auth/auth_repository.dart                     → Target: lib/features/auth/data/repositories/
Current: lib/features/profile/profile_repository.dart               → Target: lib/features/profile/data/repositories/
Current: lib/features/wallet/wallet_repository.dart                 → Target: lib/features/wallet/data/repositories/
Current: lib/features/lessons/lesson_repository.dart               → Target: lib/features/lessons/data/repositories/
Current: lib/features/store/store_repository.dart                   → Target: lib/features/store/data/repositories/
Current: lib/features/friends/friends_repository.dart               → Target: lib/features/friends/data/repositories/
Current: lib/features/community/community_repository.dart           → Target: lib/features/community/data/repositories/
Current: lib/features/notifications/notifications_repository.dart   → Target: lib/features/notifications/data/repositories/
Current: lib/features/search/search_repository.dart                 → Target: lib/features/search/data/repositories/
Current: lib/features/ai_tutor/ai_repository.dart                   → Target: lib/features/ai_tutor/data/repositories/
Current: lib/features/goethe/goethe_repository.dart                 → Target: lib/features/goethe/data/repositories/
Current: lib/features/growth/growth_repository.dart                 → Target: lib/features/growth/data/repositories/
Current: lib/features/live_learning/live_learning_repository.dart    → Target: lib/features/live_learning/data/repositories/
Current: lib/features/speaking/speaking_repository.dart             → Target: lib/features/speaking/data/repositories/
Current: lib/features/passport/passport_repository.dart             → Target: lib/features/passport/data/repositories/
Current: lib/features/certificates/certificates_repository.dart     → Target: lib/features/certificates/data/repositories/
Current: lib/features/achievements/achievements_repository.dart     → Target: lib/features/achievements/data/repositories/
Current: lib/features/daily_missions/daily_missions_repository.dart → Target: lib/features/daily_missions/data/repositories/
Current: lib/features/advanced_speaking/advanced_speaking_repository.dart → Target: lib/features/advanced_speaking/data/repositories/
Current: lib/features/ai_coach/ai_coach_repository.dart            → Target: lib/features/ai_coach/data/repositories/
Current: lib/features/ai_learning/ai_learning_repository.dart      → Target: lib/features/ai_learning/data/repositories/
Current: lib/features/account/achievements_repository.dart          → Target: lib/features/account/data/repositories/

CATEGORY: CONTROLLERS → BLOC/CUBIT
--------------------------------------------------------------------------------
Current: lib/features/auth/login_controller.dart                    → Target: lib/features/auth/presentation/cubit/
Current: lib/features/profile/profile_controller.dart               → Target: lib/features/profile/presentation/cubit/
Current: lib/features/home/home_controller.dart                     → Target: lib/features/home/presentation/cubit/
Current: lib/features/community/community_controller.dart           → Target: lib/features/community/presentation/cubit/
Current: lib/features/ai_tutor/ai_tutor_controller.dart             → Target: lib/features/ai_tutor/presentation/cubit/
Current: lib/features/ai_coach/ai_coach_controller.dart            → Target: lib/features/ai_coach/presentation/cubit/
Current: lib/features/goethe/goethe_exam_controller.dart           → Target: lib/features/goethe/presentation/cubit/
Current: lib/features/growth/growth_controller.dart                 → Target: lib/features/growth/presentation/cubit/
Current: lib/features/live_learning/live_learning_controller.dart   → Target: lib/features/live_learning/presentation/cubit/
Current: lib/features/speaking/speaking_controller.dart             → Target: lib/features/speaking/presentation/cubit/
Current: lib/features/advanced_speaking/speaking_controller.dart   → Target: lib/features/advanced_speaking/presentation/cubit/
Current: lib/features/ai_learning/ai_learning_controller.dart      → Target: lib/features/ai_learning/presentation/cubit/
Current: lib/features/lessons/lesson_controller.dart               → Target: lib/features/lessons/presentation/cubit/
Current: lib/features/daily_missions/daily_missions_controller.dart → Target: lib/features/daily_missions/presentation/cubit/

CATEGORY: MODELS → ENTITIES + DATA MODELS
--------------------------------------------------------------------------------
Current: lib/features/*/models/*.dart → Split into:
  - lib/features/*/domain/entities/ (Business entities)
  - lib/features/*/data/models/ (Data models/DTOs)

CATEGORY: DATA SOURCES
--------------------------------------------------------------------------------
Current: lib/data/german_content.dart → Target: lib/core/data/datasources/local/
Current: lib/data/models/*.dart       → Target: lib/core/data/models/

CATEGORY: SHARED MODELS → DOMAIN
--------------------------------------------------------------------------------
Current: lib/shared/models/achievement_model.dart → Target: lib/features/achievements/domain/entities/
Current: lib/shared/models/language_model.dart    → Target: lib/features/language/domain/entities/
Current: lib/shared/models/user_model.dart        → Target: lib/features/profile/domain/entities/

================================================================================
SECTION 2: DETAILED FILE MOVEMENT PLAN
================================================================================

FILE: analytics_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/analytics_service.dart
Target:     lib/core/services/analytics_service.dart
Reason:     Core service used across entire project
Safe:       YES - Only import path changes
Affects:    Any file importing from services/
Order:      PHASE 1

FILE: connectivity_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/connectivity_service.dart
Target:     lib/core/services/connectivity_service.dart
Reason:     Core service used across entire project
Safe:       YES - Only import path changes
Affects:    main.dart, any file using connectivity
Order:      PHASE 1

FILE: notification_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/notification_service.dart
Target:     lib/core/services/notification_service.dart
Reason:     Core service used across entire project
Safe:       YES - Only import path changes
Affects:    main.dart
Order:      PHASE 1

FILE: storage_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/storage_service.dart
Target:     lib/core/services/storage_service.dart
Reason:     Core service used across entire project
Safe:       YES - Only import path changes
Affects:    Files using storage
Order:      PHASE 1

FILE: api_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/api_service.dart
Target:     lib/core/services/api_service.dart
Reason:     Core service used across entire project
Safe:       YES - Only import path changes
Affects:    Repositories using API
Order:      PHASE 1

FILE: curriculum_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/curriculum/curriculum_service.dart
Target:     lib/core/services/curriculum_service.dart
Reason:     Core service for learning
Safe:       YES - Only import path changes
Affects:    main.dart, curriculum-related files
Order:      PHASE 1

FILE: user_progress_service.dart
--------------------------------------------------------------------------------
Current:    lib/services/curriculum/user_progress_service.dart
Target:     lib/core/services/user_progress_service.dart
Reason:     Core service for progress tracking
Safe:       YES - Only import path changes
Affects:    main.dart, progress-related files
Order:      PHASE 1

================================================================================
SECTION 3: REPOSITORY RESTRUCTURING
================================================================================

PATTERN: repositories/ → data/repositories/
--------------------------------------------------------------------------------
All repositories move ONE level deeper into data/ folder.

Example:
  lib/features/profile/profile_repository.dart
  → lib/features/profile/data/repositories/profile_repository.dart

AFFECTED FEATURES (22 repositories):
--------------------------------------------------------------------------------
auth, profile, wallet, lessons, store, friends, community, notifications,
search, ai_tutor, goethe, growth, live_learning, speaking, passport,
certificates, achievements, daily_missions, advanced_speaking, ai_coach,
ai_learning, account

SAFE: YES - Only import path changes
AFFECTS: Each feature's screens and controllers
ORDER: PHASE 2 (per feature)

================================================================================
SECTION 4: CONTROLLER → BLOC/CUBIT MIGRATION
================================================================================

PATTERN: controllers/ → presentation/cubit/
--------------------------------------------------------------------------------
All controllers become Cubits (simple) or Blocs (complex).

Example:
  lib/features/profile/profile_controller.dart
  → lib/features/profile/presentation/cubit/profile_cubit.dart

AFFECTED FEATURES (13 controllers):
--------------------------------------------------------------------------------
auth, profile, home, community, ai_tutor, ai_coach, goethe, growth,
live_learning, speaking, advanced_speaking, ai_learning, lessons,
daily_missions

SAFE: NO - Requires logic rewrite
AFFECTS: Each feature's screens
ORDER: PHASE 3 (per feature, after repositories)

================================================================================
SECTION 5: MODEL SPLITTING
================================================================================

PATTERN: models/ → domain/entities/ + data/models/
--------------------------------------------------------------------------------
Split each model into:
  - Entity (business logic, no JSON)
  - DataModel (JSON serialization)

Example:
  lib/features/profile/models/user.dart
  → lib/features/profile/domain/entities/user.dart (Entity)
  → lib/features/profile/data/models/user_model.dart (DataModel)

AFFECTED: All features with models/ folders
SAFE: NO - Requires code changes
ORDER: PHASE 4 (per feature)

================================================================================
SECTION 6: EXECUTION PHASES (UPDATED)
================================================================================

PHASE 1: CORE SERVICES (Day 1-2) ✅ COMPLETE
--------------------------------------------------------------------------------
Actions:
1. Create lib/core/services/ directory
2. Move analytics_service.dart
3. Move connectivity_service.dart
4. Move notification_service.dart
5. Move storage_service.dart
6. Move api_service.dart
7. Move curriculum_service.dart
8. Move user_progress_service.dart
9. Move auth_service.dart
10. Update all import paths
11. Verify compilation (ZERO ISSUES)

Files Moved: 8
Import Updates: ~30 files
Risk: LOW
STATUS: ✅ COMPLETE

PHASE 2: PILOT FEATURE MIGRATION (Day 3-5)
--------------------------------------------------------------------------------
SELECTED FEATURE: Auth (smallest, most critical)

Actions:
1. Create new directory structure for Auth:
   lib/features/auth/
   ├── data/
   │   ├── datasources/
   │   │   └── auth_remote_datasource.dart
   │   ├── models/
   │   │   └── user_model.dart
   │   └── repositories/
   │       └── auth_repository_impl.dart
   ├── domain/
   │   ├── entities/
   │   │   └── user.dart
   │   ├── repositories/
   │   └── usecases/
   │       ├── login_usecase.dart
   │       ├── register_usecase.dart
   │       └── logout_usecase.dart
   └── presentation/
       ├── bloc/
       │   └── auth_cubit.dart
       ├── screens/
       │   ├── login_screen.dart
       │   └── register_screen.dart
       └── widgets/
           └── auth_button.dart

2. Migrate auth_repository.dart → data/repositories/
3. Migrate login_controller.dart → presentation/bloc/
4. Create proper Repository Interface in domain/
5. Create Entities in domain/entities/
6. Create UseCases in domain/usecases/
7. Update all imports
8. Update DI container
9. Verify compilation (ZERO ISSUES)
10. Document as TEMPLATE

Risk: MEDIUM
STATUS: PENDING

PHASE 3: TEMPLATE VALIDATION (Day 6)
--------------------------------------------------------------------------------
Actions:
1. Review Auth migration
2. Document lessons learned
3. Create migration checklist
4. Apply same pattern to Profile feature

Risk: LOW
STATUS: PENDING

PHASE 4: BULK MIGRATION (Day 7-15)
--------------------------------------------------------------------------------
Actions:
1. Apply template to all remaining features
2. One feature at a time
3. Verify compilation after each
4. Update imports

Risk: MEDIUM
STATUS: PENDING

PHASE 5: FINAL CLEANUP (Day 16)
--------------------------------------------------------------------------------
Actions:
1. Delete empty directories
2. Run flutter analyze
3. Fix all warnings
4. Run full test suite
5. Verify app runs

Risk: LOW
STATUS: PENDING

================================================================================
SECTION 7: RISK MATRIX
================================================================================

Phase | Risk  | Rollback | Testing Required
------|-------|----------|------------------
  1   | LOW   | Easy     | Compilation only
  2   | LOW   | Easy     | Compilation only
  3   | MEDIUM| Medium   | Widget tests
  4   | MEDIUM| Medium   | Unit tests
  5   | LOW   | Easy     | Full QA

================================================================================
SECTION 8: ACCEPTANCE CRITERIA
================================================================================

Phase 1 Complete When:
☐ All core services in lib/core/services/
☐ All imports updated
☐ flutter analyze shows no errors
☐ App compiles and runs

Phase 2 Complete When:
☐ All repositories in feature/data/repositories/
☐ All imports updated
☐ flutter analyze shows no errors

Phase 3 Complete When:
☐ All controllers converted to Bloc/Cubit
☐ All screens use BlocProvider
☐ Widget tests pass

Phase 4 Complete When:
☐ All models split into Entity + DataModel
☐ JSON serialization works
☐ Unit tests pass

Phase 5 Complete When:
☐ Zero analyzer issues
☐ All tests pass
☐ App runs without errors

================================================================================
                    END OF REFACTOR PLAN
================================================================================
