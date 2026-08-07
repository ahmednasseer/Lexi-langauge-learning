import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'subscription_model.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)), Expanded(child: Text('Premium', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 24),
            Container(width: double.infinity, padding: const EdgeInsets.all(32), decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(children: [
              const Text('👑', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('Unlock Full Power', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Master any language faster', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withValues(alpha: 0.9))),
            ])).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 32),
            _toggle(),
            const SizedBox(height: 24),
            ...SubscriptionModel.plans.map((plan) => _planCard(plan)),
          ]),
        ),
      ),
    );
  }

  Widget _toggle() {
    return Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)), child: Row(children: [
      Expanded(child: GestureDetector(onTap: () => setState(() => _isYearly = false), child: AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: !_isYearly ? AppColors.primaryGradient : null, borderRadius: BorderRadius.circular(10)), child: Center(child: Text('Monthly', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: !_isYearly ? Colors.white : Colors.grey.shade600)))))),
      Expanded(child: GestureDetector(onTap: () => setState(() => _isYearly = true), child: AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: _isYearly ? AppColors.primaryGradient : null, borderRadius: BorderRadius.circular(10)), child: Center(child: Text('Yearly (Save 60%)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _isYearly ? Colors.white : Colors.grey.shade600)))))),
    ]));
  }

  Widget _planCard(SubscriptionModel plan) {
    final isSel = (_isYearly && plan.id == 'yearly') || (!_isYearly && plan.id == 'monthly');
    return Container(
      margin: const EdgeInsets.only(bottom: 16), width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: isSel ? 2 : 1), boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10)] : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (plan.isPopular) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)), child: Text('Most Popular', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
        if (plan.isPopular) const SizedBox(height: 12),
        Row(children: [
          Text(plan.name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('${plan.currency}${plan.price.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text('/${plan.id == 'yearly' ? 'year' : 'mo'}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
        ]),
        const SizedBox(height: 16),
        ...plan.features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 18), const SizedBox(width: 8), Text(f, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700))]))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/payment-methods'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text('Subscribe Now', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: SubscriptionModel.plans.indexOf(plan) * 100)).slideY(begin: 0.1);
  }
}
