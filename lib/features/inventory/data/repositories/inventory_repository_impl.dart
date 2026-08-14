import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

/// API-backed implementation. Owned items are read from NestJS; equipping is a
/// server operation. Unequipping is tracked locally because the backend does
/// not expose an unequip endpoint.
class InventoryRepositoryImpl implements InventoryRepository {
  final ApiService _api;
  final Set<String> _equippedCache = {};

  InventoryRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  ItemType _mapType(String raw) {
    switch (raw) {
      case 'avatar':
        return ItemType.avatar;
      case 'frame':
        return ItemType.frame;
      case 'background':
        return ItemType.background;
      case 'badge':
        return ItemType.badge;
      case 'powerUp':
        return ItemType.powerUp;
      case 'bundle':
        return ItemType.bundle;
      default:
        return ItemType.avatar;
    }
  }

  InventoryItem _fromJson(Map<String, dynamic> json) {
    final itemRaw = json['item'] is Map<String, dynamic>
        ? (json['item'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final categoryRaw = itemRaw['category'] as String? ?? '';
    final itemId = json['itemId'] as String? ?? itemRaw['id'] ?? '';
    final purchasedAt = json['purchasedAt'] != null
        ? DateTime.tryParse(json['purchasedAt'].toString())
        : null;
    return InventoryItem(
      id: json['id'] as String? ?? itemId,
      itemId: itemId,
      userId: json['userId'] as String? ?? '',
      itemType: _mapType(categoryRaw),
      name: itemRaw['name'] as String? ?? '',
      icon: itemRaw['imageUrl'] as String? ?? '',
      isOwned: true,
      isEquipped: _equippedCache.contains(itemId),
      purchasedAt: purchasedAt,
      equippedAt: _equippedCache.contains(itemId) ? DateTime.now() : null,
    );
  }

  @override
  Future<List<InventoryItem>> getInventory(String userId) async {
    final result = await _api.getInventory();
    if (!result.isSuccess || result.data == null) return [];
    return result.data!
        .map<InventoryItem>(
          (raw) => _fromJson((raw as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  @override
  Future<InventoryItem?> getItem(String userId, String itemId) async {
    final inventory = await getInventory(userId);
    return inventory.where((i) => i.itemId == itemId).firstOrNull;
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) {
    throw UnsupportedError(
      'Inventory is server-managed. Items are added by server-side purchases.',
    );
  }

  @override
  Future<void> removeItem(String userId, String itemId) {
    throw UnsupportedError('Removing owned items is not allowed from the client.');
  }

  @override
  Future<InventoryItem> equipItem(String userId, String itemId) async {
    final item = await getItem(userId, itemId);
    if (item == null) {
      throw Exception('Item not found in inventory');
    }

    final result = await _api.equipItem(itemId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to equip item');
    }

    _equippedCache.add(itemId);
    return item.copyWith(isEquipped: true, equippedAt: DateTime.now());
  }

  @override
  Future<InventoryItem> unequipItem(String userId, String itemId) async {
    final item = await getItem(userId, itemId);
    if (item == null) {
      throw Exception('Item not found in inventory');
    }
    _equippedCache.remove(itemId);
    return item.copyWith(isEquipped: false, equippedAt: null);
  }

  @override
  Future<List<InventoryItem>> getEquippedItems(String userId) async {
    final inventory = await getInventory(userId);
    return inventory.where((i) => i.isEquipped).toList();
  }

  @override
  Future<void> initializeInventory(String userId) async {
    // Inventory is initialized server-side (defaults) for new users.
  }
}