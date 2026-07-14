import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'English';
  int _dailyGoal = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _section('Appearance', [
          _switchTile(Icons.dark_mode, 'Dark Mode', _darkMode, (v) => setState(() => _darkMode = v)),
        ]),
        const SizedBox(height: 16),
        _section('Learning', [
          _dropdownTile(Icons.language, 'Learning Language', _language, ['English', 'Arabic', 'French', 'Spanish', 'German'], (v) => setState(() => _language = v!)),
          _sliderTile(Icons.track_changes, 'Daily Goal', _dailyGoal, (v) => setState(() => _dailyGoal = v.toInt())),
        ]),
        const SizedBox(height: 16),
        _section('Notifications', [
          _switchTile(Icons.notifications, 'Push Notifications', _notifications, (v) => setState(() => _notifications = v)),
          _switchTile(Icons.schedule, 'Study Reminders', true, (v) {}),
        ]),
        const SizedBox(height: 16),
        _section('Account', [
          _navTile(Icons.person, 'Edit Profile', () {}),
          _navTile(Icons.lock, 'Change Password', () {}),
          _navTile(Icons.delete, 'Delete Account', () {}, color: AppColors.error),
        ]),
        const SizedBox(height: 16),
        _section('Support', [
          _navTile(Icons.help, 'Help Center', () {}),
          _navTile(Icons.email, 'Contact Us', () {}),
          _navTile(Icons.description, 'Terms of Service', () {}),
          _navTile(Icons.privacy_tip, 'Privacy Policy', () {}),
        ]),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))),
      ...children,
    ]));
  }

  Widget _switchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title, style: GoogleFonts.poppins(fontSize: 14)), trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary));
  }

  Widget _dropdownTile(IconData icon, String title, String value, List<String> items, ValueChanged<String?> onChanged) {
    return ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title, style: GoogleFonts.poppins(fontSize: 14)), trailing: DropdownButton<String>(value: value, underline: const SizedBox(), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged));
  }

  Widget _sliderTile(IconData icon, String title, int value, ValueChanged<double> onChanged) {
    return ListTile(leading: Icon(icon, color: AppColors.primary), title: Text('$title: $value XP', style: GoogleFonts.poppins(fontSize: 14)), trailing: SizedBox(width: 150, child: Slider(value: value.toDouble(), min: 10, max: 200, activeColor: AppColors.primary, onChanged: onChanged)));
  }

  Widget _navTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(leading: Icon(icon, color: color ?? AppColors.primary), title: Text(title, style: GoogleFonts.poppins(fontSize: 14, color: color)), trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color ?? Colors.grey), onTap: onTap);
  }
}
