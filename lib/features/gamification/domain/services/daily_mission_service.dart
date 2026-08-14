import '../entities/daily_mission.dart';

class DailyMissionService {
  static List<DailyMission> generateDailyMissions(
    String userId,
    DateTime date,
  ) {
    final dateStr = _formatDate(date);
    return [
      DailyMission(
        id: '${userId}_${dateStr}_lesson_1',
        title: 'Complete 1 Lesson',
        description: 'Finish any lesson today',
        type: MissionType.completeLessons,
        target: 1,
        rewardXp: 25,
        date: date,
        icon: '📚',
      ),
      DailyMission(
        id: '${userId}_${dateStr}_xp_50',
        title: 'Earn 50 XP',
        description: 'Earn at least 50 XP today',
        type: MissionType.earnXp,
        target: 50,
        rewardXp: 20,
        date: date,
        icon: '⭐',
      ),
      DailyMission(
        id: '${userId}_${dateStr}_quiz_5',
        title: 'Answer 5 Questions',
        description: 'Answer 5 quiz questions',
        type: MissionType.answerQuestions,
        target: 5,
        rewardXp: 15,
        date: date,
        icon: '🎯',
      ),
    ];
  }

  static List<DailyMission> updateMissionProgress(
    List<DailyMission> missions, {
    int? lessonsCompleted,
    int? xpEarned,
    int? questionsAnswered,
    int? quizzesCompleted,
    int? streakDays,
  }) {
    return missions.map((mission) {
      int newProgress = mission.currentProgress;

      switch (mission.type) {
        case MissionType.completeLessons:
          newProgress = lessonsCompleted ?? mission.currentProgress;
          break;
        case MissionType.earnXp:
          newProgress = xpEarned ?? mission.currentProgress;
          break;
        case MissionType.answerQuestions:
          newProgress = questionsAnswered ?? mission.currentProgress;
          break;
        case MissionType.completeQuiz:
          newProgress = quizzesCompleted ?? mission.currentProgress;
          break;
        case MissionType.maintainStreak:
          newProgress = streakDays ?? mission.currentProgress;
          break;
      }

      final isNowComplete = newProgress >= mission.target;
      final wasComplete = mission.currentProgress >= mission.target;

      if (isNowComplete && !wasComplete) {
        return mission.copyWith(
          currentProgress: newProgress,
          isCompleted: true,
        );
      }

      return mission.copyWith(currentProgress: newProgress);
    }).toList();
  }

  static bool isMissionForDate(DailyMission mission, DateTime date) {
    return mission.date.year == date.year &&
        mission.date.month == date.month &&
        mission.date.day == date.day;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
