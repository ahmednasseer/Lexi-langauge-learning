import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'models/gems_wallet.dart';

class WalletRepository {
  final ApiService _api = ApiService();

  Future<GemsWallet> getWallet() async {
    try {
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
    } catch (_) {}
    return GemsWallet(
      userId: AuthService.instance.currentUser?.id ?? '',
      gems: 100,
    );
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final result = await _api.getWallet();
      if (result.isSuccess && result.data != null) {
        final raw = result.data!['transactions'] as List?;
        if (raw != null) {
          return raw.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return _sampleTransactions();
  }

  Future<void> spendGems(int amount, String description) async {
    try {
      await _api.spendGems(amount, description);
    } catch (_) {}
  }

  List<Transaction> _sampleTransactions() {
    final now = DateTime.now();
    return [
      Transaction(id: 't1', userId: AuthService.instance.currentUser?.id ?? '', type: TransactionType.reward, amount: 50, description: 'Daily login reward', createdAt: now.subtract(const Duration(days: 1))),
      Transaction(id: 't2', userId: AuthService.instance.currentUser?.id ?? '', type: TransactionType.purchase, amount: 100, description: 'Starter gem pack', createdAt: now.subtract(const Duration(days: 3))),
      Transaction(id: 't3', userId: AuthService.instance.currentUser?.id ?? '', type: TransactionType.spending, amount: 50, description: 'Gold frame purchase', createdAt: now.subtract(const Duration(days: 5))),
    ];
  }
}
