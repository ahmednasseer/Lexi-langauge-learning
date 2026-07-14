import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ActivityItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final String xp;

  const ActivityItem({super.key, required this.icon, required this.title, required this.subtitle, required this.time, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 24)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)), Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(xp, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)), Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500))]),
      ]),
    );
  }
}
