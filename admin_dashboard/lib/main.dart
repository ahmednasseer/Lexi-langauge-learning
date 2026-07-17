import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/content_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/analytics_screen.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexi Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const AdminHomeScreen(),
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UsersScreen(),
    const ContentScreen(),
    const ReportsScreen(),
    const AnalyticsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Users',
    'Content',
    'Reports',
    'Analytics',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              border: Border(
                right: BorderSide(color: Colors.white12),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Color(0xFF6C63FF),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Lexi Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                // Navigation
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                      _buildNavItem(1, Icons.people, 'Users'),
                      _buildNavItem(2, Icons.library_books, 'Content'),
                      _buildNavItem(3, Icons.flag, 'Reports'),
                      _buildNavItem(4, Icons.analytics, 'Analytics'),
                    ],
                  ),
                ),
                // User info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        child: const Icon(Icons.admin_panel_settings, color: Color(0xFF6C63FF)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'admin@lexi.com',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A2E),
                    border: Border(
                      bottom: BorderSide(color: Colors.white12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _titles[_selectedIndex],
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Search
                      Container(
                        width: 300,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Notifications
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Screen content
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}
