import '../entities/store_item.dart';

abstract class StoreRepository {
  Future<List<StoreItem>> getAllItems();
  Future<List<StoreItem>> getItemsByCategory(StoreItemCategory category);
  Future<StoreItem?> getItem(String itemId);
  Future<void> addItem(StoreItem item);
  Future<void> updateItem(StoreItem item);
  Future<void> deleteItem(String itemId);
}
