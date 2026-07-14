import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.color,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  const CustomButton.primary({super.key, required this.label, required this.onPressed, this.icon, this.isLoading = false, this.width})
      : gradient = AppColors.primaryGradient, color = null, textColor = Colors.white, height = 56;

  const CustomButton.outline({super.key, required this.label, required this.onPressed, this.icon})
      : gradient = null, color = null, textColor = AppColors.primary, isLoading = false, width = null, height = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, color: textColor), const SizedBox(width: 8)],
                    Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  ],
                ),
        ),
      ),
    );
  }
}
