import 'dart:math';
import 'models/exam_models.dart';

class GoetheExamService {
  final Random _random = Random();

  List<ExamLevelModel> getExamLevels() {
    return ExamLevelModel.getDefaultLevels();
  }

  ExamLevelModel? getExamLevel(ExamLevel level) {
    try {
      return ExamLevelModel.getDefaultLevels().firstWhere((l) => l.cefrLevel == level.name.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  List<ExamSection> getSectionsForLevel(ExamLevel level) {
    return [
      ExamSection(
        id: '${level.name}_reading',
        type: ExamSectionType.reading,
        name: 'Lesen (Reading)',
        description: 'Test your reading comprehension',
        questionCount: _getQuestionCount(level, ExamSectionType.reading),
        timeLimitMinutes: _getTimeLimit(level, ExamSectionType.reading),
        totalPoints: _getQuestionCount(level, ExamSectionType.reading) * 2,
        questions: generateReadingQuestions(level),
      ),
      ExamSection(
        id: '${level.name}_listening',
        type: ExamSectionType.listening,
        name: 'Hören (Listening)',
        description: 'Test your listening comprehension',
        questionCount: _getQuestionCount(level, ExamSectionType.listening),
        timeLimitMinutes: _getTimeLimit(level, ExamSectionType.listening),
        totalPoints: _getQuestionCount(level, ExamSectionType.listening) * 2,
        questions: generateListeningQuestions(level),
      ),
      ExamSection(
        id: '${level.name}_writing',
        type: ExamSectionType.writing,
        name: 'Schreiben (Writing)',
        description: 'Test your writing skills',
        questionCount: _getQuestionCount(level, ExamSectionType.writing),
        timeLimitMinutes: _getTimeLimit(level, ExamSectionType.writing),
        totalPoints: _getQuestionCount(level, ExamSectionType.writing) * 5,
        questions: generateWritingPrompts(level),
      ),
      ExamSection(
        id: '${level.name}_speaking',
        type: ExamSectionType.speaking,
        name: 'Sprechen (Speaking)',
        description: 'Test your speaking skills',
        questionCount: _getQuestionCount(level, ExamSectionType.speaking),
        timeLimitMinutes: _getTimeLimit(level, ExamSectionType.speaking),
        totalPoints: _getQuestionCount(level, ExamSectionType.speaking) * 5,
        questions: generateSpeakingPrompts(level),
      ),
    ];
  }

  int _getQuestionCount(ExamLevel level, ExamSectionType section) {
    final counts = {
      ExamLevel.a1: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
        ExamSectionType.writing: 2,
        ExamSectionType.speaking: 3,
      },
      ExamLevel.a2: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
        ExamSectionType.writing: 2,
        ExamSectionType.speaking: 3,
      },
      ExamLevel.b1: {
        ExamSectionType.reading: 20,
        ExamSectionType.listening: 20,
        ExamSectionType.writing: 3,
        ExamSectionType.speaking: 4,
      },
      ExamLevel.b2: {
        ExamSectionType.reading: 20,
        ExamSectionType.listening: 20,
        ExamSectionType.writing: 3,
        ExamSectionType.speaking: 4,
      },
    };
    return counts[level]?[section] ?? 10;
  }

  int _getTimeLimit(ExamLevel level, ExamSectionType section) {
    final times = {
      ExamLevel.a1: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
        ExamSectionType.writing: 15,
        ExamSectionType.speaking: 15,
      },
      ExamLevel.a2: {
        ExamSectionType.reading: 15,
        ExamSectionType.listening: 15,
        ExamSectionType.writing: 20,
        ExamSectionType.speaking: 20,
      },
      ExamLevel.b1: {
        ExamSectionType.reading: 20,
        ExamSectionType.listening: 20,
        ExamSectionType.writing: 25,
        ExamSectionType.speaking: 25,
      },
      ExamLevel.b2: {
        ExamSectionType.reading: 25,
        ExamSectionType.listening: 25,
        ExamSectionType.writing: 30,
        ExamSectionType.speaking: 25,
      },
    };
    return times[level]?[section] ?? 20;
  }

