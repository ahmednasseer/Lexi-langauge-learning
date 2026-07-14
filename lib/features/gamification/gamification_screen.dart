import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

import 'badges.dart';
import 'leaderboard.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _badges = BadgeRepository.getDefaultBadges();
  final _leaderboard = LeaderboardRepository().getLeaderboard();

  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rewards', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 16),
            TabBar(controller: _tabController, labelColor: AppColors.primary, unselectedLabelColor: Colors.grey, indicatorColor: AppColors.primary, tabs: const [Tab(text: 'Badges'), Tab(text: 'Leaderboard'), Tab(text: 'Streak')]),
          ])),
          Expanded(child: TabBarView(controller: _tabController, children: [
            _badgesTab(),
            _leaderboardTab(),
            _streakTab(),
          ])),
        ]),
      ),
    );
  }

  Widget _badgesTab() {
    return GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, crossAxisSpacing: 16, mainAxisSpacing: 16), itemCount: _badges.length, itemBuilder: (context, i) {
      final b = _badges[i];
      return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: b.isUnlocked ? Colors.white : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), boxShadow: b.isUnlocked ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10)] : null, border: b.isUnlocked ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2) : null), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(b.icon, style: TextStyle(fontSize: 40, color: b.isUnlocked ? null : Colors.grey.shade400)),
        const SizedBox(height: 12),
        Text(b.title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: b.isUnlocked ? Colors.black87 : Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(b.description, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500)),
        if (b.isUnlocked) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('Unlocked', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)))],
      ])).animate().fadeIn(delay: Duration(milliseconds: i * 100)).scale(begin: const Offset(0.8, 0.8));
    });
  }

  Widget _leaderboardTab() {
    return ListView.builder(padding: const EdgeInsets.all(20), itemCount: _leaderboard.length, itemBuilder: (context, i) {
      final u = _leaderboard[i];
      final isMe = u.isCurrentUser;
      return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isMe ? AppColors.primary.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: isMe ? Border.all(color: AppColors.primary, width: 2) : null, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]), child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: u.rank <= 3 ? const Color(0xFFFFD700) : Colors.grey.shade200, shape: BoxShape.circle), child: Center(child: Text(u.rank <= 3 ? '🏆' : '${u.rank}', style: GoogleFonts.poppins(fontSize: u.rank <= 3 ? 16 : 12, fontWeight: FontWeight.bold, color: u.rank <= 3 ? Colors.white : Colors.grey.shade600)))),
        const SizedBox(width: 16),
        Text(u.avatar, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(u.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: isMe ? FontWeight.bold : FontWeight.w500)), Text('${u.xp} XP', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary))])),
        if (u.rank <= 3) Text(u.rank == 1 ? '🥇' : u.rank == 2 ? '🥈' : '🥉', style: const TextStyle(fontSize: 24)),
      ])).animate().fadeIn(delay: Duration(milliseconds: i * 100)).slideX(begin: 0.1);
    });
  }

  Widget _streakTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(32), decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.warning.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(children: [
        const Text('🔥', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text('12', style: GoogleFonts.poppins(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)).animate().scale(begin: const Offset(0.5, 0.5)),
        Text('Day Streak', style: GoogleFonts.poppins(fontSize: 20, color: Colors.white.withValues(alpha: 0.9))),
        const SizedBox(height: 16),
        Text('Keep it up! You\'re on fire!', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withValues(alpha: 0.8))),
      ])).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('This Week', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
          final active = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].contains(d);
          return Column(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(gradient: active ? AppColors.orangeGradient : null, color: active ? null : Colors.grey.shade100, shape: BoxShape.circle), child: Center(child: active ? const Icon(Icons.check, color: Colors.white, size: 20) : Text(d[0], style: GoogleFonts.poppins(color: Colors.grey.shade500)))),
            const SizedBox(height: 8),
            Text(d, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
          ]);
        }).toList()),
      ])).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
    ]));
  }
}
