import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String amount;

  const PaymentMethodsScreen({super.key, this.amount = '\$6.99'});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'credit_card';

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
              const SizedBox(height: 12),
              _buildSubtitle(),
              const SizedBox(height: 28),
              _buildPaymentMethods(),
              const SizedBox(height: 32),
              _buildPayButton(),
              const SizedBox(height: 16),
              _buildSecurityText(),
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
              'طريقة الدفع',
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

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Text(
        'اختر طريقة الدفع المفضلة',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPaymentMethods() {
    final methods = [
      _PaymentMethodData(
        id: 'credit_card',
        name: 'بطاقات الائتمان/خصم',
        icon: Icons.credit_card_rounded,
        color: AppColors.secondary,
        subtitle: 'Visa / Mastercard',
      ),
      _PaymentMethodData(
        id: 'paypal',
        name: 'PayPal',
        icon: Icons.paypal,
        color: const Color(0xFF003087),
        subtitle: 'الدفع عبر PayPal',
      ),
      _PaymentMethodData(
        id: 'apple_pay',
        name: 'Apple Pay',
        icon: Icons.apple,
        color: Colors.black,
        subtitle: 'الدفع عبر Apple Pay',
      ),
      _PaymentMethodData(
        id: 'google_pay',
        name: 'Google Pay',
        icon: Icons.g_mobiledata_rounded,
        color: const Color(0xFF4285F4),
        subtitle: 'الدفع عبر Google Pay',
      ),
      _PaymentMethodData(
        id: 'google_play',
        name: 'Google Play',
        icon: Icons.play_arrow_rounded,
        color: const Color(0xFF0F9D58),
        subtitle: 'الدفع عبر Google Play',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر طريقة الدفع',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        ...methods.asMap().entries.map((entry) {
          final index = entry.key;
          final method = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPaymentOption(method),
          ).animate().fadeIn(delay: Duration(milliseconds: 300 + index * 80)).slideX(begin: 0.05);
        }),
      ],
    );
  }

  Widget _buildPaymentOption(_PaymentMethodData method) {
    final isSelected = _selectedMethod == method.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? method.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method.icon, color: method.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? method.color : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? method.color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/success');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'الدفع ${widget.amount}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1);
  }

  Widget _buildSecurityText() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: AppColors.success, size: 16),
          const SizedBox(width: 6),
          Text(
            'عملية دفع آمنة ومشفرة',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}

class _PaymentMethodData {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _PaymentMethodData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}
