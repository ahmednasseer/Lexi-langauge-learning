import 'package:flutter/material.dart';
import '../models/certificate.dart';

class CertificateCard extends StatelessWidget {
  final Certificate certificate;

  const CertificateCard({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Certificate header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'CERTIFICATE OF COMPLETION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Certificate content
          const Text(
            'This certifies that',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),

          const SizedBox(height: 8),

          Text(
            certificate.userName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'has successfully completed',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              certificate.levelDisplay,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('⭐', '${certificate.totalXp}', 'Total XP'),
              _buildStat('📚', '${certificate.lessonsCompleted}', 'Lessons'),
              _buildStat('📝', '${certificate.vocabularyLearned}', 'Words'),
              _buildStat('🎯', '${certificate.averageScore.round()}%', 'Score'),
            ],
          ),

          const SizedBox(height: 24),

          // Certificate details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Issued:',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      certificate.formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Certificate ID:',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      certificate.certificateCode,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Language badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇩🇪', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'German - ${certificate.level}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

  Widget _buildStat(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }
}
