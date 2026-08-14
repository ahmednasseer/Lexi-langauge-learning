import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/like_cubit.dart';
import '../bloc/comment_cubit.dart';

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<FeedCubit>()),
        BlocProvider(create: (_) => getIt<LikeCubit>()),
        BlocProvider(create: (_) => getIt<CommentCubit>()),
      ],
      child: const _SocialFeedView(),
    );
  }
}

class _SocialFeedView extends StatefulWidget {
  const _SocialFeedView();

  @override
  State<_SocialFeedView> createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<_SocialFeedView> {
  final _postController = TextEditingController();
  final _commentController = TextEditingController();
  String? _selectedPostId;

  @override
  void initState() {
    super.initState();
    context.read<FeedCubit>().loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await context.read<FeedCubit>().createPost(
      authorId: user.uid,
      authorName: user.displayName ?? 'User',
      authorAvatar: user.photoURL,
      content: content,
    );

    _postController.clear();
  }

  Future<void> _toggleLike(String postId) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await context.read<LikeCubit>().toggleLike(postId, user.uid);
    context.read<FeedCubit>().loadPosts();
  }

  Future<void> _addComment(String postId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await context.read<CommentCubit>().addComment(
      postId: postId,
      userId: user.uid,
      username: user.displayName ?? 'User',
      avatar: user.photoURL,
      text: text,
    );

    _commentController.clear();
    setState(() => _selectedPostId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCreatePost(),
            Expanded(
              child: BlocBuilder<FeedCubit, FeedState>(
                builder: (context, state) {
                  if (state is FeedLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FeedError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    );
                  }
                  if (state is FeedLoaded) {
                    if (state.posts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildFeedList(state.posts);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Community',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Social',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePost() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _postController,
            maxLines: 3,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Share something with the community...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Post',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList(List<Post> posts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) => _buildPostCard(posts[index]),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  post.authorName.isNotEmpty
                      ? post.authorName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      post.isLikedByCurrentUser
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.isLikedByCurrentUser
                          ? AppColors.error
                          : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPostId = _selectedPostId == post.id
                        ? null
                        : post.id;
                  });
                  if (_selectedPostId == post.id) {
                    context.read<CommentCubit>().loadComments(post.id);
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentsCount}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedPostId == post.id) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            BlocBuilder<CommentCubit, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CommentLoaded) {
                  return Column(
                    children: [
                      ...state.comments.map(
                        (comment) => _buildCommentItem(comment),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textHint,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _addComment(post.id),
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.username,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(comment.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment.text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
