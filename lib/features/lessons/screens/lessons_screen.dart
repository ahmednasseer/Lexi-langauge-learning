import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/services/connectivity_service.dart';
import '../lesson_repository.dart';
import '../models/lesson_model.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String initialLevel;
  const LessonsScreen({super.key, this.initialLevel = 'A1'});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _level;

  final LessonRepository _repository = LessonRepository();
  final _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final _categories = ['Vocabulary', 'Grammar', 'Listening'];

  final Map<String, List<LessonModel>> _lessonsByCategory = {};
  bool _isLoading = true;
  bool _isOffline = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLessons();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadLessons();
    }
  }

  Future<void> _loadLessons() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final category = _categories[_tabController.index];
    _isOffline = ConnectivityService().isOffline;

    try {
      final lessons = await _repository.getLessons(_level, category, 'German');
      if (!mounted) return;
      setState(() {
        _lessonsByCategory[category] = lessons;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lessonsByCategory[category] = [];
        _error = 'Failed to load lessons. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onLevelChanged(String level) {
    if (level == _level) return;
    setState(() => _level = level);
    _loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'German Lessons',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇩🇪', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              'German',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Offline banner
                  if (_isOffline)
                    _buildBanner('You are offline. Showing saved lessons.', AppColors.warning),
                  if (_error != null)
                    _buildBanner(_error!, AppColors.error),
                  const SizedBox(height: 16),
                  // Level selector
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: _levels
                          .map(
                            (l) => Expanded(
                              child: GestureDetector(
                                onTap: () => _onLevelChanged(l),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: _level == l
                                        ? AppColors.getLevelGradient(l)
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _level == l
                                        ? [
                                            BoxShadow(
                                              color: AppColors.getLevelColor(l)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      l,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _level == l
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),
                  // Category tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textHint,
                    indicatorColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: _categories.map((c) => Tab(text: c)).toList(),
                  ),
                ],
              ),
            ),
            // Lessons list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((cat) {
                  if (_isLoading) return _buildLoadingState();
                  final lessons = _lessonsByCategory[cat] ?? [];
                  if (lessons.isEmpty) return _buildEmptyState(cat);
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: lessons.length,
                    itemBuilder: (context, i) => _buildLessonCard(
                      lessons[i],
                      i,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(String message, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 4,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('📚', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 20),
          Text(
            'No $_level $category lessons yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try another level or category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson, int index) {
    final levelColor = AppColors.getLevelColor(lesson.level);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlowCard(
        glowColor: levelColor,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LessonDetailScreen(lesson: lesson),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.getLevelGradient(lesson.level),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _getCategoryIcon(lesson.category),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag(lesson.level, levelColor),
                      const SizedBox(width: 8),
                      _buildTag('${lesson.quiz.length} exercises', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildTag('${lesson.xpReward} XP', AppColors.gold),
                    ],
                  ),
                ],
              ),
            ),
            // Status
            if (lesson.isCompleted)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textHint,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX(begin: 0.1);
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    return switch (category) {
      'Vocabulary' => '📝',
      'Grammar' => '📖',
      'Listening' => '🎧',
      _ => '📚',
    };
  }
}
