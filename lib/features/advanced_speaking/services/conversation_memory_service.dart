import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lexi/core/services/auth_service.dart';
import '../models/conversation_models.dart';
import '../models/ai_character.dart';
import '../models/speaking_progress.dart';

class ConversationMemoryService {
  static const String _memoryKey = 'conversation_memory';
  static const String _progressKey = 'speaking_progress';
  static const String _challengesKey = 'speaking_challenges';
  static const int _maxMistakes = 10;
  static const int _maxProblems = 8;

  Future<ConversationMemory> getMemory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoryJson = prefs.getString(_memoryKey);
      if (memoryJson != null) {
        return ConversationMemory.fromJson(jsonDecode(memoryJson));
      }
    } catch (e) {
      // Fall through to default
    }
    return ConversationMemory.empty();
  }

  Future<void> saveMemory(ConversationMemory memory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memoryKey, jsonEncode(memory.toJson()));
  }

  Future<void> recordMistake(ConversationMemory memory, String mistake) async {
    final updatedMistakes = List<String>.from(memory.recentMistakes);
    updatedMistakes.insert(0, mistake);
    if (updatedMistakes.length > _maxMistakes) {
      updatedMistakes.removeRange(_maxMistakes, updatedMistakes.length);
    }

    final updatedMemory = memory.copyWith(
      recentMistakes: updatedMistakes,
      lastPracticeDate: DateTime.now(),
    );

    await saveMemory(updatedMemory);
  }

  Future<void> recordVocabularyProblem(
    ConversationMemory memory,
    String word,
  ) async {
    final updatedProblems = List<String>.from(memory.vocabularyProblems);
    if (!updatedProblems.contains(word)) {
      updatedProblems.insert(0, word);
      if (updatedProblems.length > _maxProblems) {
        updatedProblems.removeRange(_maxProblems, updatedProblems.length);
      }
    }

    final updatedMemory = memory.copyWith(
      vocabularyProblems: updatedProblems,
      lastPracticeDate: DateTime.now(),
    );

    await saveMemory(updatedMemory);
  }

  Future<void> recordGrammarProblem(
    ConversationMemory memory,
    String pattern,
  ) async {
    final updatedProblems = List<String>.from(memory.grammarProblems);
    if (!updatedProblems.contains(pattern)) {
      updatedProblems.insert(0, pattern);
      if (updatedProblems.length > _maxProblems) {
        updatedProblems.removeRange(_maxProblems, updatedProblems.length);
      }
    }

    final updatedMemory = memory.copyWith(
      grammarProblems: updatedProblems,
      lastPracticeDate: DateTime.now(),
    );

    await saveMemory(updatedMemory);
  }

  Future<void> updateScenarioScore(
    ConversationMemory memory,
    ConversationScenario scenario,
    int score,
  ) async {
    final updatedScores = Map<String, int>.from(memory.scenarioScores);
    updatedScores[scenario.name] = score;

    final updatedMemory = memory.copyWith(
      scenarioScores: updatedScores,
      lastPracticeDate: DateTime.now(),
    );

    await saveMemory(updatedMemory);
  }

  ConversationContext buildContext({
    required ConversationScenario scenario,
    required AICharacter character,
    required String userLevel,
  }) {
    return ConversationContext(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: AuthService.instance.currentUser?.id ?? '',
      scenario: scenario,
      character: character,
      userLevel: userLevel,
      previousMistakes: [],
      vocabularyProblems: [],
      grammarProblems: [],
      turnCount: 0,
    );
  }

  Future<SpeakingProgress> getProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        return SpeakingProgress.fromJson(jsonDecode(progressJson));
      }
    } catch (e) {
      // Fall through to default
    }
    return SpeakingProgress.empty();
  }

  Future<void> saveProgress(SpeakingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> updateProgress({
    required SpeakingProgress current,
    required int minutes,
    required int words,
    required double pronunciationScore,
    required double fluencyScore,
    required ConversationScenario scenario,
  }) async {
    final totalMinutes = current.totalSpeakingMinutes + minutes;
    final totalWords = current.totalWordsSpoken + words;
    final totalSessions = current.totalSessions + 1;

    final avgPronunciation =
        ((current.averagePronunciationScore * current.totalSessions) +
            pronunciationScore) /
        (current.totalSessions + 1);
    final avgFluency =
        ((current.averageFluencyScore * current.totalSessions) + fluencyScore) /
        (current.totalSessions + 1);

    final updatedScenarioCount = Map<String, int>.from(
      current.scenarioPracticeCount,
    );
    updatedScenarioCount[scenario.name] =
        (updatedScenarioCount[scenario.name] ?? 0) + 1;

    final updated = current.copyWith(
      totalSpeakingMinutes: totalMinutes,
      totalWordsSpoken: totalWords,
      averagePronunciationScore: avgPronunciation,
      averageFluencyScore: avgFluency,
      totalSessions: totalSessions,
      scenarioPracticeCount: updatedScenarioCount,
    );

    await saveProgress(updated);
  }

  Future<List<SpeakingChallenge>> getChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = prefs.getString(_challengesKey);
      if (challengesJson != null) {
        final List<dynamic> list = jsonDecode(challengesJson);
        return list.map((j) => SpeakingChallenge.fromJson(j)).toList();
      }
    } catch (e) {
      // Fall through to default
    }
    return [];
  }

  Future<void> saveChallenges(List<SpeakingChallenge> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _challengesKey,
      jsonEncode(challenges.map((c) => c.toJson()).toList()),
    );
  }

  List<SpeakingChallenge> getAvailableChallenges() {
    return [
      SpeakingChallenge(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Daily Speaking Challenge',
        description: 'Practice speaking for 5 minutes today',
        type: ChallengeType.daily,
        targetDays: 1,
        completedDays: 0,
        currentDay: 1,
        isActive: true,
        startDate: DateTime.now(),
        days: [
          ChallengeDay(
            dayNumber: 1,
            title: 'Daily Practice',
            description: 'Have a 5-minute conversation with Lexi',
            scenario: ConversationScenario.dailyLife,
            targetMinutes: 5,
            isCompleted: false,
          ),
        ],
        reward: const ChallengeReward(xp: 50, gems: 10),
      ),
      SpeakingChallenge(
        id: 'weekly_${DateTime.now().millisecondsSinceEpoch}',
        title: '7-Day Speaking Challenge',
        description: 'Practice speaking for 7 consecutive days',
        type: ChallengeType.weekly,
        targetDays: 7,
        completedDays: 0,
        currentDay: 1,
        isActive: true,
        startDate: DateTime.now(),
        days: List.generate(
          7,
          (index) => ChallengeDay(
            dayNumber: index + 1,
            title: 'Day ${index + 1}',
            description: 'Practice scenario ${index + 1} of 7',
            scenario: ConversationScenario
                .values[index % ConversationScenario.values.length],
            targetMinutes: 5 + index,
            isCompleted: false,
          ),
        ),
        reward: const ChallengeReward(
          xp: 200,
          gems: 50,
          badgeId: 'speaking_week',
        ),
      ),
      SpeakingChallenge(
        id: 'monthly_${DateTime.now().millisecondsSinceEpoch}',
        title: '30-Day Speaking Challenge',
        description: 'Master German speaking in 30 days',
        type: ChallengeType.monthly,
        targetDays: 30,
        completedDays: 0,
        currentDay: 1,
        isActive: true,
        startDate: DateTime.now(),
        days: List.generate(
          30,
          (index) => ChallengeDay(
            dayNumber: index + 1,
            title: 'Day ${index + 1}',
            description: 'Complete daily speaking exercise',
            scenario: ConversationScenario
                .values[index % ConversationScenario.values.length],
            targetMinutes: 5 + (index ~/ 5),
            isCompleted: false,
          ),
        ),
        reward: const ChallengeReward(
          xp: 1000,
          gems: 200,
          badgeId: 'speaking_master',
        ),
      ),
    ];
  }
}
