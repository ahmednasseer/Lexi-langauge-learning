import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnimatedAvatar extends StatefulWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  final bool showGlow;
  final Color glowColor;
  final bool isOnline;
  final VoidCallback? onTap;
  final Widget? badge;

  const AnimatedAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 80,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.showGlow = false,
    this.glowColor = AppColors.primary,
    this.isOnline = false,
    this.onTap,
    this.badge,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = widget.border ?? Border.all(
      color: AppColors.border,
      width: 2,
    );

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Stack(
          children: [
            // Glow effect
            if (widget.showGlow)
              Container(
                width: widget.size + 10,
                height: widget.size + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            // Avatar
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.gradient,
                color: widget.backgroundColor ?? AppColors.surfaceLight,
                border: effectiveBorder,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: widget.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitials();
                        },
                      ),
                    )
                  : _buildInitials(),
            ),
            // Online indicator
            if (widget.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: widget.size * 0.25,
                  height: widget.size * 0.25,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
            // Badge
            if (widget.badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: widget.badge!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = widget.initials ?? '?';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
