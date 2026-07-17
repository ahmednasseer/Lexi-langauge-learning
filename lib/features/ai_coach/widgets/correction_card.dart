import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/coach_message.dart';

class CorrectionCard extends StatelessWidget {
  final CoachMessage message;

  const CorrectionCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (message.originalSentence != null) ...[
          _buildSection('❌', 'Your sentence:', message.originalSentence!, AppColors.error),
          const SizedBox(height: 12),
        ],
        if (message.correctSentence != null) ...[
          _buildSection('✅', 'Correct:', message.correctSentence!, AppColors.success),
          const SizedBox(height: 12),
        ],
        if (message.explanation != null) ...[
          _buildSection('📖', 'Explanation:', message.explanation!, AppColors.info),
          const SizedBox(height: 12),
        ],
        if (message.betterAlternative != null) ...[
          _buildSection('💡', 'Better alternative:', message.betterAlternative!, AppColors.warning),
        ],
        if (message.xpEarned != null && message.xpEarned! > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('+${message.xpEarned} XP', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
          ),
        ],
      ]),
    );
  }

  Widget _buildSection(String icon, String label, String text, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
      ),
    ]);
  }
}
