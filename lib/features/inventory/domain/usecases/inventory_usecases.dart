import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryUseCase {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  Future<List<InventoryItem>> call(String userId) async {
    return repository.getInventory(userId);
  }
}

class AddItemUseCase {
  final InventoryRepository repository;

  AddItemUseCase(this.repository);

  Future<InventoryItem> call(InventoryItem item) async {
    return repository.addItem(item);
  }
}

class RemoveItemUseCase {
  final InventoryRepository repository;

  RemoveItemUseCase(this.repository);

  Future<void> call(String userId, String itemId) async {
    return repository.removeItem(userId, itemId);
  }
}

class EquipItemUseCase {
  final InventoryRepository repository;

  EquipItemUseCase(this.repository);

  Future<InventoryItem> call(String userId, String itemId) async {
    return repository.equipItem(userId, itemId);
  }
}

class UnequipItemUseCase {
  final InventoryRepository repository;

  UnequipItemUseCase(this.repository);

  Future<InventoryItem> call(String userId, String itemId) async {
    return repository.unequipItem(userId, itemId);
  }
}

class GetEquippedItemsUseCase {
  final InventoryRepository repository;

  GetEquippedItemsUseCase(this.repository);

  Future<List<InventoryItem>> call(String userId) async {
    return repository.getEquippedItems(userId);
  }
}

class InitializeInventoryUseCase {
  final InventoryRepository repository;

  InitializeInventoryUseCase(this.repository);

  Future<void> call(String userId) async {
    return repository.initializeInventory(userId);
  }
}
