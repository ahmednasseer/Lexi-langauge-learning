import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../shared/widgets/widgets.dart';
import 'ai_coach_controller.dart';
import 'package:lexi/features/ai_coach/models/conversation_category.dart';
import 'widgets/category_card.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final AiCoachController _controller = AiCoachController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showCategories = true;
  bool _initError = false;
  @override
  void initState() {
    super.initState();
    _initializeCoach();
    _controller.addListener(_onControllerUpdate);
  }

  Future<void> _initializeCoach() async {
    setState(() => _initError = false);
    try {
      await _controller.init();
    } catch (e) {
      if (mounted) setState(() => _initError = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    _messageController.clear();
    setState(() => _showCategories = false);
    await _controller.sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_showCategories && _controller.history.isEmpty) ...[
              _buildCategories(),
              _buildPracticeOptions(),
            ],
            Expanded(child: _buildChatArea()),
            _buildQuickActionChips(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'محرر الذكي',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
          ).animate().scale(delay: 200.ms, begin: const Offset(0.5, 0.5)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'اختر موضوعاً',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ConversationCategory.categories.length,
              itemBuilder: (context, index) {
                final category = ConversationCategory.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CategoryCard(
                    category: category,
                    isSelected: _controller.selectedCategory?.id == category.id,
                    onTap: () {
                      _controller.selectCategory(category);
                      setState(() => _showCategories = false);
                      _controller.sendMessage(
                        'Let\'s practice ${category.name}',
                      );
                    },
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 80),
                  duration: 400.ms,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بدء سريع',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildQuickOption('☕', 'مطعم'),
              _buildQuickOption('✈️', 'سفر'),
              _buildQuickOption('💼', 'عمل'),
              _buildQuickOption('🗣️', 'محادثة حرة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOption(String icon, String label) {
    return GestureDetector(
      onTap: () {
        final category = ConversationCategory.categories.firstWhere(
          (c) => c.name == label,
          orElse: () => ConversationCategory.categories.last,
        );
        _controller.selectCategory(category);
        setState(() => _showCategories = false);
        _controller.sendMessage('Let\'s practice $label');
      },
      child: GlowCard(
        glowColor: AppColors.primary,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
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
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
    );
  }

  Widget _buildChatArea() {
    if (_initError && _controller.history.isEmpty) {
      return ErrorState(
        message: 'Failed to load your coach. Please try again.',
        onRetry: _initializeCoach,
      );
    }
    if (_controller.history.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _controller.history.length + (_controller.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _controller.history.length) {
          return _buildLoadingIndicator();
        }
        final message = _controller.history[index];
        return _buildMessageBubble(message, index)
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: index * 50),
              duration: 400.ms,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: index * 50),
              duration: 400.ms,
            );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 60)),
            ),
          ).animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 600.ms,
            delay: 200.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 24),
          Text(
            'محرر الذكي',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            'اختر موضوعاً أو ابدأ بالكتابة',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, int index) {
    final bool isUser = message.isUser;
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message.content,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    if (message.xpEarned != null &&
                        message.xpEarned! > 0 &&
                        !message.hasCorrection) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${message.xpEarned} XP',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          GlowCard(
            glowColor: AppColors.primary,
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 2 - 1).clamp(0.0, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionChips() {
    if (_controller.history.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildChip('محادثة', Icons.chat_bubble_outline_rounded),
          const SizedBox(width: 8),
          _buildChip('قواعد', Icons.menu_book_outlined),
          const SizedBox(width: 8),
          _buildChip('قصص', Icons.auto_stories_outlined),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        final categoryMap = {
          'محادثة': 'free',
          'قواعد': 'grammar',
          'قصص': 'daily',
        };
        final catId = categoryMap[label] ?? 'free';
        final category = ConversationCategory.categories.firstWhere(
          (c) => c.id == catId,
          orElse: () => ConversationCategory.categories.last,
        );
        _controller.selectCategory(category);
        setState(() => _showCategories = false);
        _controller.sendMessage('Let\'s practice $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 16),
            const SizedBox(width: 6),
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_controller.remainingMessages < 5) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.warningGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_controller.remainingMessages} رسائل متبقية اليوم',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_controller.isListening) {
                    _controller.stopSpeaking();
                  } else {
                    _controller.startSpeaking();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _controller.isListening
                        ? AppColors.errorGradient
                        : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_controller.isListening
                                    ? AppColors.error
                                    : AppColors.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: _controller.isListening ? 15 : 8,
                        spreadRadius: _controller.isListening ? 3 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _controller.isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.poppins(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _controller.isLoading ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _controller.isLoading
                        ? null
                        : AppColors.primaryGradient,
                    color: _controller.isLoading
                        ? AppColors.surfaceLight
                        : null,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _controller.isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                  ),
                  child: Center(
                    child: _controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}
