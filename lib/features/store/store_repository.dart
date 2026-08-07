import '../../core/services/api_service.dart';
import 'models/store_item.dart';

class StoreRepository {
  final ApiService _api = ApiService();

  Future<List<StoreItem>> getItems({StoreCategory? category}) async {
    try {
      final result = await _api.getStoreItems(
        category: category?.name,
      );
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => StoreItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    final items = category != null
        ? StoreItem.getItemsByCategory(category)
        : StoreItem.getAllItems();
    return items;
  }

  Future<List<String>> getInventory() async {
    try {
      final result = await _api.getInventory();
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!
            .map((e) => (e['id'] ?? e['itemId'] ?? '') as String)
            .where((id) => id.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> purchase(String itemId) async {
    try {
      final result = await _api.purchaseItem(itemId);
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<bool> equip(String itemId) async {
    try {
      final result = await _api.equipItem(itemId);
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }
}