  List<ExamQuestion> generateReadingQuestions(ExamLevel level) {
    final questions = <ExamQuestion>[];
    final count = _getQuestionCount(level, ExamSectionType.reading);

    final passages = _getReadingPassages(level);
    final questionTemplates = _getReadingQuestionTemplates(level);

    for (int i = 0; i < count; i++) {
      final passage = passages[i % passages.length];
      final template = questionTemplates[i % questionTemplates.length];
      
      questions.add(ExamQuestion(
        id: 'reading_${level.name}_$i',
        sectionId: '${level.name}_reading',
        type: QuestionType.multipleChoice,
        question: template['question']!,
        passage: passage,
        options: List<String>.from(template['options']!),
        correctAnswer: template['correct']!,
        explanation: template['explanation']!,
        difficulty: _getRandomDifficulty(),
        points: 2,
      ));
    }

    return questions;
  }

  List<ExamQuestion> generateListeningQuestions(ExamLevel level) {
    final questions = <ExamQuestion>[];
    final count = _getQuestionCount(level, ExamSectionType.listening);

    final questionTemplates = _getListeningQuestionTemplates(level);

    for (int i = 0; i < count; i++) {
      final template = questionTemplates[i % questionTemplates.length];
      
      questions.add(ExamQuestion(
        id: 'listening_${level.name}_$i',
        sectionId: '${level.name}_listening',
        type: QuestionType.multipleChoice,
        question: template['question']!,
        options: List<String>.from(template['options']!),
        correctAnswer: template['correct']!,
        explanation: template['explanation']!,
        audioUrl: 'audio/listening/${level.name}_$i.mp3',
        difficulty: _getRandomDifficulty(),
        points: 2,
      ));
    }

    return questions;
  }

  List<ExamQuestion> generateWritingPrompts(ExamLevel level) {
    final prompts = <ExamQuestion>[];
    final count = _getQuestionCount(level, ExamSectionType.writing);

    final writingTasks = _getWritingTasks(level);

    for (int i = 0; i < count; i++) {
      final task = writingTasks[i % writingTasks.length];
      
      prompts.add(ExamQuestion(
        id: 'writing_${level.name}_$i',
        sectionId: '${level.name}_writing',
        type: QuestionType.essay,
        question: task['prompt']!,
        options: [],
        correctAnswer: task['example']!,
        explanation: task['criteria']!,
        difficulty: _getRandomDifficulty(),
        points: 5,
      ));
    }

    return prompts;
  }

  List<ExamQuestion> generateSpeakingPrompts(ExamLevel level) {
    final prompts = <ExamQuestion>[];
    final count = _getQuestionCount(level, ExamSectionType.speaking);

    final speakingTasks = _getSpeakingTasks(level);

    for (int i = 0; i < count; i++) {
      final task = speakingTasks[i % speakingTasks.length];
      
      prompts.add(ExamQuestion(
        id: 'speaking_${level.name}_$i',
        sectionId: '${level.name}_speaking',
        type: QuestionType.shortAnswer,
        question: task['prompt']!,
        options: [],
        correctAnswer: task['example']!,
        explanation: task['criteria']!,
        difficulty: _getRandomDifficulty(),
        points: 5,
      ));
    }

    return prompts;
  }

  List<String> _getReadingPassages(ExamLevel level) {
    final passages = {
      ExamLevel.a1: [
        'Maria kommt aus Berlin. Sie ist 25 Jahre alt und arbeitet als Lehrerin. Sie spricht Deutsch, Englisch und Französisch.',
        'Der Supermarkt ist von Montag bis Samstag von 8 bis 20 Uhr geöffnt. Am Sonntag ist der Supermarkt geschlossen.',
        'Tom fährt jeden Tag mit dem Bus zur Arbeit. Die Busfahrt dauert 20 Minuten.',
      ],
      ExamLevel.a2: [
        'Sehr geehrte Damen und Herren, hiermit bewerbe ich mich um die Stelle als Verkäufer in Ihrem Geschäft.',
        'Letzten Sommer war ich mit meiner Familie in Italien. Wir haben Rom, Florenz und Venedig besucht.',
        'Die Stadt hat einen neuen Park gebaut. Der Park hat einen Spielplatz, einen See und viele Bäume.',
      ],
      ExamLevel.b1: [
        'Obwohl die Digitalisierung viele Vorteile bringt, gibt es auch Nachteile. Viele Menschen haben Angst, ihren Arbeitsplatz zu verlieren.',
        'Die Umweltverschutung ist ein großes Problem. Es gibt viele Möglichkeiten, wie jeder Einzelne contribute kann.',
        'Das Bildungssystem in Deutschland unterscheidet sich von anderen Ländern. Kinder gehen通常lich 12-13 Jahre zur Schule.',
      ],
      ExamLevel.b2: [
        'Die Globalisierung hat die Welt in vielerlei Hinsicht verändert. Während some argue that it has brought more prosperity, others point to increasing inequality.',
        'Die Rolle der Medien in der Demokratie ist von zentraler Bedeutung. Sie fungieren als vierte Gewalt und informieren die Bürger.',
        'Die deutsche Wirtschaft steht vor großen Herausforderungen. Der Fachkräftemangel und die Energiewende sind nur zwei der vielen Probleme.',
      ],
    };
    return passages[level] ?? passages[ExamLevel.a1]!;
  }

