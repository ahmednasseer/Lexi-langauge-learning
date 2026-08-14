import '../../domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.id,
    required super.itemId,
    required super.userId,
    required super.itemType,
    required super.name,
    super.icon,
    super.isOwned,
    super.isEquipped,
    super.purchasedAt,
    super.equippedAt,
  });

  factory InventoryItemModel.fromEntity(InventoryItem item) {
    return InventoryItemModel(
      id: item.id,
      itemId: item.itemId,
      userId: item.userId,
      itemType: item.itemType,
      name: item.name,
      icon: item.icon,
      isOwned: item.isOwned,
      isEquipped: item.isEquipped,
      purchasedAt: item.purchasedAt,
      equippedAt: item.equippedAt,
    );
  }

  factory InventoryItemModel.fromJson(Map<String, dynamic> json, String id) {
    return InventoryItemModel(
      id: id,
      itemId: json['itemId'] ?? '',
      userId: json['userId'] ?? '',
      itemType: ItemType.values.firstWhere(
        (e) => e.name == json['itemType'],
        orElse: () => ItemType.avatar,
      ),
      name: json['name'] ?? '',
      icon: json['icon'],
      isOwned: json['isOwned'] ?? false,
      isEquipped: json['isEquipped'] ?? false,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'])
          : null,
      equippedAt: json['equippedAt'] != null
          ? DateTime.parse(json['equippedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'userId': userId,
      'itemType': itemType.name,
      'name': name,
      'icon': icon,
      'isOwned': isOwned,
      'isEquipped': isEquipped,
      'purchasedAt': purchasedAt?.toIso8601String(),
      'equippedAt': equippedAt?.toIso8601String(),
    };
  }
}
