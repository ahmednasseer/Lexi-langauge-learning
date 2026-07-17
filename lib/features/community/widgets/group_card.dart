import 'package:flutter/material.dart';
import '../models/community_group.dart';

class GroupCard extends StatelessWidget {
  final CommunityGroup group;
  final VoidCallback? onJoin;

  const GroupCard({
    super.key,
    required this.group,
    this.onJoin,
  });

  Color _getLevelColor() {
    switch (group.level) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.blue;
      case 'B1':
        return Colors.orange;
      case 'B2':
        return Colors.red;
      case 'C1':
        return Colors.purple;
      case 'C2':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: group.isJoined
            ? Border.all(color: Colors.blue.shade200, width: 2)
            : null,
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
          Row(
            children: [
              // Group icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getLevelColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group,
                  color: _getLevelColor(),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLevelColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group.level,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getLevelColor(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Join button
              if (group.isJoined)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Joined',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            group.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              _buildStat(Icons.article, '${group.postCount} posts'),
              const SizedBox(width: 16),
              _buildStat(Icons.people, '${group.memberCount} members'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
