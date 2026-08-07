import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/state_widgets.dart';
import 'community_repository.dart';

enum _CommunityTab { conversations, members, groups, challenges }

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  _CommunityTab _selectedTab = _CommunityTab.conversations;
  final CommunityRepository _repository = CommunityRepository();
  bool _feedError = false;

  Future<void> _loadFeed() async {
    try {
      await _repository.getFeed();
      if (mounted) setState(() => _feedError = false);
    } catch (e) {
      if (mounted) setState(() => _feedError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF6C63FF),
                onRefresh: _loadFeed,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildLearnCommunitySection(),
                      const SizedBox(height: 20),
                      _buildGermanGroupSection(),
                      const SizedBox(height: 20),
                      _buildDailyChallengesSection(),
                      const SizedBox(height: 20),
                      _buildLearningTipsSection(),
                      const SizedBox(height: 24),
                      _buildActiveUsersSection(),
                      const SizedBox(height: 20),
                      if (_feedError)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ErrorState(
                            message: 'Could not refresh community feed.',
                            onRetry: _loadFeed,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF21262D),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
          const Spacer(),
          Text(
            'المجتمع',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF21262D),
              ),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = [
      (_CommunityTab.conversations, 'المحادثات'),
      (_CommunityTab.members, 'الأعضاء'),
      (_CommunityTab.groups, 'المجموعات'),
      (_CommunityTab.challenges, 'التحديات'),
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF21262D),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab.$2,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF21262D),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'ابحث في المجتمع...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSectionTitle(String title, {String? actionText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (actionText != null)
            Text(
              actionText,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLearnCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('مجتمع متعلم', actionText: 'عرض الكل'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مجتمع المتعلم',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مجتمع تعليمي للغة الألمانية',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _miniAvatar(Colors.deepPurple, 'ف'),
                          _miniAvatar(Colors.blue, 'ع'),
                          _miniAvatar(Colors.teal, 'م'),
                          const SizedBox(width: 6),
                          Text(
                            '+245 عضو',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'انضم',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.05),
      ],
    );
  }

  Widget _buildGermanGroupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('نتحدث الألمانية'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF21262D),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          '🇩🇪',
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نتحدث الألمانية',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ممارسة المحادثة باللغة الألمانية',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'نشط',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '312 عضو',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '48 رسالة اليوم',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        children: [
                          Row(
                            children: [
                              _tinyAvatar(Colors.orange, 'س'),
                              const SizedBox(width: 4),
                              _tinyAvatar(Colors.pink, 'ن'),
                              const SizedBox(width: 4),
                              _tinyAvatar(Colors.cyan, 'ل'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.05),
      ],
    );
  }

  Widget _buildDailyChallengesSection() {
    final challenges = [
      {
        'title': 'تحدي القواعد',
        'subtitle': 'أكمل 5 تمارين قواعد',
        'icon': Icons.rule,
        'color': AppColors.accent,
        'progress': 0.6,
        'points': '+50',
      },
      {
        'title': 'تحدي المفردات',
        'subtitle': 'تعلم 10 كلمات جديدة',
        'icon': Icons.translate,
        'color': AppColors.success,
        'progress': 0.3,
        'points': '+30',
      },
      {
        'title': 'تحدي الاستماع',
        'subtitle': 'استمع إلى 3 مقاطع',
        'icon': Icons.headphones,
        'color': AppColors.secondary,
        'progress': 0.0,
        'points': '+40',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('تحديات يومية', actionText: 'عرض الكل'),
        const SizedBox(height: 14),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final c = challenges[index];
              return Container(
                width: 180,
                margin: EdgeInsets.only(right: index < challenges.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (c['color'] as Color).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (c['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            c['icon'] as IconData,
                            color: c['color'] as Color,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c['points'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      c['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['subtitle'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: c['progress'] as double,
                        backgroundColor: const Color(0xFF21262D),
                        valueColor: AlwaysStoppedAnimation(c['color'] as Color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 500 + index * 100),
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLearningTipsSection() {
    final tips = [
      {
        'title': 'نصيحة اليوم',
        'subtitle': 'استخدم الصيغة الشرطية للتعبير عن الأمنيات',
        'icon': Icons.lightbulb_outline,
        'color': AppColors.gold,
      },
      {
        'title': 'كلمة مفيدة',
        'subtitle': 'Gemütlich - مريح، مرتاح',
        'icon': Icons.book_outlined,
        'color': AppColors.primary,
      },
      {
        'title': 'تعبير شائع',
        'subtitle': 'Ich hätte gern... - أريد...',
        'icon': Icons.forum_outlined,
        'color': AppColors.secondary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('تعلم وحيل', actionText: 'المزيد'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(tips.length, (index) {
              final t = tips[index];
              return Container(
                margin: EdgeInsets.only(bottom: index < tips.length - 1 ? 10 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF21262D),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (t['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        t['icon'] as IconData,
                        color: t['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 600 + index * 100),
                  );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveUsersSection() {
    final activeUsers = [
      {'name': 'Ahmed', 'color': Colors.deepPurple, 'initial': 'A', 'level': 'B1', 'active': true},
      {'name': 'Fatima', 'color': Colors.pink, 'initial': 'F', 'level': 'A2', 'active': true},
      {'name': 'Mohamed', 'color': Colors.teal, 'initial': 'M', 'level': 'B2', 'active': true},
      {'name': 'Noor', 'color': Colors.orange, 'initial': 'N', 'level': 'A1', 'active': true},
      {'name': 'Sara', 'color': Colors.blue, 'initial': 'S', 'level': 'C1', 'active': false},
      {'name': 'Amr', 'color': Colors.cyan, 'initial': 'A', 'level': 'A2', 'active': true},
      {'name': 'Layla', 'color': Colors.red, 'initial': 'L', 'level': 'B1', 'active': false},
      {'name': 'Khaled', 'color': Colors.indigo, 'initial': 'K', 'level': 'A1', 'active': true},
      {'name': 'Reem', 'color': Colors.green, 'initial': 'R', 'level': 'B2', 'active': true},
      {'name': 'Yousef', 'color': Colors.amber, 'initial': 'Y', 'level': 'A2', 'active': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('المستخدمون النشطون', actionText: 'الكل'),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: activeUsers.length,
            itemBuilder: (context, index) {
              final user = activeUsers[index];
              return Container(
                width: 72,
                margin: EdgeInsets.only(right: index < activeUsers.length - 1 ? 12 : 0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (user['color'] as Color),
                                (user['color'] as Color).withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (user['color'] as Color).withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user['initial'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (user['active'] as bool)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0D1117),
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(user['level'] as String).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user['level'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _getLevelColor(user['level'] as String),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 700 + index * 60),
                  );
            },
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.levelA1;
      case 'A2':
        return AppColors.levelA2;
      case 'B1':
        return AppColors.levelB1;
      case 'B2':
        return AppColors.levelB2;
      case 'C1':
        return AppColors.levelC1;
      case 'C2':
        return AppColors.levelC2;
      default:
        return AppColors.primary;
    }
  }

  Widget _miniAvatar(Color color, String letter) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0D1117),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _tinyAvatar(Color color, String letter) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF161B22),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}
