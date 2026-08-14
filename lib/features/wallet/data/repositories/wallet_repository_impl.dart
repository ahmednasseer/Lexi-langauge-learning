import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// API-backed implementation. NestJS + PostgreSQL is the authoritative source
/// for the wallet balance and transaction history. The client never writes the
/// balance or transactions directly; all mutations go through server endpoints.
class WalletRepositoryImpl implements WalletRepository {
  static const int maxTransactionAmount = 10000;

  final ApiService _api;

  WalletRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  TransactionType _mapType(String raw) {
    switch (raw) {
      case 'purchase':
      case 'reward':
      case 'refund':
        return TransactionType.earned;
      case 'spending':
        return TransactionType.spent;
      default:
        return TransactionType.earned;
    }
  }

  @override
  Future<Wallet?> getWallet(String userId) async {
    final result = await _api.getWallet();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load wallet');
    }
    final gems = result.data?['gems'] as int? ?? 0;
    return Wallet(
      userId: userId,
      gems: gems,
      coins: 0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveWallet(Wallet wallet) {
    throw UnsupportedError(
      'Wallet balance is managed server-side. Use spendCurrency via the API.',
    );
  }

  @override
  Future<Wallet> addCurrency({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type = TransactionType.earned,
  }) {
    if (coins > 0) {
      throw UnsupportedError('Coins are not supported by the server wallet.');
    }
    throw UnsupportedError(
      'Gems can only be granted through server-authorized reward flows '
      '(daily missions, achievements). The client cannot add currency itself.',
    );
  }

  @override
  Future<Wallet> spendCurrency({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type = TransactionType.spent,
  }) async {
    if (coins > 0) {
      throw Exception('Coins are not supported by the server wallet.');
    }
    if (gems <= 0 || gems > maxTransactionAmount) {
      throw Exception('Invalid gem amount to spend');
    }

    final result = await _api.spendGems(gems, description);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to spend gems');
    }

    return Wallet(
      userId: userId,
      gems: result.data?['gems'] as int? ?? 0,
      coins: 0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<WalletTransaction>> getTransactions(
    String userId, {
    int limit = 50,
  }) async {
    final result = await _api.getTransactions();
    if (!result.isSuccess || result.data == null) return [];

    final list = result.data!;
    return list.take(limit).map<WalletTransaction>((raw) {
      final map = raw is Map<String, dynamic> ? raw : (raw as Map).cast<String, dynamic>();
      final typeRaw = map['type'] as String? ?? 'purchase';
      final amount = map['amount'] as int? ?? 0;
      return WalletTransaction(
        id: map['id'] as String? ?? '',
        userId: userId,
        type: _mapType(typeRaw),
        amount: amount.abs(),
        currency: 'gems',
        description: map['description'] as String? ?? '',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<WalletTransaction> addTransaction(WalletTransaction transaction) {
    throw UnsupportedError(
      'Transactions are recorded server-side. The client cannot create them.',
    );
  }

  @override
  Future<void> createInitialWallet(String userId) async {
    // The server auto-creates the wallet (with the welcome bonus) on first read.
  }
}