import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final _nativeLanguages = [
    {'name': 'Arabic', 'flag': '🇸🇦'},
    {'name': 'English', 'flag': '🇬🇧'},
    {'name': 'French', 'flag': '🇫🇷'},
    {'name': 'Spanish', 'flag': '🇪🇸'},
    {'name': 'Turkish', 'flag': '🇹🇷'},
    {'name': 'Hindi', 'flag': '🇮🇳'},
  ];

  final _learningLanguages = [
    {'name': 'German', 'flag': '🇩🇪', 'native': 'Deutsch'},
    {'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
    {'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
    {'name': 'Italian', 'flag': '🇮🇹', 'native': 'Italiano'},
    {'name': 'Japanese', 'flag': '🇯🇵', 'native': '日本語'},
  ];

  final _goals = [
    {'icon': '✈️', 'title': 'Travel', 'desc': 'Communicate while traveling'},
    {'icon': '💼', 'title': 'Work', 'desc': 'Career advancement'},
    {'icon': '📚', 'title': 'Study', 'desc': 'Academic purposes'},
    {'icon': '💬', 'title': 'Conversation', 'desc': 'Talk with native speakers'},
    {'icon': '🎨', 'title': 'Hobby', 'desc': 'Personal enrichment'},
  ];

  @override
  void dispose() => _controller.dispose();

  void _next() {
    if (_page < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await AuthService.instance.setOnboarded();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF5F5F9), Color(0xFFE8EAF6)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_page > 0)
                      IconButton(
                        onPressed: () => _controller.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                        icon: const Icon(Icons.arrow_back_ios),
                      )
                    else
                      const SizedBox(width: 48),
                    Row(
                      children: List.generate(4, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i ? AppColors.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text('Skip', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _buildLangPage(
                      'What\'s your\nnative language?',
                      _nativeLanguages,
                      (lang) => _next(),
                    ),
                    _buildLearnLangPage(),
                    _buildGoalPage(),
                    _buildWelcomePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangPage(String title, List<Map<String, String>> langs, ValueChanged<String> onTap) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        Text(title, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: langs.length,
            itemBuilder: (context, i) {
              final lang = langs[i]!;
              return GestureDetector(
                onTap: () => onTap(lang['name']!),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(lang['name']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildLearnLangPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        Text('What language\ndo you want to learn?', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: _learningLanguages.length,
            itemBuilder: (context, i) {
              final lang = _learningLanguages[i];
              final isGerman = lang['name'] == 'German';
              return GestureDetector(
                onTap: () => _next(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isGerman ? AppColors.primaryGradient : null,
                    color: isGerman ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isGerman ? AppColors.primary : Colors.grey.shade200, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(lang['name']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isGerman ? Colors.white : Colors.black87)),
                    if (isGerman) ...[
                      const SizedBox(height: 4),
                      Text('Recommended', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ]),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        Text('Why do you\nwant to learn?', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context, i) {
              final goal = _goals[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _next(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Row(children: [
                      Text(goal['icon']!, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(goal['title']!, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                        Text(goal['desc']!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                      ])),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 20),
                    ]),
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 100));
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: const Center(child: Text('🇩🇪', style: TextStyle(fontSize: 60))),
        ).animate().scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 40),
        Text('Ready to Learn German!', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        const SizedBox(height: 16),
        Text('Start your journey to mastering German with AI-powered lessons', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: _finish,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text('Get Started', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
      ]),
    );
  }
}
