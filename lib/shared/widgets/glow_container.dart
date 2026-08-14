import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.glowRadius = 20,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.gradient,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.3),
              blurRadius: glowRadius,
              spreadRadius: -glowRadius / 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          gradient: gradient,
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: glowColor.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: -5,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
