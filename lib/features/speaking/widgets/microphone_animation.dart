import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';

class MicrophoneAnimation extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onPressed;
  final double size;
  const MicrophoneAnimation({
    super.key,
    required this.isActive,
    this.onPressed,
    this.size = 120,
  });
  @override
  State<MicrophoneAnimation> createState() => _MicrophoneAnimationState();
}

class _MicrophoneAnimationState extends State<MicrophoneAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(MicrophoneAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimation();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _stopAnimation() {
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _waveAnimation]),
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isActive
                    ? [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                        Colors.purple.shade400,
                      ]
                    : [AppColors.border, AppColors.borderLight],
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.4),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 5 * _pulseAnimation.value,
                      ),
                    ]
                  : [],
            ),
            child: CustomPaint(
              painter: _WavePainter(
                animation: _waveAnimation.value,
                isActive: widget.isActive,
              ),
              child: Center(
                child: Transform.scale(
                  scale: widget.isActive ? _pulseAnimation.value : 1.0,
                  child: Icon(
                    widget.isActive ? Icons.mic : Icons.mic_none,
                    size: widget.size * 0.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final bool isActive;
  _WavePainter({required this.animation, required this.isActive});
  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) + (i * 15.0) + (animation * 10 % 15);
      final opacity = (1.0 - (i * 0.3)).clamp(0.0, 1.0);
      paint.color = Colors.blue.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      animation != oldDelegate.animation;
}
