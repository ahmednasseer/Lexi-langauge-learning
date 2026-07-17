import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    final random = Random();
    _particles = List.generate(40, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 1.5,
        color: [
          AppColors.primary,
          AppColors.accent,
          AppColors.success,
          AppColors.gold,
          AppColors.secondary,
        ][random.nextInt(5)],
        size: 4 + random.nextDouble() * 8,
        angle: random.nextDouble() * pi * 2,
        angularSpeed: (random.nextDouble() - 0.5) * 4,
      );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
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
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _confettiController.value,
          ),
        );
      },
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

class _ConfettiParticle {
  final double x;
  final double speed;
  final Color color;
  final double size;
  final double angle;
  final double angularSpeed;

  const _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.color,
    required this.size,
    required this.angle,
    required this.angularSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final yOffset = (progress * particle.speed * size.height) % (size.height + 100);
      final xOffset = particle.x * size.width + sin(progress * pi * 2 + particle.angle) * 30;
      final rotation = progress * pi * particle.angularSpeed;

      canvas.save();
      canvas.translate(xOffset, yOffset - 50);
      canvas.rotate(rotation);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
