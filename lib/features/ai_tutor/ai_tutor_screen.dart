import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_service.dart';
import '../../features/ai_tutor/chat_model.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _ai = AiService();
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: '0',
      content: 'Hello! 👋 I\'m your AI language tutor.\n\nI can help you:\n• Practice conversations\n• Correct your grammar\n• Explain rules\n• Suggest exercises\n\nWhat would you like to practice?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_msgController.text.trim().isEmpty) return;
    if (!_ai.canSendMessages) {
      _showLimitDialog();
      return;
    }

    final text = _msgController.text.trim();
    _msgController.clear();

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _loading = true;
    });
    _scroll();

    try {
      final response = await _ai.sendMessage(
        message: text,
        learningLanguage: 'English',
        nativeLanguage: 'Arabic',
      );
      setState(() {
        _messages.add(response);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _loading = false;
      });
    }
    _scroll();
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Daily Limit Reached', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'You\'ve used all ${_ai.dailyLimit} free AI messages today. Upgrade to Premium for unlimited messages!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Later')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); /* Navigate to subscription */ },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Upgrade', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _header(),
          _usageBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _typing();
                return _bubble(_messages[i], i);
              },
            ),
          ),
          _input(),
        ]),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Tutor', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Online', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.success)),
            ]),
          ]),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _messages.clear();
              _messages.add(ChatMessage(
                id: '0',
                content: 'Hello! 👋 How can I help you today?',
                isUser: false,
                timestamp: DateTime.now(),
              ));
            });
          },
          icon: const Icon(Icons.refresh),
        ),
      ]),
    );
  }

  Widget _usageBar() {
    final remaining = _ai.remainingMessages;
    final limit = _ai.dailyLimit;
    final isUnlimited = remaining == -1;
    final percentage = isUnlimited ? 1.0 : remaining / limit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            isUnlimited ? 'Premium: Unlimited messages' : '$remaining / $limit messages remaining',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
          ),
          const Spacer(),
          if (!isUnlimited)
            SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  percentage > 0.3 ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage m, int i) {
    final isUser = m.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Text(
                m.content,
                style: GoogleFonts.poppins(fontSize: 14, color: isUser ? Colors.white : AppColors.textPrimary, height: 1.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${m.timestamp.hour}:${m.timestamp.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: i * 50)).slideY(begin: 0.1);
  }

  Widget _typing() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Container(
            width: 8, height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 300.ms,
            delay: Duration(milliseconds: i * 150),
          )),
        ),
      ),
    );
  }

  Widget _input() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
      color: AppColors.surface,
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(24)),
            child: TextField(
              controller: _msgController,
              enabled: _ai.canSendMessages,
              decoration: InputDecoration(
                hintText: _ai.canSendMessages ? 'Type your message...' : 'Daily limit reached',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: IconButton(
            onPressed: (_loading || !_ai.canSendMessages) ? null : _send,
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
