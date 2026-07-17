import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final String? centerText;
  final String? centerLabel;
  final bool showPercentage;
  final bool animate;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.color,
    this.gradient,
    this.backgroundColor,
    this.centerText,
    this.centerLabel,
    this.showPercentage = true,
    this.animate = true,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: widget.animate ? 0 : widget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      if (widget.animate) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.primary;
    final effectiveGradient = widget.gradient ?? AppColors.primaryGradient;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressRingPainter(
              progress: _animation.value,
              color: effectiveColor,
              gradient: effectiveGradient,
              strokeWidth: widget.strokeWidth,
              backgroundColor: widget.backgroundColor ?? AppColors.border,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.centerText != null)
                    Text(
                      widget.centerText!,
                      style: GoogleFonts.poppins(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (widget.showPercentage)
                    Text(
                      '${(_animation.value * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.w600,
                        color: effectiveColor,
                      ),
                    ),
                  if (widget.centerLabel != null)
                    Text(
                      widget.centerLabel!,
                      style: GoogleFonts.poppins(
                        fontSize: widget.size * 0.08,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color? color;
  final LinearGradient gradient;
  final double strokeWidth;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    this.color,
    required this.gradient,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != AppColors.primaryGradient || color != null) {
      progressPaint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    } else {
      progressPaint.color = color ?? AppColors.primary;
    }

    final angle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
