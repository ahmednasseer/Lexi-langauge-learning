# Asset Pipeline Architecture

## Directory Structure

```
assets/
  images/
    achievements/   # 4 files — achievement unlock badges
    avatars/        # (empty) — future avatar customization
    backgrounds/    # 7 files — scene backgrounds
    badges/         # 6 files — CEFR level badges (A1–C2)
    characters/     # 16 files — Lexi character expressions & poses
    empty/          # (empty) — future empty-state illustrations
    frames/         # 4 files — avatar frame overlays
    icons/          # (empty) — future custom icons
    misc/           # (empty) — future miscellaneous graphics
    rewards/        # (empty) — future reward animations
  lottie/           # 2 files — Lottie JSON animations
  animations/       # (empty) — future Rive/Lottie/raw animations
  audio/            # (empty) — future sound effects / voice
  fonts/            # (empty) — future custom fonts
```

## Naming Convention

All assets use `snake_case` with categorical prefixes:

| Category     | Prefix           | Example                          |
|--------------|------------------|----------------------------------|
| Characters   | `lexi_`          | `lexi_happy.png`                 |
| Badges       | `badge_`         | `badge_a1.png`                   |
| Frames       | `frame_`         | `frame_gold.png`                 |
| Achievements | `achievement_`   | `achievement_first_word.png`     |
| Backgrounds  | `bg_`            | `bg_space.png`                   |
| Lottie       | `lottie_`        | `lottie_confetti.json`           |

## Constants Layer

All paths are centralized in `lib/core/constants/app_assets.dart`.

```dart
import 'package:your_app/core/constants/app_assets.dart';

Image.asset(AppAssets.lexiHappy);        // character
Image.asset(AppAssets.badgeA1);           // badge
Image.asset(AppAssets.bgSpace);           // background
// Lottie would use: Lottie.asset(AppAssets.lottieConfetti)
```

## Registration

`pubspec.yaml` declares only directories that currently contain assets:

```yaml
assets:
  - assets/images/achievements/
  - assets/images/backgrounds/
  - assets/images/badges/
  - assets/images/characters/
  - assets/images/frames/
  - assets/lottie/
```

Add new directories here when they gain assets.

## Current Usage Status

**0 of 39 assets are rendered.** All screens currently use Material `Icons.*` placeholders (462 references across 65+ files). The migration plan (Phase 2) will replace these with `Image.asset(AppAssets.*)` calls.

## Dependency & Validation

- `flutter analyze` passes cleanly.
- All 39 asset paths in `app_assets.dart` match files on disk.
- No duplicate content (verified by size comparison).
