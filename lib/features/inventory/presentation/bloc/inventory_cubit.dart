import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/inventory_usecases.dart';

// States
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;

  const InventoryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class InventoryItemEquipped extends InventoryState {
  final InventoryItem item;

  const InventoryItemEquipped(this.item);

  @override
  List<Object?> get props => [item];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository repository;
  late final GetInventoryUseCase getInventoryUseCase;
  late final AddItemUseCase addItemUseCase;
  late final RemoveItemUseCase removeItemUseCase;
  late final EquipItemUseCase equipItemUseCase;
  late final UnequipItemUseCase unequipItemUseCase;
  late final GetEquippedItemsUseCase getEquippedItemsUseCase;
  late final InitializeInventoryUseCase initializeInventoryUseCase;

  InventoryCubit(this.repository) : super(InventoryInitial()) {
    getInventoryUseCase = GetInventoryUseCase(repository);
    addItemUseCase = AddItemUseCase(repository);
    removeItemUseCase = RemoveItemUseCase(repository);
    equipItemUseCase = EquipItemUseCase(repository);
    unequipItemUseCase = UnequipItemUseCase(repository);
    getEquippedItemsUseCase = GetEquippedItemsUseCase(repository);
    initializeInventoryUseCase = InitializeInventoryUseCase(repository);
  }

  Future<void> loadInventory(String userId) async {
    emit(InventoryLoading());
    try {
      final items = await getInventoryUseCase(userId);
      if (items.isEmpty) {
        await initializeInventoryUseCase(userId);
        final newItems = await getInventoryUseCase(userId);
        emit(InventoryLoaded(newItems));
      } else {
        emit(InventoryLoaded(items));
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      await addItemUseCase(item);
      await loadInventory(item.userId);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> removeItem(String userId, String itemId) async {
    try {
      await removeItemUseCase(userId, itemId);
      await loadInventory(userId);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> equipItem(String userId, String itemId) async {
    try {
      final item = await equipItemUseCase(userId, itemId);
      emit(InventoryItemEquipped(item));
      await loadInventory(userId);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> unequipItem(String userId, String itemId) async {
    try {
      final item = await unequipItemUseCase(userId, itemId);
      emit(InventoryItemEquipped(item));
      await loadInventory(userId);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<List<InventoryItem>> getEquippedItems(String userId) async {
    return getEquippedItemsUseCase(userId);
  }

  Future<void> initializeInventory(String userId) async {
    try {
      await initializeInventoryUseCase(userId);
    } catch (e) {
      // Silently handle
    }
  }
}
