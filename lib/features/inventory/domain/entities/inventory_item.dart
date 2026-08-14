import 'package:equatable/equatable.dart';

enum ItemType { avatar, frame, background, badge, powerUp, bundle }

class InventoryItem extends Equatable {
  final String id;
  final String itemId;
  final String userId;
  final ItemType itemType;
  final String name;
  final String? icon;
  final bool isOwned;
  final bool isEquipped;
  final DateTime? purchasedAt;
  final DateTime? equippedAt;

  const InventoryItem({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.itemType,
    required this.name,
    this.icon,
    this.isOwned = false,
    this.isEquipped = false,
    this.purchasedAt,
    this.equippedAt,
  });

  InventoryItem copyWith({
    String? id,
    String? itemId,
    String? userId,
    ItemType? itemType,
    String? name,
    String? icon,
    bool? isOwned,
    bool? isEquipped,
    DateTime? purchasedAt,
    DateTime? equippedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      equippedAt: equippedAt ?? this.equippedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    itemId,
    userId,
    itemType,
    name,
    icon,
    isOwned,
    isEquipped,
    purchasedAt,
    equippedAt,
  ];
}
