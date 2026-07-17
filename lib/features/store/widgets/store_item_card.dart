import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/store_item.dart';

class StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final int userGems;
  final bool isOwned;
  final Function(StoreItem) onPurchase;

  const StoreItemCard({
    super.key,
    required this.item,
    required this.userGems,
    this.isOwned = false,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = userGems >= item.price;
    final isFree = item.price == 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isPremium ? Colors.amber.shade400 : AppColors.border,
          width: item.isPremium ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Item preview
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(),
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Center(
                child: _buildItemPreview(),
              ),
            ),
          ),

          // Item info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Badges
                  Row(
                    children: [
                      if (item.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      if (item.isLimited) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIMITED',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const Spacer(),

                  // Price and buy button
                  Row(
                    children: [
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFree ? Colors.green.shade100 : Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isFree ? 'FREE' : '💎 ${item.price}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isFree ? Colors.green : Colors.purple,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Buy button
                      if (!isFree)
                        GestureDetector(
                          onTap: canAfford || isOwned ? () => onPurchase(item) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOwned
                                  ? Colors.blue
                                  : canAfford
                                      ? Colors.purple
                                      : AppColors.border,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOwned
                                  ? 'Equip'
                                  : canAfford
                                      ? 'Buy'
                                      : 'Need ${item.price - userGems}💎',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: (canAfford || isOwned) ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (item.category) {
      case StoreCategory.avatar:
        return [Colors.blue.shade200, Colors.blue.shade400];
      case StoreCategory.frame:
        return [Colors.amber.shade200, Colors.amber.shade400];
      case StoreCategory.background:
        return [Colors.purple.shade200, Colors.purple.shade400];
      case StoreCategory.gems:
        return [Colors.pink.shade200, Colors.pink.shade400];
      case StoreCategory.bundle:
        return [Colors.green.shade200, Colors.green.shade400];
    }
  }

  Widget _buildItemPreview() {
    switch (item.category) {
      case StoreCategory.avatar:
        return const Icon(Icons.person, size: 50, color: Colors.white);
      case StoreCategory.frame:
        return const Icon(Icons.crop_square, size: 50, color: Colors.white);
      case StoreCategory.background:
        return const Icon(Icons.wallpaper, size: 50, color: Colors.white);
      case StoreCategory.gems:
        return const Text('💎', style: TextStyle(fontSize: 40));
      case StoreCategory.bundle:
        return const Icon(Icons.inventory_2, size: 50, color: Colors.white);
    }
  }
}
