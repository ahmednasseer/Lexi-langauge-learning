import '../models/conversation_models.dart';
import '../models/ai_character.dart';

class AIConversationService {
  final Map<ConversationScenario, List<Map<String, String>>> _scenarios = {
    ConversationScenario.restaurant: [
      {
        'role': 'ai',
        'content': 'Willkommen im Restaurant! Was möchten Sie bestellen?',
      },
      {'role': 'ai', 'content': 'Haben Sie bereits eine Bestellung im Sinn?'},
      {'role': 'ai', 'content': 'Möchten Sie die Speisekarte sehen?'},
      {
        'role': 'ai',
        'content': 'Haben Sie Allergien, die wir beachten sollten?',
      },
      {'role': 'ai', 'content': 'Ist der Tisch in Ordnung für Sie?'},
    ],
    ConversationScenario.travel: [
      {'role': 'ai', 'content': 'Guten Tag! Wo möchten Sie hinfahren?'},
      {'role': 'ai', 'content': 'Haben Sie eine Reservierung?'},
      {'role': 'ai', 'content': 'Wie lange möchten Sie bleiben?'},
      {'role': 'ai', 'content': 'Brauchen Sie Hilfe mit dem Gepäck?'},
      {'role': 'ai', 'content': 'Möchten Sie eine Stadtführung buchen?'},
    ],
    ConversationScenario.jobInterview: [
      {'role': 'ai', 'content': 'Guten Tag! Bitte stellen Sie sich vor.'},
      {'role': 'ai', 'content': 'Warum interessiert Sie diese Stelle?'},
      {'role': 'ai', 'content': 'Was sind Ihre Stärken?'},
      {'role': 'ai', 'content': 'Erzählen Sie mir von Ihrer Erfahrung.'},
      {'role': 'ai', 'content': 'Haben Sie Fragen an uns?'},
    ],
    ConversationScenario.university: [
      {'role': 'ai', 'content': 'Guten Tag! Wie kann ich Ihnen helfen?'},
      {'role': 'ai', 'content': 'Für welches Fach interessieren Sie sich?'},
      {'role': 'ai', 'content': 'Haben Sie Fragen zum Stundenplan?'},
      {
        'role': 'ai',
        'content': 'Möchten Sie sich für eine Vorlesung anmelden?',
      },
      {'role': 'ai', 'content': 'Kann ich Ihnen bei der Bibliothek helfen?'},
    ],
    ConversationScenario.doctorVisit: [
      {'role': 'ai', 'content': 'Guten Tag! Was beschwert Sie?'},
      {'role': 'ai', 'content': 'Seit wann haben Sie diese Beschwerden?'},
      {'role': 'ai', 'content': 'Nehmen Sie Medikamente?'},
      {'role': 'ai', 'content': 'Haben Sie Fieber gemessen?'},
      {'role': 'ai', 'content': 'Ich schreibe Ihnen ein Rezept.'},
    ],
    ConversationScenario.shopping: [
      {'role': 'ai', 'content': 'Guten Tag! Kann ich Ihnen helfen?'},
      {'role': 'ai', 'content': 'Suchen Sie etwas Bestimmtes?'},
      {'role': 'ai', 'content': 'Welche Größe brauchen Sie?'},
      {'role': 'ai', 'content': 'Möchten Sie das anprobieren?'},
      {'role': 'ai', 'content': 'Das kostet 29,99 Euro.'},
    ],
    ConversationScenario.dailyLife: [
      {'role': 'ai', 'content': 'Hallo! Wie geht es Ihnen heute?'},
      {'role': 'ai', 'content': 'Was haben Sie heute vor?'},
      {'role': 'ai', 'content': 'Möchten Sie einen Kaffee trinken gehen?'},
      {'role': 'ai', 'content': 'Wie war Ihr Wochenende?'},
      {'role': 'ai', 'content': 'Haben Sie Lust auf eine Pause?'},
    ],
    ConversationScenario.goetheSpeakingExam: [
      {
        'role': 'ai',
        'content':
            'Willkommen zur mündlichen Prüfung. Bitte stellen Sie sich vor.',
      },
      {'role': 'ai', 'content': 'Beschreiben Sie das Bild.'},
      {'role': 'ai', 'content': 'Erzählen Sie mir von Ihrem Alltag.'},
      {'role': 'ai', 'content': 'Was würden Sie in dieser Situation tun?'},
      {'role': 'ai', 'content': 'Vielen Dank. Das war die Prüfung.'},
    ],
  };

  String getInitialMessage(
    ConversationScenario scenario,
    AICharacter character,
  ) {
    final scenarioMessages = _scenarios[scenario];
    if (scenarioMessages != null && scenarioMessages.isNotEmpty) {
      return scenarioMessages[0]['content']!;
    }
    return 'Hallo! Ich bin ${character.name}. Lassen wir uns unterhalten!';
  }

