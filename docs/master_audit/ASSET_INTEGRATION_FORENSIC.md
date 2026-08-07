# Lexi — Asset Integration Forensic Report

> **Status:** LOCKED — Audit Mode (No code modifications yet)  
> **Date:** July 29, 2026  
> **Scope:** Complete asset-system analysis across 201 Dart files and 38 asset files  
> **Role:** Principal Flutter Architect + Senior UI Integration Engineer + Design System Auditor

---

## 1. EXECUTIVE SUMMARY

| Metric | Value |
|---|---|
| Total Dart files scanned | 201 |
| Total asset files on disk | 38 (36 PNG + 2 Lottie JSON) |
| Assets declared in pubspec.yaml | 2 directories (images/, icons/) — **no individual files** |
| `Icons.*` placeholder usages | **462** |
| `GoogleFonts.*` usages | **665** |
| `LinearGradient` placeholder usages | **106** |
| `CustomPaint` (hand-drawn) usages | **13** |
| `Image.asset` usages | **0** |
| `Lottie.*` usages | **0** |
| `AudioPlayer` asset loads | **0** |
| Asset files properly referenced | **0/38** |
| Asset files with valid filenames | **0/38** |

**The app has 0 integrated assets. 100% of visuals are placeholders (Material Icons, gradients, CustomPaint, Google Fonts CDN).**

---

## 2. ASSET INVENTORY (Complete)

### 2.1 Characters (1024×1024, ARGB — transparent background)

| # | Current Filename | Size | Dimensions | Format | Alpha | Est. Category |
|---|---|---|---|---|---|---|
| 1 | `ChatGPT Image 29 … 06_53_28.png` | 1.57 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 2 | `ChatGPT Image 29 … 06_53_40.png` | 1.57 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 3 | `ChatGPT Image 29 … 06_53_55.png` | 1.63 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 4 | `ChatGPT Image 29 … 06_54_11.png` | 1.61 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 5 | `ChatGPT Image 29 … 06_54_21.png` | 1.56 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 6 | `ChatGPT Image 29 … 06_54_29.png` | 1.57 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 7 | `ChatGPT Image 29 … 06_54_36.png` | 1.54 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 8 | `ChatGPT Image 29 … 06_53_55.png` | 1.63 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 9 | `ChatGPT Image 29 … 06_56_08.png` | 1.78 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 10 | `ChatGPT Image 29 … 06_56_16.png` | 1.80 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 11 | `ChatGPT Image 29 … 07_28_27.png` | 1.66 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 12 | `ChatGPT Image 29 … 07_28_35.png` | 1.47 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 13 | `ChatGPT Image 29 … 07_28_42.png` | 1.56 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 14 | `ChatGPT Image 29 … 07_28_48.png` | 1.65 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 15 | `ChatGPT Image 29 … 07_29_08.png` | 2.13 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 16 | `ChatGPT Image 29 … 07_30_13.png` | 1.72 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |
| 17 | `ChatGPT Image 29 … 07_30_30.png` | 1.96 MB | 1024×1024 | PNG-32 | ✅ Yes | Character |

**Count: 17 character illustrations — all need renaming**

### 2.2 Badges / Frames / Achievements (1254×1254, RGB — opaque)

| # | Current Filename | Size | Dimensions | Format | Alpha | Est. Category |
|---|---|---|---|---|---|---|
| 1 | `ChatGPT Image 29 … 06_54_05.png` | 1.24 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 2 | `ChatGPT Image 29 … 06_54_47.png` | 1.22 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 3 | `ChatGPT Image 29 … 06_54_55.png` | 1.16 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 4 | `ChatGPT Image 29 … 06_55_03.png` | 1.08 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 5 | `ChatGPT Image 29 … 06_55_10.png` | 1.27 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 6 | `ChatGPT Image 29 … 06_55_17.png` | 1.31 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 7 | `ChatGPT Image 29 … 06_55_29.png` | 1.51 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 8 | `ChatGPT Image 29 … 06_55_35.png` | 1.64 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 9 | `ChatGPT Image 29 … 06_55_44.png` | 1.65 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 10 | `ChatGPT Image 29 … 06_55_58.png` | 1.65 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 11 | `ChatGPT Image 29 … 07_28_55.png` | 1.48 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 12 | `ChatGPT Image 29 … 07_29_02.png` | 1.57 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 13 | `ChatGPT Image 29 … 07_29_15.png` | 1.52 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |
| 14 | `ChatGPT Image 29 … 07_30_20.png` | 1.20 MB | 1254×1254 | PNG-24 | ❌ No | Badge/Frame |

