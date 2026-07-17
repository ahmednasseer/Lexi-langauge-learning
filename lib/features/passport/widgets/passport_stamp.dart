import 'package:flutter/material.dart';
import '../models/passport.dart';

class PassportStamp extends StatelessWidget {
  final PassportLevel level;

  const PassportStamp({super.key, required this.level});

  Color _getStampColor() {
    if (level.isCompleted) return Colors.green;
    if (level.isUnlocked) return Colors.blue;
    return Colors.grey;
  }

  IconData _getStampIcon() {
    if (level.isCompleted) return Icons.check_circle;
    if (level.isUnlocked) return Icons.lock_open;
    return Icons.lock;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStampColor().withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Stamp circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStampColor().withValues(alpha: 0.2),
              border: Border.all(
                color: _getStampColor(),
                width: 3,
              ),
            ),
            child: Icon(
              _getStampIcon(),
              color: _getStampColor(),
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      level.level,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getStampColor(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      level.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  level.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                if (level.isUnlocked && !level.isCompleted) ...[
                  const SizedBox(height: 8),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: level.progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(_getStampColor()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(level.progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStampColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${level.lessonsCompleted}/${level.totalLessons} lessons',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Stamp status
          if (level.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'COMPLETED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else if (level.isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'IN PROGRESS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
