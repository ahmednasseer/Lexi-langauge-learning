import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/widgets.dart';
import 'certificates_repository.dart';
import 'models/certificate.dart';
import 'widgets/certificate_card.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

enum _CertStatus { initial, loading, success, empty, error }

class _CertificatesScreenState extends State<CertificatesScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  final CertificatesRepository _repository = CertificatesRepository();
  _CertStatus _status = _CertStatus.initial;
  List<Certificate> _certificates = [];
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (_status == _CertStatus.initial) _status = _CertStatus.loading;
      _error = null;
    });
    try {
      final certs = await _repository.getCertificates();
      if (!mounted) return;
      setState(() {
        _certificates = certs;
        _status = certs.isEmpty ? _CertStatus.empty : _CertStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load certificates. Please try again.';
        _status = _CertStatus.error;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Confetti effect
          Lottie.asset(
            AppAssets.lottieConfetti,
            fit: BoxFit.cover,
            repeat: true,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: _buildContentBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    if (_status == _CertStatus.loading) {
      return const LoadingState(message: 'Loading certificates...');
    }
    if (_status == _CertStatus.error) {
      return ErrorState(
        message: _error ?? 'Something went wrong.',
        onRetry: _load,
      );
    }
    if (_status == _CertStatus.empty) {
      return const EmptyState(
        icon: Icons.workspace_premium_outlined,
        title: 'No certificates yet',
        subtitle: 'Complete lessons and exams to earn your certificates.',
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (_certificates.isNotEmpty)
            ..._certificates.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CertificateCard(certificate: c),
              ),
            ),
          _buildCertificateCard(),
          const SizedBox(height: 32),
          _buildShareButton(),
          const SizedBox(height: 24),
          _buildChampionBadge(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'الشهادات والإنجازات',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCertificateCard() {
    return AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1E2A4A), const Color(0xFF151D35)],
                ),
                border: Border.all(
                  color: AppColors.gold.withValues(
                    alpha: 0.6 + (_glowController.value * 0.4),
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(
                      alpha: 0.2 + (_glowController.value * 0.15),
                    ),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surface.withValues(alpha: 0.9),
                      AppColors.surface.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    _buildZertifikatHeader(),
                    const SizedBox(height: 24),
                    _buildLexiLanguageSubtitle(),
                    const SizedBox(height: 20),
                    _buildLevelBadge(),
                    const SizedBox(height: 24),
                    _buildCompletionText(),
                    const SizedBox(height: 20),
                    _buildAchievementLabel(),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildZertifikatHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.gold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Text(
            'ZERTIFIKAT',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.workspace_premium, color: AppColors.gold, size: 28),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, delay: 200.ms);
  }

  Widget _buildLexiLanguageSubtitle() {
    return Column(
      children: [
        Text(
          'Lexi Language',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.0),
                AppColors.gold,
                AppColors.gold.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildLevelBadge() {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  AppAssets.badgeB1,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'B1',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          delay: 400.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildCompletionText() {
    return Column(
      children: [
        Text(
          'تم إتمام المستوى بنجاح',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أحمد ناصر',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اللغة B1',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'B1',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAchievementLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: AppColors.success, size: 22),
          const SizedBox(width: 10),
          Text(
            'إنجاز رائع',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildShareButton() {
    return GradientButton(
      text: 'مشاركة الشهادة',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ الرابط. يمكنك مشاركة الشهادة الآن.'),
          ),
        );
      },
      gradient: AppColors.primaryGradient,
      icon: Icons.share,
      width: double.infinity,
      borderRadius: 16,
      glowColor: AppColors.glowPrimary,
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, delay: 700.ms);
  }

  Widget _buildChampionBadge() {
    return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.military_tech,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'B1 Champion',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'أكملت المستوى B1 بنجاح',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 800.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          delay: 800.ms,
          curve: Curves.easeOutBack,
        );
  }
}
