import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/state_widgets.dart';
import 'models/gamification_models.dart';
import 'models/seasonal_event.dart';
import 'models/premium_conversion.dart';
import 'growth_controller.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final GrowthController _controller = GrowthController();
  bool _initialized = false;
  bool _initError = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    setState(() {
      _initError = false;
      _initialized = false;
    });
    try {
      await _controller.initialize('current_user');
    } catch (e) {
      if (!mounted) return;
      setState(() => _initError = true);
      return;
    }
    if (!mounted) return;
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: Text(
          'Growth Center',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_initialized
          ? (_initError
              ? ErrorState(
                  message: 'Failed to load growth data. Please try again.',
                  onRetry: _initializeController,
                )
              : const LoadingState(message: 'Loading growth data...'))
          : RefreshIndicator(
              color: const Color(0xFF6C63FF),
              onRefresh: () async {
                try {
                  await _controller.initialize('current_user');
                  if (mounted) setState(() => _initError = false);
                } catch (e) {
                  if (mounted) setState(() => _initError = true);
                }
              },
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Referral', Icons.card_giftcard),
          _buildTab(1, 'Levels', Icons.trending_up),
          _buildTab(2, 'Events', Icons.celebration),
          _buildTab(3, 'Premium', Icons.diamond),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildReferralTab();
      case 1:
        return _buildLevelsTab();
      case 2:
        return _buildEventsTab();
      case 3:
        return _buildPremiumTab();
      default:
        return _buildReferralTab();
    }
  }

  Widget _buildReferralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Referral Code Card
          _buildReferralCodeCard(),
          const SizedBox(height: 20),
          // Stats
          _buildReferralStats(),
          const SizedBox(height: 20),
          // How it works
          _buildHowItWorks(),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    final code = _controller.referralCode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Invite Friends',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your code and earn rewards!',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              code?.code ?? 'Loading...',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRewardChip('💎', '500 Gems'),
              const SizedBox(width: 12),
              _buildRewardChip('✨', '7 Days Premium'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildRewardChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralStats() {
    final stats = _controller.referralStats;
    return Row(
      children: [
        _buildStatCard('Total Invites', '${stats.totalReferrals}', Icons.people, const Color(0xFF6C63FF)),
        const SizedBox(width: 12),
        _buildStatCard('Gems Earned', '${stats.totalGemsEarned}', Icons.diamond, const Color(0xFFFF9800)),
        const SizedBox(width: 12),
        _buildStatCard('Premium Days', '${stats.totalPremiumDaysEarned}', Icons.diamond, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildStep(1, 'Share your code', 'Send your referral code to friends'),
        _buildStep(2, 'Friend signs up', 'They create an account using your code'),
        _buildStep(3, 'Both earn rewards', 'You get 500 gems + 7 days Premium!'),
      ],
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Level
          _buildCurrentLevelCard(),
          const SizedBox(height: 20),
          // Levels List
          Text(
            'All Levels',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._controller.allLevels.map((level) => _buildLevelCard(level)),
        ],
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    final progress = _controller.userProgress;
    final currentLevel = _controller.allLevels.firstWhere(
      (l) => l.level == progress.currentLevel,
      orElse: () => _controller.allLevels.first,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Level ${currentLevel.level}',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            currentLevel.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: currentLevel.progress(progress.totalXp),
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.totalXp} / ${currentLevel.maxXp} XP',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildLevelCard(UserLevel level) {
    final progress = _controller.userProgress;
    final isUnlocked = level.isUnlocked(progress.totalXp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF1A1A2E) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF6C63FF).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFF6C63FF).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                '${level.level}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? const Color(0xFF6C63FF) : Colors.white54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.title,
                  style: GoogleFonts.poppins(
                    color: isUnlocked ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${level.minXp} XP required',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (level.reward.gems > 0)
            _buildRewardChip('💎', '${level.reward.gems}'),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seasonal Events',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._controller.seasonalEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(SeasonalEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.isActive ? 'Active' : 'Upcoming',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: event.isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          // Progress
          if (event.isJoined) ...[
            LinearProgressIndicator(
              value: event.overallProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(event.overallProgress * 100).toInt()}% Complete',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Goals
          ...event.goals.map((goal) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  goal.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: goal.isCompleted ? Colors.green : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${goal.currentValue}/${goal.targetValue} ${goal.unit}',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          // Reward
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFF9800), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reward: ${event.reward.xp} XP + ${event.reward.gems} Gems',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!event.isJoined && event.canJoin)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _controller.joinEvent(event.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Joined event!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Join Event',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildPremiumTab() {
    final paywall = _controller.paywall;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Free Trial Card
          _buildFreeTrialCard(),
          const SizedBox(height: 20),
          // Premium Features
          _buildPremiumFeatures(paywall),
          const SizedBox(height: 20),
          // Pricing
          _buildPricingCards(),
        ],
      ),
    );
  }

  Widget _buildFreeTrialCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            '7-Day Free Trial',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try Premium features absolutely free!',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _controller.startFreeTrial('current_user');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Free trial started!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Free Trial',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildPremiumFeatures(SmartPaywall? paywall) {
    final features = paywall?.features ?? [
      'Unlimited AI conversations',
      'All lesson levels (A1-C2)',
      'Advanced Speaking Lab',
      'Goethe exam preparation',
      'Priority support',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPricingCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildPricingCard(PremiumPlan.monthly),
        const SizedBox(height: 12),
        _buildPricingCard(PremiumPlan.yearly, isRecommended: true),
        const SizedBox(height: 12),
        _buildPricingCard(PremiumPlan.lifetime),
      ],
    );
  }

  Widget _buildPricingCard(PremiumPlan plan, {bool isRecommended = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended ? const Color(0xFF6C63FF).withValues(alpha: 0.2) : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.1),
          width: isRecommended ? 2 : 1,
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
                      plan.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Best Value',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '\$${plan.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                if (plan.discountPercent > 0)
                  Text(
                    'Save ${plan.discountPercent}%',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecommended ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Subscribe',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
