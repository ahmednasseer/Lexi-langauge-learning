import '../../domain/entities/store_item.dart';

class StoreItemModel extends StoreItem {
  const StoreItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.itemType,
    super.image,
    required super.price,
    super.currency,
    required super.category,
    super.isActive,
    required super.createdAt,
    super.metadata,
  });

  factory StoreItemModel.fromEntity(StoreItem item) {
    return StoreItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      itemType: item.itemType,
      image: item.image,
      price: item.price,
      currency: item.currency,
      category: item.category,
      isActive: item.isActive,
      createdAt: item.createdAt,
      metadata: item.metadata,
    );
  }

  factory StoreItemModel.fromJson(Map<String, dynamic> json, String id) {
    return StoreItemModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      itemType: json['type'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'gems',
      category: StoreItemCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => StoreItemCategory.avatarFrame,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': itemType,
      'image': image,
      'price': price,
      'currency': currency,
      'category': category.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
