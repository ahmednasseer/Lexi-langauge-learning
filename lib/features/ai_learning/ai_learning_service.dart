import 'dart:math';
import 'package:lexi/features/ai_learning/models/learning_profile.dart';

class AILearningService {
  final Random _random = Random();
  LearningProfile generateDefaultProfile(String userId) {
    return LearningProfile(
      userId: userId,
      currentLevel: 'A1',
      learningGoal: LearningGoal.conversation,
      dailyMinutes: 15,
      weakAreas: [],
      strongAreas: [],
      preferredTopics: ['Greetings', 'Numbers', 'Colors'],
      learningSpeed: LearningSpeed.normal,
      lastAnalysisDate: DateTime.now(),
      totalStudyHours: 0,
      currentStreak: 0,
      overallProgress: 0.0,
    );
  }

  LearningProfile analyzeAndUpdateProfile(
    LearningProfile profile, {
    required List<Map<String, dynamic>> quizResults,
    required List<Map<String, dynamic>> flashcardResults,
    required List<Map<String, dynamic>> speakingResults,
    required List<Map<String, dynamic>> aiConversationMistakes,
  }) {
    final Map<String, WeaknessArea> weaknesses = {};
    final Map<String, StrongArea> strengths = {};
    for (final quiz in quizResults) {
      final category = quiz['category'] ?? 'General';
      final correct = quiz['correct'] as bool? ?? false;
      final mistake = quiz['mistake'] as String?;
      if (correct) {
        strengths[category] = _updateStrongArea(
          strengths[category],
          category,
          'quiz',
        );
      } else if (mistake != null) {
        weaknesses[category] = _updateWeaknessArea(
          weaknesses[category],
          category,
          mistake,
        );
      }
    }
    for (final card in flashcardResults) {
      final word = card['word'] ?? '';
      final category = card['category'] ?? 'Vocabulary';
      final remembered = card['remembered'] as bool? ?? false;
      if (remembered) {
        strengths[category] = _updateStrongArea(
          strengths[category],
          category,
          'flashcard',
        );
      } else {
        weaknesses[category] = _updateWeaknessArea(
          weaknesses[category],
          category,
          'Forgot: $word',
        );
      }
    }
    for (final speaking in speakingResults) {
      final category = speaking['category'] ?? 'Speaking';
      final score = speaking['score'] as double? ?? 0.0;
      final mistakes = List<String>.from(speaking['mistakes'] ?? []);
      if (score >= 0.8) {
        strengths[category] = _updateStrongArea(
          strengths[category],
          category,
          'speaking',
        );
      } else {
        for (final mistake in mistakes) {
          weaknesses[category] = _updateWeaknessArea(
            weaknesses[category],
            category,
            mistake,
          );
        }
      }
    }
    for (final mistake in aiConversationMistakes) {
      final category = mistake['category'] ?? 'Grammar';
      final error = mistake['error'] ?? '';
      weaknesses[category] = _updateWeaknessArea(
        weaknesses[category],
        category,
        error,
      );
    }
    final sortedWeaknesses = weaknesses.values.toList()
      ..sort((a, b) => b.severity.compareTo(a.severity));
    final sortedStrengths = strengths.values.toList()
      ..sort((a, b) => b.mastery.compareTo(a.mastery));
    final totalAttempts = quizResults.length + flashcardResults.length;
    final correctAttempts =
        quizResults.where((q) => q['correct'] == true).length +
        flashcardResults.where((c) => c['remembered'] == true).length;
    final progress = totalAttempts > 0 ? correctAttempts / totalAttempts : 0.0;
    return profile.copyWith(
      weakAreas: sortedWeaknesses.take(5).toList(),
      strongAreas: sortedStrengths.take(5).toList(),
      lastAnalysisDate: DateTime.now(),
      overallProgress: progress,
    );
  }

  WeaknessArea _updateWeaknessArea(
    WeaknessArea? existing,
    String category,
    String mistake,
  ) {
    if (existing != null) {
      final newMistakeCount = existing.mistakeCount + 1;
      final newSeverity = min(1.0, existing.severity + 0.05);
      final newMistakes = List<String>.from(existing.commonMistakes);
      if (!newMistakes.contains(mistake) && newMistakes.length < 5) {
        newMistakes.add(mistake);
      }
      return WeaknessArea(
        category: category,
        subCategory: existing.subCategory,
        mistakeCount: newMistakeCount,
        severity: newSeverity,
        lastMistakeAt: DateTime.now(),
        commonMistakes: newMistakes,
      );
    }
    return WeaknessArea(
      category: category,
      subCategory: 'General',
      mistakeCount: 1,
      severity: 0.3,
      lastMistakeAt: DateTime.now(),
      commonMistakes: [mistake],
    );
  }

