import '../entities/achievement.dart';

class AchievementService {
  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_lesson',
        title: 'First Step',
        description: 'Complete your first lesson',
        icon: '🎯',
        type: AchievementType.lessonsCompleted,
        requirementValue: 1,
        rewardXp: 25,
      ),
      Achievement(
        id: 'five_lessons',
        title: 'Getting Started',
        description: 'Complete 5 lessons',
        icon: '📚',
        type: AchievementType.lessonsCompleted,
        requirementValue: 5,
        rewardXp: 50,
      ),
      Achievement(
        id: 'ten_lessons',
        title: 'Dedicated Learner',
        description: 'Complete 10 lessons',
        icon: '🌟',
        type: AchievementType.lessonsCompleted,
        requirementValue: 10,
        rewardXp: 100,
      ),
      Achievement(
        id: 'twenty_five_lessons',
        title: 'Knowledge Seeker',
        description: 'Complete 25 lessons',
        icon: '🏆',
        type: AchievementType.lessonsCompleted,
        requirementValue: 25,
        rewardXp: 200,
      ),
      Achievement(
        id: 'fifty_lessons',
        title: 'Master Student',
        description: 'Complete 50 lessons',
        icon: '👑',
        type: AchievementType.lessonsCompleted,
        requirementValue: 50,
        rewardXp: 500,
      ),
      Achievement(
        id: 'first_100_xp',
        title: 'XP Collector',
        description: 'Earn 100 XP',
        icon: '⭐',
        type: AchievementType.xpEarned,
        requirementValue: 100,
        rewardXp: 25,
      ),
      Achievement(
        id: 'xp_500',
        title: 'XP Hunter',
        description: 'Earn 500 XP',
        icon: '💫',
        type: AchievementType.xpEarned,
        requirementValue: 500,
        rewardXp: 100,
      ),
      Achievement(
        id: 'xp_1000',
        title: 'XP Master',
        description: 'Earn 1000 XP',
        icon: '✨',
        type: AchievementType.xpEarned,
        requirementValue: 1000,
        rewardXp: 200,
      ),
      Achievement(
        id: 'level_a2',
        title: 'Moving Up',
        description: 'Reach level A2',
        icon: '📈',
        type: AchievementType.levelReached,
        requirementValue: 500,
        rewardXp: 100,
      ),
      Achievement(
        id: 'level_b1',
        title: 'Halfway There',
        description: 'Reach level B1',
        icon: '🎓',
        type: AchievementType.levelReached,
        requirementValue: 1000,
        rewardXp: 200,
      ),
      Achievement(
        id: 'level_b2',
        title: 'Advanced',
        description: 'Reach level B2',
        icon: '🏅',
        type: AchievementType.levelReached,
        requirementValue: 1500,
        rewardXp: 300,
      ),
      Achievement(
        id: 'streak_3',
        title: 'Consistent',
        description: 'Maintain a 3-day streak',
        icon: '🔥',
        type: AchievementType.streakDays,
        requirementValue: 3,
        rewardXp: 30,
      ),
      Achievement(
        id: 'streak_7',
        title: 'On Fire',
        description: 'Maintain a 7-day streak',
        icon: '🔥🔥',
        type: AchievementType.streakDays,
        requirementValue: 7,
        rewardXp: 75,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Unstoppable',
        description: 'Maintain a 30-day streak',
        icon: '🔥🔥🔥',
        type: AchievementType.streakDays,
        requirementValue: 30,
        rewardXp: 300,
      ),
      Achievement(
        id: 'quiz_perfect',
        title: 'Perfect Score',
        description: 'Get 100% on any quiz',
        icon: '💯',
        type: AchievementType.quizPerfect,
        requirementValue: 1,
        rewardXp: 50,
      ),
    ];
  }

  static List<Achievement> updateAchievementProgress(
    List<Achievement> achievements, {
    int? lessonsCompleted,
    int? totalXp,
    int? currentLevelXp,
    int? currentStreak,
    int? perfectQuizzes,
  }) {
    return achievements.map((achievement) {
      int newProgress = achievement.progress;
      switch (achievement.type) {
        case AchievementType.lessonsCompleted:
          newProgress = lessonsCompleted ?? achievement.progress;
          break;
        case AchievementType.xpEarned:
          newProgress = totalXp ?? achievement.progress;
          break;
        case AchievementType.levelReached:
          newProgress = currentLevelXp ?? achievement.progress;
          break;
        case AchievementType.streakDays:
          newProgress = currentStreak ?? achievement.progress;
          break;
        case AchievementType.quizPerfect:
          newProgress = perfectQuizzes ?? achievement.progress;
          break;
        case AchievementType.categoryMaster:
          break;
      }

      final isNowComplete = newProgress >= achievement.requirementValue;
      final wasComplete = achievement.progress >= achievement.requirementValue;

      if (isNowComplete && !wasComplete) {
        return achievement.copyWith(
          progress: newProgress,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }

      return achievement.copyWith(progress: newProgress);
    }).toList();
  }
}
