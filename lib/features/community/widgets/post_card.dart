import 'package:flutter/material.dart';
import '../models/community_post.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
  });

  Color _getTypeColor() {
    switch (post.type) {
      case PostType.achievement:
        return Colors.amber;
      case PostType.question:
        return Colors.blue;
      case PostType.challenge:
        return Colors.green;
      case PostType.discussion:
        return Colors.purple;
      case PostType.tip:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon() {
    switch (post.type) {
      case PostType.achievement:
        return Icons.emoji_events;
      case PostType.question:
        return Icons.question_answer;
      case PostType.challenge:
        return Icons.local_fire_department;
      case PostType.discussion:
        return Icons.forum;
      case PostType.tip:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.userName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.userLevel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${post.userXp} XP',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getTypeIcon(), size: 12, color: _getTypeColor()),
                    const SizedBox(width: 4),
                    Text(
                      post.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              // Like button
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: post.isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: post.isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Comment button
              GestureDetector(
                onTap: onComment,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentsCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Time
              Text(
                _formatTime(post.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}';
  }
}
