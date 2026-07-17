import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.valueColor,
    this.gradient,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
  });

  const ProgressBar.linear({super.key, required this.value, this.label, this.showPercentage = true})
      : height = 8,
        backgroundColor = null,
        valueColor = null,
        gradient = AppColors.primaryGradient,
        borderRadius = const BorderRadius.all(Radius.circular(4));

  const ProgressBar.circular({super.key, required this.value})
      : height = 8,
        backgroundColor = null,
        valueColor = AppColors.primary,
        gradient = null,
        borderRadius = null,
        label = null,
        showPercentage = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = valueColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null) Text(label!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                if (showPercentage) Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 12, color: effectiveColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: backgroundColor ?? effectiveColor.withValues(alpha: 0.1),
              valueColor: gradient != null ? AlwaysStoppedAnimation(gradient!.colors.first) : AlwaysStoppedAnimation(effectiveColor),
            ),
          ),
        ),
      ],
    );
  }
}
