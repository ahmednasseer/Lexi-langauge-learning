import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Guest';
    final userEmail = user?.email ?? 'Not signed in';
    final userXp = user?.xp ?? 0;
    final userLevel = user?.level ?? 'A1';
    final streak = user?.streak ?? 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Profile', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)).animate().fadeIn().slideX(begin: -0.1),
              const Spacer(),
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: AppColors.error),
              ),
            ]),
            const SizedBox(height: 24),
            _profileCard(userName, userEmail, userLevel, userXp),
            const SizedBox(height: 24),
            _statsGrid(userXp, streak),
            const SizedBox(height: 24),
            _progressSection(),
            const SizedBox(height: 24),
            _settingsSection(),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(String name, String email, String level, int xp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
          ),
          child: const Center(child: Text('🇩🇪', style: TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 16),
        Text(name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(email, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⭐', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('Level $level • ${xp} XP', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
      ]),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _statsGrid(int xp, int streak) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _stat('⭐', '$xp', 'Total XP', AppColors.goldGradient),
        _stat('🔥', '$streak', 'Day Streak', AppColors.orangeGradient),
        _stat('📚', '24', 'Lessons', AppColors.blueGradient),
        _stat('🏆', '0', 'Badges', AppColors.purpleGradient),
      ],
    );
  }

  Widget _stat(String icon, String val, String label, LinearGradient g) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(val, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
      ]),
    );
  }

  Widget _progressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('German Progress', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _progItem('A1 Beginner', 0.0, AppColors.success),
        const SizedBox(height: 12),
        _progItem('A2 Elementary', 0.0, AppColors.info),
        const SizedBox(height: 12),
        _progItem('B1 Intermediate', 0.0, AppColors.primary),
        const SizedBox(height: 12),
        _progItem('B2 Upper Int.', 0.0, AppColors.warning),
        const SizedBox(height: 12),
        _progItem('C1 Advanced', 0.0, AppColors.secondary),
        const SizedBox(height: 12),
        _progItem('C2 Mastery', 0.0, AppColors.error),
      ]),
    );
  }

  Widget _progItem(String label, double val, Color c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        Text('${(val * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 12, color: c, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: val, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation(c), borderRadius: BorderRadius.circular(4)),
    ]);
  }

  Widget _settingsSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(children: [
        _setting(Icons.dark_mode, 'Dark Mode', Switch(value: _darkMode, onChanged: (v) => setState(() => _darkMode = v), activeThumbColor: AppColors.primary)),
        _setting(Icons.language, 'Learning Language', Text('🇩🇪 German', style: GoogleFonts.poppins(fontSize: 14))),
        _setting(Icons.notifications, 'Notifications', Switch(value: true, onChanged: (v) {}, activeThumbColor: AppColors.primary)),
        _setting(Icons.help, 'Help & Support', const Icon(Icons.arrow_forward_ios, size: 16)),
        _setting(Icons.info, 'About', const Icon(Icons.arrow_forward_ios, size: 16), showDivider: false),
      ]),
    );
  }

  Widget _setting(IconData icon, String title, Widget trailing, {bool showDivider = true}) {
    return Column(children: [
      ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing,
      ),
      if (showDivider) Divider(height: 1, color: Colors.grey.shade100),
    ]);
  }
}