**Count: 14 badges/frames/achievements — all need renaming**

### 2.3 Backgrounds (941×1672, RGB — opaque, 9:16 portrait)

| # | Current Filename | Size | Dimensions | Format | Alpha | Est. Category |
|---|---|---|---|---|---|---|
| 1 | `ChatGPT Image 29 … 07_29_25.png` | 1.88 MB | 941×1672 | PNG-24 | ❌ No | Background |
| 2 | `ChatGPT Image 29 … 07_29_31.png` | 2.01 MB | 941×1672 | PNG-24 | ❌ No | Background |
| 3 | `ChatGPT Image 29 … 07_29_38.png` | 2.36 MB | 941×1672 | PNG-24 | ❌ No | Background |
| 4 | `ChatGPT Image 29 … 07_29_45.png` | 2.67 MB | 941×1672 | PNG-24 | ❌ No | Background |
| 5 | `ChatGPT Image 29 … 07_29_51.png` | 2.25 MB | 941×1672 | PNG-24 | ❌ No | Background |
| 6 | `ChatGPT Image 29 … 07_29_58.png` | 2.33 MB | 941×1672 | PNG-24 | ❌ No | Background |
| 7 | `ChatGPT Image 29 … 07_30_04.png` | 1.72 MB | 941×1672 | PNG-24 | ❌ No | Background |

**Count: 7 backgrounds — all need renaming. WARNING: Resolution 941×1672 is non-standard (neither 1080×1920 nor 1080×2340).**

### 2.4 Lottie Animations

| # | Current Filename | Size | Dimensions | Type | Content |
|---|---|---|---|---|---|
| 1 | `Untitled file.json` | 32 KB | 512×512 | Lottie JSON | Confetti animation (60fps, 30 layers, one-shot) |
| 2 | `Untitled file (1).json` | 202 KB | Unknown | Lottie JSON | Unknown animation (needs inspection) |

**Count: 2 Lottie animations — both need renaming**

### 2.5 Empty Directories (No assets — only .gitkeep)

| Directory | Status |
|---|---|
| `assets/images/` | ❌ Empty (.gitkeep only) |
| `assets/icons/` | ❌ Empty (.gitkeep only) |
| `assets/animations/` | ❌ Empty |
| `assets/lottie/` | ❌ Empty |

---

## 3. ASSET USAGE IN FLUTTER CODEBASE

### 3.1 True Asset References (Real asset loading)

| API | Usage Count | Files | Status |
|---|---|---|---|
| `Image.asset()` | **0** | — | ❌ Missing |
| `AssetImage()` | **0** | — | ❌ Missing |
| `DecorationImage()` | **0** | — | ❌ Missing |
| `SvgPicture.asset()` | **0** | — | ❌ Missing |
| `Lottie.asset()` | **0** | — | ❌ Missing |
| `AudioPlayer` (asset) | **0** | — | ❌ Missing |
| `Image.network()` | **1** | `animated_avatar.dart:116` | ⚠️ Network-only |
| `CachedNetworkImage()` | **0** | — | ❌ Missing |

### 3.2 Placeholder Usages (462 Icons.* across 201 files)

| Category | Icon Used | Count | Purpose |
|---|---|---|---|
| Navigation/Back | `Icons.arrow_back_ios`, `Icons.arrow_forward_ios` | ~35 | Back/forward buttons |
| User/Avatar | `Icons.person`, `Icons.person_outline` | ~25 | Profile, avatars, store |
| Speaking/Mic | `Icons.mic`, `Icons.mic_none`, `Icons.mic_off` | ~15 | Speaking exercises |
| Streak/Fire | `Icons.local_fire_department` | ~8 | Streak tracking |
| Trophy/Award | `Icons.emoji_events`, `Icons.military_tech`, `Icons.workspace_premium` | ~12 | Achievements, premium |
| Stars/Gems | `Icons.star`, `Icons.diamond` | ~15 | Rewards, store |
| Check/Correct | `Icons.check_circle`, `Icons.check` | ~20 | Quiz results |
| Chat/Messages | `Icons.chat_bubble_outline`, `Icons.forum` | ~10 | Community |
| School/Learning | `Icons.school`, `Icons.auto_stories`, `Icons.menu_book` | ~10 | Lessons, courses |
| Media/Play | `Icons.play_arrow`, `Icons.play_circle_fill`, `Icons.headphones` | ~12 | Audio lessons |
| Misc | 150+ unique icon names | 462 total | All remaining UI |

