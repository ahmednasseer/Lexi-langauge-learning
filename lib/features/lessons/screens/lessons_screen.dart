import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/german_content.dart';
import '../models/lesson_model.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String initialLevel;
  const LessonsScreen({super.key, this.initialLevel = 'A1'});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _level;

  final _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final _categories = ['Vocabulary', 'Grammar', 'Listening'];

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('German Lessons', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)).animate().fadeIn().slideX(begin: -0.1),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Text('🇩🇪', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('German', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                height: 48,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Row(children: _levels.map((l) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _level = l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: _level == l ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(l, style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _level == l ? Colors.white : Colors.grey.shade600,
                      ))),
                    ),
                  ),
                )).toList()),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: AppColors.primary,
                tabs: _categories.map((c) => Tab(text: c)).toList(),
              ),
            ]),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((cat) {
                final lessons = GermanContent.getLessonsByCategory(_level, cat);
                if (lessons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text('No $_level $cat lessons yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Try another level or category', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: lessons.length,
                  itemBuilder: (context, i) => _card(lessons[i], i),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(LessonModel l, int i) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => LessonDetailScreen(lesson: l),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(_icon(l.category), style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(l.description, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              _tag(l.level), const SizedBox(width: 8),
              _tag('${l.quiz.length} exercises'), const SizedBox(width: 8),
              _tag('${l.xpReward} XP'),
            ]),
          ])),
          if (l.isCompleted)
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check, color: AppColors.success))
          else
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 20),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: i * 100)).slideX(begin: 0.1);
  }

  Widget _tag(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(t, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
  );

  String _icon(String c) => switch (c) {
    'Vocabulary' => '📝',
    'Grammar' => '📖',
    'Listening' => '🎧',
    _ => '📚',
  };
}
