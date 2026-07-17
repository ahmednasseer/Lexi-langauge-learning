import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreCard extends StatefulWidget {
  final double accuracy;
  final double fluency;
  final double grammar;
  final int xpEarned;
  final String feedback;
  final bool isPerfect;

  const ScoreCard({
    super.key,
    required this.accuracy,
    required this.fluency,
    required this.grammar,
    required this.xpEarned,
    required this.feedback,
    this.isPerfect = false,
  });

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isPerfect
                  ? [Colors.amber.shade100, Colors.orange.shade100]
                  : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.isPerfect
                    ? Colors.amber.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(widget.accuracy * _scoreAnimation.value),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _getGrade(widget.accuracy * _scoreAnimation.value),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(widget.accuracy),
                        ),
                      ),
                      Text(
                        '${(widget.accuracy * _scoreAnimation.value).round()}%',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                widget.feedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isPerfect ? Colors.amber.shade700 : Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 24),
              _buildScoreBar('Accuracy', widget.accuracy, _scoreAnimation.value),
              const SizedBox(height: 12),
              _buildScoreBar('Fluency', widget.fluency, _scoreAnimation.value),
              const SizedBox(height: 12),
              _buildScoreBar('Grammar', widget.grammar, _scoreAnimation.value),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.xpEarned} XP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isPerfect) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'PERFECT SCORE!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBar(String label, double value, double animationValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            Text(
              '${(value * animationValue).round()}%',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getScoreColor(value)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (value / 100) * animationValue,
            minHeight: 12,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
          ),
        ),
      ],
    );
  }
}
