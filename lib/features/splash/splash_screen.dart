import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final auth = AuthService.instance;
    final onboarded = await auth.getOnboarded();

    if (!mounted) return;

    if (!onboarded) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (auth.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Center(child: Text('🇩🇪', style: TextStyle(fontSize: 60))),
                ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut).then().fadeIn(duration: 300.ms),
                const SizedBox(height: 32),
                Text('Lexi', style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))
                    .animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text('Learn German with AI', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white.withValues(alpha: 0.9)))
                    .animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.3),
                const SizedBox(height: 48),
                SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.8))),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
