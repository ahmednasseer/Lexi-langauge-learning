import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../core/services/auth_service.dart';
import 'models/exam_models.dart';
import 'goethe_exam_controller.dart';

class GoetheExamScreen extends StatefulWidget {
  const GoetheExamScreen({super.key});

  @override
  State<GoetheExamScreen> createState() => _GoetheExamScreenState();
}

class _GoetheExamScreenState extends State<GoetheExamScreen> {
  late GoetheExamController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GoetheExamController();
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
          'Goethe Exam Prep',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_controller.currentExam != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => _controller.resetExam(),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          if (_controller.currentExam != null) {
            return _buildExamView();
          }

          return _buildLevelSelection();
        },
      ),
    );
  }

  Widget _buildLevelSelection() {
    if (_controller.levelsLoading) {
      return const LoadingState(message: 'Loading exam levels...');
    }
    if (_controller.levelsError && _controller.levels.isEmpty) {
      return ErrorState(
        message: 'Failed to load exam levels. Please try again.',
        onRetry: _controller.reloadLevels,
      );
    }
    if (_controller.levels.isEmpty) {
      return const EmptyState(
        icon: Icons.school_outlined,
        title: 'No exam levels available',
        subtitle: 'Check back later for new Goethe exam preparation levels.',
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF6C63FF),
      onRefresh: _controller.reloadLevels,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
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
                      const Icon(Icons.school, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Text(
                        'Goethe Exam Preparation',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                   Text(
                     'Practice Goethe-Zertifikat exam questions with real curriculum-based reading and listening comprehension exercises.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            // Exam Levels
            Text(
              'Select Exam Level',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ..._controller.levels.map((level) => _buildLevelCard(level)),

            const SizedBox(height: 24),

            // Quick Practice
            Text(
              'Quick Practice',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickPracticeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(ExamLevelModel level) {
    final color = _getLevelColor(level.cefrLevel);
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                level.cefrLevel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                  level.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLevelStat(
                      Icons.quiz,
                      '${level.totalQuestions} questions',
                    ),
                    const SizedBox(width: 12),
                    _buildLevelStat(
                      Icons.timer,
                      '${level.timeLimitMinutes} min',
                    ),
                    const SizedBox(width: 12),
                    _buildLevelStat(
                      Icons.star,
                      '${level.passingScore}% to pass',
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _startExam(level),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLevelStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildQuickPracticeSection() {
    return Row(
      children: [
        _buildQuickPracticeCard(
          '📖',
          'Reading Practice',
          'Improve reading comprehension',
          const Color(0xFF4CAF50),
          () {},
        ),
        const SizedBox(width: 12),
        _buildQuickPracticeCard(
          '🎧',
          'Listening',
          'Coming soon',
          const Color(0xFF00BCD4),
          () {},
        ),
      ],
    );
  }

  Widget _buildQuickPracticeCard(
    String emoji,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamView() {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(),
        // Section tabs
        _buildSectionTabs(),
        // Question area
        Expanded(child: _buildQuestionArea()),
        // Navigation
        _buildNavigation(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_controller.answeredQuestions} of ${_controller.totalQuestions}',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              Text(
                '${(_controller.progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _controller.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6C63FF),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _controller.currentSections.length,
        itemBuilder: (context, index) {
          final section = _controller.currentSections[index];
          final isSelected = index == _controller.currentSectionIndex;
          return GestureDetector(
            onTap: () => _controller.goToSection(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: const Color(0xFF6C63FF))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(section.typeEmoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    section.name.split(' ').first,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
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

  Widget _buildQuestionArea() {
    final question = _controller.currentQuestion;
    if (question == null) {
      return const Center(
        child: Text(
          'No questions available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    question.difficulty,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.difficultyText,
                  style: TextStyle(
                    color: _getDifficultyColor(question.difficulty),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${question.points} points',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Passage if exists
          if (question.passage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.passage!,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Question
          Text(
            question.question,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ...question.options.map((option) => _buildOption(option, question)),
        ],
      ),
    );
  }

  Widget _buildOption(String option, ExamQuestion question) {
    final isSelected = _controller.answers[question.id] == option;
    return GestureDetector(
      onTap: () => _controller.answerQuestion(question.id, option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _controller.currentSectionIndex > 0 ||
                      _controller.currentQuestionIndex > 0
                  ? () => _controller.previousQuestion()
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLastQuestion()
                  ? () => _submitExam()
                  : () => _controller.nextQuestion(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLastQuestion()
                    ? Colors.green
                    : const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_isLastQuestion() ? 'Submit Exam' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLastQuestion() {
    final sections = _controller.currentSections;
    final lastIndex = sections.length - 1;
    final lastQuestionIndex = sections[lastIndex].questions.length - 1;
    return _controller.currentSectionIndex == lastIndex &&
        _controller.currentQuestionIndex == lastQuestionIndex;
  }

  Future<void> _startExam(ExamLevelModel level) async {
    final examLevel = ExamLevel.values.firstWhere(
      (e) => e.name.toUpperCase() == level.cefrLevel,
      orElse: () => ExamLevel.a1,
    );
    final userId = AuthService.instance.currentUser?.id ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to take the exam.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    await _controller.startMockExam(examLevel, userId);
    if (!mounted) return;
    if (_controller.currentSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No questions available for this level yet.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    setState(() {});
  }

  void _submitExam() {
    final result = _controller.completeExam();
    _showResultDialog(result);
  }

  void _showResultDialog(ExamResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              result.passed ? Icons.check_circle : Icons.cancel,
              color: result.passed ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              result.passed ? 'Congratulations!' : 'Keep Practicing',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: result.passed
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        result.grade,
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: result.passed ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${result.scorePercentage.toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Feedback
              Text(
                result.feedback,
                style: GoogleFonts.poppins(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Strengths
              if (result.strengths.isNotEmpty) ...[
                Text(
                  'Strengths',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...result.strengths.map(
                  (s) =>
                      Text('✓ $s', style: const TextStyle(color: Colors.green)),
                ),
                const SizedBox(height: 12),
              ],

              // Weaknesses
              if (result.weaknesses.isNotEmpty) ...[
                Text(
                  'Areas to Improve',
                  style: GoogleFonts.poppins(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...result.weaknesses.map(
                  (w) => Text(
                    '• $w',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Recommendation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.recommendation,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.resetExam();
            },
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.resetExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('Try Again'),
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

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }
}
