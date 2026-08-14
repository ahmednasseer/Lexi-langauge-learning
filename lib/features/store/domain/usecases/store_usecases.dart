import '../entities/store_item.dart';
import '../repositories/store_repository.dart';

class GetAllItemsUseCase {
  final StoreRepository repository;

  GetAllItemsUseCase(this.repository);

  Future<List<StoreItem>> call() async {
    return repository.getAllItems();
  }
}

class GetItemsByCategoryUseCase {
  final StoreRepository repository;

  GetItemsByCategoryUseCase(this.repository);

  Future<List<StoreItem>> call(StoreItemCategory category) async {
    return repository.getItemsByCategory(category);
  }
}

class GetItemUseCase {
  final StoreRepository repository;

  GetItemUseCase(this.repository);

  Future<StoreItem?> call(String itemId) async {
    return repository.getItem(itemId);
  }
}

class AddItemUseCase {
  final StoreRepository repository;

  AddItemUseCase(this.repository);

  Future<void> call(StoreItem item) async {
    return repository.addItem(item);
  }
}

class UpdateItemUseCase {
  final StoreRepository repository;

  UpdateItemUseCase(this.repository);

  Future<void> call(StoreItem item) async {
    return repository.updateItem(item);
  }
}

class DeleteItemUseCase {
  final StoreRepository repository;

  DeleteItemUseCase(this.repository);

  Future<void> call(String itemId) async {
    return repository.deleteItem(itemId);
  }
}
