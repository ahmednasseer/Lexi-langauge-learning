import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../community_controller.dart';
import 'group_card.dart';

class GroupsTab extends StatelessWidget {
  final CommunityController controller;

  const GroupsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Groups
          const Text(
            'My Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildMyGroups(),

          const SizedBox(height: 24),

          // Discover Groups
          const Text(
            'Discover Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...controller.groups.where((g) => !g.isJoined).map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GroupCard(
                group: group,
                onJoin: () => controller.toggleGroupJoin(group.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMyGroups() {
    final myGroups = controller.groups.where((g) => g.isJoined).toList();

    if (myGroups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.group_add, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No groups joined yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join a group to connect with other learners!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: myGroups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GroupCard(
            group: group,
            onJoin: () => controller.toggleGroupJoin(group.id),
          ),
        );
      }).toList(),
    );
  }
}
