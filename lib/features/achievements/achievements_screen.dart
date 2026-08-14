import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'models/achievement_badge.dart';
import 'widgets/badge_card.dart';
import 'achievements_repository.dart';
import '../../shared/widgets/state_widgets.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<AchievementBadge> _badges = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    try {
      final repo = AchievementsRepository();
      _badges = await repo.getAchievements();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<AchievementBadge> get _filteredBadges {
    if (_selectedCategory == 'all') return _badges;
    return _badges.where((b) => b.category == _selectedCategory).toList();
  }

  int get _unlockedCount => _badges.where((b) => b.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadBadges,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading achievements...')
          : _badges.isEmpty
          ? const EmptyState(
              icon: Icons.emoji_events,
              title: 'No achievements yet',
              subtitle: 'Start learning to earn achievements!',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredBadges.length,
              itemBuilder: (context, index) {
                final badge = _filteredBadges[index];
                return BadgeCard(badge: badge);
              },
            ),
    );
  }
}
