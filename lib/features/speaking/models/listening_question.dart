class ListeningQuestion {
  final String id;
  final String audioText;
  final String? audioUrl;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String translation;
  final int xpReward;

  const ListeningQuestion({
    required this.id,
    required this.audioText,
    this.audioUrl,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.translation,
    this.xpReward = 20,
  });

  String get correctAnswer => options[correctIndex];

  Map<String, dynamic> toJson() => {
    'id': id,
    'audioText': audioText,
    'audioUrl': audioUrl,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'translation': translation,
    'xpReward': xpReward,
  };

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) =>
      ListeningQuestion(
        id: json['id'] ?? '',
        audioText: json['audioText'] ?? '',
        audioUrl: json['audioUrl'],
        question: json['question'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
        translation: json['translation'] ?? '',
        xpReward: json['xpReward'] ?? 20,
      );

  static List<ListeningQuestion> getQuestionsByLevel(String level) {
    return _allQuestions
        .where((q) => _getLevelForQuestion(q.id) == level)
        .toList();
  }

  static String _getLevelForQuestion(String id) {
    if (id.startsWith('l1') || id.startsWith('l2')) return 'A1';
    if (id.startsWith('l3') || id.startsWith('l4')) return 'A2';
    if (id.startsWith('l5') || id.startsWith('l6')) return 'B1';
    if (id.startsWith('l7') || id.startsWith('l8')) return 'B2';
    if (id.startsWith('l9')) return 'C1';
    return 'C2';
  }

  static final List<ListeningQuestion> _allQuestions = [
    // A1 Questions
    const ListeningQuestion(
      id: 'l1',
      audioText: 'Guten Morgen! Wie geht es Ihnen?',
      question: 'Was sagt die Person?',
      options: ['Gute Nacht', 'Guten Morgen', 'Auf Wiedersehen', 'Tschüss'],
      correctIndex: 1,
      explanation: 'The person says "Guten Morgen" which means "Good morning".',
      translation: 'Good morning! How are you?',
    ),
    const ListeningQuestion(
      id: 'l2',
      audioText: 'Ich möchte einen Kaffee bestellen.',
      question: 'Was möchte die Person?',
      options: ['Tee', 'Kaffee', 'Wasser', 'Saft'],
      correctIndex: 1,
      explanation:
          'The person says "einen Kaffee bestellen" which means "order a coffee".',
      translation: 'I would like to order a coffee.',
    ),

    // A2 Questions
    const ListeningQuestion(
      id: 'l3',
      audioText: 'Ich habe gestern einen Film im Kino gesehen.',
      question: 'Was hat die Person gestern gemacht?',
      options: [
        'Ein Buch gelesen',
        'Einen Film gesehen',
        'Musik gehört',
        'Ein Lied gesungen',
      ],
      correctIndex: 1,
      explanation:
          'The person says "einen Film gesehen" which means "watched a movie".',
      translation: 'I watched a movie in the cinema yesterday.',
    ),
    const ListeningQuestion(
      id: 'l4',
      audioText: 'Der Zug fährt um acht Uhr ab.',
      question: 'Wann fährt der Zug?',
      options: ['Um sieben Uhr', 'Um acht Uhr', 'Um neun Uhr', 'Um zehn Uhr'],
      correctIndex: 1,
      explanation:
          'The person says "um acht Uhr" which means "at eight o\'clock".',
      translation: 'The train departs at eight o\'clock.',
    ),

    // B1 Questions
    const ListeningQuestion(
      id: 'l5',
      audioText: 'Obwohl es sehr kalt ist, gehe ich jeden Tag zur Arbeit.',
      question: 'Was macht die Person trotz des Wetters?',
      options: [
        'Bleibt sie zu Hause',
        'Geht sie zur Arbeit',
        'Fährt sie in den Urlaub',
        'Trinkt sie einen Kaffee',
      ],
      correctIndex: 1,
      explanation:
          'The person says "gehe ich jeden Tag zur Arbeit" which means "I go to work every day".',
      translation: 'Although it is very cold, I go to work every day.',
    ),
    const ListeningQuestion(
      id: 'l6',
      audioText: 'Ich hätte gerne einen Tisch für zwei Personen, bitte.',
      question: 'Was möchte die Person?',
      options: [
        'Einen Tisch für vier',
        'Einen Tisch für zwei',
        'Einen Stuhl',
        'Ein Menü',
      ],
      correctIndex: 1,
      explanation:
          'The person says "einen Tisch für zwei Personen" which means "a table for two people".',
      translation: 'I would like a table for two people, please.',
    ),

    // B2 Questions
    const ListeningQuestion(
      id: 'l7',
      audioText: 'Die Situation hat sich grundlegend verändert.',
      question: 'Was ist passiert?',
      options: [
        'Nichts hat sich geändert',
        'Die Situation hat sich verändert',
        'Die Person ist umgezogen',
        'Das Wetter hat sich verändert',
      ],
      correctIndex: 1,
      explanation:
          'The person says "Die Situation hat sich grundlegend verändert" which means "The situation has fundamentally changed".',
      translation: 'The situation has fundamentally changed.',
    ),
    const ListeningQuestion(
      id: 'l8',
      audioText: 'Trotz der Schwierigkeiten habe ich mein Ziel erreicht.',
      question: 'Was hat die Person erreicht?',
      options: ['Nichts', 'Ihr Ziel', 'Einen Preis', 'Einen Freund'],
      correctIndex: 1,
      explanation:
          'The person says "habe ich mein Ziel erreicht" which means "I achieved my goal".',
      translation: 'Despite the difficulties, I achieved my goal.',
    ),

    // C1 Questions
    const ListeningQuestion(
      id: 'l9',
      audioText:
          'Die Forschungsergebnisse deuten darauf hin, dass die Klimaveränderungen schneller voranschreiten als erwartet.',
      question: 'Was sagen die Forschungsergebnisse?',
      options: [
        'Das Klima verbessert sich',
        'Die Klimaveränderungen sind langsamer',
        'Die Klimaveränderungen sind schneller',
        'Das Klima ist stabil',
      ],
      correctIndex: 2,
      explanation:
          'The research results suggest that climate changes are progressing faster than expected.',
      translation:
          'The research results suggest that climate changes are progressing faster than expected.',
    ),

    // C2 Questions
    const ListeningQuestion(
      id: 'l10',
      audioText:
          'Es ist unbestreitbar, dass die digitale Transformation die Art und Weise, wie wir kommunizieren, revolutioniert hat.',
      question: 'Was hat die digitale Transformation gemacht?',
      options: [
        'Die Kommunikation verschlechtert',
        'Die Kommunikation revolutioniert',
        'Die Kommunikation verlangsamt',
        'Die Kommunikation beendet',
      ],
      correctIndex: 1,
      explanation:
          'The digital transformation has revolutionized the way we communicate.',
      translation:
          'It is undeniable that the digital transformation has revolutionized the way we communicate.',
    ),
  ];
}
