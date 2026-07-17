import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              _buildStatCard('Total Users', '1,250', Icons.people, const Color(0xFF6C63FF)),
              const SizedBox(width: 16),
              _buildStatCard('Active Today', '430', Icons.person_add, const Color(0xFF00BCD4)),
              const SizedBox(width: 16),
              _buildStatCard('Premium Users', '45', Icons.workspace_premium, const Color(0xFFFFD700)),
              const SizedBox(width: 16),
              _buildStatCard('Revenue', '\$4,500', Icons.attach_money, const Color(0xFF4CAF50)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Lessons Completed', '3,200', Icons.school, const Color(0xFFFF6B9D)),
              const SizedBox(width: 16),
              _buildStatCard('AI Conversations', '900', Icons.smart_toy, const Color(0xFF9C27B0)),
              const SizedBox(width: 16),
              _buildStatCard('Words Learned', '15,000', Icons.book, const Color(0xFFE91E63)),
              const SizedBox(width: 16),
              _buildStatCard('Avg. Session', '12m', Icons.timer, const Color(0xFF009688)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent users
              Expanded(
                flex: 2,
                child: _buildRecentUsers(),
              ),
              const SizedBox(width: 24),
              // Activity chart
              Expanded(
                flex: 3,
                child: _buildActivityChart(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top languages
              Expanded(
                child: _buildTopLanguages(),
              ),
              const SizedBox(width: 24),
              // Pending reports
              Expanded(
                child: _buildPendingReports(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: color.withValues(alpha: 0.5), size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    final users = [
      {'name': 'Ahmed', 'email': 'ahmed@email.com', 'date': '2 min ago', 'premium': true},
      {'name': 'Sarah', 'email': 'sarah@email.com', 'date': '15 min ago', 'premium': false},
      {'name': 'John', 'email': 'john@email.com', 'date': '1 hour ago', 'premium': true},
      {'name': 'Maria', 'email': 'maria@email.com', 'date': '2 hours ago', 'premium': false},
      {'name': 'David', 'email': 'david@email.com', 'date': '3 hours ago', 'premium': false},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Users',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...users.map((user) => _buildUserTile(user)),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
            child: Text(
              (user['name'] as String)[0],
              style: const TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
          ),
          Text(
            user['date'],
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity (Last 7 Days)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              DropdownButton<String>(
                value: 'This Week',
                items: ['This Week', 'Last Week', 'This Month']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {},
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Mon', 0.6, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildChartBar('Tue', 0.8, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildChartBar('Wed', 0.45, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildChartBar('Thu', 0.9, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildChartBar('Fri', 0.7, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildChartBar('Sat', 0.5, const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _buildChartBar('Sun', 0.35, const Color(0xFF6C63FF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double height, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 180 * height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLanguages() {
    final languages = [
      {'name': 'German', 'flag': '🇩🇪', 'users': 450, 'percent': 36},
      {'name': 'French', 'flag': '🇫🇷', 'users': 280, 'percent': 22},
      {'name': 'Spanish', 'flag': '🇪🇸', 'users': 220, 'percent': 18},
      {'name': 'Italian', 'flag': '🇮🇹', 'users': 150, 'percent': 12},
      {'name': 'Japanese', 'flag': '🇯🇵', 'users': 150, 'percent': 12},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Languages',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...languages.map((lang) => _buildLanguageBar(lang)),
        ],
      ),
    );
  }

  Widget _buildLanguageBar(Map<String, dynamic> lang) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(lang['flag'], style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                lang['name'],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${lang['users']} users',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: lang['percent'] / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingReports() {
    final reports = [
      {'user': 'SpamBot123', 'reason': 'Spam', 'time': '1h ago', 'status': 'pending'},
      {'user': 'TrollUser', 'reason': 'Harassment', 'time': '3h ago', 'status': 'pending'},
      {'user': 'BadActor', 'reason': 'Inappropriate', 'time': '5h ago', 'status': 'pending'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Reports',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${reports.length} pending',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reports.map((report) => _buildReportTile(report)),
        ],
      ),
    );
  }

  Widget _buildReportTile(Map<String, dynamic> report) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['user'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  report['reason'],
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            report['time'],
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
