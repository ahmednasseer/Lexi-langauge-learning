import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
                'Analytics Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  // Date range
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButton<String>(
                      value: 'Last 7 Days',
                      items: ['Today', 'Last 7 Days', 'Last 30 Days', 'Last 90 Days']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {},
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
                    label: const Text('Export Report'),
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
          // Key metrics
          Row(
            children: [
              _buildMetricCard(
                'Total Users',
                '1,250',
                '+12%',
                Icons.people,
                const Color(0xFF6C63FF),
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                'Active Users',
                '430',
                '+8%',
                Icons.person,
                const Color(0xFF00BCD4),
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                'Retention Rate',
                '68%',
                '+5%',
                Icons.trending_up,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                'Avg. Session',
                '12m',
                '+2m',
                Icons.timer,
                const Color(0xFFFF9800)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User growth chart
              Expanded(
                flex: 2,
                child: _buildUserGrowthChart(),
              ),
              const SizedBox(width: 24),
              // Learning progress
              Expanded(
                child: _buildLearningProgress(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top performing lessons
              Expanded(
                child: _buildTopLessons(),
              ),
              const SizedBox(width: 24),
              // User demographics
              Expanded(
                child: _buildDemographics(),
              ),
              const SizedBox(width: 24),
              // AI usage
              Expanded(
                child: _buildAIUsage(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // AI Learning Intelligence Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Common mistakes
              Expanded(
                child: _buildCommonMistakes(),
              ),
              const SizedBox(width: 24),
              // Weakest grammar topics
              Expanded(
                child: _buildWeakestTopics(),
              ),
              const SizedBox(width: 24),
              // AI recommendation success
              Expanded(
                child: _buildRecommendationSuccess(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String change, IconData icon, Color color) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 32,
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

  Widget _buildUserGrowthChart() {
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
            'User Growth',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildGrowthBar('Week 1', 0.4, '850'),
                const SizedBox(width: 16),
                _buildGrowthBar('Week 2', 0.55, '980'),
                const SizedBox(width: 16),
                _buildGrowthBar('Week 3', 0.7, '1,100'),
                const SizedBox(width: 16),
                _buildGrowthBar('Week 4', 0.85, '1,250'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthBar(String label, double height, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200 * height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6C63FF), Color(0xFF4A42B5)],
              ),
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

  Widget _buildLearningProgress() {
    final progress = [
      {'level': 'A1', 'completed': 450, 'total': 500, 'percent': 90},
      {'level': 'A2', 'completed': 320, 'total': 500, 'percent': 64},
      {'level': 'B1', 'completed': 180, 'total': 500, 'percent': 36},
      {'level': 'B2', 'completed': 85, 'total': 500, 'percent': 17},
      {'level': 'C1', 'completed': 25, 'total': 500, 'percent': 5},
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
            'Learning Progress',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...progress.map((p) => _buildProgressBar(p)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> p) {
    final color = _getLevelColor(p['level']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p['level'],
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${p['completed']}/${p['total']}',
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
              value: p['percent'] / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
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

  Widget _buildTopLessons() {
    final lessons = [
      {'title': 'Greetings', 'completions': 1250, 'rating': 4.8},
      {'title': 'Numbers 1-20', 'completions': 1100, 'rating': 4.7},
      {'title': 'Basic Phrases', 'completions': 980, 'rating': 4.9},
      {'title': 'Articles', 'completions': 850, 'rating': 4.5},
      {'title': 'Colors', 'completions': 720, 'rating': 4.6},
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
            'Top Lessons',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...lessons.map((l) => _buildLessonRow(l)),
        ],
      ),
    );
  }

  Widget _buildLessonRow(Map<String, dynamic> lesson) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.book, size: 16, color: Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${lesson['completions']} completions',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${lesson['rating']}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemographics() {
    final demographics = [
      {'age': '18-24', 'percent': 35, 'color': const Color(0xFF6C63FF)},
      {'age': '25-34', 'percent': 40, 'color': const Color(0xFF00BCD4)},
      {'age': '35-44', 'percent': 15, 'color': const Color(0xFF4CAF50)},
      {'age': '45+', 'percent': 10, 'color': const Color(0xFFFF9800)},
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
            'User Demographics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...demographics.map((d) => _buildDemographicRow(d)),
        ],
      ),
    );
  }

  Widget _buildDemographicRow(Map<String, dynamic> d) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                d['age'],
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
              Text(
                '${d['percent']}%',
                style: GoogleFonts.poppins(
                  color: d['color'],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: d['percent'] / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(d['color']),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIUsage() {
    final usage = [
      {'type': 'Grammar Help', 'count': 450, 'percent': 35},
      {'type': 'Vocabulary', 'count': 380, 'percent': 30},
      {'type': 'Conversation', 'count': 250, 'percent': 20},
      {'type': 'Pronunciation', 'count': 180, 'percent': 15},
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
            'AI Coach Usage',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...usage.map((u) => _buildUsageRow(u)),
        ],
      ),
    );
  }

  Widget _buildUsageRow(Map<String, dynamic> u) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                u['type'],
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${u['count']} (${u['percent']}%)',
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
              value: u['percent'] / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMistakes() {
    final mistakes = [
      {'topic': 'Articles (der/die/das)', 'users': 320, 'percent': 64},
      {'topic': 'Verb Conjugation', 'users': 280, 'percent': 56},
      {'topic': 'Word Order', 'users': 210, 'percent': 42},
      {'topic': 'Cases', 'users': 180, 'percent': 36},
      {'topic': 'Prepositions', 'users': 150, 'percent': 30},
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
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Most Common Mistakes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...mistakes.map((m) => _buildMistakeRow(m)),
        ],
      ),
    );
  }

  Widget _buildMistakeRow(Map<String, dynamic> m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  m['topic'],
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${m['users']} users',
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
              value: m['percent'] / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakestTopics() {
    final topics = [
      {'topic': 'German Articles', 'level': 'A1', 'severity': 'High'},
      {'topic': 'Past Tense', 'level': 'A2', 'severity': 'Medium'},
      {'topic': 'Subjunctive', 'level': 'B2', 'severity': 'High'},
      {'topic': 'Passive Voice', 'level': 'B1', 'severity': 'Low'},
      {'topic': 'Relative Clauses', 'level': 'B2', 'severity': 'Medium'},
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
            children: [
              const Icon(Icons.trending_down, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weakest Grammar Topics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topics.map((t) => _buildTopicRow(t)),
        ],
      ),
    );
  }

  Widget _buildTopicRow(Map<String, dynamic> t) {
    final severityColor = t['severity'] == 'High'
        ? Colors.red
        : t['severity'] == 'Medium'
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['topic'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Level: ${t['level']}',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              t['severity'],
              style: TextStyle(
                color: severityColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSuccess() {
    final stats = [
      {'label': 'Recommendations Sent', 'value': '2,450', 'icon': Icons.send, 'color': const Color(0xFF6C63FF)},
      {'label': 'Completed', 'value': '1,820', 'icon': Icons.check_circle, 'color': Colors.green},
      {'label': 'Completion Rate', 'value': '74%', 'icon': Icons.trending_up, 'color': const Color(0xFF00BCD4)},
      {'label': 'Avg. Improvement', 'value': '+12%', 'icon': Icons.speed, 'color': const Color(0xFFFF9800)},
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
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Recommendation Success',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stats.map((s) => _buildSuccessStat(s)),
        ],
      ),
    );
  }

  Widget _buildSuccessStat(Map<String, dynamic> s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (s['color'] as Color).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(s['icon'], color: s['color'], size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s['label'],
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            s['value'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
