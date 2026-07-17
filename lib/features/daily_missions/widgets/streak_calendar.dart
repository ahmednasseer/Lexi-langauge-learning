import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StreakCalendar extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final List<DateTime> activeDays;

  const StreakCalendar({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currentStreak Day Streak',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Best: $bestStreak days',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalendarGrid(),
          const SizedBox(height: 20),
          _buildMilestones(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday % 7;

    return Column(
      children: [
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        for (int week = 0; week < 5; week++)
          Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = week * 7 + dayIndex - firstDayOfWeek + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final date = DateTime(now.year, now.month, dayNumber);
              final isActive = activeDays.any((d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day);
              final isToday = date.day == now.day;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.orange
                        : isToday
                            ? Colors.orange.shade100
                            : Colors.transparent,
                    border: isToday && !isActive
                        ? Border.all(color: Colors.orange, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : isToday
                                ? Colors.orange
                                : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildMilestones() {
    final milestones = [
      {'days': 7, 'label': '7 Days', 'icon': '🥉', 'color': Colors.brown},
      {'days': 30, 'label': '30 Days', 'icon': '🥈', 'color': Colors.grey},
      {'days': 100, 'label': '100 Days', 'icon': '🥇', 'color': Colors.amber},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: milestones.map((m) {
        final isAchieved = currentStreak >= (m['days'] as int);
        final color = m['color'] as Color;
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAchieved ? color.withValues(alpha: 0.2) : AppColors.border,
                border: Border.all(
                  color: isAchieved ? color : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  m['icon'] as String,
                  style: TextStyle(fontSize: 24, color: isAchieved ? color : AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              m['label'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAchieved ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
            if (isAchieved)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        );
      }).toList(),
    );
  }
}
