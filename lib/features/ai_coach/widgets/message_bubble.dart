import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/coach_message.dart';
import 'correction_card.dart';

class MessageBubble extends StatelessWidget {
  final CoachMessage message;
  final bool isLast;

  const MessageBubble({super.key, required this.message, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserMessage();
    } else {
      return _buildAiMessage();
    }
  }

  Widget _buildUserMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(message.content, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white)),
      ),
    );
  }

  Widget _buildAiMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(message.content, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white.withValues(alpha: 0.9))),
                  if (message.xpEarned != null && message.xpEarned! > 0 && !message.hasCorrection) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('+${message.xpEarned} XP', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
        if (message.hasCorrection)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: CorrectionCard(message: message),
          ),
      ]),
    );
  }
}
