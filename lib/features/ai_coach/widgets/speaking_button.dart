import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SpeakingButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const SpeakingButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  State<SpeakingButton> createState() => _SpeakingButtonState();
}

class _SpeakingButtonState extends State<SpeakingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SpeakingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.isListening ? AppColors.errorGradient : AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: (widget.isListening ? AppColors.error : AppColors.primary).withValues(alpha: 0.4),
                blurRadius: widget.isListening ? 20 : 10,
                spreadRadius: widget.isListening ? 5 : 0,
              ),
            ],
          ),
          child: IconButton(
            onPressed: widget.onPressed,
            icon: Icon(
              widget.isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        widget.isListening ? 'Listening...' : 'Tap to speak',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: widget.isListening ? AppColors.error : Colors.white.withValues(alpha: 0.7),
        ),
      ),
    ]);
  }
}
