import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/learning_profile.dart';
import 'ai_learning_controller.dart';

class AILearningScreen extends StatefulWidget {
  const AILearningScreen({super.key});

  @override
  State<AILearningScreen> createState() => _AILearningScreenState();
}

class _AILearningScreenState extends State<AILearningScreen> {
  late AILearningController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AILearningController();
    _controller.initializeProfile('current_user');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: Text(
          'AI Learning Intelligence',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => _controller.refreshRecommendations(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSummary(),
                const SizedBox(height: 20),
                _buildWeaknessesSection(),
                const SizedBox(height: 20),
                _buildStrengthsSection(),
                const SizedBox(height: 20),
                _buildRecommendationsSection(),
                const SizedBox(height: 20),
                _buildStudyPlanSection(),
                const SizedBox(height: 20),
                _buildMemorySection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSummary() {
    final profile = _controller.profile;
    if (profile == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A42B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${profile.currentLevel} Level • ${profile.goalText}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildProfileStat('⏱️', '${profile.dailyMinutes}m', 'Daily'),
              const SizedBox(width: 16),
              _buildProfileStat('🔥', '${profile.currentStreak}', 'Streak'),
              const SizedBox(width: 16),
              _buildProfileStat('📊', '${(profile.overallProgress * 100).toInt()}%', 'Progress'),
              const SizedBox(width: 16),
              _buildProfileStat('📚', '${profile.totalStudyHours}h', 'Total'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildProfileStat(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaknessesSection() {
    final weaknesses = _controller.profile?.weakAreas ?? [];
    if (weaknesses.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Areas to Improve',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...weaknesses.map((weakness) => _buildWeaknessCard(weakness)),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildWeaknessCard(WeaknessArea weakness) {
    final color = weakness.severity >= 0.6 ? Colors.red : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${(weakness.severity * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weakness.category,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weakness.mistakeCount} mistakes • ${weakness.severityText} priority',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                if (weakness.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Common: ${weakness.commonMistakes.first}',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }

  Widget _buildStrengthsSection() {
    final strengths = _controller.profile?.strongAreas ?? [];
    if (strengths.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Your Strengths',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: strengths.map((strength) => _buildStrengthChip(strength)).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildStrengthChip(StrongArea strength) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            strength.category,
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(strength.mastery * 100).toInt()}%',
            style: GoogleFonts.poppins(
              color: Colors.green.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final topRecs = _controller.getTopRecommendations(count: 3);
    if (topRecs.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF), size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Recommendations',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topRecs.map((rec) => _buildRecommendationCard(rec)),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRecommendationCard(AIRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(rec.typeEmoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRecTag('${rec.estimatedMinutes}m', Icons.timer),
                    const SizedBox(width: 8),
                    _buildRecTag(rec.category, Icons.category),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPlanSection() {
    final plan = _controller.studyPlan;
    if (plan == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00BCD4), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Weekly Study Plan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _controller.regenerateStudyPlan(),
              child: const Text('Regenerate'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plan.days.length,
            itemBuilder: (context, index) => _buildDayCard(plan.days[index]),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildDayCard(StudyPlanDay day) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.dayName.substring(0, 3),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${day.totalMinutes}m',
            style: GoogleFonts.poppins(
              color: const Color(0xFF6C63FF),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          ...day.activities.take(3).map((a) => Text(
            '${a.typeEmoji} ${a.title}',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }

  Widget _buildMemorySection() {
    final memory = _controller.memory;
    if (memory == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Memory',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildMemoryStat('Mistake Patterns', '${memory.mistakePatterns.length}', Icons.pattern),
              const SizedBox(height: 12),
              _buildMemoryStat('Words Learned', '${memory.successfullyLearned.length}', Icons.book),
              const SizedBox(height: 12),
              _buildMemoryStat('Conversations', '${memory.conversationHistory.length}', Icons.chat),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildMemoryStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
