import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/widgets/state_widgets.dart';
import 'friends_repository.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendsRepository _repo = FriendsRepository();
  List<_FriendData> _friends = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _repo.getFriends();
      if (mounted) {
        setState(() {
          _friends = users
              .map(
                (u) => _FriendData(
                  name: u.name,
                  status: u.isPremium
                      ? 'مميز'
                      : (u.streak > 0 ? 'متصل' : 'غير متصل'),
                  isOnline: u.streak > 0,
                  avatar: _avatarFor(u.name),
                ),
              )
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
      if (mounted) {
        setState(() {
          _error = 'تعذر تحميل قائمة الأصدقاء. تأكد من اتصالك بالإنترنت.';
          _isLoading = false;
        });
      }
    }
  }

  String _avatarFor(String name) {
    final emojis = ['👩', '👦', '👧', '🧑', '👨', '👱'];
    final code = name.codeUnits.fold(0, (a, b) => a + b);
    return emojis[code % emojis.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildFriendCount(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const LoadingState(message: 'Loading friends...')
                  : _error != null
                  ? ErrorState(message: _error!, onRetry: _load)
                  : _friends.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No Friends Yet',
                      subtitle: 'Add friends to practice together',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _friends.length,
                      itemBuilder: (context, index) =>
                          _buildFriendCard(_friends[index], index),
                    ),
            ),
            _buildAddFriendButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 8),
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
              'ارتداءة الصداقة',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildFriendCount() {
    final onlineCount = _friends.where((f) => f.isOnline).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '$onlineCount من الأصدقاء متصلين',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildFriendCard(_FriendData friend, int index) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlowCard(
            glowColor: friend.isOnline ? AppColors.success : AppColors.border,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: friend.isOnline
                            ? AppColors.primaryGradient
                            : null,
                        color: friend.isOnline ? null : AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: friend.isOnline
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          friend.avatar,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: friend.isOnline
                              ? AppColors.success
                              : AppColors.textHint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: friend.isOnline
                                  ? AppColors.success
                                  : AppColors.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            friend.status,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: friend.isOnline
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + index * 100))
        .slideX(begin: 0.15);
  }

  Widget _buildAddFriendButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlowCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.all(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text(
              'إضافة صديق',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _FriendData {
  final String name;
  final String status;
  final bool isOnline;
  final String avatar;

  const _FriendData({
    required this.name,
    required this.status,
    required this.isOnline,
    required this.avatar,
  });
}
