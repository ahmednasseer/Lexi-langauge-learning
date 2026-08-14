enum LearningGoal { travel, work, study, conversation, hobby, goetheExam }

enum LearningSpeed { slow, normal, fast }

enum WeaknessCategory {
  articles,
  verbConjugation,
  cases,
  wordOrder,
  vocabulary,
  pronunciation,
  listening,
  writing,
}

class LearningProfile {
  final String userId;
  final String currentLevel;
  final LearningGoal learningGoal;
  final int dailyMinutes;
  final List<WeaknessArea> weakAreas;
  final List<StrongArea> strongAreas;
  final List<String> preferredTopics;
  final LearningSpeed learningSpeed;
  final DateTime lastAnalysisDate;
  final int totalStudyHours;
  final int currentStreak;
  final double overallProgress;

  const LearningProfile({
    required this.userId,
    required this.currentLevel,
    required this.learningGoal,
    required this.dailyMinutes,
    required this.weakAreas,
    required this.strongAreas,
    required this.preferredTopics,
    required this.learningSpeed,
    required this.lastAnalysisDate,
    this.totalStudyHours = 0,
    this.currentStreak = 0,
    this.overallProgress = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'currentLevel': currentLevel,
    'learningGoal': learningGoal.name,
    'dailyMinutes': dailyMinutes,
    'weakAreas': weakAreas.map((w) => w.toJson()).toList(),
    'strongAreas': strongAreas.map((s) => s.toJson()).toList(),
    'preferredTopics': preferredTopics,
    'learningSpeed': learningSpeed.name,
    'lastAnalysisDate': lastAnalysisDate.toIso8601String(),
    'totalStudyHours': totalStudyHours,
    'currentStreak': currentStreak,
    'overallProgress': overallProgress,
  };

  factory LearningProfile.fromJson(Map<String, dynamic> json) =>
      LearningProfile(
        userId: json['userId'] ?? '',
        currentLevel: json['currentLevel'] ?? 'A1',
        learningGoal: LearningGoal.values.firstWhere(
          (e) => e.name == json['learningGoal'],
          orElse: () => LearningGoal.conversation,
        ),
        dailyMinutes: json['dailyMinutes'] ?? 15,
        weakAreas: (json['weakAreas'] as List? ?? [])
            .map((w) => WeaknessArea.fromJson(w))
            .toList(),
        strongAreas: (json['strongAreas'] as List? ?? [])
            .map((s) => StrongArea.fromJson(s))
            .toList(),
        preferredTopics: List<String>.from(json['preferredTopics'] ?? []),
        learningSpeed: LearningSpeed.values.firstWhere(
          (e) => e.name == json['learningSpeed'],
          orElse: () => LearningSpeed.normal,
        ),
        lastAnalysisDate: json['lastAnalysisDate'] != null
            ? DateTime.parse(json['lastAnalysisDate'])
            : DateTime.now(),
        totalStudyHours: json['totalStudyHours'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        overallProgress: (json['overallProgress'] ?? 0.0).toDouble(),
      );

  String get goalText {
    switch (learningGoal) {
      case LearningGoal.travel:
        return 'Travel & Tourism';
      case LearningGoal.work:
        return 'Business German';
      case LearningGoal.study:
        return 'Academic Studies';
      case LearningGoal.conversation:
        return 'Daily Conversation';
      case LearningGoal.hobby:
        return 'Hobby & Culture';
      case LearningGoal.goetheExam:
        return 'Goethe Exam Preparation';
    }
  }

  String get speedText {
    switch (learningSpeed) {
      case LearningSpeed.slow:
        return 'Thorough (More practice)';
      case LearningSpeed.normal:
        return 'Balanced';
      case LearningSpeed.fast:
        return 'Accelerated';
    }
  }
}

class WeaknessArea {
  final String category;
  final String subCategory;
  final int mistakeCount;
  final double severity; // 0.0 to 1.0
  final DateTime lastMistakeAt;
  final List<String> commonMistakes;

  const WeaknessArea({
    required this.category,
    required this.subCategory,
    required this.mistakeCount,
    required this.severity,
    required this.lastMistakeAt,
    this.commonMistakes = const [],
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'subCategory': subCategory,
    'mistakeCount': mistakeCount,
    'severity': severity,
    'lastMistakeAt': lastMistakeAt.toIso8601String(),
    'commonMistakes': commonMistakes,
  };

  factory WeaknessArea.fromJson(Map<String, dynamic> json) => WeaknessArea(
    category: json['category'] ?? '',
    subCategory: json['subCategory'] ?? '',
    mistakeCount: json['mistakeCount'] ?? 0,
    severity: (json['severity'] ?? 0.0).toDouble(),
    lastMistakeAt: json['lastMistakeAt'] != null
        ? DateTime.parse(json['lastMistakeAt'])
        : DateTime.now(),
    commonMistakes: List<String>.from(json['commonMistakes'] ?? []),
  );

  String get severityText {
    if (severity >= 0.8) return 'Critical';
    if (severity >= 0.6) return 'High';
    if (severity >= 0.4) return 'Medium';
    return 'Low';
  }
}

class StrongArea {
  final String category;
  final String subCategory;
  final int correctCount;
  final double mastery; // 0.0 to 1.0
  final DateTime lastPracticedAt;

  const StrongArea({
    required this.category,
    required this.subCategory,
    required this.correctCount,
    required this.mastery,
    required this.lastPracticedAt,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'subCategory': subCategory,
    'correctCount': correctCount,
    'mastery': mastery,
    'lastPracticedAt': lastPracticedAt.toIso8601String(),
  };

  factory StrongArea.fromJson(Map<String, dynamic> json) => StrongArea(
    category: json['category'] ?? '',
    subCategory: json['subCategory'] ?? '',
    correctCount: json['correctCount'] ?? 0,
    mastery: (json['mastery'] ?? 0.0).toDouble(),
    lastPracticedAt: json['lastPracticedAt'] != null
        ? DateTime.parse(json['lastPracticedAt'])
        : DateTime.now(),
  );
}

class AIRecommendation {
  final String id;
  final String userId;
  final String
  type; // 'weakness_fix', 'review', 'new_topic', 'challenge', 'daily'
  final String title;
  final String description;
  final String category;
  final int estimatedMinutes;
  final int priority; // 1-10
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;

  const AIRecommendation({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedMinutes,
    required this.priority,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'title': title,
    'description': description,
    'category': category,
    'estimatedMinutes': estimatedMinutes,
    'priority': priority,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      AIRecommendation(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        type: json['type'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        estimatedMinutes: json['estimatedMinutes'] ?? 5,
        priority: json['priority'] ?? 5,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        isCompleted: json['isCompleted'] ?? false,
      );

  String get typeEmoji {
    switch (type) {
      case 'weakness_fix':
        return '🎯';
      case 'review':
        return '🔄';
      case 'new_topic':
        return '📚';
      case 'challenge':
        return '⚡';
      case 'daily':
        return '📅';
      default:
        return '💡';
    }
  }
}

class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<StudyPlanDay> days;
  final bool isActive;
  final DateTime createdAt;

  const StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    title: json['title'] ?? '',
    startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : DateTime.now(),
    endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'])
        : DateTime.now().add(const Duration(days: 7)),
    days: (json['days'] as List? ?? [])
        .map((d) => StudyPlanDay.fromJson(d))
        .toList(),
    isActive: json['isActive'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}

class StudyPlanDay {
  final String dayName;
  final List<StudyPlanActivity> activities;
  final int totalMinutes;

  const StudyPlanDay({
    required this.dayName,
    required this.activities,
    required this.totalMinutes,
  });

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'activities': activities.map((a) => a.toJson()).toList(),
    'totalMinutes': totalMinutes,
  };

  factory StudyPlanDay.fromJson(Map<String, dynamic> json) => StudyPlanDay(
    dayName: json['dayName'] ?? '',
    activities: (json['activities'] as List? ?? [])
        .map((a) => StudyPlanActivity.fromJson(a))
        .toList(),
    totalMinutes: json['totalMinutes'] ?? 0,
  );
}

class StudyPlanActivity {
  final String
  type; // 'vocabulary', 'grammar', 'speaking', 'listening', 'ai_chat', 'quiz'
  final String title;
  final int minutes;
  final String? lessonId;
  final String? description;

  const StudyPlanActivity({
    required this.type,
    required this.title,
    required this.minutes,
    this.lessonId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'minutes': minutes,
    'lessonId': lessonId,
    'description': description,
  };

  factory StudyPlanActivity.fromJson(Map<String, dynamic> json) =>
      StudyPlanActivity(
        type: json['type'] ?? '',
        title: json['title'] ?? '',
        minutes: json['minutes'] ?? 5,
        lessonId: json['lessonId'],
        description: json['description'],
      );

  String get typeEmoji {
    switch (type) {
      case 'vocabulary':
        return '📝';
      case 'grammar':
        return '📖';
      case 'speaking':
        return '🎤';
      case 'listening':
        return '🎧';
      case 'ai_chat':
        return '🤖';
      case 'quiz':
        return '❓';
      default:
        return '📚';
    }
  }
}

class StudentMemory {
  final String userId;
  final List<MistakePattern> mistakePatterns;
  final List<String> successfullyLearned;
  final List<ConversationSummary> conversationHistory;
  final LearningPreferences preferences;
  final DateTime lastUpdated;

  const StudentMemory({
    required this.userId,
    required this.mistakePatterns,
    required this.successfullyLearned,
    required this.conversationHistory,
    required this.preferences,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'mistakePatterns': mistakePatterns.map((m) => m.toJson()).toList(),
    'successfullyLearned': successfullyLearned,
    'conversationHistory': conversationHistory.map((c) => c.toJson()).toList(),
    'preferences': preferences.toJson(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory StudentMemory.fromJson(Map<String, dynamic> json) => StudentMemory(
    userId: json['userId'] ?? '',
    mistakePatterns: (json['mistakePatterns'] as List? ?? [])
        .map((m) => MistakePattern.fromJson(m))
        .toList(),
    successfullyLearned: List<String>.from(json['successfullyLearned'] ?? []),
    conversationHistory: (json['conversationHistory'] as List? ?? [])
        .map((c) => ConversationSummary.fromJson(c))
        .toList(),
    preferences: LearningPreferences.fromJson(json['preferences'] ?? {}),
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'])
        : DateTime.now(),
  );
}

class MistakePattern {
  final String pattern;
  final String category;
  final int occurrences;
  final List<String> examples;
  final DateTime firstSeen;
  final DateTime lastSeen;

  const MistakePattern({
    required this.pattern,
    required this.category,
    required this.occurrences,
    required this.examples,
    required this.firstSeen,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'pattern': pattern,
    'category': category,
    'occurrences': occurrences,
    'examples': examples,
    'firstSeen': firstSeen.toIso8601String(),
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory MistakePattern.fromJson(Map<String, dynamic> json) => MistakePattern(
    pattern: json['pattern'] ?? '',
    category: json['category'] ?? '',
    occurrences: json['occurrences'] ?? 0,
    examples: List<String>.from(json['examples'] ?? []),
    firstSeen: json['firstSeen'] != null
        ? DateTime.parse(json['firstSeen'])
        : DateTime.now(),
    lastSeen: json['lastSeen'] != null
        ? DateTime.parse(json['lastSeen'])
        : DateTime.now(),
  );
}

class ConversationSummary {
  final DateTime date;
  final String topic;
  final List<String> keyPoints;
  final List<String> mistakesMade;
  final int durationMinutes;

  const ConversationSummary({
    required this.date,
    required this.topic,
    required this.keyPoints,
    required this.mistakesMade,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'topic': topic,
    'keyPoints': keyPoints,
    'mistakesMade': mistakesMade,
    'durationMinutes': durationMinutes,
  };

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      ConversationSummary(
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        topic: json['topic'] ?? '',
        keyPoints: List<String>.from(json['keyPoints'] ?? []),
        mistakesMade: List<String>.from(json['mistakesMade'] ?? []),
        durationMinutes: json['durationMinutes'] ?? 0,
      );
}

class LearningPreferences {
  final String preferredDifficulty;
  final List<String> favoriteTopics;
  final String feedbackStyle; // 'gentle', 'direct', 'detailed'
  final bool showTranslations;
  final bool audioEnabled;

  const LearningPreferences({
    required this.preferredDifficulty,
    required this.favoriteTopics,
    required this.feedbackStyle,
    this.showTranslations = true,
    this.audioEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'preferredDifficulty': preferredDifficulty,
    'favoriteTopics': favoriteTopics,
    'feedbackStyle': feedbackStyle,
    'showTranslations': showTranslations,
    'audioEnabled': audioEnabled,
  };

  factory LearningPreferences.fromJson(Map<String, dynamic> json) =>
      LearningPreferences(
        preferredDifficulty: json['preferredDifficulty'] ?? 'intermediate',
        favoriteTopics: List<String>.from(json['favoriteTopics'] ?? []),
        feedbackStyle: json['feedbackStyle'] ?? 'gentle',
        showTranslations: json['showTranslations'] ?? true,
        audioEnabled: json['audioEnabled'] ?? true,
      );
}
