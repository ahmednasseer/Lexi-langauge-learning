import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class PremiumOfferScreen extends StatefulWidget {
  const PremiumOfferScreen({super.key});

  @override
  State<PremiumOfferScreen> createState() => _PremiumOfferScreenState();
}

class _PremiumOfferScreenState extends State<PremiumOfferScreen> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSubtitle(),
              const SizedBox(height: 24),
              _buildMonthlyCard(),
              const SizedBox(height: 16),
              _buildYearlyCard(),
              const SizedBox(height: 24),
              _buildFavoriteQuizzes(),
              const SizedBox(height: 24),
              _buildFooterLinks(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Text(
            'اشتراكات',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'اختر خطتك المفضلة',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildMonthlyCard() {
    final features = [
      'كل مرات Lexi',
      'شخصيات حصرية',
      'دروس متقدمة',
      'خارج MessageLookupبات',
      'دعم مفضل',
    ];

    return GestureDetector(
      onTap: () => setState(() => _isYearly = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: !_isYearly
              ? LinearGradient(
                  colors: [
                    AppColors.goldGradient.colors.first.withValues(alpha: 0.15),
                    AppColors.goldGradient.colors.last.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _isYearly ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: !_isYearly ? AppColors.gold : AppColors.border,
            width: !_isYearly ? 2 : 1,
          ),
          boxShadow: !_isYearly
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lexi Premium',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'شهرية',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$4.99',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/ شهر',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05);
  }

  Widget _buildYearlyCard() {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: _isYearly
              ? LinearGradient(
                  colors: [
                    AppColors.primaryGradient.colors.first.withValues(
                      alpha: 0.15,
                    ),
                    AppColors.primaryGradient.colors.last.withValues(
                      alpha: 0.05,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !_isYearly ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isYearly ? AppColors.primary : AppColors.border,
            width: _isYearly ? 2 : 1,
          ),
          boxShadow: _isYearly
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lexi Premium',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'سنوية',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '33% وفر',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$39.99',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/ سنة',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05);
  }

  Widget _buildFavoriteQuizzes() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.quiz, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'اختبارات المفضلة',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            'شروط الاستخدام',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textHint,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textHint,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {},
          child: Text(
            'سياسة الخصوصية',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textHint,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textHint,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}