  List<Map<String, dynamic>> _getReadingQuestionTemplates(ExamLevel level) {
    return [
      {
        'question': 'Was macht Maria beruflich?',
        'options': ['Lehrerin', 'Ärztin', 'Ingenieurin', 'Programmiererin'],
        'correct': 'Lehrerin',
        'explanation': 'Im Text steht: "Sie arbeitet als Lehrerin."',
      },
      {
        'question': 'Wann ist der Supermarkt geschlossen?',
        'options': ['Montag', 'Mittwoch', 'Sonntag', 'Samstag'],
        'correct': 'Sonntag',
        'explanation': 'Im Text steht: "Am Sonntag ist der Supermarkt geschlossen."',
      },
      {
        'question': 'Wie lange dauert die Busfahrt?',
        'options': ['10 Minuten', '15 Minuten', '20 Minuten', '25 Minuten'],
        'correct': '20 Minuten',
        'explanation': 'Im Text steht: "Die Busfahrt dauert 20 Minuten."',
      },
    ];
  }

  List<Map<String, dynamic>> _getListeningQuestionTemplates(ExamLevel level) {
    return [
      {
        'question': 'Was möchte die Person?',
        'options': ['Einen Termin', 'Eine Fahrkarte', 'Ein Zimmer', 'Ein Essen'],
        'correct': 'Einen Termin',
        'explanation': 'Die Person sagt: "Ich möchte gerne einen Termin vereinbaren."',
      },
      {
        'question': 'Wo ist die Person?',
        'options': ['Im Restaurant', 'Im Hotel', 'Auf dem Bahnhof', 'Im Geschäft'],
        'correct': 'Auf dem Bahnhof',
        'explanation': 'Die Person fragt nach dem nächsten Bahnhof.',
      },
    ];
  }

  List<Map<String, dynamic>> _getWritingTasks(ExamLevel level) {
    final tasks = {
      ExamLevel.a1: [
        {
          'prompt': 'Schreiben Sie eine kurze Nachricht an Ihren Freund. Fragen Sie, wie es ihm geht und erzählen Sie, was Sie machen.',
          'example': 'Hallo Peter, wie geht es dir? Mir geht es gut. Ich arbeite jetzt in einem Büro.',
          'criteria': 'Grammar, vocabulary, structure, coherence',
        },
        {
          'prompt': 'Schreiben Sie eine E-Mail an Ihr Hotel. Fragen Sie nach Verfügbarkeit.',
          'example': 'Sehr geehrte Damen und Herren, ich möchte ein Zimmer für zwei Nächte reservieren.',
          'criteria': 'Formal language, correct grammar, clear request',
        },
      ],
      ExamLevel.a2: [
        {
          'prompt': 'Schreiben Sie eine E-Mail an Ihren Kollegen. Planen Sie ein Treffen.',
          'example': 'Lieber Herr Müller, schlagen Sie ein Treffen nächste Woche vor. Ich bin flexibel.',
          'criteria': 'Formal/informal register, grammar, vocabulary',
        },
      ],
      ExamLevel.b1: [
        {
          'prompt': 'Schreiben Sie einen Brief über Ihre Erfahrungen mit dem Deutschlernen.',
          'example': 'Sehr geehrte Damen und Herren, seit zwei Jahren lerne ich Deutsch...',
          'criteria': 'Complex sentences, varied vocabulary, coherence',
        },
      ],
      ExamLevel.b2: [
        {
          'prompt': 'Verfassen Sie einen Aufsatz über die Vor- und Nachteile der Digitalisierung.',
          'example': 'Die Digitalisierung hat unser Leben in vielerlei Hinsicht verändert...',
          'criteria': 'Academic style, complex grammar, argumentation',
        },
      ],
    };
    return tasks[level] ?? tasks[ExamLevel.a1]!;
  }

