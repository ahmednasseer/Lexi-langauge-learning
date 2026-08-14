import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/services/api_service.dart';
import '../wallet/presentation/screens/wallet_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _subscription;
  Map<String, dynamic>? _wallet;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileResult = await _api.getProfile();
      final subscriptionResult = await _api.getSubscription();
      final walletResult = await _api.getWallet();

      if (profileResult.isSuccess && profileResult.data != null) {
        _profile = profileResult.data;
      }
      if (subscriptionResult.isSuccess && subscriptionResult.data != null) {
        _subscription = subscriptionResult.data;
      }
      if (walletResult.isSuccess && walletResult.data != null) {
        _wallet = walletResult.data;
      }
    } catch (e) {
      _error = e.toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 28),
              if (_isLoading)
                _buildLoadingState()
              else if (_error != null)
                _buildErrorState()
              else
                Column(
                  children: [
                    _buildGemBalance(),
                    const SizedBox(height: 20),
                    _buildPurchaseHistoryButton(context),
                    const SizedBox(height: 28),
                    _buildCurrentPlan(),
                    const SizedBox(height: 20),
                    _buildManageSubscriptionsButton(context),
                    const SizedBox(height: 20),
                    _buildHelpCenter(context),
                    const SizedBox(height: 32),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'حساب',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load account data',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGemBalance() {
    final gems = _wallet?['gems'] ?? _wallet?['balance'] ?? 0;
    final gemDisplay = '$gems 💎';

    return GlowCard(
      glowColor: AppColors.gem,
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.6),
          AppColors.accent.withValues(alpha: 0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(28),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('💎', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رصيد الجواهر',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gemDisplay,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildPurchaseHistoryButton(BuildContext context) {
    return GlowCard(
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletScreen()),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'سجل المشتريات',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textHint,
            size: 16,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05);
  }

  Widget _buildCurrentPlan() {
    final isPremium = _profile?['isPremium'] ?? false;
    final planName = _subscription?['planName'] ?? _subscription?['plan'] ?? 'Premium';
    final planPeriod = _subscription?['billingPeriod'] ?? _subscription?['interval'] ?? '';
    final expiryDate = _subscription?['expiresAt'] ?? _subscription?['currentPeriodEnd'] ?? '';

    if (!isPremium) {
      return GlowCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.all(20),
        child: Text(
          'Free Plan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
    }

    String formattedExpiry = '';
    if (expiryDate.isNotEmpty) {
      try {
        final date = DateTime.parse(expiryDate);
        formattedExpiry = 'تاريخ الانتهاء: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        formattedExpiry = expiryDate;
      }
    }

    return GlowCard(
      glowColor: AppColors.gold,
      gradient: LinearGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.15),
          AppColors.goldDark.withValues(alpha: 0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      planName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (planPeriod.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    planPeriod,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
            ],
          ),
          if (formattedExpiry.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedExpiry,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildManageSubscriptionsButton(BuildContext context) {
    return GlowCard(
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.pushNamed(context, '/premium'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'إدارة الاشتراكات',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textHint,
            size: 16,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05);
  }

  Widget _buildHelpCenter(BuildContext context) {
    return GlowCard(
      glowColor: AppColors.secondary,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.pushNamed(context, '/support'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'مركز المساعدة',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textHint,
            size: 16,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05);
  }
}
