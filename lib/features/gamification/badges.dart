import '../../shared/models/achievement_model.dart';

class BadgeRepository {
  static List<AchievementModel> getDefaultBadges() => [
    AchievementModel(
      id: '1',
      title: 'First Steps',
      description: 'Complete your first lesson',
      icon: '🌟',
      type: AchievementType.lessons,
      targetValue: 1,
      isUnlocked: true,
    ),
    AchievementModel(
      id: '2',
      title: 'Word Collector',
      description: 'Learn 50 words',
      icon: '📚',
      type: AchievementType.words,
      targetValue: 50,
      isUnlocked: true,
    ),
    AchievementModel(
      id: '3',
      title: 'Streak Master',
      description: '7 day streak',
      icon: '🔥',
      type: AchievementType.streak,
      targetValue: 7,
      isUnlocked: true,
    ),
    AchievementModel(
      id: '4',
      title: 'Quiz Champion',
      description: 'Score 100% on a quiz',
      icon: '🏆',
      type: AchievementType.quiz,
      targetValue: 1,
      isUnlocked: false,
    ),
    AchievementModel(
      id: '5',
      title: 'Conversation Starter',
      description: 'Chat with AI 10 times',
      icon: '💬',
      type: AchievementType.chat,
      targetValue: 10,
      isUnlocked: false,
    ),
    AchievementModel(
      id: '6',
      title: 'Pronunciation Pro',
      description: 'Score 90%+ pronunciation',
      icon: '🎤',
      type: AchievementType.pronunciation,
      targetValue: 90,
      isUnlocked: false,
    ),
  ];
}