  String getAIResponse({
    required ConversationScenario scenario,
    required List<ConversationMessage> messages,
    required ConversationContext context,
    required String userResponse,
  }) {
    final scenarioMessages = _scenarios[scenario] ?? [];
    final turnCount = messages.where((m) => m.role == 'user').length;

    if (turnCount >= scenarioMessages.length) {
      return _generateClosingMessage(scenario, context);
    }

    final nextMessage = scenarioMessages[turnCount];
    return nextMessage['content']!;
  }

  String _generateClosingMessage(
    ConversationScenario scenario,
    ConversationContext context,
  ) {
    switch (scenario) {
      case ConversationScenario.restaurant:
        return 'Vielen Dank für Ihren Besuch! Ich wünsche Ihnen einen schönen Abend.';
      case ConversationScenario.travel:
        return 'Ich wünsche Ihnen eine gute Reise! Kommen Sie bald wieder.';
      case ConversationScenario.jobInterview:
        return 'Vielen Dank für das Gespräch. Wir melden uns bei Ihnen.';
      case ConversationScenario.university:
        return 'Viel Erfolg in Ihrem Studium! Bei Fragen können Sie mich jederzeit fragen.';
      case ConversationScenario.doctorVisit:
        return 'Gute Besserung! Kommen Sie in einer Woche wieder.';
      case ConversationScenario.shopping:
        return 'Vielen Dank für Ihren Einkauf! Kommen Sie bald wieder.';
      case ConversationScenario.dailyLife:
        return 'Es war schön, mit Ihnen zu reden! Bis bald!';
      case ConversationScenario.goetheSpeakingExam:
        return 'Vielen Dank. Das war die mündliche Prüfung. Das Ergebnis erhalten Sie in 4 Wochen.';
    }
  }

  PronunciationAnalysis analyzePronunciation({
    required String spokenText,
    required String targetText,
  }) {
    final spokenLower = spokenText.toLowerCase().trim();
    final targetLower = targetText.toLowerCase().trim();

    final pronunciation = _calculatePronunciationScore(
      spokenLower,
      targetLower,
    );
    final accent = _calculateAccentScore(spokenLower, targetLower);
    final speakingSpeed = _calculateSpeakingSpeed(spokenText);
    final pauses = _calculatePauseScore(spokenText);
    final confidence = _calculateConfidence(spokenText);
    final wordAccuracy = _calculateWordAccuracy(spokenLower, targetLower);
    final mispronouncedWords = _findMispronouncedWords(
      spokenLower,
      targetLower,
    );
    final suggestions = _generatePronunciationSuggestions(
      pronunciation: pronunciation,
      accent: accent,
      speakingSpeed: speakingSpeed,
      mispronouncedWords: mispronouncedWords,
    );

    return PronunciationAnalysis(
      pronunciation: pronunciation,
      accent: accent,
      speakingSpeed: speakingSpeed,
      pauses: pauses,
      confidence: confidence,
      wordAccuracy: wordAccuracy,
      mispronouncedWords: mispronouncedWords,
      suggestions: suggestions,
    );
  }

  double _calculatePronunciationScore(String spoken, String target) {
    if (spoken.isEmpty) return 0.0;

    double score = 70;

    if (spoken == target) {
      score = 100;
    } else {
      final similarity = _calculateSimilarity(spoken, target);
      score = 50 + (similarity * 50);
    }

    final germanPatterns = ['ch', 'sch', 'ei', 'eu', 'au', 'ü', 'ö', 'ä'];
    for (final pattern in germanPatterns) {
      if (spoken.contains(pattern)) {
        score += 2;
      }
    }

    return score.clamp(0.0, 100.0);
  }

  double _calculateAccentScore(String spoken, String target) {
    if (spoken.isEmpty) return 0.0;

    double score = 75;

    final germanPatterns = {
      'ch': 3,
      'sch': 3,
      'ei': 3,
      'eu': 3,
      'au': 3,
      'ß': 4,
      'st': 2,
      'sp': 2,
    };

    for (final entry in germanPatterns.entries) {
      if (spoken.contains(entry.key)) {
        score += entry.value;
      }
    }

    return score.clamp(0.0, 100.0);
  }

  double _calculateSpeakingSpeed(String spoken) {
    if (spoken.isEmpty) return 0.0;

    final words = spoken.split(' ').length;
    final estimatedMinutes = words / 150;
    final estimatedSeconds = estimatedMinutes * 60;

    if (estimatedSeconds < 1) return 60;
    if (estimatedSeconds < 3) return 80;
    if (estimatedSeconds < 5) return 90;
    if (estimatedSeconds < 10) return 85;
    return 70;
  }

