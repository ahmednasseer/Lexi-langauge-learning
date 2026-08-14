import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  Future<Wallet?> call(String userId) async {
    return repository.getWallet(userId);
  }
}

class AddCurrencyUseCase {
  final WalletRepository repository;

  AddCurrencyUseCase(this.repository);

  Future<Wallet> call({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type = TransactionType.earned,
  }) async {
    return repository.addCurrency(
      userId: userId,
      gems: gems,
      coins: coins,
      description: description,
      type: type,
    );
  }
}

class SpendCurrencyUseCase {
  final WalletRepository repository;

  SpendCurrencyUseCase(this.repository);

  Future<Wallet> call({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type = TransactionType.spent,
  }) async {
    return repository.spendCurrency(
      userId: userId,
      gems: gems,
      coins: coins,
      description: description,
      type: type,
    );
  }
}

class GetTransactionsUseCase {
  final WalletRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<WalletTransaction>> call(String userId, {int limit = 50}) async {
    return repository.getTransactions(userId, limit: limit);
  }
}

class CreateInitialWalletUseCase {
  final WalletRepository repository;

  CreateInitialWalletUseCase(this.repository);

  Future<void> call(String userId) async {
    return repository.createInitialWallet(userId);
  }
}

class CanAffordUseCase {
  final WalletRepository repository;

  CanAffordUseCase(this.repository);

  Future<bool> call({
    required String userId,
    int gems = 0,
    int coins = 0,
  }) async {
    final wallet = await repository.getWallet(userId);
    if (wallet == null) return false;
    return wallet.canAfford(gems: gems, coins: coins);
  }
}
