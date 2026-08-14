import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final double borderRadius;
  final double height;
  final double? width;
  final IconData? icon;
  final bool isLoading;
  final bool isSmall;
  final Color? glowColor;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppColors.primaryGradient,
    this.borderRadius = 20,
    this.height = 56,
    this.width,
    this.icon,
    this.isLoading = false,
    this.isSmall = false,
    this.glowColor,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = widget.glowColor ?? AppColors.glowPrimary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: widget.width,
          height: widget.isSmall ? 40 : widget.height,
          decoration: BoxDecoration(
            gradient: widget.onPressed != null ? widget.gradient : null,
            color: widget.onPressed == null ? AppColors.textHint : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: effectiveGlowColor,
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: widget.isSmall ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
