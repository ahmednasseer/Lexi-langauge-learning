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
    final repo = AchievementsRepository();
    _badges = await repo.getAchievements();
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // Category filter
                  _buildCategoryFilter(),

                  const SizedBox(height: 24),

                  // Badges grid
                  _buildBadgesGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.pink.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Achievement Badges',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_unlockedCount/${_badges.length} badges unlocked',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _badges.isNotEmpty ? _unlockedCount / _badges.length : 0,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'key': 'all', 'label': 'All', 'icon': Icons.grid_view},
      {'key': 'learning', 'label': 'Learning', 'icon': Icons.school},
      {'key': 'vocabulary', 'label': 'Vocabulary', 'icon': Icons.book},
      {'key': 'streak', 'label': 'Streak', 'icon': Icons.local_fire_department},
      {'key': 'speaking', 'label': 'Speaking', 'icon': Icons.mic},
      {'key': 'xp', 'label': 'XP', 'icon': Icons.star},
      {'key': 'level', 'label': 'Level', 'icon': Icons.emoji_events},
      {'key': 'special', 'label': 'Special', 'icon': Icons.auto_awesome},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['key'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.purple : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey,
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

  Widget _buildBadgesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredBadges.length,
      itemBuilder: (context, index) {
        return BadgeCard(badge: _filteredBadges[index]);
      },
    );
  }
}
