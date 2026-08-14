import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/wallet_usecases.dart';

// States
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;

  const WalletLoaded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class WalletUpdating extends WalletState {}

class WalletTransactionLoaded extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;

  const WalletTransactionLoaded(this.wallet, this.transactions);

  @override
  List<Object?> get props => [wallet, transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository;
  late final GetWalletUseCase getWalletUseCase;
  late final AddCurrencyUseCase addCurrencyUseCase;
  late final SpendCurrencyUseCase spendCurrencyUseCase;
  late final GetTransactionsUseCase getTransactionsUseCase;
  late final CreateInitialWalletUseCase createInitialWalletUseCase;
  late final CanAffordUseCase canAffordUseCase;

  WalletCubit(this.repository) : super(WalletInitial()) {
    getWalletUseCase = GetWalletUseCase(repository);
    addCurrencyUseCase = AddCurrencyUseCase(repository);
    spendCurrencyUseCase = SpendCurrencyUseCase(repository);
    getTransactionsUseCase = GetTransactionsUseCase(repository);
    createInitialWalletUseCase = CreateInitialWalletUseCase(repository);
    canAffordUseCase = CanAffordUseCase(repository);
  }

  Future<void> loadWallet(String userId) async {
    emit(WalletLoading());
    try {
      final wallet = await getWalletUseCase(userId);
      if (wallet != null) {
        emit(WalletLoaded(wallet));
      } else {
        await createInitialWalletUseCase(userId);
        final newWallet = await getWalletUseCase(userId);
        if (newWallet != null) {
          emit(WalletLoaded(newWallet));
        } else {
          emit(const WalletError('Failed to load wallet'));
        }
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> addCurrency({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type = TransactionType.earned,
  }) async {
    emit(WalletUpdating());
    try {
      final wallet = await addCurrencyUseCase(
        userId: userId,
        gems: gems,
        coins: coins,
        description: description,
        type: type,
      );
      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<bool> spendCurrency({
    required String userId,
    int gems = 0,
    int coins = 0,
    required String description,
    TransactionType type = TransactionType.spent,
  }) async {
    emit(WalletUpdating());
    try {
      final wallet = await spendCurrencyUseCase(
        userId: userId,
        gems: gems,
        coins: coins,
        description: description,
        type: type,
      );
      emit(WalletLoaded(wallet));
      return true;
    } catch (e) {
      emit(WalletError(e.toString()));
      return false;
    }
  }

  Future<void> loadTransactions(String userId) async {
    try {
      final transactions = await getTransactionsUseCase(userId);
      final wallet = await getWalletUseCase(userId);
      if (wallet != null) {
        emit(WalletTransactionLoaded(wallet, transactions));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<bool> canAfford({
    required String userId,
    int gems = 0,
    int coins = 0,
  }) async {
    return canAffordUseCase(userId: userId, gems: gems, coins: coins);
  }

  Future<void> createInitialWallet(String userId) async {
    try {
      await createInitialWalletUseCase(userId);
    } catch (e) {
      // Silently handle
    }
  }
}