### 3.3 CustomPaint & Hand-Drawn Graphics (13 usages)

| File | Line | Painter Class | What It Draws | Should Be |
|---|---|---|---|---|
| `certificates_screen.dart` | 102 | `ConfettiPainter` | Confetti particles | `lottie_confetti.json` |
| `certificates_screen.dart` | 599 | `ConfettiPainter` (impl) | Drawing logic | — |
| `payment/success_screen.dart` | 89 | `_ConfettiPainter` | Confetti particles | `lottie_confetti.json` |
| `payment/success_screen.dart` | 211 | `_ConfettiPainter` (impl) | Drawing logic | — |
| `frames_workshop_screen.dart` | 323 | `_OrnateFramePainter` | Frame borders | Frame asset images |
| `frames_workshop_screen.dart` | 458 | `_OrnateFramePainter` | Frame borders | Frame asset images |
| `frames_workshop_screen.dart` | 666 | `_OrnateFramePainter` | Frame borders | Frame asset images |
| `frames_workshop_screen.dart` | 781 | `_OrnateFramePainter` (impl) | Drawing logic | — |
| `speaking/microphone_animation.dart` | 120 | `_WavePainter` | Audio wave animation | Lottie wave |
| `speaking/microphone_animation.dart` | 143 | `_WavePainter` (impl) | Drawing logic | — |
| `shared/progress_ring.dart` | 89 | `_ProgressRingPainter` | Circular progress | — (keep) |
| `shared/progress_ring.dart` | 137 | `_ProgressRingPainter` (impl) | Drawing logic | — (keep) |

### 3.4 CircleAvatar & Letter Avatars (1 usage)

| File | Line | Usage |
|---|---|---|
| `ai_learning_screen.dart` | 97 | `CircleAvatar` with `Icons.person` |

Additional letter-avatar patterns found as gradient containers with text initials (profile_screen.dart:96, support_screen.dart:129).

---

## 4. DESIGN ISSUES & PROBLEMS DETECTED

### 4.1 CRITICAL — Asset Organization

| # | Issue | Severity |
|---|---|---|
| 1 | All 38 asset files dumped in `assets/` root directory (no subfolders) | 🔴 Critical |
| 2 | All files have nonsensical ChatGPT auto-generated names with special chars | 🔴 Critical |
| 3 | `pubspec.yaml` does NOT declare the root `assets/` directory — only `assets/images/` and `assets/icons/` | 🔴 Critical |
| 4 | Empty subdirectories (`images/`, `icons/`, `animations/`, `lottie/`) contradict actual asset locations | 🟠 High |
| 5 | Both Lottie files named "Untitled file.json" — zero discoverability | 🔴 Critical |

### 4.2 HIGH — Naming Convention Breaks

| # | Issue | Severity |
|---|---|---|
| 1 | Filenames contain unicode characters, spaces, and question marks | 🟠 High |
| 2 | No semantic naming — impossible to identify which asset is which | 🟠 High |
| 3 | No category prefix (e.g., `char_`, `bg_`, `badge_`, `ico_`) | 🟠 High |
| 4 | Case sensitivity risk on case-sensitive filesystems (Linux/Android) | 🟠 High |

### 4.3 MEDIUM — Size & Format Issues

| # | Issue | Severity |
|---|---|---|
| 1 | 36 PNGs avg ~1.6 MB = **~58 MB total** — excessive for mobile | 🟡 Medium |
| 2 | Largest PNG: 2.67 MB (background 941×1672) — needs WebP conversion | 🟡 Medium |
| 3 | Character PNGs (1024×1024) at 1.6 MB each — should be WebP or compressed PNG | 🟡 Medium |
| 4 | Backgrounds at 941×1672 — non-standard resolution, should be 1080×1920 | 🟡 Medium |
| 5 | Badges at 1254×1254 — oversized for badge use (should be 80-256px) | 🟡 Medium |
| 6 | No WebP format used despite spec documents requiring it | 🟡 Medium |
| 7 | No SVG for icons (Material Icons used instead) | 🟡 Medium |
| 8 | No MP3/WAV audio files found | 🟡 Medium |
| 9 | No TTF/OTF font files found | 🟡 Medium |

