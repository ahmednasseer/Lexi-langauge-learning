import 'package:flutter/material.dart';
import 'package:lexi/features/ai_learning/models/learning_profile.dart';
import 'ai_learning_service.dart';

class AILearningController extends ChangeNotifier {
  final AILearningService _service = AILearningService();
  LearningProfile? _profile;
  List<AIRecommendation> _recommendations = [];
  StudyPlan? _studyPlan;
  StudentMemory? _memory;
  bool _isLoading = false;
  LearningProfile? get profile => _profile;
  List<AIRecommendation> get recommendations => _recommendations;
  StudyPlan? get studyPlan => _studyPlan;
  StudentMemory? get memory => _memory;
  bool get isLoading => _isLoading;
  String get dailySummary {
    if (_profile == null)
      return 'Start learning to get personalized recommendations!';
    final weakCount = _profile!.weakAreas.length;
    final strongCount = _profile!.strongAreas.length;
    return '$weakCount areas to improve, $strongCount strengths identified';
  }

  String get todayRecommendation {
    if (_recommendations.isEmpty)
      return 'Complete some lessons to get AI recommendations!';
    final dailyRecs = _recommendations.where((r) => r.type == 'daily').toList();
    if (dailyRecs.isNotEmpty) return dailyRecs.first.description;
    return _recommendations.first.description;
  }

  void initializeProfile(String userId) {
    _profile = _service.generateDefaultProfile(userId);
    _memory = StudentMemory(
      userId: userId,
      mistakePatterns: [],
      successfullyLearned: [],
      conversationHistory: [],
      preferences: const LearningPreferences(
        preferredDifficulty: 'intermediate',
        favoriteTopics: [],
        feedbackStyle: 'gentle',
      ),
      lastUpdated: DateTime.now(),
    );
    _recommendations = _service.generateRecommendations(_profile!);
    _studyPlan = _service.generateStudyPlan(_profile!);
    notifyListeners();
  }

  Future<void> analyzePerformance({
    required List<Map<String, dynamic>> quizResults,
    required List<Map<String, dynamic>> flashcardResults,
    required List<Map<String, dynamic>> speakingResults,
    required List<Map<String, dynamic>> aiConversationMistakes,
  }) async {
    if (_profile == null) return;
    _isLoading = true;
    notifyListeners();
    _profile = _service.analyzeAndUpdateProfile(
      _profile!,
      quizResults: quizResults,
      flashcardResults: flashcardResults,
      speakingResults: speakingResults,
      aiConversationMistakes: aiConversationMistakes,
    );
    _recommendations = _service.generateRecommendations(_profile!);
    _studyPlan = _service.generateStudyPlan(_profile!);
    _isLoading = false;
    notifyListeners();
  }

  void updateProfile({
    String? level,
    LearningGoal? goal,
    int? dailyMinutes,
    LearningSpeed? speed,
  }) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      currentLevel: level,
      learningGoal: goal,
      dailyMinutes: dailyMinutes,
      learningSpeed: speed,
    );
    _recommendations = _service.generateRecommendations(_profile!);
    _studyPlan = _service.generateStudyPlan(_profile!);
    notifyListeners();
  }

  void recordMistake(String mistake, String category) {
    if (_memory == null) return;
    _memory = _service.updateStudentMemory(
      _memory!,
      newMistake: mistake,
      mistakeCategory: category,
    );
    notifyListeners();
  }

  void recordConversation(String topic, List<String> mistakes) {
    if (_memory == null) return;
    _memory = _service.updateStudentMemory(
      _memory!,
      conversationTopic: topic,
      conversationMistakes: mistakes,
    );
    notifyListeners();
  }

  void recordLearnedWord(String word) {
    if (_memory == null) return;
    _memory = _service.updateStudentMemory(_memory!, learnedWord: word);
    notifyListeners();
  }

  void completeRecommendation(String recommendationId) {
    final index = _recommendations.indexWhere((r) => r.id == recommendationId);
    if (index != -1) {
      _recommendations[index] = AIRecommendation(
        id: _recommendations[index].id,
        userId: _recommendations[index].userId,
        type: _recommendations[index].type,
        title: _recommendations[index].title,
        description: _recommendations[index].description,
        category: _recommendations[index].category,
        estimatedMinutes: _recommendations[index].estimatedMinutes,
        priority: _recommendations[index].priority,
        createdAt: _recommendations[index].createdAt,
        completedAt: DateTime.now(),
        isCompleted: true,
      );
      notifyListeners();
    }
  }

  void refreshRecommendations() {
    if (_profile == null) return;
    _recommendations = _service.generateRecommendations(_profile!);
    notifyListeners();
  }

  void regenerateStudyPlan() {
    if (_profile == null) return;
    _studyPlan = _service.generateStudyPlan(_profile!);
    notifyListeners();
  }

  WeaknessArea? getMostCriticalWeakness() {
    if (_profile == null || _profile!.weakAreas.isEmpty) return null;
    return _profile!.weakAreas.first;
  }

  StrongArea? getStrongestArea() {
    if (_profile == null || _profile!.strongAreas.isEmpty) return null;
    return _profile!.strongAreas.first;
  }

  List<AIRecommendation> getTopRecommendations({int count = 3}) {
    return _recommendations.where((r) => !r.isCompleted).take(count).toList();
  }

  List<AIRecommendation> getCompletedRecommendations() {
    return _recommendations.where((r) => r.isCompleted).toList();
  }

  double getCompletionRate() {
    if (_recommendations.isEmpty) return 0.0;
    final completed = _recommendations.where((r) => r.isCompleted).length;
    return completed / _recommendations.length;
  }

  int getEstimatedDailyMinutes() {
    return _profile?.dailyMinutes ?? 15;
  }

  Map<String, int> getWeeklyActivity() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final activities = <String, int>{};
    for (int i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      activities[dayName] = 0;
    }
    if (_memory != null) {
      for (final conv in _memory!.conversationHistory) {
        if (conv.date.isAfter(weekAgo)) {
          final dayName = _getDayName(conv.date.weekday);
          activities[dayName] =
              (activities[dayName] ?? 0) + conv.durationMinutes;
        }
      }
    }
    return activities;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
