import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory(String userId);
  Future<InventoryItem?> getItem(String userId, String itemId);
  Future<InventoryItem> addItem(InventoryItem item);
  Future<void> removeItem(String userId, String itemId);
  Future<InventoryItem> equipItem(String userId, String itemId);
  Future<InventoryItem> unequipItem(String userId, String itemId);
  Future<List<InventoryItem>> getEquippedItems(String userId);
  Future<void> initializeInventory(String userId);
}
