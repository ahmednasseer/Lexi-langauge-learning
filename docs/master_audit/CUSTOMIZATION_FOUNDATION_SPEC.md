# Customization Foundation — Implementation Specification

> **Status:** DRAFT v2 — Awaiting approval before implementation  
> **Phase:** 3 (between Asset Integration Waves and Lottie Polish)  
> **Dependencies:** Phase 1–2 complete (assets organized, `pubspec.yaml` fixed)  
> **Risk:** LOW — no UI screens modified, no existing behavior broken  
> **Backward Compatibility:** 100% — all changes are additive, nullable, non-breaking

---

## Table of Contents

1. [Scope](#1-scope)
2. [UserModel Changes](#2-usermodel-changes)
3. [CustomizationController](#3-customizationcontroller)
4. [Asset Resolver System](#4-asset-resolver-system)
5. [AnimatedAvatar Extension](#5-animatedavatar-extension)
6. [CustomizationState](#6-customizationstate)
7. [StoreRepository Integration](#7-storerepository-integration)
8. [Equip Flow (Revised)](#8-equip-flow-revised)
9. [Execution Order](#9-execution-order)
10. [Domain Layer](#10-domain-layer)
11. [AssetResolver Interface](#11-assetresolver-interface)
12. [Files Modified](#12-files-modified)
13. [Validation](#13-validation)
14. [What This Unlocks](#14-what-this-unlocks)
15. [Future Extensibility](#15-future-extensibility)
16. [Golden Rule](#16-golden-rule)
17. [Asset Manifest](#17-asset-manifest)
18. [Rendering Performance Contract](#18-rendering-performance-contract)

---

## 1. Scope

### Included (Foundation Only)

| Component | Action |
|-----------|--------|
| `UserModel` | Add `equippedFrameId`, `equippedBackgroundId`, `ownedItemIds` fields |
| `AuthService` | Add `updateCustomization()` method |
| `CustomizationController` | New class — single source of truth for customization state |
| `FrameArtworkResolver` | New class — maps store frame IDs → asset paths |
| `BackgroundArtworkResolver` | New class — maps store background IDs → asset paths |
| `AnimatedAvatar` | Add `frame`, `background`, `frameOverlay` optional parameters |
| `StoreRepository` | Add `getEquipped()`, wire `equip()` to update controller |
| `StoreItem` | Add `resolveAssetPath()` method (optional convenience) |

### Excluded (Future Phases)

| Component | Reason |
|-----------|--------|
| `FramesWorkshopScreen` rewrite | Needs unified picker spec first |
| `BackgroundsShopScreen` rewrite | Needs unified picker spec first |
| `AvatarShopScreen` consolidation | Needs unified picker spec first |
| `ProfileScreen` AnimatedAvatar refactor | Needs foundation operational first |
| `StoreScreen` equip UI feedback | Needs controller operational first |
| `StoreItemCard` asset preview | Needs resolver operational first |
| Lottie integration | Separate phase |
| WebP conversion | Performance phase |

### Design Principle

**Every addition is nullable, optional, and default-null.** Screens that do not use the customization system will render identically before and after this phase. No `CustomizationController` is required to use `AnimatedAvatar` — it remains fully backward-compatible.

---

## 2. UserModel Changes

### File: `lib/shared/models/user_model.dart`

```dart
class UserModel {
  // ── Existing fields (unchanged) ──────────────────────────────────
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  // ... all existing fields remain ...

  // ── NEW: Customization fields (nullable, optional) ────────────────
  final String? equippedFrameId;       // e.g., 'frame_2', 'frame_gold'
  final String? equippedBackgroundId;  // e.g., 'bg_4', 'bg_space'
  final List<String> ownedItemIds;     // e.g., ['frame_1', 'bg_1', 'avatar_3']
  final Map<String, dynamic>? avatarConfig;  // body part selections as JSON
}
```

### Constructor Changes

```dart
const UserModel({
  // ... existing required params ...
  this.equippedFrameId,
  this.equippedBackgroundId,
  this.ownedItemIds = const [],
  this.avatarConfig,
});
```

### `copyWith` Changes

```dart
UserModel copyWith({
  // ... existing params ...
  String? equippedFrameId,
  String? equippedBackgroundId,
  List<String>? ownedItemIds,
  Map<String, dynamic>? avatarConfig,
  // Use nullable sentinel for List/Map to support clearing
  bool clearEquippedFrameId = false,
  bool clearEquippedBackgroundId = false,
  bool clearAvatarConfig = false,
});
```

**Rule for `copyWith`:** When `clearEquippedFrameId` is `true`, set to `null` regardless of `equippedFrameId` value. Same for background and avatarConfig.

### `toJson` / `fromJson` Changes

```dart
Map<String, dynamic> toJson() => {
  // ... existing fields ...
  'equippedFrameId': equippedFrameId,
  'equippedBackgroundId': equippedBackgroundId,
  'ownedItemIds': ownedItemIds,
  'avatarConfig': avatarConfig,
};

factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
  // ... existing fields ...
  equippedFrameId: json['equippedFrameId'],
  equippedBackgroundId: json['equippedBackgroundId'],
  ownedItemIds: (json['ownedItemIds'] as List<dynamic>?)
      ?.cast<String>() ?? const [],
  avatarConfig: json['avatarConfig'] != null
      ? Map<String, dynamic>.from(json['avatarConfig'])
      : null,
);
```

### Backward Compatibility

- Old JSON without `equippedFrameId` → `null` (no crash, no customization shown)
- Old JSON without `ownedItemIds` → `const []` (empty inventory, no owned items)
- `copyWith` never breaks existing callers — all new params are optional
- `AuthService.updateProfile()` still works unchanged for existing callers

---

## 3. CustomizationController

### File: `lib/shared/customization/customization_controller.dart`

New directory: `lib/shared/customization/`

### Interface

```dart
class CustomizationController extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────
  String? get equippedFrameId;
  String? get equippedBackgroundId;
  List<String> get ownedItemIds;
  bool isOwned(String itemId);
  bool isEquipped(String itemId);

  // ── Init ─────────────────────────────────────────────────────────
  /// Called once on app start. Reads UserModel + StoreRepository
  /// to populate state. Does NOT block app startup — default null OK.
  Future<void> initialize();

  // ── Actions ──────────────────────────────────────────────────────
  /// Equip a frame. Updates UserModel + notifies listeners.
  /// Returns false if item is not owned.
  Future<bool> equipFrame(String itemId);

  /// Equip a background. Updates UserModel + notifies listeners.
  Future<bool> equipBackground(String itemId);

  /// Unequip current frame (set to null).
  Future<void> unequipFrame();

  /// Unequip current background (set to null).
  Future<void> unequipBackground();

  /// Add item to owned list after purchase.
  void addOwned(String itemId);

  /// Remove item from owned list.
  void removeOwned(String itemId);
}
```

### Behavior Rules

1. **`equipFrame`** — Sets `equippedFrameId`, calls `StoreRepository.equip()`, saves to `UserModel`, calls `notifyListeners()`. If API `equip()` fails, revert local state.

2. **`equipBackground`** — Same pattern as `equipFrame`.

3. **`initialize`** — Reads `UserModel` from `AuthService`, reads `StoreRepository.getInventory()`, populates `_ownedItemIds`. If API fails, falls back to UserModel's `ownedItemIds` (from local cache).

4. **No automatic persistence of `ownedItemIds` in UserModel** — Inventory is fetched from API on init. `ownedItemIds` in UserModel is a local cache fallback.

5. **Threading** — All async methods must use `WidgetsBinding.instance.addPostFrameCallback` if calling `notifyListeners` after a build cycle.

### Singleton Access

```dart
static final CustomizationController instance = CustomizationController._();
```

Same pattern as `AuthService.instance`.

### Semantic Identity Only

The controller **must never** call resolvers or reference asset paths. It holds and exposes only semantic IDs:

| Getter | Returns | Example |
|--------|---------|---------|
| `equippedFrameId` | `String?` | `'frame_2'`, `'frame_gold'` |
| `equippedBackgroundId` | `String?` | `'bg_4'`, `'bg_space'` |
| `ownedItemIds` | `List<String>` | `['frame_1', 'bg_1', 'avatar_3']` |

### Widget Integration

```dart
// Correct: widget reads a semantic ID from controller,
// then passes it to AnimatedAvatar which calls the resolver internally.
final controller = CustomizationController.instance;
AnimatedAvatar(
  equippedFrameId: controller.equippedFrameId,
  equippedBackgroundId: controller.equippedBackgroundId,
)
```

Or with `ListenableBuilder` for reactive updates:

```dart
ListenableBuilder(
  listenable: CustomizationController.instance,
  builder: (context, _) {
    final frameId = CustomizationController.instance.equippedFrameId;
    final bgId = CustomizationController.instance.equippedBackgroundId;
    return AnimatedAvatar(
      equippedFrameId: frameId,
      equippedBackgroundId: bgId,
    );
  },
);
```

**Never this:**

```dart
// ❌ WRONG — controller must not know about resolvers or asset paths
final path = FrameArtworkResolver.resolve(controller.equippedFrameId);
Image.asset(path);
```

---

## 4. Asset Resolver System

### 4.1 AssetResolver Interface

**File:** `lib/shared/customization/asset_resolver.dart`

All resolvers implement a common interface so the rendering layer and domain layer can treat them polymorphically:

```dart
/// Base interface for all artwork resolvers.
/// Each resolver maps a semantic identity (store item ID or asset name)
/// to a physical asset path.
abstract class AssetResolver {
  /// Resolve a store item ID to an asset path.
  /// Returns null when no artwork exists (keep placeholder).
  String? resolve(String? storeItemId);

  /// Resolve by asset base name (for non-store direct usage).
  String? resolveByName(String? assetName);

  /// Returns true if artwork exists for this store item.
  bool hasArtwork(String? storeItemId);

  /// The complete mapping for inspection/override.
  Map<String, String> get mapping;
}
```

### 4.2 Concrete Resolvers

All resolvers inherit from `AssetResolver` and follow the same contract.

#### FrameArtworkResolver

**File:** `lib/shared/customization/frame_artwork_resolver.dart`

```dart
class FrameArtworkResolver implements AssetResolver {
  FrameArtworkResolver._();
  static final FrameArtworkResolver instance = FrameArtworkResolver._();

  @override
  static const Map<String, String> _mapping = {
    'frame_1': AppAssets.frameSilver,
    'frame_2': AppAssets.frameGold,
    'frame_3': AppAssets.frameDiamond,
    // 'frame_4': null — Fire Frame (no artwork, keep gradient)
    // 'frame_5': null — Galaxy Frame (no artwork, keep gradient)
  };

  @override
  static const Map<String, String> _directMapping = {
    'frame_silver': AppAssets.frameSilver,
    'frame_gold': AppAssets.frameGold,
    'frame_diamond': AppAssets.frameDiamond,
    'frame_neon': AppAssets.frameNeon,
  };

  @override
  String? resolve(String? storeItemId) =>
      storeItemId != null ? _mapping[storeItemId] : null;

  @override
  String? resolveByName(String? assetName) =>
      assetName != null ? _directMapping[assetName] : null;

  @override
  bool hasArtwork(String? storeItemId) =>
      storeItemId != null && _mapping.containsKey(storeItemId);

  @override
  Map<String, String> get mapping => Map.unmodifiable(_mapping);
}
```

#### BackgroundArtworkResolver

**File:** `lib/shared/customization/background_artwork_resolver.dart`

```dart
class BackgroundArtworkResolver implements AssetResolver {
  BackgroundArtworkResolver._();
  static final BackgroundArtworkResolver instance = BackgroundArtworkResolver._();

  @override
  static const Map<String, String> _mapping = {
    'bg_1': AppAssets.bgOcean,
    'bg_2': AppAssets.bgMountain,
    'bg_3': AppAssets.bgCity,
    'bg_4': AppAssets.bgSpace,
    // 'bg_5': null — Golden (no artwork, keep gradient)
  };

  @override
  static const Map<String, String> _directMapping = {
    'bg_ocean': AppAssets.bgOcean,
    'bg_mountain': AppAssets.bgMountain,
    'bg_city': AppAssets.bgCity,
    'bg_space': AppAssets.bgSpace,
    'bg_forest': AppAssets.bgForest,
    'bg_abstract': AppAssets.bgAbstract,
    'bg_aurora': AppAssets.bgAurora,
  };

  @override
  String? resolve(String? storeItemId) =>
      storeItemId != null ? _mapping[storeItemId] : null;

  @override
  String? resolveByName(String? assetName) =>
      assetName != null ? _directMapping[assetName] : null;

  @override
  bool hasArtwork(String? storeItemId) =>
      storeItemId != null && _mapping.containsKey(storeItemId);

  @override
  Map<String, String> get mapping => Map.unmodifiable(_mapping);
}
```

#### AchievementArtworkResolver (future)

```
class AchievementArtworkResolver implements AssetResolver { ... }
```

#### AvatarArtworkResolver (future)

```
class AvatarArtworkResolver implements AssetResolver { ... }
```

### 4.3 Design Decisions

| Decision | Rationale |
|----------|-----------|
| Singleton per resolver (implements interface) | Interface requires instance methods; `AssetResolver` type enables polymorphism |
| Returns `String?` not asset | We may switch to WebP/SVG/CDN later; return the path, let `Image.asset` handle format |
| Separates `_mapping` (store ID) from `_directMapping` (filename) | Store IDs and filenames may diverge; separate lookups prevent confusion |
| `hasArtwork()` quick check | Widgets can decide to show asset or fallback without resolving full path |
| `get mapping` exposed | Future: allow server-provided overrides to mapping |

### 4.4 Resolver Selection Rule

```
CustomizationController.equippedFrameId
        │
        ▼
FrameArtworkResolver.instance.resolve('frame_2')
        │
        ├─ non-null → Image.asset(path)
        └─ null → keep existing gradient/CustomPaint placeholder
```

### 4.5 New Asset Category = New Resolver

To add a new cosmetic category (e.g., nameplates):
1. Create `NameplateArtworkResolver implements AssetResolver`
2. Add mappings from store IDs → asset paths
3. Register in the domain layer
4. No other code changes needed

---

## 5. AnimatedAvatar Extension

### File: `lib/shared/widgets/animated_avatar.dart`

### New Parameters

```dart
class AnimatedAvatar extends StatefulWidget {
  // ... existing parameters unchanged ...

  /// Frame overlay widget. If null, no frame is rendered.
  /// Typically a positioned Image.asset resolved by FrameArtworkResolver.
  final Widget? frameOverlay;

  /// Background widget rendered behind the avatar circle.
  /// If null, no background image — gradient/border defaults apply.
  final Widget? background;

  /// Convenience: pass a store item ID to auto-resolve frame asset.
  /// Overrides frameOverlay if both provided.
  final String? equippedFrameId;

  /// Convenience: pass a store item ID to auto-resolve background asset.
  /// Overrides background if both provided.
  final String? equippedBackgroundId;
}
```

### Rendering Order (Stack)

```
Stack
  ├─ [NEW] Background widget (bottom-most)
  │     if background != null → render that
  │     else if equippedBackgroundId != null → resolve + render Image.asset
  │     else → nothing (transparent)
  │
  ├─ Glow effect (existing)
  ├─ Avatar circle (existing)
  │     with ClipOval + Image.network / initials fallback
  │
  ├─ [NEW] Frame overlay
  │     if frameOverlay != null → render that
  │     else if equippedFrameId != null → resolve + render Image.asset
  │     else → nothing
  │
  ├─ Online indicator (existing)
  └─ Badge (existing)
```

### Auto-resolution Logic (inside build)

**Important:** `AnimatedAvatar` is the single allowed entry point for resolver calls. No screen or widget above it should call resolvers directly.

```dart
Widget? _resolveBackground() {
  if (widget.background != null) return widget.background;
  if (widget.equippedBackgroundId != null) {
    // ── Resolver is called here, not in controller ──
    final path = BackgroundArtworkResolver.instance.resolve(widget.equippedBackgroundId);
    if (path != null) {
      return Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      );
    }
  }
  return null;
}

Widget? _resolveFrame() {
  if (widget.frameOverlay != null) return widget.frameOverlay;
  if (widget.equippedFrameId != null) {
    // ── Resolver is called here, not in controller ──
    final path = FrameArtworkResolver.instance.resolve(widget.equippedFrameId);
    if (path != null) {
      return Positioned.fill(
        child: Image.asset(path, fit: BoxFit.contain),
      );
    }
  }
  return null;
}
```

### Exported Convenience

```dart
/// Creates an equipped frame asset widget for use as frameOverlay.
static Widget buildFrameAsset(String storeItemId, {double? size}) {
  final path = FrameArtworkResolver.instance.resolve(storeItemId);
  if (path == null) return const SizedBox.shrink();
  return Image.asset(path, fit: BoxFit.contain);
}

/// Creates an equipped background asset widget for use as background.
static Widget buildBackgroundAsset(String storeItemId, {double? size}) {
  final path = BackgroundArtworkResolver.instance.resolve(storeItemId);
  if (path == null) return const SizedBox.shrink();
  return Image.asset(path, fit: BoxFit.cover);
}
```

### Backward Compatibility

```dart
const AnimatedAvatar(
  // No frame, no background → renders exactly as today
)
// or
AnimatedAvatar(
  equippedFrameId: controller.equippedFrameId,
  equippedBackgroundId: controller.equippedBackgroundId,
)
```

**All existing call sites compile without changes.** New parameters are optional and default to null.

---

## 6. CustomizationState

### File: `lib/shared/customization/customization_state.dart` (optional)

For widgets that only need to **read** customization state without importing the full controller, provide a lightweight data class:

```dart
class CustomizationState {
  final String? equippedFrameId;
  final String? equippedBackgroundId;
  final String? frameAssetPath;
  final String? backgroundAssetPath;
  final bool hasFrameArtwork;
  final bool hasBackgroundArtwork;

  CustomizationState._({
    this.equippedFrameId,
    this.equippedBackgroundId,
    this.frameAssetPath,
    this.backgroundAssetPath,
    this.hasFrameArtwork = false,
    this.hasBackgroundArtwork = false,
  });

  factory CustomizationState.fromController(CustomizationController c) {
    final frameId = c.equippedFrameId;
    final bgId = c.equippedBackgroundId;
    return CustomizationState._(
      equippedFrameId: frameId,
      equippedBackgroundId: bgId,
      frameAssetPath: FrameArtworkResolver.resolve(frameId),
      backgroundAssetPath: BackgroundArtworkResolver.resolve(bgId),
      hasFrameArtwork: FrameArtworkResolver.hasArtwork(frameId),
      hasBackgroundArtwork: BackgroundArtworkResolver.hasArtwork(bgId),
    );
  }
}
```

This is optional — include only if multiple screens need read-only state.

---

## 7. StoreRepository Integration

### File: `lib/features/store/store_repository.dart`

### New Methods

```dart
/// Returns the currently equipped item IDs from backend.
/// Returns empty map on failure (graceful degradation).
Future<Map<String, String?>> getEquipped() async {
  try {
    final result = await _api.getEquippedItems();
    if (result.isSuccess && result.data != null) {
      return {
        'frame': result.data!['frameId'],
        'background': result.data!['backgroundId'],
      };
    }
  } catch (_) {}
  return {'frame': null, 'background': null};
}
```

### Modified equip()

```dart
Future<bool> equip(String itemId, {String? category}) async {
  try {
    final result = await _api.equipItem(itemId);
    if (result.isSuccess) {
      // Notify CustomizationController to update UserModel
      await CustomizationController.instance.notifyEquipped(itemId, category);
      return true;
    }
  } catch (_) {}
  return false;
}
```

**Note:** The `category` parameter helps the controller know whether this is a frame or background equip. If the backend returns item type, this can be inferred instead.

---

## 8. Equip Flow (Revised)

### Post-Foundation Pipeline

```
User taps "Equip" on StoreItemCard
        │
        ▼
StoreScreen._purchaseItem(item)
        │
        ├─ Owned? ──Yes──► StoreRepository.equip(item.id, category: 'frame')
        │                          │
        │                          ▼
        │                    ApiService.equipItem(itemId)
        │                          │
        │                          ▼
        │                    On success:
        │                      CustomizationController.equipFrame(itemId)
        │                          │
        │                          ├─► Local: setState('equippedFrameId')
        │                          ├─► UserModel: copyWith(equippedFrameId:)
        │                          ├─► SharedPreferences: save updated user
        │                          └─► notifyListeners()
        │                          │
        │                          ▼
        │                    AnimatedAvatar rebuilds with new frame
        │
        └─ Not owned ──► StoreRepository.purchase(itemId) [existing flow]
```

### Key Changes from Current

| Aspect | Current | Post-Foundation |
|--------|---------|-----------------|
| Equip result | Dead-end snackbar | Propagates to UI via controller |
| State storage | Local `_owned` Set | `UserModel` + `CustomizationController` |
| Frame rendering | None | `AnimatedAvatar.frameOverlay` |
| Background rendering | None | `AnimatedAvatar.background` |
| Persistence | Lost on restart | `SharedPreferences` + API |

---

## 9. Execution Order

### Step 1: `UserModel` — Add fields (15 min)
**File:** `lib/shared/models/user_model.dart`

- Add `equippedFrameId`, `equippedBackgroundId`, `ownedItemIds`, `avatarConfig`
- Update `const` constructor, `copyWith`, `toJson`, `fromJson`
- **Validation:** `flutter analyze` passes. No callers break (new fields are optional).

### Step 2: Artwork Resolvers — Create classes (15 min)
**Files:**
- `lib/shared/customization/frame_artwork_resolver.dart`
- `lib/shared/customization/background_artwork_resolver.dart`

- Static mapping classes with `resolve()`, `resolveByName()`, `hasArtwork()`
- **Validation:** Unit tests for each mapping entry pass.

### Step 3: `CustomizationController` — Create singleton (30 min)
**File:** `lib/shared/customization/customization_controller.dart`

- `ChangeNotifier` with `equipFrame()`, `equipBackground()`, `unequipFrame()`, `unequipBackground()`, `initialize()`
- Reads from `AuthService.instance.currentUser` + `StoreRepository`
- **Validation:** Controller initializes without crash. Equip calls update state.

### Step 4: `StoreRepository` — Add methods (15 min)
**File:** `lib/features/store/store_repository.dart`

- Add `getEquipped()` method
- Modify `equip()` to notify controller
- **Validation:** `flutter analyze` passes.

### Step 5: `AnimatedAvatar` — Add parameters (30 min)
**File:** `lib/shared/widgets/animated_avatar.dart`

- Add `frameOverlay`, `background`, `equippedFrameId`, `equippedBackgroundId` parameters
- Add `_resolveFrame()` and `_resolveBackground()` helper methods
- Update Stack children order
- **Validation:** All existing call sites compile without changes. Rendering test with mock frame passes.

### Step 6: Wire initialization (15 min)
**File:** `lib/main.dart` (or appropriate startup location)

- Call `CustomizationController.instance.initialize()` after `AuthService.init()`
- Non-blocking — errors are caught silently
- **Validation:** App starts normally with or without backend.

### Step 7: Integration test (30 min)
- Create a widget test that renders `AnimatedAvatar` with `equippedFrameId: 'frame_2'`
- Verify frame image appears in widget tree
- Verify gradient fallback when `equippedFrameId: 'frame_4'` (no artwork)

**Total execution time:** ~2.5 hours

---

## 10. Domain Layer

### Rationale

Business rules must be independent of data source (API/local) and UI framework (Flutter widgets). Without a domain layer, the `CustomizationController` becomes coupled to `StoreRepository` directly, making it impossible to:
- Swap API for local-first storage
- Add validation rules (e.g., "cannot equip premium item without subscription")
- Unit test business logic without mocking HTTP calls

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Rendering Layer                          │
│  AnimatedAvatar, ProfileScreen, etc.                         │
│  Reads semantic IDs from controller                          │
│  Calls AssetResolver to resolve IDs → asset paths            │
│  Renders Image.asset(path)                                   │
└─────────────────────────┬────────────────────────────────────┘
                          │ reads IDs from
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                  Customization State                         │
│  CustomizationController (ChangeNotifier)                    │
│  Holds equippedFrameId, equippedBackgroundId, ownedItemIds   │
│  Semantic identities only — never calls resolvers            │
│  Delegates business logic to Domain                          │
└─────────────────────────┬────────────────────────────────────┘
                          │ delegates
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                  Domain Layer                                │
│  CustomizationDomain                                         │
│  - canEquip(itemId) → business rules (ownership, premium)    │
│  - inferCategory(itemId) → 'frame', 'background', etc.       │
│  - validateEquip(itemId) → EquipRequest or null              │
│  Pure Dart — no Flutter dependency, no asset knowledge       │
└─────────────────────────┬────────────────────────────────────┘
                          │ calls
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                  Data Layer                                  │
│  StoreRepository + ApiService                                │
│  Raw CRUD — no business logic                                │
└──────────────────────────────────────────────────────────────┘

Resolution happens at the rendering layer, not in state:
  AnimatedAvatar._resolveFrame()
      → FrameArtworkResolver.instance.resolve(equippedFrameId)
      → Image.asset(path)
```
```

### File: `lib/shared/customization/domain/customization_domain.dart`

```dart
/// Pure business logic for customization operations.
/// No Flutter dependency — testable in pure Dart.
class CustomizationDomain {
  const CustomizationDomain();

  /// Can the user equip this item?
  /// Returns null if allowed, or an error message string if blocked.
  String? canEquip(String itemId, {
    required bool isOwned,
    required bool isPremium,
    required bool hasActiveSubscription,
  }) {
    if (!isOwned) return 'Item not owned';
    // Future rules:
    // - premium items require subscription
    // - level-gated items require minimum level
    // - mutually exclusive categories (only one frame at a time)
    return null; // allowed
  }

  /// Returns the category for a given item ID.
  /// Used by the controller to route equip calls.
  String? inferCategory(String itemId) {
    if (itemId.startsWith('frame_') || itemId.startsWith('bg_')) {
      return itemId.startsWith('frame_') ? 'frame' : 'background';
    }
    return null; // unknown category
  }

  /// Validates that an equip operation is allowed and returns
  /// the category. Throws or returns error for invalid items.
  EquipRequest? validateEquip(String itemId, {
    required bool isOwned,
    required bool isPremium,
    required bool hasActiveSubscription,
  }) {
    final error = canEquip(itemId,
      isOwned: isOwned,
      isPremium: isPremium,
      hasActiveSubscription: hasActiveSubscription,
    );
    if (error != null) return null;
    final category = inferCategory(itemId);
    if (category == null) return null;
    return EquipRequest(itemId: itemId, category: category);
  }
}

class EquipRequest {
  final String itemId;
  final String category;
  const EquipRequest({required this.itemId, required this.category});
}
```

### What the Domain Layer Does NOT Do

| Not its responsibility | Handled by |
|------------------------|------------|
| Call APIs | `StoreRepository` |
| Store state | `CustomizationController` + `UserModel` |
| Resolve asset paths | `AssetResolver` implementations |
| Render widgets | `AnimatedAvatar` + screens |
| Persist to disk | `SharedPreferences` + API |

### Backward Compatibility

- `CustomizationDomain` is a new class with no dependencies on existing code
- All methods are pure functions — no side effects
- Existing `StoreRepository` and `CustomizationController` continue to work; the domain is adopted incrementally
- During Phase 3, the controller may call domain optionally; fallback = direct repository call (current behavior)

---

## 11. AssetResolver Interface

> Already specified in [Section 4 — Asset Resolver System](#4-asset-resolver-system)

The `AssetResolver` abstract class and its concrete implementations (`FrameArtworkResolver`, `BackgroundArtworkResolver`) serve as the bridge between the domain/state layers and the physical asset files. Key properties:

- **Polymorphic dispatch:** Any code that needs to resolve an asset can accept `AssetResolver` without knowing the concrete type
- **Zero Flutter dependency:** Resolvers return `String?` paths — no `Image` or `BuildContext` involved
- **Hot-swappable:** A resolver can be replaced at runtime (e.g., CDN-backed resolver vs local asset resolver)

---

## 12. Files Modified

| # | File | Change Type | Lines Changed |
|---|------|-------------|--------------|
| 1 | `lib/shared/models/user_model.dart` | Extension — add 4 fields | +25 |
| 2 | `lib/shared/customization/customization_controller.dart` | **New file** | ~80 |
| 3 | `lib/shared/customization/frame_artwork_resolver.dart` | **New file** | ~35 |
| 4 | `lib/shared/customization/background_artwork_resolver.dart` | **New file** | ~35 |
| 5 | `lib/shared/customization/customization_state.dart` | **New file** (optional) | ~30 |
| 6 | `lib/shared/widgets/animated_avatar.dart` | Extension — add 4 params + resolution | +50 |
| 7 | `lib/features/store/store_repository.dart` | Extension — add getEquipped() | +15 |
| 8 | `lib/main.dart` (or app startup) | Extension — add init call | +2 |
| 9 | `lib/shared/widgets/widgets.dart` | Export new files if in shared barrel | +3 |

**Total new files:** 3–4  
**Total modified files:** 5  
**Total lines added:** ~250 (mostly new files)

### Exports

If `lib/shared/widgets/widgets.dart` is a barrel file:
```dart
export 'customization/customization_controller.dart';
export 'customization/frame_artwork_resolver.dart';
export 'customization/background_artwork_resolver.dart';
```

---

## 13. Validation

### Automation

```
flutter analyze
```
Expected: 0 errors, 0 warnings (existing info-level issues unchanged).

### Manual Checks

| Check | Method |
|-------|--------|
| `UserModel` backward compat | Create from old JSON → all new fields null |
| `AnimatedAvatar` backward compat | Existing call sites compile, render identical |
| `CustomizationController.init()` | Logs warning on API failure, doesn't crash |
| Frame resolve correct | `FrameArtworkResolver.resolve('frame_2')` → returns `AppAssets.frameGold` |
| Background resolve correct | `BackgroundArtworkResolver.resolve('bg_4')` → returns `AppAssets.bgSpace` |
| Missing artwork fallback | `FrameArtworkResolver.resolve('frame_4')` → returns `null` |
| Equip → UI propagation | Mock: call `controller.equipFrame('frame_2')` → `controller.equippedFrameId` equals `'frame_2'` |

### What NOT to Test (Phase 3 Scope)

- Do NOT test that frames appear on ProfileScreen (requires Phase 4 screen updates)
- Do NOT test purchase flow end-to-end (existing StoreScreen unchanged)
- Do NOT test frame/background grid selection (existing shops unchanged)
- Do NOT test performance with 10+ frames in memory (future phase)

---

## 14. What This Unlocks

### After Phase 3 Foundation, the following become trivial:

| Future Task | Effort Before Foundation | Effort After Foundation |
|-------------|-------------------------|------------------------|
| Show equipped frame on Profile | Days (build all infra) | **Minutes** (pass `controller.equippedFrameId` to `AnimatedAvatar`) |
| Show equipped background on Home | Days | **Minutes** |
| Replace CustomPaint frame with PNG | Days (rewrite workshop + state) | **1 hour** (update resolver mapping + workshop picker) |
| Replace gradient BG with image | Days | **1 hour** |
| Persist avatar body parts | Impossible without model | **30 min** (`avatarConfig` field ready) |
| Server-driven asset mapping | Impossible | **1 hour** (overload `_mapping` from API) |

### Design Principle Preserved

> "Don't replace a working gradient/image placeholder just because an asset exists. Replace only when the full pipeline (purchase → equip → render) is operational."

---

## 15. Future Extensibility

The architecture described in this specification must support future cosmetic systems without redesign. Below is a catalog of known and anticipated cosmetic categories, with the impact assessment for each.

### Legend

| Category | Description | Priority |
|----------|-------------|----------|
| **Implemented now** | Frame, Background | Phase 3 |
| **Planned** | Achievements (Wave 4 completed), Avatar body parts | Phase 4 |
| **Future** | Nameplates, Chat Bubbles, Entry Effects, Themes | V2+ |

### Compatibility Matrix

| Future Cosmetic | Data Model Impact | Rendering Impact | Resolver Impact | Store Impact | Migration Risk |
|----------------|------------------|-----------------|-----------------|-------------|----------------|
| **Avatar Clothing** | Add `equippedClothingId` to `UserModel`; `avatarConfig.clothing` map | `AnimatedAvatar` new clothing layer below badge | New `ClothingArtworkResolver implements AssetResolver` | New `StoreCategory.clothing` + store items | LOW — additive, no existing system changes |
| **Hairstyles** | Add `equippedHairstyleId`; `avatarConfig.hairstyle` | `AnimatedAvatar` hairstyle layer on top of avatar circle | New `HairstyleArtworkResolver implements AssetResolver` | New store items or part of avatar shop | LOW — hair is independent slot |
| **Accessories** | Already partially supported by `avatarConfig` field | `AnimatedAvatar` accessory layer (top-most) | New `AccessoryArtworkResolver implements AssetResolver` | Extend existing avatar editor | LOW — `avatarConfig` was designed for this |
| **Nameplates** | Add `equippedNameplateId` to `UserModel` | Nameplate rendered below username in profile header; needs new widget slot | New `NameplateArtworkResolver implements AssetResolver` | New `StoreCategory.nameplate` + items | LOW — independent layer, no existing overlap |
| **Chat Bubbles** | Add `equippedChatBubbleId` to `UserModel` | Chat message widget reads bubble ID → renders custom bubble shape; may need `CustomPainter` fallback | New `ChatBubbleArtworkResolver implements AssetResolver` | New store category | MEDIUM — touches chat rendering code; fallback to default bubble trivial |
| **Entry Effects** | Add `equippedEntryEffectId` to `UserModel` | Splash/transition screens read effect ID → play Lottie or animation | New `EntryEffectResolver implements AssetResolver` (may resolve to Lottie paths, not PNG) | New store category (premium) | MEDIUM — entry points are scattered; need single animation gateway widget |
| **Profile Themes** | Add `equippedThemeId` to `UserModel` | Profile screen gradient/text colors read from theme definition; may override `AppColors` | New `ThemeResolver implements AssetResolver` (resolves to theme JSON/config, not image) | New store category | HIGH — touches design system (`AppColors`); must coexist with existing theme |
| **Seasonal Events** | Add `eventCosmetics` map to `UserModel` (keyed by event ID) | Event-specific overlays on avatar, home screen banner, etc. | Event resolver wraps existing resolvers with override mappings | Event store section with time-limited items | MEDIUM — resolver override mechanism needed; `AssetResolver.mapping` override support planned |
| **Limited-Time Rewards** | No model change (uses existing equipped fields + expiry) | No rendering change | Resolver checks expiry before returning path | Store items gain `availableUntil` (already supported) | LOW — `StoreItem` already has `availableUntil` |
| **Premium Cosmetics** | Add `isPremium` flags to items (already supported) | Premium badge overlay on cosmetic items | No change | Already categorized | LOW — `StoreItem.isPremium` already exists |
| **NFT / Collectibles (future)** | Add `tokenId`, `contractAddress` to items; blockchain verification layer | No rendering change; asset may load from IPFS/URL instead of local | New `BlockchainArtworkResolver implements AssetResolver` — resolves token URI → CDN path | New blockchain store section; verification service | HIGH — new infrastructure, but resolver abstraction makes rendering layer immune |

### What NEVER Changes

Regardless of which future cosmetic is added, these layers remain untouched:

| Layer | Reason |
|-------|--------|
| `AnimatedAvatar` rendering order | The Stack pattern (background → glow → avatar → frame → badge) is universal |
| `UserModel` equipped fields | Adding a new field is additive; existing fields never move or rename |
| `AssetResolver` interface | New resolvers implement the same contract; rendering code stays polymorphic |
| `CustomizationController` | Controller dispatches by category; adding a new category is a new method, not a refactor |
| `CustomizationDomain.canEquip()` | Rules are item-specific; the method signature stays, logic extends |

---

## 16. Golden Rule

### The UI must never know where an asset lives.

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   Widgets may only request semantic identities.              ║
║   The mapping from semantic identity to asset path           ║
║   must always be handled by the resolver layer.              ║
║                                                              ║
║   ✅ FrameArtworkResolver.resolve(FrameId.gold)              ║
║   ❌ Image.asset(AppAssets.frameGold)  (in a widget)         ║
║                                                              ║
║   No widget may reference AppAssets directly                 ║
║   unless it is itself a rendering component                  ║
║   (i.e., AnimatedAvatar or an explicit asset widget).        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

### Why

| Scenario | Without Golden Rule | With Golden Rule |
|----------|-------------------|------------------|
| PNG → WebP conversion | Update 100+ `Image.asset(AppAssets.xxx)` call sites | Update 1 resolver mapping |
| Local assets → CDN | Rewrite every `Image.asset` → `Image.network` | Update 1 resolver to return URL |
| File renamed | Update 100+ `AppAssets` references + `pubspec.yaml` | Update 1 resolver mapping |
| New asset format (SVG) | Replace `Image.asset` with `SvgPicture.asset` everywhere | Update 1 resolver + renderer |
| Server-driven asset mapping | Impossible without touching every widget | Resolver reads from API at runtime |

### Enforcement

| Level | Rule |
|-------|------|
| **Lint** | (Future) Custom lint rule: forbid `AppAssets.xxx` outside of `lib/shared/customization/` and `lib/shared/widgets/animated_avatar.dart` |
| **Code review** | Any `Image.asset(AppAssets.xxx)` in a screen file must be justified and approved |
| **Architecture** | Screens import resolvers, not `AppAssets` |

### Exception

`AnimatedAvatar` (the rendering component) may reference `AppAssets` directly in its auto-resolution logic (`_resolveFrame`, `_resolveBackground`). This is the **single allowed entry point** for asset path resolution into the widget tree. All other widgets must go through `AnimatedAvatar` parameters or resolver calls.

---

## 17. Asset Manifest

### Problem

Currently, asset paths are hardcoded in two places:
1. `AppAssets` constants in `lib/core/constants/app_assets.dart`
2. `pubspec.yaml` directory declarations

This creates a maintenance burden: renaming a file or changing a format requires edits in multiple locations with no single source of truth.

### Solution: Single Manifest File

**File:** `lib/shared/customization/asset_manifest.dart`

```dart
/// Single source of truth for all asset paths.
/// Resolvers read from this manifest, never from hardcoded strings.
///
/// To add a new asset: 1) add path here, 2) add file to assets/,
/// 3) update pubspec.yaml. No other code changes needed.
class AssetManifest {
  AssetManifest._();

  // ── Characters ────────────────────────────────────────────────────
  static const String lexiHappy = 'assets/images/characters/lexi_happy.png';
  static const String lexiThinking = 'assets/images/characters/lexi_thinking.png';
  // ... all existing AppAssets paths ...

  // ── Frames ────────────────────────────────────────────────────────
  static const String frameGold = 'assets/images/frames/frame_gold.png';
  static const String frameSilver = 'assets/images/frames/frame_silver.png';
  static const String frameNeon = 'assets/images/frames/frame_neon.png';
  static const String frameDiamond = 'assets/images/frames/frame_diamond.png';

  // ── Backgrounds ───────────────────────────────────────────────────
  static const String bgSpace = 'assets/images/backgrounds/bg_space.png';
  static const String bgOcean = 'assets/images/backgrounds/bg_ocean.png';
  static const String bgForest = 'assets/images/backgrounds/bg_forest.png';
  static const String bgCity = 'assets/images/backgrounds/bg_city.png';
  static const String bgMountain = 'assets/images/backgrounds/bg_mountain.png';
  static const String bgAbstract = 'assets/images/backgrounds/bg_abstract.png';
  static const String bgAurora = 'assets/images/backgrounds/bg_aurora.png';

  // ── Achievements ──────────────────────────────────────────────────
  static const String achievementFirstWord = 'assets/images/achievements/achievement_first_word.png';
  static const String achievementStreak7 = 'assets/images/achievements/achievement_streak_7.png';
  static const String achievementStreak30 = 'assets/images/achievements/achievement_streak_30.png';
  static const String achievement100Words = 'assets/images/achievements/achievement_100_words.png';

  // ── Lottie ────────────────────────────────────────────────────────
  static const String lottieConfetti = 'assets/lottie/lottie_confetti.json';
  static const String lottieSuccessCheck = 'assets/lottie/lottie_success_check.json';
}
```

### Manifest → Resolver Flow

```
AssetManifest (single source of truth)
      │
      ▼
FrameArtworkResolver._mapping = {
  'frame_1': AssetManifest.frameSilver,
  'frame_2': AssetManifest.frameGold,
  ...
}
      │
      ▼
AnimatedAvatar._resolveFrame()
  → FrameArtworkResolver.instance.resolve('frame_2')
  → AssetManifest.frameGold
  → Image.asset(AssetManifest.frameGold)
```

### What Changes When

| Change | Files Modified |
|--------|----------------|
| Rename file | `AssetManifest` path + `pubspec.yaml` (if directory changed) |
| Convert PNG → WebP | `AssetManifest` path extension + rename actual file |
| Add new frame asset | `AssetManifest` + resolver mapping + add file + `pubspec.yaml` |
| Move to CDN | `AssetManifest` changes from local path to URL; resolver returns URL; renderer switches to `Image.network` |
| Server-driven overrides | `AssetManifest` is the default; server response merges at resolver level |

### Migration from `AppAssets`

`AppAssets` (current) → `AssetManifest` (new). During Phase 3:
- `AssetManifest` is created with all paths from `AppAssets`
- Resolvers are updated to reference `AssetManifest` instead of `AppAssets`
- `AppAssets` is kept for backward compatibility (other code may still import it)
- Future phase: `AppAssets` is deprecated and removed

### Validation Tool (Future)

A script can verify that every path in `AssetManifest` corresponds to an actual file on disk:

```bash
# Example check (future)
dart run scripts/validate_manifest.dart
```

---

## 18. Rendering Performance Contract

All customization rendering must follow these rules to prevent jank, memory bloat, and unnecessary rebuilds.

### Rule 1: Never decode invisible images

```dart
// ❌ WRONG — decoded before visible
Image.asset(AssetManifest.frameGold);

// ✅ CORRECT — decoded only when needed
if (isVisible) {
  Image.asset(AssetManifest.frameGold);
}
```

**Implementation:** Use `VisibilityDetector` or `AutomaticKeepAliveClientMixin` in scrollable lists. Do not pre-build asset widgets for off-screen items.

### Rule 2: Precache only what's expected

```dart
// ❌ WRONG — precache every possible frame
for (final id in allFrameIds) {
  precacheImage(AssetImage(AssetManifest.frameGold), context);
}

// ✅ CORRECT — precache only the equipped item + top 3 shop items
Future<void> _precacheCustomization() async {
  final controller = CustomizationController.instance;
  final equippedFrame = controller.equippedFrameId;
  if (equippedFrame != null) {
    final path = FrameArtworkResolver.instance.resolve(equippedFrame);
    if (path != null) {
      await precacheImage(AssetImage(path), context);
    }
  }
}
```

**Implementation:** `CustomizationController.initialize()` returns a future that screen-level widgets may optionally `await` for precaching. Non-blocking by default.

### Rule 3: No large images in scrollable lists

Backgrounds are 941×1672 (~4.5 MB decoded). Never render them inside a `ListView`, `GridView`, or `SingleChildScrollView` directly.

```dart
// ❌ WRONG — background in scrollable
ListView(
  children: [
    Image.asset(AssetManifest.bgSpace), // 4.5 MB decoded
    // ... 20 more items
  ],
);

// ✅ CORRECT — background is behind the scrollable, not inside it
Stack(
  children: [
    // Background: fixed, scrolls with the stack
    Positioned.fill(child: Image.asset(AssetManifest.bgSpace, fit: BoxFit.cover)),
    // Content: scrollable
    Positioned.fill(
      child: ListView(children: [...]),
    ),
  ],
);
```

### Rule 4: No new resolver instances per build

```dart
// ❌ WRONG — creates new instance on every build
Widget build(BuildContext context) {
  final resolver = FrameArtworkResolver(); // new every frame
  return Image.asset(resolver.resolve('frame_2'));
}

// ✅ CORRECT — singleton
Widget build(BuildContext context) {
  return Image.asset(FrameArtworkResolver.instance.resolve('frame_2'));
}
```

**Implementation:** All `AssetResolver` implementations are singletons (`static final instance`). Widgets call `ClassName.instance`, never `ClassName()`.

### Rule 5: Stable keys for cosmetic switches

When a frame or background changes, Flutter must recognize the widget tree change without rebuilding unrelated widgets.

```dart
// ❌ WRONG — no key, Flutter may diff incorrectly
AnimatedAvatar(
  equippedFrameId: frameId, // changing this rebuilds the entire avatar
);

// ✅ CORRECT — key changes force clean swap, preventing stale cache
AnimatedAvatar(
  key: ValueKey('avatar_$frameId_$bgId'),
  equippedFrameId: frameId,
  equippedBackgroundId: bgId,
);
```

**Implementation:** `AnimatedAvatar` internally derives a `ValueKey` from its customization parameters when any equipped ID is non-null.

### Rule 6: Dispose unused image streams

When a frame is unequipped, the old image asset must be disposed to free memory.

```dart
// Handled by Flutter's ImageCache when:
// 1. The old Image.asset widget is removed from the tree
// 2. The cache entry is evicted (default 1000 entries / 50 MB)
//
// Explicit eviction for large backgrounds:
void didUpdateWidget(AnimatedAvatar old) {
  if (old.equippedBackgroundId != widget.equippedBackgroundId) {
    final oldPath = BackgroundArtworkResolver.instance.resolve(old.equippedBackgroundId);
    if (oldPath != null) {
      ImageCache? cache = PaintingBinding.instance?.imageCache;
      cache?.evict(AssetImage(oldPath));
    }
  }
}
```

### Rule 7: Profile-ready for `Image.network` switch

All asset rendering code uses `Image.asset` with a `String` path. When switching to CDN-delivered assets, the rendering code changes in one place only:

```dart
// Current widget helper (inside AnimatedAvatar):
Widget _buildAssetImage(String path, BoxFit fit) {
  return Image.asset(path, fit: fit);
}

// Future CDN version (same signature, different implementation):
Widget _buildAssetImage(String path, BoxFit fit) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: fit);
  }
  return Image.asset(path, fit: fit);
}
```

The `AssetResolver` layer is the only place that decides whether the returned `String?` is a local asset path or a URL.

### Performance Budget

| Metric | Target | Enforcement |
|--------|--------|-------------|
| Max decoded images in memory | 5 | ImageCache default (1000 entries) + Rule 6 eviction |
| Max frame decode time | < 16ms | PNG < 512×512; resize if larger |
| Max background decode time | < 50ms | WebP format recommended; 941×1672 at 24-bit |
| Build count on equip change | 1 (the affected AnimatedAvatar) | Rule 5 (stable keys) |
| Resolver call overhead | < 0.1ms per call | Singleton + `const` map lookup |

---

*End of Specification v2. No code implementation yet — awaiting approval.*
