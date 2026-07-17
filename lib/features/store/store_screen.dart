import 'package:flutter/material.dart';
import 'models/store_item.dart';
import 'widgets/store_item_card.dart';
import 'store_repository.dart';
import '../../features/wallet/wallet_repository.dart';
import '../../shared/widgets/state_widgets.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  StoreCategory _selectedCategory = StoreCategory.gems;
  int _userGems = 500;
  List<StoreItem> _items = [];
  Set<String> _owned = {};
  bool _isLoading = true;
  bool _error = false;

  final StoreRepository _storeRepo = StoreRepository();
  final WalletRepository _walletRepo = WalletRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = false;
    });
    try {
      final wallet = await _walletRepo.getWallet();
      final inventory = await _storeRepo.getInventory();
      final items = await _storeRepo.getItems(category: _selectedCategory);
      if (mounted) {
        setState(() {
          _userGems = wallet.gems;
          _owned = inventory.toSet();
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _loadItems() async {
    setState(() => _error = false);
    try {
      final items = await _storeRepo.getItems(category: _selectedCategory);
      if (mounted) setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1E36),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Store',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade400,
                  Colors.pink.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$_userGems',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          _buildCategorySelector(),

          // Items grid
          Expanded(
            child: RefreshIndicator(
              color: Colors.purple,
              onRefresh: () async {
                await _loadData();
              },
              child: _error
                  ? ErrorState(
                      message: 'Failed to load store items. Please try again.',
                      onRetry: _loadData,
                    )
                  : _isLoading
                      ? const LoadingState(message: 'Loading store...')
                      : _buildItemsGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'key': StoreCategory.gems, 'label': 'Gems', 'icon': Icons.diamond},
      {'key': StoreCategory.avatar, 'label': 'Avatars', 'icon': Icons.person},
      {'key': StoreCategory.frame, 'label': 'Frames', 'icon': Icons.crop_square},
      {'key': StoreCategory.background, 'label': 'Backgrounds', 'icon': Icons.wallpaper},
      {'key': StoreCategory.bundle, 'label': 'Bundles', 'icon': Icons.inventory_2},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['key'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat['key'] as StoreCategory);
              _loadItems();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : const Color(0xFF1A1E36),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.white24,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid() {
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.store_outlined,
        title: 'No items in this category',
        subtitle: 'Try selecting a different category.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return StoreItemCard(
          item: _items[index],
          userGems: _userGems,
          isOwned: _owned.contains(_items[index].id),
          onPurchase: (item) => _purchaseItem(item),
        );
      },
    );
  }

  Future<void> _purchaseItem(StoreItem item) async {
    if (_owned.contains(item.id)) {
      final equipped = await _storeRepo.equip(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(equipped ? 'Equipped ${item.name}!' : 'Already owned'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }
    if (_userGems >= item.price) {
      final success = await _storeRepo.purchase(item.id);
      if (success) {
        setState(() {
          _userGems -= item.price;
          _owned.add(item.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchased ${item.name}!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        _showError('Purchase failed. Try again.');
      }
    } else {
      _showError('Not enough gems!');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
