# Fonts Report

## Current state
- `pubspec.yaml` has **no `fonts:` section**.
- All typography uses **`google_fonts`** package: `GoogleFonts.poppins(...)` at ~100+ call sites.
- Poppins is fetched at runtime from the Google Fonts CDN. This requires network access on first load; offline, Flutter falls back to the default font.

## Recommendation
Poppins is an open-source font (SIL Open Font License) — no commercial license needed.

For production (deterministic rendering, offline support, no CDN dependency), bundle Poppins locally:
1. Download Poppins (Regular, Medium, SemiBold, Bold) `.ttf` from Google Fonts (OFL).
2. Place under `assets/fonts/poppins/`.
3. Add to `pubspec.yaml`:
```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/poppins/Poppins-Regular.ttf
      - asset: assets/fonts/poppins/Poppins-Medium.ttf
        weight: 500
      - asset: assets/fonts/poppins/Poppins-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/poppins/Poppins-Bold.ttf
        weight: 700
```
4. Optionally switch `GoogleFonts.poppins(...)` calls to `TextStyle(fontFamily: 'Poppins', ...)` to avoid the runtime fetch.

No other custom fonts are required. `cupertino_icons` and Material icons cover iconography.
