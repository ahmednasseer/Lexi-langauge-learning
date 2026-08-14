import 'package:lexi/core/services/api_service.dart';
import '../../domain/entities/store_item.dart';
import '../../domain/repositories/store_repository.dart';

/// API-backed implementation. The store catalog is read from NestJS
/// (PostgreSQL). Catalog mutation (add/update/delete) is admin-only and not
/// exposed to the client.
class StoreRepositoryImpl implements StoreRepository {
  final ApiService _api;

  StoreRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  String _backendCategory(StoreItemCategory category) {
    switch (category) {
      case StoreItemCategory.avatarFrame:
        return 'frame';
      case StoreItemCategory.background:
        return 'background';
      case StoreItemCategory.badge:
        return 'badge';
      case StoreItemCategory.powerUp:
        return 'powerUp';
      case StoreItemCategory.bundle:
        return 'bundle';
      case StoreItemCategory.premium:
        return 'premium';
    }
  }

  StoreItem _fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'] as String? ?? '';
    final category = _categoryFrom(categoryRaw);
    return StoreItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      itemType: categoryRaw,
      image: json['imageUrl'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      currency: 'gems',
      category: category,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? (json['metadata'] as Map).cast<String, dynamic>()
          : null,
    );
  }

  StoreItemCategory _categoryFrom(String raw) {
    switch (raw) {
      case 'frame':
        return StoreItemCategory.avatarFrame;
      case 'background':
        return StoreItemCategory.background;
      case 'badge':
        return StoreItemCategory.badge;
      case 'powerUp':
      case 'gems':
        return StoreItemCategory.powerUp;
      case 'bundle':
        return StoreItemCategory.bundle;
      case 'premium':
      case 'avatar':
        return StoreItemCategory.premium;
      default:
        return StoreItemCategory.avatarFrame;
    }
  }

  @override
  Future<List<StoreItem>> getAllItems() async {
    final result = await _api.getStoreItems();
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load store items');
    }
    return result.data!
        .map<StoreItem>(
          (raw) => _fromJson((raw as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  @override
  Future<List<StoreItem>> getItemsByCategory(StoreItemCategory category) async {
    final result = await _api.getStoreItems(
      category: _backendCategory(category),
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load store items');
    }
    return result.data!
        .map<StoreItem>(
          (raw) => _fromJson((raw as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  @override
  Future<StoreItem?> getItem(String itemId) async {
    try {
      final items = await getAllItems();
      for (final item in items) {
        if (item.id == itemId) return item;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addItem(StoreItem item) {
    throw UnsupportedError('Adding store items is an admin-only operation.');
  }

  @override
  Future<void> updateItem(StoreItem item) {
    throw UnsupportedError('Updating store items is an admin-only operation.');
  }

  @override
  Future<void> deleteItem(String itemId) {
    throw UnsupportedError('Deleting store items is an admin-only operation.');
  }
}