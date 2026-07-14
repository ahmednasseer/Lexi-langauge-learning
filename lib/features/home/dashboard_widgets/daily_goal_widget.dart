import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DailyGoalWidget extends StatelessWidget {
  final double progress;
  final int currentXp;
  final int goalXp;

  const DailyGoalWidget({super.key, required this.progress, required this.currentXp, required this.goalXp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Row(children: [
        SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: AppColors.primary.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.primary), strokeCap: StrokeCap.round),
          Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ])),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daily Goal', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$currentXp/$goalXp XP today', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: AppColors.primary.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.primary), borderRadius: BorderRadius.circular(4)),
        ])),
      ]),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }
}
