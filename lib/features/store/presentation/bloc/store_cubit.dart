import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/store_item.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/services/purchase_service.dart';
import '../../domain/usecases/store_usecases.dart';

// States
abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreItem> items;
  final StoreItemCategory? selectedCategory;

  const StoreLoaded({required this.items, this.selectedCategory});

  @override
  List<Object?> get props => [items, selectedCategory];
}

class StorePurchasing extends StoreState {}

class StorePurchaseSuccess extends StoreState {
  final StoreItem item;
  final int remainingGems;

  const StorePurchaseSuccess(this.item, this.remainingGems);

  @override
  List<Object?> get props => [item, remainingGems];
}

class StorePurchaseError extends StoreState {
  final String message;

  const StorePurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class StoreCubit extends Cubit<StoreState> {
  final StoreRepository storeRepository;
  final PurchaseService purchaseService;

  late final GetAllItemsUseCase getAllItemsUseCase;
  late final GetItemsByCategoryUseCase getItemsByCategoryUseCase;
  late final GetItemUseCase getItemUseCase;

  StoreCubit({required this.storeRepository, PurchaseService? purchaseService})
    : purchaseService = purchaseService ?? PurchaseService(),
      super(StoreInitial()) {
    getAllItemsUseCase = GetAllItemsUseCase(storeRepository);
    getItemsByCategoryUseCase = GetItemsByCategoryUseCase(storeRepository);
    getItemUseCase = GetItemUseCase(storeRepository);
  }

  Future<void> loadItems() async {
    emit(StoreLoading());
    try {
      final items = await getAllItemsUseCase();
      emit(StoreLoaded(items: items));
    } catch (e) {
      emit(StorePurchaseError(e.toString()));
    }
  }

  Future<void> loadItemsByCategory(StoreItemCategory category) async {
    emit(StoreLoading());
    try {
      final items = await getItemsByCategoryUseCase(category);
      emit(StoreLoaded(items: items, selectedCategory: category));
    } catch (e) {
      emit(StorePurchaseError(e.toString()));
    }
  }

  Future<void> purchaseItem({
    required String userId,
    required StoreItem item,
  }) async {
    emit(StorePurchasing());
    try {
      final result = await purchaseService.purchaseItem(
        userId: userId,
        item: item,
      );

      if (result.success) {
        emit(StorePurchaseSuccess(item, result.remainingGems));
        await loadItems();
      } else {
        emit(StorePurchaseError(result.errorMessage ?? 'Purchase failed'));
      }
    } catch (e) {
      emit(StorePurchaseError(e.toString()));
    }
  }

  Future<bool> isItemOwned(String userId, String itemId) async {
    try {
      final item = await purchaseService.isItemOwned(userId, itemId);
      return item;
    } catch (e) {
      return false;
    }
  }
}
