import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/wallet.dart';
import '../bloc/wallet_cubit.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WalletCubit>(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  @override
  void initState() {
    super.initState();
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<WalletCubit>().loadWallet(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Wallet',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalletError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }
          if (state is WalletLoaded || state is WalletTransactionLoaded) {
            Wallet wallet;
            if (state is WalletLoaded) {
              wallet = state.wallet;
            } else {
              wallet = (state as WalletTransactionLoaded).wallet;
            }
            return _buildWalletContent(context, wallet);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context, Wallet wallet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(wallet),
          const SizedBox(height: 24),
          _buildQuickActions(context, wallet),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Wallet wallet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Balance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCurrencyItem(
                icon: '💎',
                label: 'Gems',
                amount: wallet.gems,
              ),
              const SizedBox(width: 32),
              _buildCurrencyItem(
                icon: '🪙',
                label: 'Coins',
                amount: wallet.coins,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem({
    required String icon,
    required String label,
    required int amount,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$amount',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Wallet wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Earn Gems',
                onTap: () {
                  final user = fb.FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    context.read<WalletCubit>().addCurrency(
                      userId: user.uid,
                      gems: 10,
                      description: 'Daily bonus',
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: 'History',
                onTap: () {
                  final user = fb.FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    context.read<WalletCubit>().loadTransactions(user.uid);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
