import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  static const _lessonsCompletedKey = 'lessons_completed';
  static const _quizScoresKey = 'quiz_scores';
  static const _userXpKey = 'user_xp';
  static const _userStreakKey = 'user_streak';
  static const _lastStudyDateKey = 'last_study_date';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _updateStreak();
  }

  void _updateStreak() {
    final lastDate = _prefs?.getString(_lastStudyDateKey);
    
    if (lastDate == null) {
      _prefs?.setInt(_userStreakKey, 0);
    } else {
      final last = DateTime.parse(lastDate);
      final diff = DateTime.now().difference(last).inDays;
      
      if (diff > 1) {
        _prefs?.setInt(_userStreakKey, 0);
      }
    }
  }

  Future<void> completeLesson(String lessonId) async {
    final completed = getCompletedLessons();
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await _prefs?.setStringList(_lessonsCompletedKey, completed);
      await addXp(10);
      await _markStudiedToday();
    }
  }

  List<String> getCompletedLessons() {
    return _prefs?.getStringList(_lessonsCompletedKey) ?? [];
  }

  Future<void> saveQuizScore(String lessonId, int score, int total) async {
    final scores = getQuizScores();
    scores[lessonId] = {'score': score, 'total': total, 'date': DateTime.now().toIso8601String()};
    await _prefs?.setString(_quizScoresKey, jsonEncode(scores));
    await addXp(score * 5);
    await _markStudiedToday();
  }

  Map<String, dynamic> getQuizScores() {
    final data = _prefs?.getString(_quizScoresKey);
    if (data == null) return {};
    return jsonDecode(data);
  }

  Future<void> addXp(int amount) async {
    final current = getXp();
    await _prefs?.setInt(_userXpKey, current + amount);
  }

  int getXp() {
    return _prefs?.getInt(_userXpKey) ?? 0;
  }

  int getStreak() {
    return _prefs?.getInt(_userStreakKey) ?? 0;
  }

  Future<void> _markStudiedToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs?.getString(_lastStudyDateKey);
    
    if (lastDate != today) {
      await _prefs?.setString(_lastStudyDateKey, DateTime.now().toIso8601String());
      final currentStreak = getStreak();
      await _prefs?.setInt(_userStreakKey, currentStreak + 1);
    }
  }

  bool isLessonCompleted(String lessonId) {
    return getCompletedLessons().contains(lessonId);
  }

  int getCompletedLessonsCount() {
    return getCompletedLessons().length;
  }
}