  List<Map<String, dynamic>> _getSpeakingTasks(ExamLevel level) {
    final tasks = {
      ExamLevel.a1: [
        {
          'prompt': 'Stellen Sie sich vor. Sagen Sie, wie Sie heißen, woher Sie kommen und was Sie beruflich machen.',
          'example': 'Ich heiße Maria. Ich komme aus Berlin. Ich bin Lehrerin.',
          'criteria': 'Pronunciation, fluency, basic grammar',
        },
        {
          'prompt': 'Beschreiben Sie Ihr Zuhause.',
          'example': 'Ich wohne in einer Wohnung. Sie hat drei Zimmer.',
          'criteria': 'Vocabulary, grammar, pronunciation',
        },
      ],
      ExamLevel.a2: [
        {
          'prompt': 'Erzählen Sie von Ihrem letzten Urlaub.',
          'example': 'Letzten Sommer war ich in Spanien. Es war sehr schön.',
          'criteria': 'Past tense, vocabulary, fluency',
        },
      ],
      ExamLevel.b1: [
        {
          'prompt': 'Diskutieren Sie die Vor- und Nachteile von Social Media.',
          'example': 'Social Media hat viele Vorteile, aber auch Nachteile...',
          'criteria': 'Argumentation, complex grammar, vocabulary',
        },
      ],
      ExamLevel.b2: [
        {
          'prompt': 'Präsentieren Sie Ihre Meinung zur Zukunft der Arbeit.',
          'example': 'Die Zukunft der Arbeit wird von vielen Faktoren bestimmt...',
          'criteria': 'Academic language, complex structures, fluency',
        },
      ],
    };
    return tasks[level] ?? tasks[ExamLevel.a1]!;
  }

  DifficultyLevel _getRandomDifficulty() {
    final values = DifficultyLevel.values;
    return values[_random.nextInt(values.length)];
  }

