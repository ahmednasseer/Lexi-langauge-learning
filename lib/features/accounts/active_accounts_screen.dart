import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import '../wallet/transaction_history_screen.dart';

class ActiveAccountsScreen extends StatelessWidget {
  const ActiveAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildPremiumCard(),
              const SizedBox(height: 20),
              _buildSubscriptionDetails(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildSubscriptionHistoryLink(context),
              const SizedBox(height: 32),
            ],
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
              'الحسابات النشطة',
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

  Widget _buildPremiumCard() {
    return PremiumCard(
      showGlow: true,
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
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.diamond, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lexi Premium',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الاشتراك النشط',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const PremiumBadge(),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.gold, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سنوي',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'تاريخ الانتهاء: 20/03/2027',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'إدارة',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSubscriptionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل الاشتراك',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.auto_awesome, 'الذكاء الاصطناعي', 'غير محدود', AppColors.primary),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.headphones, 'الدروس الصوتية', '88 درس', AppColors.secondary),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.chat, 'المدرب الشخصي', 'غير محدود', AppColors.accent),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.book, 'الاختبارات', 'غير محدود', AppColors.success),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, Color color) {
    return GlowCard(
      glowColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 300 + _detailRows.indexOf(title) * 80));
  }

  static const _detailRows = ['الذكاء الاصطناعي', 'الدروس الصوتية', 'المدرب الشخصي', 'الاختبارات'];

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlowCard(
                glowColor: AppColors.primary,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.upgrade, color: AppColors.primary, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'ترقية',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlowCard(
                glowColor: AppColors.accent,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.card_giftcard, color: AppColors.accent, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'هدية',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlowCard(
                glowColor: AppColors.warning,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.help_outline, color: AppColors.warning, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'الدعم',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildSubscriptionHistoryLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
        ),
        child: Text(
          'سجل الاشتراكات',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primaryLight,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }
}
