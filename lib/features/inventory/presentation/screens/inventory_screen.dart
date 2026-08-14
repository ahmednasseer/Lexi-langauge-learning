import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/inventory_cubit.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InventoryCubit>(),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  @override
  void initState() {
    super.initState();
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<InventoryCubit>().loadInventory(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Inventory',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InventoryError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }
          if (state is InventoryLoaded) {
            return _buildInventoryContent(context, state.items);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInventoryContent(
    BuildContext context,
    List<InventoryItem> items,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final groupedItems = <ItemType, List<InventoryItem>>{};
    for (final item in items) {
      groupedItems.putIfAbsent(item.itemType, () => []).add(item);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedItems.entries.map((entry) {
          return _buildCategorySection(context, entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎒', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase items from the store',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    ItemType type,
    List<InventoryItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCategoryName(type),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(context, items[index]);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, InventoryItem item) {
    return GestureDetector(
      onTap: () {
        if (item.isOwned && !item.isEquipped) {
          context.read<InventoryCubit>().equipItem(item.userId, item.itemId);
        } else if (item.isEquipped) {
          context.read<InventoryCubit>().unequipItem(item.userId, item.itemId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isEquipped ? AppColors.primary : AppColors.border,
            width: item.isEquipped ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.icon ?? '📦', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.isEquipped) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Equipped',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryName(ItemType type) {
    switch (type) {
      case ItemType.avatar:
        return 'Avatars';
      case ItemType.frame:
        return 'Frames';
      case ItemType.background:
        return 'Backgrounds';
      case ItemType.badge:
        return 'Badges';
      case ItemType.powerUp:
        return 'Power-ups';
      case ItemType.bundle:
        return 'Bundles';
    }
  }
}
