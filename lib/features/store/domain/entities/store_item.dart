import 'package:equatable/equatable.dart';

enum StoreItemCategory {
  avatarFrame,
  background,
  badge,
  powerUp,
  bundle,
  premium,
}

class StoreItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String itemType;
  final String image;
  final int price;
  final String currency;
  final StoreItemCategory category;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.itemType,
    this.image = '',
    required this.price,
    this.currency = 'gems',
    required this.category,
    this.isActive = true,
    required this.createdAt,
    this.metadata,
  });

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    String? itemType,
    String? image,
    int? price,
    String? currency,
    StoreItemCategory? category,
    bool? isActive,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      image: image ?? this.image,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    itemType,
    image,
    price,
    currency,
    category,
    isActive,
    createdAt,
    metadata,
  ];
}
