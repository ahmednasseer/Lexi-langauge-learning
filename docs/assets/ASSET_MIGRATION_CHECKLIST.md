# Asset Migration Checklist

## Phase 1: Asset Pipeline Infrastructure ✅ DONE

| Step | Status | Details |
|------|--------|---------|
| 1a. Create folder structure | ✅ | 14 subdirectories in `assets/` |
| 1b. Move PNGs to subdirectories | ✅ | 37 files → 5 categories |
| 1c. Move Lottie JSONs | ✅ | 2 files → `assets/lottie/` |
| 1d. Semantic rename | ✅ | All assets follow `snake_case` convention |
| 1e. Update `pubspec.yaml` | ✅ | Declares 6 directories, launcher icon fixed |
| 1f. Create `AppAssets` constants | ✅ | 39 constants in `lib/core/constants/app_assets.dart` |
| 1g. Validate no duplicates | ✅ | All paths are unique; all files present |
| 1h. `flutter analyze` | ✅ | Clean (only 3 pre-existing infos) |
| 1i. Pipeline documentation | ✅ | `ASSET_PIPELINE.md`, `RENAME_TABLE.md`, `ORPHAN_ASSETS.md` |

## Phase 2: UI Migration ⏸️ BLOCKED (User instruction)

| Step | Status | Details |
|------|--------|---------|
| 2a. `home_screen.dart` | ⏸️ | 65 `Icons.*` → `AppAssets.*` |
| 2b. `avatar_editor_screen.dart` | ⏸️ | 25 `Icons.*` → `AppAssets.*` |
| 2c. `profile_screen.dart` | ⏸️ | 24 `Icons.*` → `AppAssets.*` |
| 2d. All remaining screens | ⏸️ | 348 more `Icons.*` → `AppAssets.*` |
| 2e. Remove `cupertino_icons` dep | ⏸️ | If no longer needed after migration |
| 2f. Validate no placeholder regressions | ⏸️ | Manual visual review |

## Phase 3: Optimization (Future)

| Step | Status | Details |
|------|--------|---------|
| 3a. WebP conversion | ❌ | 37 PNGs → lossy/lossless WebP (estimated -74% size) |
| 3b. Lottie compression | ❌ | Strip unused layers from JSON |
| 3c. `flutter_lottie` package | ❌ | Add dependency when Lottie is wired |
| 3d. Re-validate paths | ❌ | After conversion, update `AppAssets` extensions |

## Current State Summary

- **39 assets** organized, renamed, registered, and centralized.
- **0 assets rendered** — all waiting for Phase 2 UI migration.
- **`flutter analyze`** passes clean (0 errors, 0 warnings).
- **`flutter pub get`** resolves cleanly.