### 4.4 LOW — Missing Asset Types

| # | Missing Type | Expected Count |
|---|---|---|
| 1 | Audio SFX (correct, wrong, levelup, gem) | 4-5 files |
| 2 | Listening exercise audio | 1+ files |
| 3 | Local font files (Poppins TTF) | 4 files |
| 4 | Empty state illustrations | 2 files |
| 5 | Avatar part images | 10 files |

### 4.5 Suspicious Files

| # | Filename | Size | Note |
|---|---|---|---|
| 1 | `ChatGPT Image 29 … 06_54_05.png` | 1.24 MB at 1254×1254 | Single file in set with different timestamp |
| 2 | `ChatGPT Image 29 … 06_53_55.png` (first) | 1.63 MB | Duplicate timestamp? Check for duplicates |
| 3 | `ChatGPT Image 29 … 06_53_55.png` (second) | 1.63 MB | Appears in both 06:53 and 06:54 sets — possible duplicate |

**Note**: Two files share the timestamp `06_53_55` — possible duplicate. Need visual verification.

---

## 5. ASSET-TO-UI MAPPING

### 5.1 Characters → Screens

| Asset (proposed name) | Current Placeholder | Screen | File:Line | Difficulty |
|---|---|---|---|---|
| `char_lexi_happy.png` | Gradient circle + text | Onboarding welcome | `onboarding_screen.dart:263-321` | Easy |
| `char_lexi_thinking.png` | Gradient container + 'L' | Support screen mascot | `support_screen.dart:77-156` | Easy |
| `char_lexi_waving.png` | Gradient container + text | Onboarding page 1 | `onboarding_screen.dart:213-383` | Easy |
| `char_lexi_celebrating.png` | Trophy emoji + gradient | Onboarding result | `onboarding_screen.dart:694-867` | Easy |
| `char_lexi_studying.png` | Gradient card + icon | Dashboard continue card | `continue_learning_card.dart` | Medium |
| `char_lexi_speaking.png` | Icon.person circle | AI Coach status | `ai_coach_screen.dart:147` | Medium |
| `char_lexi_listening.png` | Icons.headphones | Audio lessons header | `audio_lessons_screen.dart:111` | Medium |
| (more character assets) | Icons.person | AI Learning screen | `ai_learning_screen.dart:100` | Medium |

### 5.2 Icons → Screens

| Asset (proposed name) | Current Placeholder | Screen | File:Line | Difficulty |
|---|---|---|---|---|
| `ico_vocabulary.png` | `Icons.book` | AI Learning stats | `ai_learning_screen.dart:578` | Easy |
| `ico_grammar.png` | `Icons.menu_book_outlined` | AI Coach chips | `ai_coach_screen.dart:563` | Easy |
| `ico_speaking.png` | `Icons.record_voice_over` | Speaking progress | `advanced_speaking_screen.dart:755` | Easy |
| `ico_streak.png` | `Icons.local_fire_department` | Streak screen | `daily_streak_screen.dart:229` | Easy |
| `ico_gems.png` | `Icons.diamond` | Store screen | `store_screen.dart:144` | Easy |
| `ico_trophy.png` | `Icons.emoji_events` | Streak screen | `daily_streak_screen.dart:238` | Easy |
| `ico_certificate.png` | `Icons.workspace_premium_outlined` | Certificates | `certificates_screen.dart:142` | Easy |
| `ico_crown.png` | `Icons.workspace_premium` | Premium screen | `premium_offer_screen.dart:146` | Easy |
| (14+ more icons) | Various Icons.* | Multiple screens | — | Easy-Medium |

### 5.3 Badges → Screens

| Asset (proposed name) | Current Placeholder | Screen | File:Line | Difficulty |
|---|---|---|---|---|
| `badge_a1.png` through `badge_c2.png` | Gradient text in container | Level badge widget | `level_badge.dart:35-141` | Medium |
| Level badges | Gradient container | Onboarding result | `onboarding_screen.dart:785-817` | Easy |

### 5.4 Frames → Screens

