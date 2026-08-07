import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _buildConfetti(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCheckmark(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildDetail(),
                    const SizedBox(height: 48),
                    _buildAwesomeButton(),
                    const SizedBox(height: 20),
                    _buildHomeLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Lottie.asset(
      AppAssets.lottieConfetti,
      fit: BoxFit.cover,
      repeat: true,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildCheckmark() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.successGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 64,
      ),
    ).animate().scale(
          delay: 200.ms,
          duration: 500.ms,
          begin: const Offset(0.3, 0.3),
          curve: Curves.elasticOut,
        );
  }

  Widget _buildTitle() {
    return Text(
      'تمت العملية بنجاح!',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildDetail() {
    return Text(
      'تمت إضافة 800 💎 +100 مجاناً إلى حسابك',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  Widget _buildAwesomeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'رائع!',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1);
  }

  Widget _buildHomeLink() {
    return GestureDetector(
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: Text(
        'العودة إلى الرئيسية',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.primaryLight,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryLight,
        ),
      ),
    ).animate().fadeIn(delay: 1100.ms);
  }
}


