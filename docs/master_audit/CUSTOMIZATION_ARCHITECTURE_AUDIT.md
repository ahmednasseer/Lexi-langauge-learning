# Customization System Architecture Audit

> **Status:** LOCKED — Audit Mode (No code modifications)  
> **Date:** July 29, 2026  
> **Scope:** Avatar, Frames, Backgrounds, Profile Appearance, Shop, Inventory, Equip, Persistence, Preview, Rendering  
> **Role:** Principal Flutter Architect & Product Systems Engineer

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Inventory — All Customization Systems](#2-system-inventory--all-customization-systems)
3. [Duplicate Systems Detection](#3-duplicate-systems-detection)
4. [Rendering Pipeline Analysis](#4-rendering-pipeline-analysis)
5. [Data Flow & Persistence](#5-data-flow--persistence)
6. [Asset Compatibility Mapping](#6-asset-compatibility-mapping)
7. [Recommended Architecture](#7-recommended-architecture)
8. [Migration Risks](#8-migration-risks)
9. [Implementation Order](#9-implementation-order)

---

## 1. Executive Summary

| Metric | Value |
|--------|-------|
| Independent customization systems | **5** |
| Frame implementations | **3 parallel** (none wins) |
| Frame PNG assets on disk | 4 (never used) |
| Background PNG assets on disk | 7 (never used) |
| Store items for frames | 5 (ID: `frame_1`–`frame_5`) |
| Store items for backgrounds | 5 (ID: `bg_1`–`bg_5`) |
| Avatar implementations | **2 parallel** |
| Persistence models with customization fields | **0** |
| Widgets that render an equipped item | **0** |
| Equip flow that reaches the UI | **0** — dead-end API call |
| User-facing routes for customization | **4** (`/avatar-shop`, `/avatar-editor`, `/frames-workshop`, `/backgrounds-shop`) |

### Status Summary by System

| System | Status |
|--------|--------|
| `store_screen.dart` — Store purchase | **Active** — functional purchase & equip calls |
| `avatar_shop_screen.dart` — Avatar+Frame+Background shop | **Prototype** — 8 emoji frames, local state only, no persistence |
| `frames_workshop_screen.dart` — Frame workshop | **Prototype** — CustomPainter frames, no persistence, apply is cosmetic snackbar |
| `backgrounds_shop_screen.dart` — Background shop | **Prototype** — gradient swatches, no purchase, no persistence |
| `avatar_editor_screen.dart` — Avatar builder | **Active** — 5 body part categories, no frame/background |
| `animated_avatar.dart` — Shared avatar widget | **Active** — used across app, **no frame/background support** |
| `user_model.dart` — User persistence | **Active** — **no customization fields** |
| `store_item.dart` — Store item model | **Active** — defines 5 frames + 5 backgrounds by ID |
| `store_repository.dart` — Purchase/equip API | **Active** — `purchase()`, `equip()`, `getInventory()` hit backend |
| `community/models/message.dart` — `UserProfile` | **Active** — separate profile model for community, **no customization fields** |

---

## 2. System Inventory — All Customization Systems

### 2.1 Avatar Systems

#### System A: `AvatarEditorScreen` (`lib/features/avatar_editor/`)
- **Type:** Character builder
- **Tabs:** الجسم (Body/Skin), العيون (Eyes), الشعر (Hair), القميص (Shirt), الإكسسوارات (Accessories)
- **State:** `_selectedBody`, `_selectedEyes`, `_selectedHair`, `_selectedShirt`, `_selectedAccessory`
- **Persistence:** None — all local `int` state, lost on dispose
- **Frame support:** None
- **Background support:** None

#### System B: `AvatarShopScreen` (`lib/features/avatar_shop/`)
- **Type:** Avatar + Frame + Background shop (Arabic UI)
- **Avatars:** 4 named (Lena/Paul/Anna/Max), gradient-colored circles with initials + price
- **Frames:** 8 emoji-labeled frames (🔥💡👑🌿🚀💎⚡🏰), colored containers
- **Backgrounds tab:** Stub — only shows avatar preview + grid (no background content)
- **State:** `_selectedAvatarIndex`, `_selectedFrameIndex` — local only
- **Persistence:** None
- **Frame PNG usage:** None — renders colored containers with emoji text

### 2.2 Frame Systems

#### System A: `FramesWorkshopScreen` (`lib/features/workshop/`)
- **Type:** Dedicated frame shop (Arabic: ورشة الإطارات)
- **Frame count:** 10, classified in 4 tabs (All/Featured/Rare/VIP)
- **Rendering:** `_OrnateFramePainter` — CustomPainter drawing concentric rings + 12 decorative dots + arc ornaments
- **State:** `_selectedFrameIndex`, `_showDetailSheet`, `_showPreviewSheet`
- **Purchase:** Local overlay with "Buy" button — no real purchase
- **Equip:** Snackbar says "تم تطبيق الإطار بنجاح" (Frame applied successfully) — **does nothing**
- **Persistence:** None
- **Frame PNG usage:** None — CustomPainter only

#### System B: `AvatarShopScreen._buildFramesSection()` (see 2.1 System B)
- **Type:** Sub-section of avatar shop
- **Frame count:** 8 emoji-labeled frames
- **Rendering:** `Container` with color + emoji text icon
- **State:** Same local `_selectedFrameIndex`
- **Frame PNG usage:** None — emoji text only

#### System C: `StoreItem` Model (`lib/features/store/models/store_item.dart`)
- **Type:** Data model for store
- **Frame items:** 5 (`frame_1`: Silver, `frame_2`: Gold, `frame_3`: Diamond, `frame_4`: Fire, `frame_5`: Galaxy)
- **Used by:** `StoreScreen` — renders frames as `StoreItemCard` with `Icons.crop_square`
- **Purchase flow:** Calls `store_repository.purchase()` then `store_repository.equip()`
- **Equip:** API call to backend — **no local state update, no UI reaction**
- **Frame PNG usage:** None — `Icons.crop_square` placeholder

### 2.3 Background Systems

#### System A: `BackgroundsShopScreen` (`lib/features/workshop/`)
- **Type:** Background shop
- **Background count:** 5 gradient swatches (not matching `bg_*.png` files)
- **Rendering:** `LinearGradient` containers with name + price
- **Purchase:** No real purchase — hardcoded `locked` flags
- **Persistence:** None
- **Background PNG usage:** None — gradient swatches only

#### System B: `StoreItem` Model (`lib/features/store/models/store_item.dart`)
- **Background items:** 5 (`bg_1`: Ocean, `bg_2`: Mountain, `bg_3`: City, `bg_4`: Space, `bg_5`: Golden)
- **Used by:** `StoreScreen` — renders as `StoreItemCard` with `Icons.wallpaper`
- **Purchase flow:** Same as frame — API call, no local UI update
- **Background PNG usage:** None — `Icons.wallpaper` placeholder

#### System C: `AvatarShopScreen._buildBackgroundsTab()` (see 2.1 System B)
- **Type:** Sub-tab of avatar shop
- **Status:** **Stub** — shows only avatar preview + avatar grid, no actual background content

### 2.4 Rendering Systems

#### System A: `AnimatedAvatar` (`lib/shared/widgets/`)
- **Usage:** Profile, Home, Community, Support, AI screens
- **Parameters:** `imageUrl`, `initials`, `size`, `backgroundColor`, `gradient`, `border`, `showGlow`, `glowColor`, `isOnline`, `badge`
- **Frame support:** **None** — no frame parameter, no frame overlay
- **Background support:** **None** — no background rendering
- **Rendering pattern:** Circular container with optional `Image.network`, fallback to text initials

#### System B: Profile header (`lib/features/profile/`)
- **Usage:** Profile screen avatar (line 77–104)
- **Rendering pattern:** Gradient circle with initial letter + hero glow + level badge
- **Frame support:** None — `Border.all()` is static, not custom
- **Background support:** None — flat `AppColors.background`

#### System C: Community `UserProfile` (`lib/features/community/models/message.dart`)
- **Fields:** `id`, `name`, `avatar` (String?), `level`, `xp`, `streak`, `isPremium`, `privacySetting`
- **Customization fields:** None
- **Frame/background support:** None

### 2.5 Shop & Purchase Systems

#### System A: `StoreScreen` (`lib/features/store/`)
- **Categories:** Gems, Avatars, Frames, Backgrounds, Bundles
- **State:** `_selectedCategory`, `_userGems`, `_items`, `_owned`, `_isLoading`
- **Purchase flow:** `_purchaseItem()` → if owned → `equip()`, else → `purchase()` + local state update
- **Equip flow:** Calls `store_repository.equip(id)` → shows snackbar → **no UI update anywhere**
- **Persistence:** `_owned` is `Set<String>` in local state only — not saved to `UserModel`

#### System B: `StoreRepository` (`lib/features/store/`)
- **Methods:** `getItems()`, `getInventory()`, `purchase()`, `equip()`
- **Backend:** `ApiService` for all calls
- **Fallback:** Returns hardcoded `StoreItem` data on API failure
- **Equip:** `Future<bool> equip(String itemId)` — calls `_api.equipItem(itemId)` — **result never propagates to UI**

---

## 3. Duplicate Systems Detection

### 3.1 Frame Systems — **3 duplicates**

| System | Location | Frame Count | Rendering | Persistence | Status |
|--------|----------|-------------|-----------|-------------|--------|
| Frames Workshop | `frames_workshop_screen.dart` | 10 | CustomPainter | None | Prototype |
| Avatar Shop section | `avatar_shop_screen.dart:523` | 8 | Emoji containers | None | Prototype |
| Store items | `store_item.dart:66-70` | 5 | `Icons.crop_square` | API (dead-end) | Active |

**Root cause:** No single source of truth for frame definitions. Three devs/features each built their own system without consolidating.

**Recommended owner:** `StoreItem` (data) → `FramesWorkshopScreen` (selection) → `AnimatedAvatar` (rendering)

### 3.2 Background Systems — **2 duplicates (+1 stub)**

| System | Location | BG Count | Rendering | Persistence | Status |
|--------|----------|----------|-----------|-------------|--------|
| Backgrounds Shop | `backgrounds_shop_screen.dart` | 5 | Gradient swatches | None | Prototype |
| Store items | `store_item.dart:72-77` | 5 | `Icons.wallpaper` | API (dead-end) | Active |
| Avatar Shop tab | `avatar_shop_screen.dart:204` | 0 | Stub | None | Dead |

**Root cause:** Same as frames — background definitions replicated across systems.

### 3.3 Avatar Systems — **2 duplicates**

| System | Location | Avatars | Rendering | Persistence | Status |
|--------|----------|---------|-----------|-------------|--------|
| Avatar Editor | `avatar_editor_screen.dart` | 5 categories | Colored containers with features | None | Active |
| Avatar Shop | `avatar_shop_screen.dart:19` | 4 named | Gradient circles + initials | None | Prototype |

**Recommended owner:** `AvatarEditorScreen` (editing) → new unified model → `AnimatedAvatar` (rendering)

### 3.4 Equip Systems — **2 dead paths**

| Path | Source | Destination | Result |
|------|--------|-------------|--------|
| Store → Equip → UI | `StoreScreen._purchaseItem()` | `store_repository.equip()` | Snackbar only — no UI renders equipped item |
| Workshop → Apply → UI | `FramesWorkshopScreen._onApplyTap()` | `setState()` + snackbar | Snackbar only — local state lost on exit |

**Both equip flows are dead-ends.** No code reads the equipped item ID and renders it.

---

## 4. Rendering Pipeline Analysis

### 4.1 Current: Store Purchase → Equip → Display

```
StoreScreen._purchaseItem(item)
    │
    ├─ Owned? ──Yes──► StoreRepository.equip(itemId)
    │                          │
    │                          ▼
    │                     ApiService.equipItem(itemId)
    │                          │
    │                          ▼
    │                     [Backend saves equipped item]
    │                          │
    │                          ▼
    │                     Returns bool ──► SnackBar("Equipped!")
    │                                              │
    │                                              ▼
    │                                         [NOTHING renders]
    │
    └─ Not owned ──► StoreRepository.purchase(itemId)
                           │
                           ▼
                      ApiService.purchaseItem(itemId)
                           │
                           ▼
                      [Backend saves ownership]
                           │
                           ▼
                      Local state: _owned.add(itemId)
                           │
                           ▼
                      [Grid re-renders with "Owned" badge]
                           │
                           ▼
                      [User must tap again to equip = same dead-end]
```

**Gap:** The equip call succeeds, but:
- No widget subscribes to "currently equipped item ID"
- `UserModel` has no `equippedFrameId` or `equippedBackgroundId` field
- `AnimatedAvatar` has no mechanism to render a frame or background
- No state management (Riverpod/Bloc/etc.) propagates the equipped state

### 4.2 Future: Intended Pipeline

```
[Design intent inferred from StoreItem + equip API]

Store Purchase
      │
      ▼
  Inventory (owned items)
      │
      ▼
  Equip Selection
      │
      ▼
  UserModel.equippedFrameId / equippedBackgroundId
      │
      ▼
  AnimatedAvatar reads UserModel
      │
      ├─► Renders frame overlay around avatar
      └─► Renders background behind avatar
      │
      ▼
  All screens using AnimatedAvatar
  (Profile, Home, Community, Support, etc.)
```

**Missing layers:**
1. `UserModel` equipped fields (data)
2. State that reads equipped ID and propagates to widgets
3. `AnimatedAvatar` frame/background rendering logic
4. Mapping from store item IDs to asset paths

### 4.3 Current Widget → Asset Resolution

| Widget | Currently Renders | Should Render | Resolution Method |
|--------|------------------|---------------|-------------------|
| `AnimatedAvatar` | Gradient circle + network image | Same + optional frame overlay | Needs `frame` parameter |
| Profile header | Hero gradient + initial letter | Same + optional frame + background | Uses own rendering, not `AnimatedAvatar` |
| Store frame card | `Icons.crop_square` | Frame PNG preview | Needs `StoreItem.imageUrl` or asset mapping |
| Store bg card | `Icons.wallpaper` | Background PNG preview | Needs `StoreItem.imageUrl` or asset mapping |
| Frame workshop | CustomPainter concentric rings | Frame PNG | Needs complete rewrite |
| BG shop | Gradient swatch | Background PNG | Needs complete rewrite |
| Avatar shop | Colored container + emoji | Actual avatar + frame PNG | Needs complete rewrite |

---

## 5. Data Flow & Persistence

### 5.1 `UserModel` (`lib/shared/models/user_model.dart`)

**Fields:** `id`, `name`, `email`, `photoUrl`, `nativeLanguage`, `learningLanguage`, `level`, `xp`, `streak`, `totalXp`, `learningGoal`, `isPremium`, `createdAt`, `lastActiveAt`, `dailyXp`, `dailyGoal`

**Customization fields: 0**

```dart
// Fields needed but missing:
String? equippedFrameId;       // e.g., 'frame_1' or 'frame_gold'
String? equippedBackgroundId;  // e.g., 'bg_1' or 'bg_space'
String? equippedAvatarId;      // e.g., 'avatar_1' or body part config
```

**Persistence:** JSON → `SharedPreferences` key `current_user` (cached) + Firebase Auth + backend API

### 5.2 AuthService (`lib/services/auth_service.dart`)

- `_currentUser: UserModel?` — in-memory singleton
- `updateProfile()` — partial update method
- No customization-specific methods

### 5.3 StoreRepository (`lib/features/store/store_repository.dart`)

- `getInventory()` → `List<String>` (item IDs owned)
- `purchase(itemId)` → `bool`
- `equip(itemId)` → `bool`
- **No `getEquipped()` method** — no way to retrieve what's currently equipped

### 5.4 ProfileRepository (`lib/features/profile/profile_repository.dart`)

- `getProfile()` → `UserModel?`
- No customization methods

### 5.5 Persistence Summary

| Data | Where Stored | Persistence Type | Duration |
|------|-------------|------------------|----------|
| User profile | `UserModel` in `AuthService` | SharedPreferences + API | Persistent |
| Inventory (owned IDs) | `StoreScreen._owned` | Local state only | Session only |
| Equipped frame | None | Missing | — |
| Equipped background | None | Missing | — |
| Avatar body parts | `AvatarEditorScreen._selected*` | Local state only | Session only |
| Selected frame (shop) | `AvatarShopScreen._selectedFrameIndex` | Local state only | Session only |
| Selected frame (workshop) | `FramesWorkshopScreen._selectedFrameIndex` | Local state only | Session only |
| Frame ownership | `StoreScreen._owned` (subset) | Local state only | Session only |

**Every customization choice is lost on screen dispose.** No data survives app restart.

---

## 6. Asset Compatibility Mapping

### 6.1 Frame PNG Assets vs Store IDs vs Shop Names

| PNG Asset (filesystem) | `AppAssets` Constant | Store ID | Store Name | Avatar Shop Emoji | Workshop Label |
|---|---|---|---|---|---|
| `frame_gold.png` | `frameGold` | `frame_2` | Gold Frame | 👑 (ذهبي) | إطار ذهبي |
| `frame_silver.png` | `frameSilver` | `frame_1` | Silver Frame | — | — |
| `frame_neon.png` | `frameNeon` | — | — | 💡 (نيون) | — |
| `frame_diamond.png` | `frameDiamond` | `frame_3` | Diamond Frame | 💎 (كريستال) | — |
| — | — | `frame_4` | Fire Frame | 🔥 (أطارات) | — |
| — | — | `frame_5` | Galaxy Frame | 🚀 (فضاء) | — |
| — | — | — | — | 🌿 (طبيعة) | إطار أخضر |
| — | — | — | — | ⚡ (كهرباء) | — |
| — | — | — | — | 🏰 (ملكي) | إطار ملكي |

**Observations:**
- Only `frame_gold.png` and `frame_diamond.png` have matching store items
- `frame_silver.png` matches store `frame_1` (Silver Frame)
- `frame_neon.png` has no store counterpart — orphan asset
- Store items `frame_4` (Fire) and `frame_5` (Galaxy) have no PNG assets — they'd need artwork OR be kept as gradient/CustomPaint
- Avatar Shop has 8 emoji frames that don't correspond to any PNG assets (except 💎→diamond, 👑→gold)
- Workshop has 10 frames that don't correspond to any PNG assets

**Mapping recommendation:**

| Store ID → Asset | Confidence | Action |
|-----------------|------------|--------|
| `frame_1` (Silver) → `frame_silver.png` | ✅ Direct match | Map in resolver |
| `frame_2` (Gold) → `frame_gold.png` | ✅ Direct match | Map in resolver |
| `frame_3` (Diamond) → `frame_diamond.png` | ✅ Direct match | Map in resolver |
| `frame_4` (Fire) → No asset | ❌ Missing artwork | Keep gradient/CustomPaint |
| `frame_5` (Galaxy) → No asset | ❌ Missing artwork | Keep gradient/CustomPaint |
| (Neon) → `frame_neon.png` | ⚠️ No store item | Add store item or repurpose |

### 6.2 Background PNG Assets vs Store IDs vs Shop Names

| PNG Asset (filesystem) | `AppAssets` Constant | Store ID | Store Name | Shop Gradient Name |
|---|---|---|---|---|
| `bg_space.png` | `bgSpace` | `bg_4` | Space | — |
| `bg_ocean.png` | `bgOcean` | `bg_1` | Ocean | — |
| `bg_forest.png` | `bgForest` | — | — | — |
| `bg_city.png` | `bgCity` | `bg_3` | City | — |
| `bg_mountain.png` | `bgMountain` | `bg_2` | Mountain | — |
| `bg_abstract.png` | `bgAbstract` | — | — | — |
| `bg_aurora.png` | `bgAurora` | — | — | — |
| — | — | `bg_5` | Golden | غروب شمسي (Sunset) |

**Observations:**
- 4 of 7 assets have store counterparts (Space, Ocean, City, Mountain)
- `bg_forest.png`, `bg_abstract.png`, `bg_aurora.png` have no store items
- Store item `bg_5` (Golden) has no matching asset — would need artwork
- Backgrounds Shop gradient names don't match store item names at all

**Mapping recommendation:**

| Store ID → Asset | Confidence | Action |
|-----------------|------------|--------|
| `bg_1` (Ocean) → `bg_ocean.png` | ✅ Direct match | Map in resolver |
| `bg_2` (Mountain) → `bg_mountain.png` | ✅ Direct match | Map in resolver |
| `bg_3` (City) → `bg_city.png` | ✅ Direct match | Map in resolver |
| `bg_4` (Space) → `bg_space.png` | ✅ Direct match | Map in resolver |
| `bg_5` (Golden) → No asset | ❌ Missing artwork | Keep gradient |
| (Forest) → `bg_forest.png` | ⚠️ No store item | Add store item |
| (Abstract) → `bg_abstract.png` | ⚠️ No store item | Add store item |
| (Aurora) → `bg_aurora.png` | ⚠️ No store item | Add store item |

### 6.3 Avatar PNG Assets vs Store IDs

**No avatar-specific PNG assets exist.** All 17 character PNGs are Lexi mascot illustrations, not customizable avatars. The store has 5 avatar IDs (`avatar_1`–`avatar_5`) with zero related assets.

**Conclusion:** Avatar customization is purely programmatic (color/feature selection), not asset-driven. This is a separate concern from frames/backgrounds.

---

## 7. Recommended Architecture

### 7.1 Canonical Customization Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     UserModel                           │
│  + equippedFrameId: String?                             │
│  + equippedBackgroundId: String?                        │
│  + equippedAvatarConfig: AvatarConfig?                  │
│  + ownedItemIds: List<String>                           │
└─────────────────────┬───────────────────────────────────┘
                      │ read by
                      ▼
┌─────────────────────────────────────────────────────────┐
│             CustomizationController                     │
│  (or Riverpod Provider / Bloc)                          │
│                                                         │
│  - Reads UserModel equipped IDs                         │
│  - Resolves IDs → Asset paths via Resolver              │
│  - Provides selected/owned state to widgets             │
└─────────────────────┬───────────────────────────────────┘
                      │ consumed by
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  AnimatedAvatar                         │
│  + frame: FrameType?                                    │
│  + background: BackgroundType?                          │
│                                                         │
│  Renders:                                               │
│  1. Background image (behind avatar)                    │
│  2. Avatar circle (image or gradient + initials)        │
│  3. Frame overlay (around avatar)                       │
│  4. Badge (top-right, existing)                         │
│  5. Online indicator (bottom-right, existing)           │
└─────────────────────────────────────────────────────────┘
```

### 7.2 Asset Resolution Pipeline

```
Store Item ID (e.g., 'frame_2', 'bg_1')
        │
        ▼
FrameArtworkResolver.resolve('frame_2')
        │
        ├─► AppAssets.frameGold
        │
        ▼
   Image.asset(AppAssets.frameGold)
```

**Resolver class** (future implementation):

```
class FrameArtworkResolver {
  static const Map<String, String> _mapping = {
    'frame_1': AppAssets.frameSilver,
    'frame_2': AppAssets.frameGold,
    'frame_3': AppAssets.frameDiamond,
    // frame_4, frame_5 → null (no artwork, keep gradient fallback)
  };

  static String? resolve(String storeItemId) => _mapping[storeItemId];
}
```

Same pattern for backgrounds:

```
class BackgroundArtworkResolver {
  static const Map<String, String> _mapping = {
    'bg_1': AppAssets.bgOcean,
    'bg_2': AppAssets.bgMountain,
    'bg_3': AppAssets.bgCity,
    'bg_4': AppAssets.bgSpace,
    // bg_5 → null (no artwork, keep gradient fallback)
  };

  static String? resolve(String storeItemId) => _mapping[storeItemId];
}
```

### 7.3 System Consolidation Plan

| Current System | Fate | Merge Into |
|---------------|------|------------|
| `FramesWorkshopScreen` | **Deprecate** | A single unified frame picker |
| `AvatarShopScreen._buildFramesSection` | **Remove** | Unified frame picker |
| `AvatarShopScreen._buildBackgroundsTab` | **Remove** | Unified background picker |
| `BackgroundsShopScreen` | **Deprecate** | Unified background picker |
| `StoreScreen` frames/backgrounds | **Keep** but add asset preview | Unified `StoreItemCard` |
| `AnimatedAvatar` | **Extend** | Add `frame` + `background` parameters |
| `ProfileScreen._buildProfileHeader` | **Refactor** | Use `AnimatedAvatar` instead of custom rendering |

### 7.4 Equip Flow (Future)

```
User taps "Equip" in store
        │
        ▼
StoreRepository.equip(itemId) → API call
        │
        ▼
On success → Update UserModel.equippedFrameId
        │
        ▼
CustomizationController notifies listeners
        │
        ▼
AnimatedAvatar re-renders with new frame
```

---

## 8. Migration Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Deprecating 3 frame systems may break existing routes | Medium | Medium | Keep routes alive, redirect to unified picker |
| `UserModel` schema change needs backend sync | Medium | High | Add fields as nullable, default null |
| CustomizationController adds complexity to simple screens | Low | Medium | Make controller optional — screens work without it |
| Frame/background asset mismatch (PNG dimensions vs UI) | Medium | Medium | `BoxFit.contain` on frames, `BoxFit.cover` on backgrounds |
| Avatar body part persistence lost for existing users | High | Medium | Store as JSON string in UserModel |
| Lottie/CustomPaint confetti duplication not addressed | Low | Low | Separate scope — not in customization audit |
| Backend `equipItem` API may expect different ID format | Medium | High | Audit backend before frontend changes |

---

## 9. Implementation Order

### Phase A: Data Layer (No UI Changes)
**Risk:** Low | **Est. effort:** 2-3 hours

1. Add `equippedFrameId` and `equippedBackgroundId` to `UserModel` (nullable)
2. Add `equippedAvatarConfig` (nullable JSON/map for body part selections)
3. Add `getEquipped()` method to `StoreRepository`
4. Create `FrameArtworkResolver` and `BackgroundArtworkResolver`
5. Update `StoreRepository.equip()` to also update `UserModel` locally

### Phase B: Widget Layer
**Risk:** Medium | **Est. effort:** 4-6 hours

6. Add `frame` and `background` parameters to `AnimatedAvatar`
7. Implement frame overlay rendering (Stack: background → avatar → frame)
8. Refactor `ProfileScreen._buildProfileHeader` to use `AnimatedAvatar`
9. Create unified frame picker widget
10. Create unified background picker widget

### Phase C: Screen Consolidation
**Risk:** High | **Est. effort:** 6-8 hours

11. Deprecate `FramesWorkshopScreen` → redirect to unified picker
12. Deprecate `BackgroundsShopScreen` → redirect to unified picker
13. Rewrite `AvatarShopScreen` to use Unified Picker widgets
14. Update `StoreItemCard` to render asset previews via Resolver
15. Remove `AvatarShopScreen._buildFramesSection` and `_buildBackgroundsTab`
16. Wire equip flow end-to-end: Store → Controller → UI

### Phase D: Polish
**Risk:** Low | **Est. effort:** 2-3 hours

17. Add `precacheImage()` for top 3 frames + top 3 backgrounds
18. Add frame/background empty state design
19. Handle missing artwork: gradient/CustomPaint fallback when Resolver returns null

### Total estimated effort: **14-20 hours**

---

## Appendix A: File Reference Map

| File | System | Lines | Customization Relevance |
|------|--------|-------|------------------------|
| `lib/shared/models/user_model.dart` | Data | 100 | 🔴 Needs `equippedFrameId`, `equippedBackgroundId` |
| `lib/services/auth_service.dart` | Data | 310 | 🟡 Needs customization methods |
| `lib/features/store/store_repository.dart` | Data | 52 | 🟡 Needs `getEquipped()` |
| `lib/features/store/models/store_item.dart` | Data | 95 | ✅ Defines items, needs asset mapping |
| `lib/features/store/store_screen.dart` | Shop | 287 | 🟡 Needs asset previews + equip UI feedback |
| `lib/features/store/widgets/store_item_card.dart` | Shop | ~200 | 🟡 Needs asset preview rendering |
| `lib/features/avatar_shop/avatar_shop_screen.dart` | Shop | 626 | 🔴 3 systems in 1 — consolidate |
| `lib/features/workshop/frames_workshop_screen.dart` | Shop | 871 | 🔴 Largest file — rewrite candidate |
| `lib/features/workshop/backgrounds_shop_screen.dart` | Shop | 388 | 🔴 Rewrite candidate |
| `lib/features/avatar_editor/avatar_editor_screen.dart` | Editor | 800 | 🟡 Needs frame/background tabs + persistence |
| `lib/shared/widgets/animated_avatar.dart` | Widget | 170 | 🔴 Needs `frame` + `background` |
| `lib/features/profile/profile_screen.dart` | Screen | 464 | 🟡 Refactor to use `AnimatedAvatar` |
| `lib/features/community/models/message.dart` | Data | 271 | 🟡 Community UserProfile needs frame/bg |

---

## Appendix B: Asset File → Store ID Mapping (Proposed)

### Frames

```
┌──────────────┬────────────┬──────────┐
│ Asset File   │ Store ID   │ AppAsset │
├──────────────┼────────────┼──────────┤
│ frame_silver │ frame_1    │ ✓        │
│ frame_gold   │ frame_2    │ ✓        │
│ frame_diamond│ frame_3    │ ✓        │
│ frame_neon   │ (none)     │ ✓        │ ← orphan
│ (no asset)   │ frame_4    │ ✗        │ ← needs artwork
│ (no asset)   │ frame_5    │ ✗        │ ← needs artwork
└──────────────┴────────────┴──────────┘
```

### Backgrounds

```
┌──────────────┬────────────┬──────────┐
│ Asset File   │ Store ID   │ AppAsset │
├──────────────┼────────────┼──────────┤
│ bg_ocean     │ bg_1       │ ✓        │
│ bg_mountain  │ bg_2       │ ✓        │
│ bg_city      │ bg_3       │ ✓        │
│ bg_space     │ bg_4       │ ✓        │
│ (no asset)   │ bg_5       │ ✗        │ ← needs artwork
│ bg_forest    │ (none)     │ ✓        │ ← orphan
│ bg_abstract  │ (none)     │ ✓        │ ← orphan
│ bg_aurora    │ (none)     │ ✓        │ ← orphan
└──────────────┴────────────┴──────────┘
```

---

*End of Architecture Audit. No code was modified in producing this document.*
