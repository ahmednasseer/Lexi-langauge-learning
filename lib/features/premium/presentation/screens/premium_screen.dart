import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/premium.dart';
import '../bloc/premium_cubit.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PremiumCubit>(),
      child: const _PremiumView(),
    );
  }
}

class _PremiumView extends StatefulWidget {
  const _PremiumView();

  @override
  State<_PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<_PremiumView> {
  @override
  void initState() {
    super.initState();
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<PremiumCubit>().loadPremium(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Premium',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<PremiumCubit, PremiumState>(
        builder: (context, state) {
          if (state is PremiumLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PremiumError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }
          if (state is PremiumLoaded || state is PremiumActivated) {
            Premium premium;
            if (state is PremiumLoaded) {
              premium = state.premium;
            } else {
              premium = (state as PremiumActivated).premium;
            }
            return _buildPremiumContent(context, premium);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPremiumContent(BuildContext context, Premium premium) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(premium),
          const SizedBox(height: 24),
          _buildFeaturesList(premium),
          const SizedBox(height: 24),
          _buildPlans(context, premium),
        ],
      ),
    );
  }

  Widget _buildHeader(Premium premium) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: premium.isActive
            ? AppColors.goldGradient
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            premium.isActive ? '👑' : '⭐',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            premium.isActive ? 'Premium Active' : 'Go Premium',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (premium.isActive && premium.expiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Expires in ${premium.daysRemaining} days',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesList(Premium premium) {
    final features = [
      'Unlimited lessons',
      'No advertisements',
      'Exclusive frames & badges',
      'Priority support',
      'Early access to new features',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  premium.isActive ? Icons.check_circle : Icons.circle_outlined,
                  color: premium.isActive
                      ? AppColors.success
                      : AppColors.textHint,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  feature,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlans(BuildContext context, Premium premium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          plan: PremiumPlan.monthly,
          title: 'Monthly',
          price: '\$4.99/month',
          durationDays: 30,
          premium: premium,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          context,
          plan: PremiumPlan.yearly,
          title: 'Yearly',
          price: '\$39.99/year',
          durationDays: 365,
          premium: premium,
          isPopular: true,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          context,
          plan: PremiumPlan.lifetime,
          title: 'Lifetime',
          price: '\$99.99 once',
          durationDays: 3650,
          premium: premium,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required PremiumPlan plan,
    required String title,
    required String price,
    required int durationDays,
    required Premium premium,
    bool isPopular = false,
  }) {
    final isCurrentPlan = premium.plan == plan && premium.isActive;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan ? AppColors.primary : AppColors.border,
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                final user = fb.FirebaseAuth.instance.currentUser;
                if (user != null) {
                  context.read<PremiumCubit>().activatePremium(
                    userId: user.uid,
                    plan: plan,
                    durationDays: durationDays,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Select',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
