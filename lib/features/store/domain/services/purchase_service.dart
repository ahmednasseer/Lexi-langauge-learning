import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/store_item.dart';

class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final int remainingGems;

  PurchaseResult({
    required this.success,
    this.errorMessage,
    this.remainingGems = 0,
  });
}

/// API-backed purchase flow. All price checks, balance checks, ownership checks
/// and ledger entries happen server-side (NestJS + PostgreSQL).
class PurchaseService {
  final ApiService _api;

  PurchaseService({ApiService? api}) : _api = api ?? ApiService();

  Future<PurchaseResult> purchaseItem({
    required String userId,
    required StoreItem item,
  }) async {
    if (item.price <= 0) {
      return PurchaseResult(success: false, errorMessage: 'Invalid item price');
    }

    try {
      final result = await _api.purchaseItem(item.id);
      if (!result.isSuccess) {
        return PurchaseResult(
          success: false,
          errorMessage: result.error ?? 'Purchase failed',
        );
      }
      final gems = result.data?['gems'] as int? ?? 0;
      return PurchaseResult(success: true, remainingGems: gems);
    } catch (e) {
      return PurchaseResult(
        success: false,
        errorMessage: 'Purchase failed. Please try again.',
      );
    }
  }

  Future<bool> isItemOwned(String userId, String itemId) async {
    try {
      final result = await _api.getInventory();
      if (!result.isSuccess || result.data == null) return false;
      return result.data!.any((raw) {
        final map = (raw as Map).cast<String, dynamic>();
        final ownedItemId = map['itemId'] as String?;
        return ownedItemId == itemId;
      });
    } catch (e) {
      return false;
    }
  }
}