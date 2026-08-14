import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Wallet?> getWallet(String userId);
  Future<void> saveWallet(Wallet wallet);
  Future<Wallet> addCurrency({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type,
  });
  Future<Wallet> spendCurrency({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type,
  });
  Future<List<WalletTransaction>> getTransactions(
    String userId, {
    int limit = 50,
  });
  Future<WalletTransaction> addTransaction(WalletTransaction transaction);
  Future<void> createInitialWallet(String userId);
}
