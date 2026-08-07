# Orphan Assets Report

**All 39 assets are currently orphaned.** None are rendered by any widget.

## Discovery Method

- Grep for `AppAssets.` (0 hits outside `app_assets.dart`)
- Grep for `Image.asset` (0 hits)
- Grep for `AssetImage` (0 hits)
- Grep for `Lottie.asset` (0 hits)
- Grep for asset path strings (0 hits outside `app_assets.dart`)

## What Orphans Exists

| Group | Count | Files |
|-------|-------|-------|
| Characters | 16 | `lexi_happy`, `lexi_thinking`, `lexi_waving`, `lexi_welcoming`, `lexi_studying`, `lexi_celebrating`, `lexi_speaking`, `lexi_teacher_happy`, `lexi_teacher_thinking`, `lexi_default`, `lexi_pose_01`–`06` |
| Badges | 6 | `badge_a1`–`c2` |
| Frames | 4 | `frame_gold`, `frame_silver`, `frame_neon`, `frame_diamond` |
| Achievements | 4 | `achievement_first_word`, `achievement_streak_7`, `achievement_streak_30`, `achievement_100_words` |
| Backgrounds | 7 | `bg_space`, `bg_ocean`, `bg_forest`, `bg_city`, `bg_mountain`, `bg_abstract`, `bg_aurora` |
| Lottie | 2 | `lottie_confetti`, `lottie_success_check` |

## Why They're Orphaned

The codebase was built entirely with Material Design `Icons.*` placeholders — **462 references** across **65+ feature files**. The migration plan will replace these in order of priority.

## What the Placeholder Gaps Look Like

| Feature File | `Icons.*` Count | Probable Asset Need |
|---|---|---|
| `home_screen.dart` | 65 | Characters, backgrounds |
| `avatar_editor_screen.dart` | 25 | Characters, frames, badges |
| `profile_screen.dart` | 24 | Characters, badges |
| `live_learning_screen.dart` | 18 | Characters, backgrounds |
| `community_screen.dart` | 18 | Characters, avatars |
| `advanced_speaking_screen.dart` | 18 | Characters |
| `ai_learning_screen.dart` | 15 | Characters, backgrounds |
| `achievements_screen.dart` | 10 | Achievements, badges |
| `gamification_screen.dart` | 6 | Badges, frames, achievements |
| `backgrounds_shop_screen.dart` | 3 | Backgrounds |
| `character_selection_screen.dart` | 2 | Characters |
| … 54 more files | 1–13 each | Mixed |

## Next Step (Phase 2)

Import `AppAssets` and replace `Icons.*` with `Image.asset(AppAssets.*)` in the files above, starting with the highest-icon-count files.