| Asset (proposed name) | Current Placeholder | Screen | File:Line | Difficulty |
|---|---|---|---|---|
| `frame_gold.png` | CustomPaint + Icons.person | Frames workshop | `frames_workshop_screen.dart:323-348` | Hard |
| `frame_silver.png` | CustomPaint + Icons.person | Frames workshop | `frames_workshop_screen.dart:458-487` | Hard |
| `frame_neon.png` | CustomPaint + Icons.person | Frames workshop | `frames_workshop_screen.dart:666-696` | Hard |

### 5.5 Backgrounds → Screens

| Asset (proposed name) | Current Placeholder | Screen | File:Line | Difficulty |
|---|---|---|---|---|
| `bg_space.png` | LinearGradient container | Backgrounds shop | `backgrounds_shop_screen.dart:281` | Medium |
| `bg_ocean.png` | LinearGradient container | Backgrounds shop | `backgrounds_shop_screen.dart:281` | Medium |
| (5 more backgrounds) | LinearGradient containers | Backgrounds shop | — | Medium |

### 5.6 Lottie → Screens

| Asset (proposed name) | Current Placeholder | Screen | File:Line | Difficulty |
|---|---|---|---|---|
| `lottie_confetti.json` | `CustomPaint(ConfettiPainter)` | Certificates | `certificates_screen.dart:102` | Hard |
| `lottie_confetti.json` | `CustomPaint(_ConfettiPainter)` | Payment success | `success_screen.dart:89` | Hard |
| `lottie_streak.json` | `Icons.local_fire_department` | Streak calendar | `streak_calendar.dart:185` | Medium |
| `lottie_microphone.json` | `CustomPaint(_WavePainter)` | Mic animation | `microphone_animation.dart:120` | Hard |

---

## 6. BROKEN REFERENCES & CONFIGURATION ISSUES

### 6.1 pubspec.yaml Analysis

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/      # Directory is EMPTY (.gitkeep only)
    - assets/icons/       # Directory is EMPTY (.gitkeep only)
```

**Issues:**
- ✅ `assets/images/` declared — but empty
- ✅ `assets/icons/` declared — but empty
- ❌ `assets/` (root) NOT declared — 38 asset files here are invisible to Flutter
- ❌ `assets/lottie/` NOT declared — 2 Lottie files here are invisible
- ❌ `assets/animations/` NOT declared — but empty anyway
- ❌ `fonts:` section missing entirely

**Launcher Icon config also broken:**
```yaml
flutter_launcher_icons:
  image_path: "assets/images/LexiLogo.jpg"     # ❌ File does not exist
  adaptive_icon_foreground: "assets/images/LexiLogo.jpg"  # ❌ File does not exist
