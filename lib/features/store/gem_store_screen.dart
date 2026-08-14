import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class GemStoreScreen extends StatefulWidget {
  const GemStoreScreen({super.key});

  @override
  State<GemStoreScreen> createState() => _GemStoreScreenState();
}

class _GemStoreScreenState extends State<GemStoreScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildHeaderBanner(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 20),
                _buildGemPackages(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
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
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'متجر الجواهر',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildHeaderBanner() {
    return GlowCard(
      glowColor: AppColors.gem,
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.8),
          AppColors.accent.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(28),
      child: Row(
        children: [
          const Text('💎', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ارفع الجواهر',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'احصل على جواهر إضافية مجاناً مع كل باقة',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTabs() {
    final tabs = ['للمشتركين', 'للفنات'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildGemPackages() {
    final packages = [
      _GemPackageData(gems: 100, price: '\$0.99', bonus: 0),
      _GemPackageData(gems: 300, price: '\$2.99', bonus: 10),
      _GemPackageData(gems: 800, price: '\$6.99', bonus: 50, isPopular: true),
      _GemPackageData(gems: 2000, price: '\$13.99', bonus: 150),
      _GemPackageData(gems: 5000, price: '\$29.99', bonus: 500),
      _GemPackageData(gems: 12000, price: '\$59.99', bonus: 1500),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: packages.asMap().entries.map((entry) {
        final index = entry.key;
        final pkg = entry.value;
        return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPackageCard(pkg),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 400 + index * 80))
            .slideY(begin: 0.05);
      }).toList(),
    );
  }

  Widget _buildPackageCard(_GemPackageData pkg) {
    return GlowCard(
      glowColor: pkg.isPopular ? AppColors.gold : AppColors.gem,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pkg.isPopular
                    ? [AppColors.gold, AppColors.goldDark]
                    : [AppColors.gem, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('💎', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${pkg.gems} 💎',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (pkg.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'الأكثر شعبية',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (pkg.bonus > 0)
                  Text(
                    '+${pkg.bonus} مجاناً',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/payment-methods'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: pkg.isPopular
                    ? AppColors.goldGradient
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pkg.price,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GemPackageData {
  final int gems;
  final String price;
  final int bonus;
  final bool isPopular;

  const _GemPackageData({
    required this.gems,
    required this.price,
    required this.bonus,
    this.isPopular = false,
  });
}
