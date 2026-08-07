import 'package:flutter/material.dart';
import '../community_controller.dart';
import '../models/community_post.dart';
import 'post_card.dart';

class FeedTab extends StatelessWidget {
  final CommunityController controller;

  const FeedTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create post
          _buildCreatePost(context),

          const SizedBox(height: 16),

          // Leaderboard preview
          _buildLeaderboardPreview(),

          const SizedBox(height: 16),

          // Posts
          const Text(
            'Recent Posts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...controller.posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PostCard(
                post: post,
                onLike: () => controller.togglePostLike(post.id),
                onComment: () => _showCommentDialog(context, post.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCreatePost(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreatePostDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.blue.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Share your progress...',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.camera_alt, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardPreview() {
    final top3 = controller.leaderboard.take(3).toList();
    if (top3.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Top Learners This Week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (top3.length > 1) _buildTopUser(top3[1], '🥈', 2),
              _buildTopUser(top3[0], '🥇', 1),
              if (top3.length > 2) _buildTopUser(top3[2], '🥉', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUser(dynamic user, String medal, int rank) {
    return Column(
      children: [
        Container(
          width: rank == 1 ? 60 : 50,
          height: rank == 1 ? 60 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              medal,
              style: TextStyle(fontSize: rank == 1 ? 28 : 22),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '${user.xp} XP',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share with Community'),
        content: TextField(
          controller: textController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What did you learn today?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.addPost(textController.text, PostType.discussion);
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String postId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Write a comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.addComment(postId, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Comment'),
          ),
        ],
      ),
    );
  }
}