  StrongArea _updateStrongArea(
    StrongArea? existing,
    String category,
    String source,
  ) {
    if (existing != null) {
      final newCorrectCount = existing.correctCount + 1;
      final newMastery = min(1.0, existing.mastery + 0.05);
      return StrongArea(
        category: category,
        subCategory: existing.subCategory,
        correctCount: newCorrectCount,
        mastery: newMastery,
        lastPracticedAt: DateTime.now(),
      );
    }
    return StrongArea(
      category: category,
      subCategory: 'General',
      correctCount: 1,
      mastery: 0.3,
      lastPracticedAt: DateTime.now(),
    );
  }

  List<AIRecommendation> generateRecommendations(LearningProfile profile) {
    final recommendations = <AIRecommendation>[];
    int priority = 10;
    for (final weakness in profile.weakAreas.take(3)) {
      recommendations.add(
        AIRecommendation(
          id: 'rec_weak_${weakness.category}_${DateTime.now().millisecondsSinceEpoch}',
          userId: profile.userId,
          type: 'weakness_fix',
          title: 'Practice ${weakness.category}',
          description: _getWeaknessDescription(weakness),
          category: weakness.category,
          estimatedMinutes: _estimateMinutes(weakness.severity),
          priority: priority--,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (profile.strongAreas.isNotEmpty) {
      final weakestStrong = profile.strongAreas.last;
      if (weakestStrong.mastery < 0.8) {
        recommendations.add(
          AIRecommendation(
            id: 'rec_review_${DateTime.now().millisecondsSinceEpoch}',
            userId: profile.userId,
            type: 'review',
            title: 'Review ${weakestStrong.category}',
            description:
                'Maintain your progress in ${weakestStrong.category} with a quick review session.',
            category: weakestStrong.category,
            estimatedMinutes: 10,
            priority: priority--,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    final newTopics = _getNewTopicsForLevel(
      profile.currentLevel,
      profile.weakAreas,
    );
    if (newTopics.isNotEmpty) {
      recommendations.add(
        AIRecommendation(
          id: 'rec_new_${DateTime.now().millisecondsSinceEpoch}',
          userId: profile.userId,
          type: 'new_topic',
          title: 'Explore: ${newTopics.first}',
          description:
              'Ready to learn something new? Try ${newTopics.first} to expand your knowledge.',
          category: 'New Content',
          estimatedMinutes: 15,
          priority: priority--,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (profile.currentStreak > 0 && profile.currentStreak % 7 == 0) {
      recommendations.add(
        AIRecommendation(
          id: 'rec_challenge_${DateTime.now().millisecondsSinceEpoch}',
          userId: profile.userId,
          type: 'challenge',
          title: 'Weekly Challenge',
          description:
              'You\'ve been consistent for ${profile.currentStreak} days! Take on a challenge to test your skills.',
          category: 'Challenge',
          estimatedMinutes: 20,
          priority: 8,
          createdAt: DateTime.now(),
        ),
      );
    }
    recommendations.add(
      AIRecommendation(
        id: 'rec_daily_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.userId,
        type: 'daily',
        title: _getDailyRecommendationTitle(profile),
        description: _getDailyRecommendation(profile),
        category: 'Daily',
        estimatedMinutes: profile.dailyMinutes,
        priority: 5,
        createdAt: DateTime.now(),
      ),
    );
    return recommendations;
  }

  String _getWeaknessDescription(WeaknessArea weakness) {
    switch (weakness.category.toLowerCase()) {
      case 'articles':
        return 'You\'ve made ${weakness.mistakeCount} mistakes with German articles. Focus on der/die/das patterns.';
      case 'verb conjugation':
        return 'Practice verb conjugations to improve your sentence structure.';
      case 'cases':
        return 'Work on Nominative, Accusative, Dative, and Genitive cases.';
      case 'word order':
        return 'German word order can be tricky. Practice placing verbs correctly.';
      case 'vocabulary':
        return 'Review vocabulary in this category to strengthen your word bank.';
      case 'pronunciation':
        return 'Practice pronunciation to sound more natural in German.';
      case 'listening':
        return 'Improve your listening skills with targeted exercises.';
      default:
        return 'Focus on ${weakness.category} to improve your overall skills.';
    }
  }

  int _estimateMinutes(double severity) {
    if (severity >= 0.8) return 20;
    if (severity >= 0.6) return 15;
    if (severity >= 0.4) return 10;
    return 5;
  }

  List<String> _getNewTopicsForLevel(
    String level,
    List<WeaknessArea> weaknesses,
  ) {
    final allTopics = {
      'A1': ['Greetings', 'Numbers', 'Colors', 'Family', 'Food', 'Body Parts'],
      'A2': [
        'Shopping',
        'Travel',
        'Health',
        'Weather',
        'Hobbies',
        'Directions',
      ],
      'B1': [
        'Work',
        'Education',
        'Environment',
        'Technology',
        'Culture',
        'News',
      ],
      'B2': ['Politics', 'Science', 'Arts', 'Philosophy', 'Economics', 'Law'],
      'C1': [
        'Academic Writing',
        'Professional',
        'Literature',
        'Media',
        'Research',
      ],
      'C2': ['Idioms', 'Dialects', 'Advanced Grammar', 'Nuanced Expression'],
    };
    final currentTopics = allTopics[level] ?? allTopics['A1']!;
    final weakCategories = weaknesses
        .map((w) => w.category.toLowerCase())
        .toList();
    return currentTopics
        .where((topic) => !weakCategories.contains(topic.toLowerCase()))
        .toList();
  }

  String _getDailyRecommendationTitle(LearningProfile profile) {
    final titles = [
      'Start your German journey today!',
      'Time for a quick German practice!',
      'Keep your streak alive!',
      'Challenge yourself with German!',
      'Learn something new in German!',
    ];
    return titles[_random.nextInt(titles.length)];
  }

  String _getDailyRecommendation(LearningProfile profile) {
    if (profile.weakAreas.isNotEmpty) {
      final weakest = profile.weakAreas.first;
      return 'Spend ${profile.dailyMinutes} minutes practicing ${weakest.category}. You\'re making progress!';
    }
    return 'Practice German for ${profile.dailyMinutes} minutes today to maintain your streak!';
  }

  StudyPlan generateStudyPlan(LearningProfile profile) {
    final days = <StudyPlanDay>[];
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final activities = _getActivitiesForGoal(profile);
    int activityIndex = 0;
    for (final dayName in dayNames) {
      final dayActivities = <StudyPlanActivity>[];
      int remainingMinutes = profile.dailyMinutes;
      while (remainingMinutes > 0 && activityIndex < activities.length * 2) {
        final activity = activities[activityIndex % activities.length];
        final minutes = min(activity.minutes, remainingMinutes);
        dayActivities.add(
          StudyPlanActivity(
            type: activity.type,
            title: activity.title,
            minutes: minutes,
            description: activity.description,
          ),
        );
        remainingMinutes -= minutes;
        activityIndex++;
      }
      days.add(
        StudyPlanDay(
          dayName: dayName,
          activities: dayActivities,
          totalMinutes: profile.dailyMinutes - remainingMinutes,
        ),
      );
    }
    final goalTitle = profile.goalText;
    return StudyPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.userId,
      title: '$goalTitle - ${profile.currentLevel} Level',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      days: days,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  List<StudyPlanActivity> _getActivitiesForGoal(LearningProfile profile) {
    switch (profile.learningGoal) {
      case LearningGoal.goetheExam:
        return [
          const StudyPlanActivity(
            type: 'grammar',
            title: 'Grammar Focus',
            minutes: 10,
            description: 'Practice exam-style grammar questions',
          ),
          const StudyPlanActivity(
            type: 'vocabulary',
            title: 'Vocabulary Builder',
            minutes: 10,
            description: 'Learn exam-level vocabulary',
          ),
          const StudyPlanActivity(
            type: 'listening',
            title: 'Listening Comprehension',
            minutes: 10,
            description: 'Practice with exam audio',
          ),
          const StudyPlanActivity(
            type: 'quiz',
            title: 'Practice Quiz',
            minutes: 10,
            description: 'Test your knowledge',
          ),
          const StudyPlanActivity(
            type: 'ai_chat',
            title: 'Writing Practice',
            minutes: 10,
            description: 'Practice essay writing with AI',
          ),
        ];
      case LearningGoal.work:
        return [
          const StudyPlanActivity(
            type: 'vocabulary',
            title: 'Business Vocabulary',
            minutes: 10,
            description: 'Learn professional terms',
          ),
          const StudyPlanActivity(
            type: 'ai_chat',
            title: 'Meeting Practice',
            minutes: 10,
            description: 'Practice business conversations',
          ),
          const StudyPlanActivity(
            type: 'grammar',
            title: 'Formal Grammar',
            minutes: 10,
            description: 'Master formal expressions',
          ),
          const StudyPlanActivity(
            type: 'listening',
            title: 'Business Audio',
            minutes: 10,
            description: 'Listen to business German',
          ),
        ];
      case LearningGoal.travel:
        return [
          const StudyPlanActivity(
            type: 'vocabulary',
            title: 'Travel Phrases',
            minutes: 10,
            description: 'Essential travel vocabulary',
          ),
          const StudyPlanActivity(
            type: 'ai_chat',
            title: 'Hotel & Restaurant',
            minutes: 10,
            description: 'Practice booking and ordering',
          ),
          const StudyPlanActivity(
            type: 'speaking',
            title: 'Pronunciation',
            minutes: 10,
            description: 'Sound natural when traveling',
          ),
          const StudyPlanActivity(
            type: 'listening',
            title: 'Train Announcements',
            minutes: 10,
            description: 'Understand public transport',
          ),
        ];
      default:
        return [
          const StudyPlanActivity(
            type: 'vocabulary',
            title: 'Daily Vocabulary',
            minutes: 10,
            description: 'Build your word bank',
          ),
          const StudyPlanActivity(
            type: 'grammar',
            title: 'Grammar Practice',
            minutes: 10,
            description: 'Strengthen your grammar foundation',
          ),
          const StudyPlanActivity(
            type: 'ai_chat',
            title: 'Conversation Practice',
            minutes: 10,
            description: 'Chat with AI in German',
          ),
          const StudyPlanActivity(
            type: 'listening',
            title: 'Listening Exercise',
            minutes: 10,
            description: 'Improve your comprehension',
          ),
          const StudyPlanActivity(
            type: 'quiz',
            title: 'Daily Quiz',
            minutes: 10,
            description: 'Test what you learned',
          ),
        ];
    }
  }

  StudentMemory updateStudentMemory(
    StudentMemory memory, {
    String? newMistake,
    String? mistakeCategory,
    String? conversationTopic,
    List<String>? conversationMistakes,
    String? learnedWord,
  }) {
    final updatedPatterns = List<MistakePattern>.from(memory.mistakePatterns);
    final updatedLearned = List<String>.from(memory.successfullyLearned);
    final updatedConversations = List<ConversationSummary>.from(
      memory.conversationHistory,
    );
    if (newMistake != null && mistakeCategory != null) {
      final existingIndex = updatedPatterns.indexWhere(
        (p) => p.pattern == newMistake,
      );
      if (existingIndex != -1) {
        final existing = updatedPatterns[existingIndex];
        updatedPatterns[existingIndex] = MistakePattern(
          pattern: existing.pattern,
          category: existing.category,
          occurrences: existing.occurrences + 1,
          examples: existing.examples,
          firstSeen: existing.firstSeen,
          lastSeen: DateTime.now(),
        );
      } else {
        updatedPatterns.add(
          MistakePattern(
            pattern: newMistake,
            category: mistakeCategory,
            occurrences: 1,
            examples: [newMistake],
            firstSeen: DateTime.now(),
            lastSeen: DateTime.now(),
          ),
        );
      }
    }
    if (learnedWord != null && !updatedLearned.contains(learnedWord)) {
      updatedLearned.add(learnedWord);
    }
    if (conversationTopic != null) {
      updatedConversations.add(
        ConversationSummary(
          date: DateTime.now(),
          topic: conversationTopic,
          keyPoints: [],
          mistakesMade: conversationMistakes ?? [],
          durationMinutes: 5,
        ),
      );
      if (updatedConversations.length > 50) {
        updatedConversations.removeAt(0);
      }
    }
    return StudentMemory(
      userId: memory.userId,
      mistakePatterns: updatedPatterns,
      successfullyLearned: updatedLearned,
      conversationHistory: updatedConversations,
      preferences: memory.preferences,
      lastUpdated: DateTime.now(),
    );
  }
}

extension LearningProfileCopyWith on LearningProfile {
  LearningProfile copyWith({
    String? currentLevel,
    LearningGoal? learningGoal,
    int? dailyMinutes,
    List<WeaknessArea>? weakAreas,
    List<StrongArea>? strongAreas,
    List<String>? preferredTopics,
    LearningSpeed? learningSpeed,
    DateTime? lastAnalysisDate,
    int? totalStudyHours,
    int? currentStreak,
    double? overallProgress,
  }) {
    return LearningProfile(
      userId: userId,
      currentLevel: currentLevel ?? this.currentLevel,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      weakAreas: weakAreas ?? this.weakAreas,
      strongAreas: strongAreas ?? this.strongAreas,
      preferredTopics: preferredTopics ?? this.preferredTopics,
      learningSpeed: learningSpeed ?? this.learningSpeed,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      totalStudyHours: totalStudyHours ?? this.totalStudyHours,
      currentStreak: currentStreak ?? this.currentStreak,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }
}
