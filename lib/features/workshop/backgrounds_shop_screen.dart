import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class BackgroundsShopScreen extends StatefulWidget {
  const BackgroundsShopScreen({super.key});

  @override
  State<BackgroundsShopScreen> createState() => _BackgroundsShopScreenState();
}

class _BackgroundsShopScreenState extends State<BackgroundsShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = -1;

  final _backgrounds = [
    {
      'name': 'غروب شمسي',
      'price': 200,
      'gradient': [Color(0xFFF97316), Color(0xFFEC4899)],
      'locked': false,
    },
    {
      'name': 'محيط سماوي',
      'price': 250,
      'gradient': [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      'locked': false,
    },
    {
      'name': 'غابة خضراء',
      'price': 300,
      'gradient': [Color(0xFF22C55E), Color(0xFF14B8A6)],
      'locked': true,
    },
    {
      'name': 'أحلام بنفسجية',
      'price': 200,
      'gradient': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      'locked': false,
    },
    {
      'name': 'ليل نجمي',
      'price': 250,
      'gradient': [Color(0xFF1E1B4B), Color(0xFF3B82F6)],
      'locked': true,
    },
    {
      'name': 'مطر ذهبي',
      'price': 300,
      'gradient': [Color(0xFFFBBF24), Color(0xFFF97316)],
      'locked': false,
    },
    {
      'name': 'وردي ناعم',
      'price': 200,
      'gradient': [Color(0xFFEC4899), Color(0xFFF472B6)],
      'locked': false,
    },
    {
      'name': 'سحابي أزرق',
      'price': 250,
      'gradient': [Color(0xFF60A5FA), Color(0xFF93C5FD)],
      'locked': true,
    },
    {
      'name': 'نار حمراء',
      'price': 300,
      'gradient': [Color(0xFFEF4444), Color(0xFFF97316)],
      'locked': false,
    },
  ];

  final _tabTitles = ['لجميع', 'مميزة', 'نادرة'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBackgrounds {
    switch (_tabController.index) {
      case 0:
        return _backgrounds;
      case 1:
        return _backgrounds.where((b) => (b['price'] as int) <= 250).toList();
      case 2:
        return _backgrounds.where((b) => (b['price'] as int) >= 300).toList();
      default:
        return _backgrounds;
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
            const SizedBox(height: 12),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildBackgroundGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'خلفيات الأفاتار',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.gemGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '1250',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_tabTitles.length, (index) {
          final isSelected = _tabController.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabController.index = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _tabTitles[index],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildBackgroundGrid() {
    final items = _filteredBackgrounds;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final gradientColors =
            (item['gradient'] as List<Color>); // ignore: implicit_dynamic_typing
        final locked = item['locked'] as bool;
        final price = item['price'] as int;
        final name = item['name'] as String;
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: locked
              ? null
              : () => setState(() {
                    _selectedIndex = isSelected ? -1 : index;
                  }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? gradientColors[0]
                    : AppColors.border.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (locked)
                          Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.success.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.gemGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$price',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Text('💎', style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 200 + index * 60),
              duration: 350.ms,
            )
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}
