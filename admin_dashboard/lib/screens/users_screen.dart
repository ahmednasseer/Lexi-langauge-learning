import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  String _filterType = 'All';
  int _currentPage = 1;

  final List<Map<String, dynamic>> _users = [
    {'id': '1', 'name': 'Ahmed Hassan', 'email': 'ahmed@email.com', 'level': 'B1', 'xp': 12500, 'premium': true, 'status': 'active', 'joined': '2024-01-15'},
    {'id': '2', 'name': 'Sarah Johnson', 'email': 'sarah@email.com', 'level': 'A2', 'xp': 5200, 'premium': false, 'status': 'active', 'joined': '2024-02-20'},
    {'id': '3', 'name': 'John Smith', 'email': 'john@email.com', 'level': 'C1', 'xp': 28000, 'premium': true, 'status': 'active', 'joined': '2024-01-05'},
    {'id': '4', 'name': 'Maria Garcia', 'email': 'maria@email.com', 'level': 'A1', 'xp': 1800, 'premium': false, 'status': 'active', 'joined': '2024-03-10'},
    {'id': '5', 'name': 'David Wilson', 'email': 'david@email.com', 'level': 'B2', 'xp': 8900, 'premium': false, 'status': 'inactive', 'joined': '2024-02-01'},
    {'id': '6', 'name': 'Emma Brown', 'email': 'emma@email.com', 'level': 'A2', 'xp': 3400, 'premium': true, 'status': 'active', 'joined': '2024-02-15'},
    {'id': '7', 'name': 'Mohammed Ali', 'email': 'mohammed@email.com', 'level': 'B1', 'xp': 6700, 'premium': false, 'status': 'active', 'joined': '2024-01-25'},
    {'id': '8', 'name': 'Lisa Chen', 'email': 'lisa@email.com', 'level': 'C1', 'xp': 32000, 'premium': true, 'status': 'active', 'joined': '2024-01-10'},
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterType == 'All' ||
          (_filterType == 'Premium' && user['premium']) ||
          (_filterType == 'Free' && !user['premium']) ||
          (_filterType == 'Active' && user['status'] == 'active') ||
          (_filterType == 'Inactive' && user['status'] == 'inactive');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  // Search
                  Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5), size: 20),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButton<String>(
                      value: _filterType,
                      items: ['All', 'Premium', 'Free', 'Active', 'Inactive']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) => setState(() => _filterType = value!),
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Export
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Users table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('User', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Level', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('XP', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Status', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Joined', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                      SizedBox(width: 100, child: Text('Actions', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                // Table body
                ..._filteredUsers.map((user) => _buildUserRow(user)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                icon: const Icon(Icons.chevron_left, color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page $_currentPage',
                  style: const TextStyle(color: Color(0xFF6C63FF)),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _currentPage++),
                icon: const Icon(Icons.chevron_right, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                  child: Text(
                    user['name'][0],
                    style: const TextStyle(color: Color(0xFF6C63FF)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['name'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (user['premium']) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      user['email'],
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getLevelColor(user['level']).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['level'],
                style: TextStyle(
                  color: _getLevelColor(user['level']),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${user['xp']}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user['status'] == 'active'
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['status'],
                style: TextStyle(
                  color: user['status'] == 'active' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Text(
              user['joined'],
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showEditDialog(user),
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _showBanDialog(user),
                  icon: const Icon(Icons.block, size: 18, color: Colors.red),
                  tooltip: 'Ban',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFF4CAF50);
      case 'A2':
        return const Color(0xFF8BC34A);
      case 'B1':
        return const Color(0xFFFFC107);
      case 'B2':
        return const Color(0xFFFF9800);
      case 'C1':
        return const Color(0xFFFF5722);
      case 'C2':
        return const Color(0xFFF44336);
      default:
        return Colors.white54;
    }
  }

  void _showEditDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Edit User',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: user['name'],
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Premium: ', style: TextStyle(color: Colors.white70)),
                Switch(
                  value: user['premium'],
                  onChanged: (value) {},
                  activeThumbColor: const Color(0xFF6C63FF),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Ban User', style: TextStyle(color: Colors.red)),
        content: Text(
          'Are you sure you want to ban ${user['name']}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
  }
}
