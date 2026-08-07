import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import 'models/gems_wallet.dart';

class WalletRepository {
  final ApiService _api = ApiService();

  Future<GemsWallet> getWallet() async {
    final result = await _api.getWallet();
    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      return GemsWallet(
        userId: AuthService.instance.currentUser?.id ?? data['userId'] ?? '',
        gems: data['gems'] ?? data['balance'] ?? 0,
        totalPurchased: data['totalPurchased'] ?? 0,
        totalSpent: data['totalSpent'] ?? 0,
      );
    }
    throw Exception(result.error ?? 'Failed to load wallet');
  }

  Future<List<Transaction>> getTransactions() async {
    final result = await _api.getTransactions();
    if (result.isSuccess && result.data != null) {
      return result.data!.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(result.error ?? 'Failed to load transactions');
  }

  Future<GemsWallet> spendGems(int amount, String description) async {
    final result = await _api.spendGems(amount, description);
    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      return GemsWallet(
        userId: AuthService.instance.currentUser?.id ?? data['userId'] ?? '',
        gems: data['gems'] ?? data['balance'] ?? 0,
        totalPurchased: data['totalPurchased'] ?? 0,
        totalSpent: data['totalSpent'] ?? 0,
      );
    }
    throw Exception(result.error ?? 'Failed to spend gems');
  }
}
