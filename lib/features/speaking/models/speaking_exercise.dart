class SpeakingExercise {
  final String id;
  final String level;
  final String sentence;
  final String translation;
  final String? audioUrl;
  final String category;
  final int difficulty; // 1-5
  final int xpReward;

  const SpeakingExercise({
    required this.id,
    required this.level,
    required this.sentence,
    required this.translation,
    this.audioUrl,
    required this.category,
    this.difficulty = 1,
    this.xpReward = 30,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'sentence': sentence,
    'translation': translation,
    'audioUrl': audioUrl,
    'category': category,
    'difficulty': difficulty,
    'xpReward': xpReward,
  };

  factory SpeakingExercise.fromJson(Map<String, dynamic> json) =>
      SpeakingExercise(
        id: json['id'] ?? '',
        level: json['level'] ?? 'A1',
        sentence: json['sentence'] ?? '',
        translation: json['translation'] ?? '',
        audioUrl: json['audioUrl'],
        category: json['category'] ?? 'general',
        difficulty: json['difficulty'] ?? 1,
        xpReward: json['xpReward'] ?? 30,
      );

  static List<SpeakingExercise> getExercisesByLevel(String level) {
    return _allExercises.where((e) => e.level == level).toList();
  }

  static final List<SpeakingExercise> _allExercises = [
    // A1 - Beginner
    const SpeakingExercise(
      id: 's1',
      level: 'A1',
      sentence: 'Ich heiße Ahmed.',
      translation: 'My name is Ahmed.',
      category: 'introduction',
      difficulty: 1,
    ),
    const SpeakingExercise(
      id: 's2',
      level: 'A1',
      sentence: 'Guten Morgen!',
      translation: 'Good morning!',
      category: 'greetings',
      difficulty: 1,
    ),
    const SpeakingExercise(
      id: 's3',
      level: 'A1',
      sentence: 'Wie geht es Ihnen?',
      translation: 'How are you?',
      category: 'greetings',
      difficulty: 1,
    ),
    const SpeakingExercise(
      id: 's4',
      level: 'A1',
      sentence: 'Ich möchte einen Kaffee bestellen.',
      translation: 'I would like to order a coffee.',
      category: 'restaurant',
      difficulty: 2,
    ),
    const SpeakingExercise(
      id: 's5',
      level: 'A1',
      sentence: 'Wo ist der Bahnhof?',
      translation: 'Where is the train station?',
      category: 'travel',
      difficulty: 2,
    ),
    const SpeakingExercise(
      id: 's6',
      level: 'A1',
      sentence: 'Das ist sehr gut!',
      translation: 'That is very good!',
      category: 'general',
      difficulty: 1,
    ),

    // A2 - Elementary
    const SpeakingExercise(
      id: 's7',
      level: 'A2',
      sentence: 'Ich habe gestern einen Film gesehen.',
      translation: 'I watched a movie yesterday.',
      category: 'past tense',
      difficulty: 2,
    ),
    const SpeakingExercise(
      id: 's8',
      level: 'A2',
      sentence: 'Können Sie mir bitte helfen?',
      translation: 'Can you please help me?',
      category: 'requests',
      difficulty: 2,
    ),
    const SpeakingExercise(
      id: 's9',
      level: 'A2',
      sentence: 'Ich gehe jeden Tag zur Arbeit.',
      translation: 'I go to work every day.',
      category: 'daily routine',
      difficulty: 2,
    ),
    const SpeakingExercise(
      id: 's10',
      level: 'A2',
      sentence: 'Das Essen war sehr lecker.',
      translation: 'The food was very delicious.',
      category: 'restaurant',
      difficulty: 2,
    ),

    // B1 - Intermediate
    const SpeakingExercise(
      id: 's11',
      level: 'B1',
      sentence: 'Obwohl es regnet, gehe ich spazieren.',
      translation: 'Although it is raining, I am going for a walk.',
      category: 'conjunctions',
      difficulty: 3,
    ),
    const SpeakingExercise(
      id: 's12',
      level: 'B1',
      sentence: 'Ich hätte gerne einen Tisch für zwei Personen.',
      translation: 'I would like a table for two.',
      category: 'restaurant',
      difficulty: 3,
    ),
    const SpeakingExercise(
      id: 's13',
      level: 'B1',
      sentence: 'Können Sie das bitte langsamer sagen?',
      translation: 'Can you please speak slower?',
      category: 'requests',
      difficulty: 3,
    ),
    const SpeakingExercise(
      id: 's14',
      level: 'B1',
      sentence: 'Ich interessiere mich für deutsche Kultur.',
      translation: 'I am interested in German culture.',
      category: 'hobbies',
      difficulty: 3,
    ),

    // B2 - Upper Intermediate
    const SpeakingExercise(
      id: 's15',
      level: 'B2',
      sentence: 'Trotz der Schwierigkeiten habe ich es geschafft.',
      translation: 'Despite the difficulties, I managed it.',
      category: 'complex sentences',
      difficulty: 4,
    ),
    const SpeakingExercise(
      id: 's16',
      level: 'B2',
      sentence: 'Ich würde gerne meine Meinung dazu äußern.',
      translation: 'I would like to express my opinion on this.',
      category: 'opinions',
      difficulty: 4,
    ),
    const SpeakingExercise(
      id: 's17',
      level: 'B2',
      sentence: 'Die Situation hat sich grundlegend verändert.',
      translation: 'The situation has fundamentally changed.',
      category: 'current events',
      difficulty: 4,
    ),

    // C1 - Advanced
    const SpeakingExercise(
      id: 's18',
      level: 'C1',
      sentence:
          'Man kann sagen, dass die Globalisierung sowohl Chancen als auch Risiken birgt.',
      translation:
          'One can say that globalization entails both opportunities and risks.',
      category: 'academic',
      difficulty: 5,
    ),
    const SpeakingExercise(
      id: 's19',
      level: 'C1',
      sentence: 'Die Forschungsergebnisse deuten darauf hin, dass...',
      translation: 'The research results suggest that...',
      category: 'academic',
      difficulty: 5,
    ),

    // C2 - Mastery
    const SpeakingExercise(
      id: 's20',
      level: 'C2',
      sentence:
          'Es ist unbestreitbar, dass die digitale Transformation die Art und Weise, wie wir kommunizieren, revolutioniert hat.',
      translation:
          'It is undeniable that the digital transformation has revolutionized the way we communicate.',
      category: 'academic',
      difficulty: 5,
    ),
  ];
}