```

### 6.2 Platform-Specific Issues

| Platform | Concern | Severity |
|---|---|---|
| Android | Case-sensitive filesystem — filenames with unicode chars may break | 🟠 High |
| iOS | Case-insensitive but special chars in filenames rejected by bundle | 🟠 High |
| Web | Path separators must be forward-slash (already correct) | ✅ OK |
| Desktop (Win/Mac/Linux) | Unicode filenames may cause indexing issues | 🟡 Medium |

---

## 7. PERFORMANCE AUDIT

### 7.1 File Sizes & Optimization Potential

| Category | Current Avg Size | Target Size | Suggested Format | Est. Savings |
|---|---|---|---|---|
| Characters (17 files) | ~1.65 MB each | ~200-400 KB | WebP (lossy, q=85) | ~80% |
| Badges (14 files) | ~1.40 MB each | ~50-150 KB | WebP (lossy) or compressed PNG | ~90% |
| Backgrounds (7 files) | ~2.17 MB each | ~300-500 KB | WebP (lossy) or JPEG q=85 | ~80% |
| Lottie (2 files) | 117 KB avg | — | Already efficient | ✅ OK |
| **Total** | **~58 MB** | **~8-12 MB** | | **~80% reduction** |

### 7.2 Memory Concerns

| Concern | Detail | Impact |
|---|---|---|
| 1024×1024 characters at 32-bit | ~4 MB per decode in memory | High — 17 simultaneous = 68 MB |
| 1254×1254 badges at 24-bit | ~3.8 MB per decode in memory | High — wasted on small badge widgets |
| 941×1672 backgrounds at 24-bit | ~4.5 MB per decode in memory | Medium — shown one at a time |
| No precaching strategy | Every image decoded on first render | Latency impact |

### 7.3 Caching Recommendations

| Asset Type | Strategy |
|---|---|
| Characters | `precacheImage()` on app start (top 3 most-used) |
| Badges | Keep in ImageCache via reusable widget |
| Backgrounds | Cache after first load, 2-3 max in memory |
| Lottie | Use `Lottie.asset()` with `animate: true` only when visible |
| Icons | Convert to SVG/WebP, let Flutter ImageCache handle |

---

## 8. MIGRATION PLAN — Integration Waves

### Wave 1: Foundation (Risk: LOW)
**Goal:** Fix asset declaration so files are loadable

| Step | Files Affected | Action |
|---|---|---|
| 1.1 | `pubspec.yaml` | Declare root `assets/` directory |
| 1.2 | `pubspec.yaml` | Declare `assets/lottie/` directory |
| 1.3 | `pubspec.yaml` | Fix or remove broken launcher icon paths |
| 1.4 | All asset files | Rename to semantic names (see Section 9) |

**Rollback:** Revert pubspec.yaml. No code changes.

### Wave 2: Characters (Risk: LOW-MEDIUM)
**Goal:** Replace gradient/text character placeholders with real images

| Step | Files | Replacements |
|---|---|---|
| 2.1 | `onboarding_screen.dart` | 3 character placeholders → `Image.asset()` |
| 2.2 | `support_screen.dart` | 1 character placeholder → `Image.asset()` |
| 2.3 | `ai_learning_screen.dart` | 1 CircleAvatar → `Image.asset()` |
| 2.4 | `ai_coach_screen.dart` | 1 character container → `Image.asset()` |
| 2.5 | `continue_learning_card.dart` | 1 character → `Image.asset()` |
| 2.6 | `advanced_speaking_screen.dart` | 1 character → `Image.asset()` |

**Rollback:** Revert specific file changes. ~8 files modified.

### Wave 3: UI Icons (Risk: LOW)
**Goal:** Replace ~20 key Material Icons with custom icon images

| Step | Files | Replacements |
|---|---|---|
| 3.1 | `store_screen.dart` | 5 category icons → `Image.asset()` |
| 3.2 | `daily_streak_screen.dart` | 4 stat icons → `Image.asset()` |
| 3.3 | `certificates_screen.dart` | 2 icon placeholders → `Image.asset()` |
| 3.4 | `learn_screen.dart` | Section header icons → `Image.asset()` |
| 3.5 | `profile_screen.dart` | 1-2 icons → `Image.asset()` |

**Rollback:** Revert specific file changes. ~15 files modified.

### Wave 4: Badges & Achievements (Risk: MEDIUM)
**Goal:** Replace gradient-level badges with real badge images

| Step | Files | Replacements |
|---|---|---|
| 4.1 | `level_badge.dart` | 6 level gradients → conditionally loaded badge images |
| 4.2 | `achievements_screen.dart` | Achievement icons → badge images |
| 4.3 | `onboarding_screen.dart` | Level result badge → badge image |

**Rollback:** Revert badge widget and screen changes. ~3 files modified.

### Wave 5: Frames & Backgrounds (Risk: MEDIUM-HIGH)
**Goal:** Replace CustomPaint and gradients with real images

| Step | Files | Replacements |
|---|---|---|
| 5.1 | `frames_workshop_screen.dart` | 3+ CustomPaint frames → `Image.asset()` |
| 5.2 | `backgrounds_shop_screen.dart` | 6+ gradient backgrounds → `Image.asset()` |
| 5.3 | `store_item_card.dart` | 4 icon previews → asset previews |

**Rollback:** Keep old CustomPaint code as fallback. ~3 files modified.

### Wave 6: Lottie Integration (Risk: MEDIUM)
**Goal:** Replace CustomPaint confetti/wave with Lottie animations

| Step | Files | Replacements |
|---|---|---|
| 6.1 | `certificates_screen.dart` | Remove ConfettiPainter, add `Lottie.asset()` |
| 6.2 | `success_screen.dart` | Remove _ConfettiPainter, add `Lottie.asset()` |
| 6.3 | `microphone_animation.dart` | Remove _WavePainter, add `Lottie.asset()` |
| 6.4 | `reward_animation.dart` | Add Lottie for streak/gem rewards |

**Rollback:** Keep old CustomPaint widgets as fallbacks. ~4 files modified.

### Wave 7: Audio (Risk: LOW)
**Goal:** Add SFX and listening audio

| Step | Files | Replacements |
|---|---|---|
| 7.1 | Add `assets/audio/` to pubspec | Add build files |
| 7.2 | Create audio service/helper | New file |
| 7.3 | Quiz screens | Play sfx_correct/sfx_wrong |
| 7.4 | `goethe_exam_service.dart` | Fix mock audioUrl → real asset path |

**Rollback:** Remove audio service. New code only.

### Wave 8: Local Fonts (Risk: LOW)
**Goal:** Bundle Poppins locally for offline + deterministic rendering

| Step | Files | Replacements |
|---|---|---|
| 8.1 | `pubspec.yaml` | Add `fonts:` section with Poppins TTF |
| 8.2 | Create `assets/fonts/poppins/` | Add 4 TTF files |
| 8.3 | Optionally refactor | Replace `GoogleFonts.poppins()` → `TextStyle(fontFamily: 'Poppins')` |

**Rollback:** Remove fonts section. GoogleFonts fallback still works.

### Wave 9: Performance Optimization (Risk: LOW)
**Goal:** Reduce bundle size, add precaching

| Step | Files | Action |
|---|---|---|
| 9.1 | All PNGs → WebP | Convert using cwebp or Squoosh |
| 9.2 | `main.dart` | Add `precacheImage()` for top 5 images |
| 9.3 | — | Add `flutter_native_screenshot` or image loading strategy |

---

## 9. RENAMING MAP — Current → Proposed

### 9.1 Characters (1024×1024, ARGB)

| Current Filename | Proposed Name |
|---|---|
| `ChatGPT Image 29 … 06_53_28.png` | `char_lexi_happy.png` |
| `ChatGPT Image 29 … 06_53_40.png` | `char_lexi_thinking.png` |
| `ChatGPT Image 29 … 06_53_55.png` (first) | `char_lexi_waving.png` |
| `ChatGPT Image 29 … 06_54_11.png` | `char_lexi_welcoming.png` |
| `ChatGPT Image 29 … 06_54_21.png` | `char_lexi_studying.png` |
| `ChatGPT Image 29 … 06_54_29.png` | `char_lexi_celebrating.png` |
| `ChatGPT Image 29 … 06_54_36.png` | `char_lexi_speaking.png` |
| `ChatGPT Image 29 … 06_53_55.png` (second) | `char_lexi_listening.png` |
| `ChatGPT Image 29 … 06_56_08.png` | `char_lexi_teacher_happy.png` |
| `ChatGPT Image 29 … 06_56_16.png` | `char_lexi_teacher_thinking.png` |
| `ChatGPT Image 29 … 07_28_27.png` | `char_lexi_avatar_default.png` |
| `ChatGPT Image 29 … 07_28_35.png` | `char_lexi_pose_01.png` |
| `ChatGPT Image 29 … 07_28_42.png` | `char_lexi_pose_02.png` |
| `ChatGPT Image 29 … 07_28_48.png` | `char_lexi_pose_03.png` |
| `ChatGPT Image 29 … 07_29_08.png` | `char_lexi_pose_04.png` |
| `ChatGPT Image 29 … 07_30_13.png` | `char_lexi_pose_05.png` |
| `ChatGPT Image 29 … 07_30_30.png` | `char_lexi_pose_06.png` |

### 9.2 Badges / Frames (1254×1254, RGB)

| Current Filename | Proposed Name |
|---|---|
| `ChatGPT Image 29 … 06_54_05.png` | `badge_a1.png` |
| `ChatGPT Image 29 … 06_54_47.png` | `badge_a2.png` |
| `ChatGPT Image 29 … 06_54_55.png` | `badge_b1.png` |
| `ChatGPT Image 29 … 06_55_03.png` | `badge_b2.png` |
| `ChatGPT Image 29 … 06_55_10.png` | `badge_c1.png` |
| `ChatGPT Image 29 … 06_55_17.png` | `badge_c2.png` |
| `ChatGPT Image 29 … 06_55_29.png` | `frame_gold.png` |
| `ChatGPT Image 29 … 06_55_35.png` | `frame_silver.png` |
| `ChatGPT Image 29 … 06_55_44.png` | `frame_neon.png` |
| `ChatGPT Image 29 … 06_55_58.png` | `frame_diamond.png` |
| `ChatGPT Image 29 … 07_28_55.png` | `achv_first_word.png` |
| `ChatGPT Image 29 … 07_29_02.png` | `achv_streak_7.png` |
| `ChatGPT Image 29 … 07_29_15.png` | `achv_streak_30.png` |
| `ChatGPT Image 29 … 07_30_20.png` | `achv_100_words.png` |

### 9.3 Backgrounds (941×1672, RGB)

| Current Filename | Proposed Name |
|---|---|
| `ChatGPT Image 29 … 07_29_25.png` | `bg_space.png` |
| `ChatGPT Image 29 … 07_29_31.png` | `bg_ocean.png` |
| `ChatGPT Image 29 … 07_29_38.png` | `bg_forest.png` |
| `ChatGPT Image 29 … 07_29_45.png` | `bg_city.png` |
| `ChatGPT Image 29 … 07_29_51.png` | `bg_mountain.png` |
| `ChatGPT Image 29 … 07_29_58.png` | `bg_abstract.png` |
| `ChatGPT Image 29 … 07_30_04.png` | `bg_aurora.png` |

### 9.4 Lottie (JSON)

| Current Filename | Proposed Name |
|---|---|
| `Untitled file.json` | `lottie_confetti.json` |
| `Untitled file (1).json` | `lottie_success_check.json` |

---

## 10. FINAL RECOMMENDATION

### Immediate Actions (Pre-Integration)

1. **🔴 CRITICAL — Rename all 38 files** to semantic names before any code changes
2. **🔴 CRITICAL — Fix `pubspec.yaml`** to declare all asset directories:
   ```yaml
   assets:
     - assets/images/
     - assets/icons/
     - assets/ (or specific subdirectories after reorganization)
   ```
3. **🔴 CRITICAL — Move files into proper subdirectories** (`assets/images/characters/`, `assets/images/badges/`, etc.)
4. **🟠 HIGH — Fix launcher icon path** in pubspec.yaml (remove broken `LexiLogo.jpg` reference or add the file)
5. **🟠 HIGH — Convert large PNGs to WebP** to reduce bundle size from ~58 MB to ~10 MB
6. **🟠 HIGH — Deduplicate** check for identical files (two files share timestamp `06_53_55`)

### Integration Order (Approved Waves)

| Wave | What | Risk | Est. Files Changed | Est. Effort |
|---|---|---|---|---|
| 1 | Foundation (pubspec + folder setup) | LOW | 1 | 30 min |
| 2 | Characters | LOW-MED | 8 | 2-3 hours |
| 3 | UI Icons | LOW | 15 | 3-4 hours |
| 4 | Badges & Achievements | MEDIUM | 3 | 1-2 hours |
| 5 | Frames & Backgrounds | MED-HIGH | 3 | 2-3 hours |
| 6 | Lottie | MEDIUM | 4 | 2-3 hours |
| 7 | Audio | LOW | 3 | 1-2 hours |
| 8 | Local Fonts | LOW | 1 | 30 min |
| 9 | Performance | LOW | 2 | 1 hour |
| **Total** | | | **~40 files** | **~14-20 hours** |

### Files NOT to Modify
- `lib/services/` — No UI assets here (auth, analytics, etc.)
- `lib/core/theme/` — Colors and gradients stay (design system)
- `lib/shared/widgets/progress_ring.dart` — CustomPaint progress ring is intentional
- `lib/shared/widgets/glass_card.dart`, `glow_container.dart` — Structural widgets
- `lib/shared/widgets/gradient_button.dart` — Gradient buttons are design-system choice
- `lib/features/wallet/` — No asset replacements needed
- `lib/features/subscription/` — Keep gradients for plans

### Risk Register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Asset misidentified (wrong category) | Medium | Low | Visual verify each file before mapping |
| Duplicate files in assets | Medium | Low | SHA-1 check before dedup |
| CustomPaint removal breaks animation | Low | High | Keep old widget as fallback via feature flag |
| Image dimensions don't fit UI | Medium | Medium | Use `BoxFit.cover/contain` flexibly |
| Font swap changes layout | Low | Medium | Keep GoogleFonts as fallback in parallel |

---

*End of Forensic Report. Awaiting approval before any code modifications.*
