import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..checkCurrentUser(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    final onboarded = await AuthService.instance.getOnboarded();

    if (!mounted) return;

    if (!onboarded) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (authState is AuthAuthenticated) {
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
                ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        AppAssets.lexiHappy,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 120),
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .fadeIn(duration: 300.ms),
                const SizedBox(height: 32),
                Text(
                      'Lexi',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text(
                      'Learn German with AI',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.3),
                const SizedBox(height: 48),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