  MockExam createMockExam(ExamLevel level, String userId) {
    final sections = getSectionsForLevel(level);
    
    return MockExam(
      id: 'mock_${level.name}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      level: level,
      score: 0,
      totalPoints: sections.fold(0, (sum, s) => sum + s.totalPoints),
      timeSpentSeconds: 0,
      completedSections: [],
      result: const ExamResult(
        passed: false,
        scorePercentage: 0,
        grade: 'F',
        feedback: 'Not yet completed',
        strengths: [],
        weaknesses: [],
        recommendation: 'Complete the exam to see your results',
      ),
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  ExamResult evaluateExam(MockExam exam, Map<String, String> answers) {
    int totalScore = 0;
    int totalPoints = exam.totalPoints;
    final sectionResults = <SectionResult>[];

    for (final section in exam.completedSections) {
      totalScore += section.score;
      sectionResults.add(section);
    }

    final percentage = totalPoints > 0 ? (totalScore / totalPoints * 100).toDouble() : 0.0;
    final passed = percentage >= 60;

    final grade = _calculateGrade(percentage);
    final strengths = _identifyStrengths(sectionResults);
    final weaknesses = _identifyWeaknesses(sectionResults);
    final recommendation = _generateRecommendation(percentage, weaknesses);

    return ExamResult(
      passed: passed,
      scorePercentage: percentage,
      grade: grade,
      feedback: _generateFeedback(percentage, strengths, weaknesses),
      strengths: strengths,
      weaknesses: weaknesses,
      recommendation: recommendation,
    );
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  List<String> _identifyStrengths(List<SectionResult> results) {
    final strengths = <String>[];
    for (final result in results) {
      if (result.percentage >= 80) {
        strengths.add(_getSectionName(result.type));
      }
    }
    return strengths;
  }

  List<String> _identifyWeaknesses(List<SectionResult> results) {
    final weaknesses = <String>[];
    for (final result in results) {
      if (result.percentage < 60) {
        weaknesses.add(_getSectionName(result.type));
      }
    }
    return weaknesses;
  }

  String _getSectionName(ExamSectionType type) {
    switch (type) {
      case ExamSectionType.reading: return 'Reading';
      case ExamSectionType.listening: return 'Listening';
      case ExamSectionType.writing: return 'Writing';
      case ExamSectionType.speaking: return 'Speaking';
    }
  }

  String _generateFeedback(double percentage, List<String> strengths, List<String> weaknesses) {
    if (percentage >= 80) {
      return 'Excellent performance! You are well-prepared for the exam.';
    } else if (percentage >= 60) {
      return 'Good job! You passed, but there is room for improvement.';
    } else {
      return 'Keep practicing! Focus on your weak areas to improve.';
    }
  }

  String _generateRecommendation(double percentage, List<String> weaknesses) {
    if (percentage >= 80) {
      return 'You are ready for the exam! Take a final practice test to confirm.';
    } else if (percentage >= 60) {
      return 'Focus on improving your weak areas: ${weaknesses.join(", ")}.';
    } else {
      return 'Spend more time studying and practice regularly. Consider taking a course.';
    }
  }

  WritingEvaluation evaluateWriting(String text, ExamLevel level) {
    final wordCount = text.split(' ').length;
    final hasGreeting = text.contains('Sehr geehrte') || text.contains('Hallo') || text.contains('Liebe');
    final hasClosing = text.contains('Mit freundlichen Grüßen') || text.contains('Viele Grüße');

    double grammarScore = 70 + _random.nextDouble() * 25;
    double vocabularyScore = 65 + _random.nextDouble() * 30;
    double structureScore = 60 + _random.nextDouble() * 35;

    if (hasGreeting) structureScore = min(100, structureScore + 5);
    if (hasClosing) structureScore = min(100, structureScore + 5);
    if (wordCount < 30) {
      grammarScore *= 0.8;
      vocabularyScore *= 0.8;
    }

    final overallScore = (grammarScore + vocabularyScore + structureScore) / 3;

    return WritingEvaluation(
      grammarScore: grammarScore,
      vocabularyScore: vocabularyScore,
      structureScore: structureScore,
      overallScore: overallScore,
      corrections: _generateWritingCorrections(text, level),
      suggestions: _generateWritingSuggestions(level),
      feedback: _generateWritingFeedback(overallScore),
    );
  }

  SpeakingEvaluation evaluateSpeaking(String audioTranscript, ExamLevel level) {
    double pronunciationScore = 65 + _random.nextDouble() * 30;
    double fluencyScore = 60 + _random.nextDouble() * 35;
    double grammarScore = 65 + _random.nextDouble() * 30;
    double vocabularyScore = 60 + _random.nextDouble() * 35;

    final overallScore = (pronunciationScore + fluencyScore + grammarScore + vocabularyScore) / 4;

    return SpeakingEvaluation(
      pronunciationScore: pronunciationScore,
      fluencyScore: fluencyScore,
      grammarScore: grammarScore,
      vocabularyScore: vocabularyScore,
      overallScore: overallScore,
      mistakes: _generateSpeakingMistakes(level),
      suggestions: _generateSpeakingSuggestions(level),
      feedback: _generateSpeakingFeedback(overallScore),
    );
  }

  List<String> _generateWritingCorrections(String text, ExamLevel level) {
    return [
      'Check article usage (der/die/das)',
      'Consider using more complex sentence structures',
      'Add transitional words for better flow',
    ];
  }

  List<String> _generateWritingSuggestions(ExamLevel level) {
    return [
      'Use formal greetings for business letters',
      'Include specific details and examples',
      'Proofread for spelling and grammar',
    ];
  }

  String _generateWritingFeedback(double score) {
    if (score >= 80) return 'Excellent writing! Your text is clear and well-structured.';
    if (score >= 60) return 'Good writing! Focus on grammar and vocabulary variety.';
    return 'Keep practicing! Work on sentence structure and word choice.';
  }

  List<String> _generateSpeakingMistakes(ExamLevel level) {
    return [
      'Watch your pronunciation of "ch" sounds',
      'Practice verb conjugation in past tense',
      'Work on word order in subordinate clauses',
    ];
  }

  List<String> _generateSpeakingSuggestions(ExamLevel level) {
    return [
      'Practice speaking slowly and clearly',
      'Use linking words for better fluency',
      'Expand your vocabulary for more variety',
    ];
  }

  String _generateSpeakingFeedback(double score) {
    if (score >= 80) return 'Excellent speaking! You communicate clearly and fluently.';
    if (score >= 60) return 'Good speaking! Work on pronunciation and fluency.';
    return 'Keep practicing! Focus on pronunciation and sentence structure.';
  }
}
