import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'models/speaking_exercise.dart';
import 'models/pronunciation_result.dart';
import 'models/listening_question.dart';

class SpeakingRepository {
  static const String _pronunciationKey = 'pronunciation_results';
  static const String _listeningKey = 'listening_progress';

  final SharedPreferences _prefs;
  final ApiService _api = ApiService();

  SpeakingRepository(this._prefs);

  List<SpeakingExercise> getExercises(String level) {
    return SpeakingExercise.getExercisesByLevel(level);
  }

  List<ListeningQuestion> getListeningQuestions(String level) {
    return ListeningQuestion.getQuestionsByLevel(level);
  }

  Future<List<SpeakingExercise>> getExercisesFromApi(String level) async {
    try {
      final result = await _api.getSpeakingExercises(level);
      if (result.isSuccess && result.data != null) {
        return (result.data as List)
            .map((e) => SpeakingExercise.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return getExercises(level);
  }

  Future<List<ListeningQuestion>> getListeningFromApi(String level) async {
    try {
      final result = await _api.getListeningQuestions(level);
      if (result.isSuccess && result.data != null) {
        return (result.data as List)
            .map((e) => ListeningQuestion.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return getListeningQuestions(level);
  }

  Future<void> savePronunciationResult(PronunciationResult result) async {
    final results = getPronunciationResults();
    results.add(result);
    final jsonList = results.map((r) => r.toJson()).toList();
    await _prefs.setString(_pronunciationKey, jsonEncode(jsonList));
  }

  List<PronunciationResult> getPronunciationResults() {
    final jsonString = _prefs.getString(_pronunciationKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((j) => PronunciationResult.fromJson(j as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> getPronunciationStats() {
    final results = getPronunciationResults();
    if (results.isEmpty) {
      return {
        'totalAttempts': 0,
        'averageScore': 0.0,
        'perfectCount': 0,
        'totalXp': 0,
      };
    }

    final totalScore = results.fold<double>(0.0, (sum, r) => sum + r.overallScore);
    final perfectCount = results.where((r) => r.isPerfect).length;
    final totalXp = results.fold<int>(0, (sum, r) => sum + r.xpEarned);

    return {
      'totalAttempts': results.length,
      'averageScore': totalScore / results.length,
      'perfectCount': perfectCount,
      'totalXp': totalXp,
    };
  }

  Future<void> saveListeningProgress(String questionId, bool isCorrect, int score) async {
    final progress = getListeningProgress();
    progress[questionId] = {
      'completed': true,
      'correct': isCorrect,
      'score': score,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_listeningKey, jsonEncode(progress));
  }

  Map<String, dynamic> getListeningProgress() {
    final jsonString = _prefs.getString(_listeningKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Map<String, dynamic> getListeningStats() {
    final progress = getListeningProgress();
    final completed = progress.length;
    final correct = progress.values.where((p) => p['correct'] == true).length;

    return {
      'totalCompleted': completed,
      'correctAnswers': correct,
      'accuracy': completed > 0 ? (correct / completed * 100).round() : 0,
    };
  }
}
