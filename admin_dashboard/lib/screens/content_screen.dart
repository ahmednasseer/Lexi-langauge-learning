import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  int _selectedTab = 0;

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
                'Content Management',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddContentDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab(0, 'Languages'),
                _buildTab(1, 'Lessons'),
                _buildTab(2, 'Vocabulary'),
                _buildTab(3, 'Audio'),
                _buildTab(4, 'Quizzes'),
                _buildTab(5, 'Goethe'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Content based on tab
          if (_selectedTab == 0) _buildLanguagesTab(),
          if (_selectedTab == 1) _buildLessonsTab(),
          if (_selectedTab == 2) _buildVocabularyTab(),
          if (_selectedTab == 3) _buildAudioTab(),
          if (_selectedTab == 4) _buildQuizzesTab(),
          if (_selectedTab == 5) _buildGoetheTab(),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagesTab() {
    final languages = [
      {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch', 'flag': '🇩🇪', 'lessons': 50, 'active': true},
      {'code': 'fr', 'name': 'French', 'nativeName': 'Français', 'flag': '🇫🇷', 'lessons': 35, 'active': true},
      {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸', 'lessons': 40, 'active': true},
      {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano', 'flag': '🇮🇹', 'lessons': 30, 'active': true},
      {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語', 'flag': '🇯🇵', 'lessons': 25, 'active': true},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇸🇦', 'lessons': 20, 'active': false},
    ];

    return Container(
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
                Expanded(flex: 2, child: Text('Language', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Code', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Lessons', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Status', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                SizedBox(width: 120, child: Text('Actions', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          // Table body
          ...languages.map((lang) => Container(
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
                      Text(lang['flag'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang['name'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            lang['nativeName'] as String,
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
                  child: Text(
                    lang['code'] as String,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${lang['lessons']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (lang['active'] as bool)
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (lang['active'] as bool) ? 'Active' : 'Draft',
                      style: TextStyle(
                        color: (lang['active'] as bool) ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    final lessons = [
      {'title': 'Greetings', 'language': '🇩🇪 German', 'level': 'A1', 'type': 'Vocabulary', 'words': 15, 'order': 1},
      {'title': 'Numbers 1-20', 'language': '🇩🇪 German', 'level': 'A1', 'type': 'Vocabulary', 'words': 20, 'order': 2},
      {'title': 'Basic Phrases', 'language': '🇩🇪 German', 'level': 'A1', 'type': 'Speaking', 'words': 10, 'order': 3},
      {'title': 'Articles (der, die, das)', 'language': '🇩🇪 German', 'level': 'A1', 'type': 'Grammar', 'words': 25, 'order': 4},
      {'title': 'Colors & Shapes', 'language': '🇫🇷 French', 'level': 'A1', 'type': 'Vocabulary', 'words': 18, 'order': 1},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Lesson', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Language', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Level', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Type', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Words', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                SizedBox(width: 120, child: Text('Actions', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          ...lessons.map((lesson) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    lesson['title'] as String,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    lesson['language'] as String,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(lesson['level'] as String).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lesson['level'] as String,
                      style: TextStyle(
                        color: _getLevelColor(lesson['level'] as String),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    lesson['type'] as String,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${lesson['words']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVocabularyTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vocabulary Management',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Bulk Import'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          Row(
            children: [
              _buildVocabStat('Total Words', '15,000', const Color(0xFF6C63FF)),
              const SizedBox(width: 16),
              _buildVocabStat('With Audio', '12,500', const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildVocabStat('With Images', '8,000', const Color(0xFFFF9800)),
              const SizedBox(width: 16),
              _buildVocabStat('Pending Review', '250', const Color(0xFFF44336)),
            ],
          ),
          const SizedBox(height: 24),
          // Upload area
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Drag & drop CSV/JSON file here',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'or click to browse',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioTab() {
    return Container(
      padding: const EdgeInsets.all(24),
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
                'Audio Management',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Upload Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Audio stats
          Row(
            children: [
              _buildAudioStat('Total Files', '2,500', Icons.audio_file, const Color(0xFF6C63FF)),
              const SizedBox(width: 16),
              _buildAudioStat('Size', '4.2 GB', Icons.storage, const Color(0xFF00BCD4)),
              const SizedBox(width: 16),
              _buildAudioStat('Languages', '6', Icons.language, const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
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
    );
  }

  Widget _buildQuizzesTab() {
    return Container(
      padding: const EdgeInsets.all(24),
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
                'Quiz Management',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quiz stats
          Row(
            children: [
              _buildQuizStat('Total Questions', '5,000', Icons.question_answer, const Color(0xFF6C63FF)),
              const SizedBox(width: 16),
              _buildQuizStat('Quizzes', '250', Icons.quiz, const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildQuizStat('Avg. Score', '72%', Icons.trending_up, const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
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
    );
  }

  Widget _buildGoetheTab() {
    return Container(
      padding: const EdgeInsets.all(24),
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
                'Goethe Exam Management',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddGoetheQuestionDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          Row(
            children: [
              _buildGoetheStat('Total Questions', '1,200', Icons.question_answer, const Color(0xFF6C63FF)),
              const SizedBox(width: 16),
              _buildGoetheStat('Levels', '4', Icons.layers, const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildGoetheStat('Mock Exams', '12', Icons.quiz, const Color(0xFFFF9800)),
              const SizedBox(width: 16),
              _buildGoetheStat('Avg. Score', '68%', Icons.trending_up, const Color(0xFF00BCD4)),
            ],
          ),
          const SizedBox(height: 24),
          // Exam Levels Table
          _buildGoetheLevelsTable(),
        ],
      ),
    );
  }

  Widget _buildGoetheStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
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
    );
  }

  Widget _buildGoetheLevelsTable() {
    final levels = [
      {
        'level': 'A1',
        'name': 'Goethe-Zertifikat A1',
        'questions': 180,
        'sections': ['Lesen', 'Hören', 'Schreiben', 'Sprechen'],
        'passingScore': '60%',
        'duration': '90 min',
        'active': true,
      },
      {
        'level': 'A2',
        'name': 'Goethe-Zertifikat A2',
        'questions': 220,
        'sections': ['Lesen', 'Hören', 'Schreiben', 'Sprechen'],
        'passingScore': '60%',
        'duration': '110 min',
        'active': true,
      },
      {
        'level': 'B1',
        'name': 'Goethe-Zertifikat B1',
        'questions': 280,
        'sections': ['Lesen', 'Hören', 'Schreiben', 'Sprechen'],
        'passingScore': '60%',
        'duration': '135 min',
        'active': true,
      },
      {
        'level': 'B2',
        'name': 'Goethe-Zertifikat B2',
        'questions': 320,
        'sections': ['Lesen', 'Hören', 'Schreiben', 'Sprechen'],
        'passingScore': '60%',
        'duration': '160 min',
        'active': true,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Level', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Questions', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Sections', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Pass Score', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Duration', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Status', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text('Actions', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          ...levels.map((level) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['level'] as String,
                        style: GoogleFonts.poppins(
                          color: _getLevelColor(level['level'] as String),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        level['name'] as String,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    '${level['questions']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Wrap(
                    spacing: 6,
                    children: (level['sections'] as List<String>).map((section) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        section,
                        style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 11),
                      ),
                    )).toList(),
                  ),
                ),
                Expanded(
                  child: Text(
                    level['passingScore'] as String,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Text(
                    level['duration'] as String,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (level['active'] as bool)
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (level['active'] as bool) ? 'Active' : 'Draft',
                      style: TextStyle(
                        color: (level['active'] as bool) ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                        tooltip: 'Edit Level',
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.quiz, size: 18, color: Color(0xFF6C63FF)),
                        tooltip: 'Manage Questions',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showAddGoetheQuestionDialog() {
    String selectedLevel = 'A1';
    String selectedSection = 'Lesen';
    String questionType = 'multipleChoice';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(
            'Add Goethe Question',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Level selector
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Level',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: ['A1', 'A2', 'B1', 'B2'].map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedLevel = value!);
                  },
                ),
                const SizedBox(height: 16),
                // Section selector
                DropdownButtonFormField<String>(
                  initialValue: selectedSection,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Section',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: ['Lesen', 'Hören', 'Schreiben', 'Sprechen'].map((section) {
                    return DropdownMenuItem(value: section, child: Text(section));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedSection = value!);
                  },
                ),
                const SizedBox(height: 16),
                // Question type selector
                DropdownButtonFormField<String>(
                  initialValue: questionType,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Question Type',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'multipleChoice', child: Text('Multiple Choice')),
                    DropdownMenuItem(value: 'trueFalse', child: Text('True/False')),
                    DropdownMenuItem(value: 'fillInBlank', child: Text('Fill in Blank')),
                    DropdownMenuItem(value: 'shortAnswer', child: Text('Short Answer')),
                  ].toList(),
                  onChanged: (value) {
                    setDialogState(() => questionType = value!);
                  },
                ),
                const SizedBox(height: 16),
                // Question text field
                TextField(
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Question Text',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Enter the question...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Question added for Goethe $selectedLevel - $selectedSection'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Question'),
            ),
          ],
        ),
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

  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Add New Content',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(Icons.language, 'Language', 'Add a new language'),
            const SizedBox(height: 8),
            _buildDialogOption(Icons.book, 'Lesson', 'Create a new lesson'),
            const SizedBox(height: 8),
            _buildDialogOption(Icons.bookmark, 'Vocabulary', 'Add vocabulary'),
            const SizedBox(height: 8),
            _buildDialogOption(Icons.audio_file, 'Audio', 'Upload audio file'),
            const SizedBox(height: 8),
            _buildDialogOption(Icons.quiz, 'Quiz', 'Create a quiz'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(IconData icon, String title, String subtitle) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6C63FF), size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }
}