  double _calculatePauseScore(String spoken) {
    if (spoken.isEmpty) return 0.0;

    final hasPunctuation =
        spoken.contains('.') || spoken.contains('!') || spoken.contains('?');
    final hasComma = spoken.contains(',');

    double score = 70;
    if (hasPunctuation) score += 15;
    if (hasComma) score += 10;

    return score.clamp(0.0, 100.0);
  }

  double _calculateConfidence(String spoken) {
    if (spoken.isEmpty) return 0.0;

    final words = spoken.split(' ').length;
    final hasPunctuation =
        spoken.contains('.') || spoken.contains('!') || spoken.contains('?');

    double score = 60;
    if (words > 3) score += 10;
    if (words > 6) score += 10;
    if (hasPunctuation) score += 10;

    return score.clamp(0.0, 100.0);
  }

  double _calculateWordAccuracy(String spoken, String target) {
    if (spoken.isEmpty || target.isEmpty) return 0.0;

    final spokenWords = spoken.split(' ');
    final targetWords = target.split(' ');

    int matches = 0;
    for (final word in spokenWords) {
      if (targetWords.contains(word)) {
        matches++;
      }
    }

    if (targetWords.isEmpty) return 0.0;
    return (matches / targetWords.length * 100).clamp(0.0, 100.0);
  }

  List<String> _findMispronouncedWords(String spoken, String target) {
    final mispronounced = <String>[];
    final spokenWords = spoken.split(' ');
    final targetWords = target.split(' ');

    for (int i = 0; i < targetWords.length && i < spokenWords.length; i++) {
      if (spokenWords[i] != targetWords[i]) {
        mispronounced.add(targetWords[i]);
      }
    }

    return mispronounced;
  }

  List<String> _generatePronunciationSuggestions({
    required double pronunciation,
    required double accent,
    required double speakingSpeed,
    required List<String> mispronouncedWords,
  }) {
    final suggestions = <String>[];

    if (pronunciation < 70) {
      suggestions.add('Focus on pronouncing each word clearly');
    }
    if (accent < 70) {
      suggestions.add('Practice German sounds like "ch", "sch", "ei"');
    }
    if (speakingSpeed < 60) {
      suggestions.add('Try speaking at a moderate pace');
    }
    if (mispronouncedWords.isNotEmpty) {
      suggestions.add('Pay attention to: ${mispronouncedWords.join(", ")}');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Great pronunciation! Keep practicing!');
    }

    return suggestions;
  }

  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;

    final aWords = a.split(' ');
    final bWords = b.split(' ');

    int matches = 0;
    for (final word in aWords) {
      if (bWords.contains(word)) matches++;
    }

    if (bWords.isEmpty) return 0.0;
    return matches / bWords.length;
  }

  ConversationFeedback generateFeedback(ConversationSession session) {
    final userMessages = session.messages
        .where((m) => m.role == 'user')
        .toList();
    final corrections = userMessages.where((m) => m.isCorrected).toList();
    final perfect = userMessages
        .where(
          (m) =>
              m.pronunciationAnalysis != null &&
              m.pronunciationAnalysis!.overallScore >= 90,
        )
        .toList();

    final whatYouDidWell = <String>[];
    final mistakes = <String>[];
    final betterSentences = <String>[];

    if (perfect.isNotEmpty) {
      whatYouDidWell.add(
        'Excellent pronunciation in ${perfect.length} sentences!',
      );
    }
    if (userMessages.length >= 5) {
      whatYouDidWell.add('Great conversation flow and engagement!');
    }
    if (corrections.isEmpty) {
      whatYouDidWell.add('No corrections needed - perfect grammar!');
    }

    for (final correction in corrections) {
      if (correction.correction != null) {
        mistakes.add('You said: "${correction.content}"');
        betterSentences.add('Better: "${correction.correction}"');
      }
    }

    final averageScore = userMessages.isNotEmpty
        ? userMessages
                  .where((m) => m.pronunciationAnalysis != null)
                  .fold(
                    0.0,
                    (sum, m) => sum + m.pronunciationAnalysis!.overallScore,
                  ) /
              userMessages.where((m) => m.pronunciationAnalysis != null).length
        : 0.0;

    final xp = (averageScore * 2).toInt().clamp(10, 200);

    return ConversationFeedback(
      sessionId: session.id,
      whatYouDidWell: whatYouDidWell.isEmpty
          ? ['Good effort!']
          : whatYouDidWell,
      mistakes: mistakes,
      betterSentences: betterSentences,
      nextPractice: _generateNextPractice(session.scenario, averageScore),
      overallScore: averageScore,
      xpEarned: xp,
    );
  }

  String _generateNextPractice(ConversationScenario scenario, double score) {
    if (score >= 90) {
      return 'Excellent work! Try a more challenging scenario like Job Interview.';
    } else if (score >= 70) {
      return 'Good progress! Practice the same scenario again to improve.';
    } else {
      return 'Keep practicing! Try reviewing basic vocabulary for this scenario.';
    }
  }
}
