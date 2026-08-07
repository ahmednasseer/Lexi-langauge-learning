# Visual Consistency Audit

## 1. Character Rendering

| Screen | Asset | Widget Size | Fill | Perceived | Verdict |
|--------|-------|-------------|------|-----------|---------|
| Splash | `lexiHappy` | 120×120 | 22% | 56px | ✅ Appropriate for splash hero |
| Home | `lexiHappy` | 80×80 | 22% | 38px | ✅ Correct for header Row |
| Onboarding | `lexiWelcoming` | 180×180 | 25.7% | 91px | ✅ Welcome hero, intentionally large |
| Support | `lexiDefault` | 120×120 | 40.4% | 76px | ✅ Adjusted from 160→120 in refinement |
| AI Tutor | `lexiTeacherHappy` | 48×48 | 48.4% | 33px | ✅ Standard chat avatar size |

**Result: ✅ Consistent.** Perceived sizes range from 33px (avatar) to 91px (hero). Each fits its screen role. No two characters at similar display levels have mismatched perceived sizes.

## 2. Image Quality & Format Consistency

| Category | Dims | Format | DPI | Alpha | Verdict |
|----------|------|--------|-----|-------|---------|
| Characters | 1024×1024 | 32bppArgb | 96 | ✅ Yes | ✅ |
| Badges | 1254×1254 | 24bppRgb | 96 | ❌ No (solid bg) | ✅ Expected |
| Achievements | 1254×1254 | 24bppRgb | 96 | ❌ No (solid bg) | ✅ Expected |
| Frames | 1254×1254 | 24bppRgb | 96 | ❌ No (solid bg) | ✅ Expected |
| Backgrounds | 941×1672 | 24bppRgb | 96 | ❌ No (solid bg) | ✅ Portrait orientation |
| Lottie | JSON | — | — | — | ✅ |

All PNGs are 96 DPI — consistent across all categories. No mixed resolutions.

## 3. BoxFit Usage

| File | Asset | BoxFit | Risk |
|------|-------|--------|------|
| `splash_screen.dart` | `lexiHappy` | `BoxFit.cover` | ✅ 1:1 aspect, no stretch |
| `onboarding_screen.dart` | `lexiWelcoming` | `BoxFit.cover` | ✅ 1:1 aspect, no stretch |
| `home_screen.dart` | `lexiHappy` | `BoxFit.cover` | ✅ 1:1 aspect, no stretch |
| `support_screen.dart` | `lexiDefault` | `BoxFit.cover` | ✅ 1:1 aspect, no stretch |
| `ai_tutor_screen.dart` | `lexiTeacherHappy` | `BoxFit.cover` | ✅ 1:1 aspect, no stretch |
| `certificates_screen.dart` | `badgeB1` (in pill) | `BoxFit.cover` | ✅ Circular clip, 1:1 source |
| `onboarding_screen.dart` | `badgeB1` (in pill) | `BoxFit.cover` | ✅ Circular clip, 1:1 source |
| `level_badge.dart` | `badge*` | `BoxFit.cover` | ✅ Circular clip, 1:1 source |

**Result: ✅ No pixelation or stretch risk.** All assets are square (1:1 aspect ratio) displayed in square containers with `BoxFit.cover`. Backgrounds (941×1672) are not yet rendered in any widget.

## 4. Badge Consistency (Onboarding vs Certificates)

Both screens now use the same pattern:
- Gold gradient pill container (borderRadius: 30)
- `ClipOval` with `Image.asset(AppAssets.badgeB1, fit: BoxFit.cover)`
- Text "B1" at right (28px cert / 36px onboarding)

| Metric | Certificates | Onboarding |
|--------|-------------|------------|
| Badge size | 40×40 | 48×48 |
| Gradient | goldGradient | getLevelGradient('B1') |
| Text size | 28px w900 | 36px bold |
| Shadows | Gold shadow | B1 + gold shadow |

**Result: ✅ Minor but justifiable differences.** Certificates uses gold (ceremonial). Onboarding uses level-B1 gradient (informational). Sizes differ because certificate is a compact card while onboarding is a full result page. Both use the same badge image embedded in a pill — semantically consistent.

## 5. Dark/Light Mode

All 37 PNGs have baked-in colors (no theme-dependent rendering). The assets are:
- Characters: bright, saturated, dark background-friendly
- Badges: dark backgrounds with bright text (work on both)
- Achievements: similar to badges
- Backgrounds: full-scene illustrations

**Result: ✅ No regression risk.** Assets look the same in both modes since they're pre-rendered. The surrounding UI (gradient containers, glass cards) handles dark/light via `AppColors` values.

## 6. Lint & Compilation

`flutter analyze` — **0 errors, 0 warnings** (3 pre-existing infos).

## Summary

| Check | Status |
|-------|--------|
| Character size consistency | ✅ Pass |
| Image format consistency | ✅ Pass |
| Pixelation / stretch | ✅ None detected |
| Badge visual consistency | ✅ Pass (pill + badge + text) |
| Dark/light mode | ✅ Neutral (baked colors) |
| Layout shift | ✅ None |
| DPI consistency | ✅ All 96 DPI |
| Compilation | ✅ Clean |

**No visual regressions found. Ready to proceed to Waves 4+ when directed.**
