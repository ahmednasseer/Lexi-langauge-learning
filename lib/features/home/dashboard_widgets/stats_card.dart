import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final LinearGradient gradient;

  const StatsCard({super.key, required this.icon, required this.value, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(icon, style: const TextStyle(fontSize: 24)), const SizedBox(height: 8), Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)))]),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}
