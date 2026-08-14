import '../features/lessons/models/lesson_model.dart';
import '../features/lessons/models/vocabulary_model.dart';

class GermanContent {
  GermanContent._();

  static final Map<String, List<LessonModel>> lessonsByLevel = {
    'A1': _a1Lessons(),
    'A2': _a2Lessons(),
    'B1': _b1Lessons(),
    'B2': _b2Lessons(),
    'C1': _c1Lessons(),
    'C2': _c2Lessons(),
  };

  static List<LessonModel> getAllLessons() {
    return lessonsByLevel.values.expand((l) => l).toList();
  }

  static List<LessonModel> getLessonsByLevel(String level) {
    return lessonsByLevel[level] ?? [];
  }

  static List<LessonModel> getLessonsByCategory(String level, String category) {
    return getLessonsByLevel(
      level,
    ).where((l) => l.category == category).toList();
  }

  // ==================== A1 BEGINNER ====================
  static List<LessonModel> _a1Lessons() => [
    // VOCABULARY
    LessonModel(
      id: 'a1_vocab_1',
      title: ' begruessungen',
      description: 'Basic German greetings',
      level: 'A1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 50,
      vocabulary: [
        VocabularyItem(
          word: 'Hallo',
          translation: 'مرحبا / Hello',
          example: 'Hallo, wie geht es dir?',
          exampleTranslation: 'مرحبا، كيف حالك؟',
        ),
        VocabularyItem(
          word: 'Guten Morgen',
          translation: 'صباح الخير / Good morning',
          example: 'Guten Morgen, Herr Müller!',
          exampleTranslation: 'صباح الخير، السيد مولر!',
        ),
        VocabularyItem(
          word: 'Guten Tag',
          translation: 'مرحبا / Good day',
          example: 'Guten Tag, kann ich Ihnen helfen?',
          exampleTranslation: 'مرحبا، هل يمكنني مساعدتك؟',
        ),
        VocabularyItem(
          word: 'Guten Abend',
          translation: 'مساء الخير / Good evening',
          example: 'Guten Abend, willkommen!',
          exampleTranslation: 'مساء الخير، أهلا وسهلا!',
        ),
        VocabularyItem(
          word: 'Tschüss',
          translation: 'مع السلامة / Goodbye',
          example: 'Tschüss, bis morgen!',
          exampleTranslation: 'مع السلامة، حتى الغد!',
        ),
        VocabularyItem(
          word: 'Auf Wiedersehen',
          translation: 'مع السلامة رسميا / Goodbye formal',
          example: 'Auf Wiedersehen, bis nächste Woche!',
          exampleTranslation: 'مع السلامة، حتى الأسبوع القادم!',
        ),
        VocabularyItem(
          word: 'Danke',
          translation: 'شكرا / Thank you',
          example: 'Danke für Ihre Hilfe!',
          exampleTranslation: 'شكرا لمساعدتك!',
        ),
        VocabularyItem(
          word: 'Bitte',
          translation: 'من فضلك / Please/You\'re welcome',
          example: 'Bitte, setzen Sie sich.',
          exampleTranslation: 'من فضلك، اجلس.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How do you say "Good morning" in German?',
          correctAnswer: 'Guten Morgen',
          options: ['Guten Morgen', 'Guten Abend', 'Guten Tag', 'Tschüss'],
        ),
        QuizQuestion(
          question: 'What does "Danke" mean?',
          correctAnswer: 'Thank you',
          options: ['Thank you', 'Please', 'Goodbye', 'Hello'],
        ),
        QuizQuestion(
          question: 'Which is a formal goodbye?',
          correctAnswer: 'Auf Wiedersehen',
          options: ['Auf Wiedersehen', 'Tschüss', 'Hallo', 'Danke'],
        ),
        QuizQuestion(
          question: '"Hallo" means...',
          correctAnswer: 'Hello',
          options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
        ),
        QuizQuestion(
          question: 'When do you say "Guten Abend"?',
          correctAnswer: 'In the evening',
          options: ['In the evening', 'In the morning', 'At noon', 'At night'],
        ),
      ],
    ),
    LessonModel(
      id: 'a1_vocab_2',
      title: 'Zahlen 1-20',
      description: 'Numbers from 1 to 20',
      level: 'A1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 50,
      vocabulary: [
        VocabularyItem(
          word: 'eins',
          translation: '1 - واحد',
          example: 'Ich habe eins.',
          exampleTranslation: 'لدي واحد.',
        ),
        VocabularyItem(
          word: 'zwei',
          translation: '2 - اثنان',
          example: 'Zwei Kaffee, bitte.',
          exampleTranslation: 'قهوتان، من فضلك.',
        ),
        VocabularyItem(
          word: 'drei',
          translation: '3 - ثلاثة',
          example: 'Drei Äpfel.',
          exampleTranslation: 'ثلاثة تفاح.',
        ),
        VocabularyItem(
          word: 'vier',
          translation: '4 - أربعة',
          example: 'Vier Stunden.',
          exampleTranslation: 'أربع ساعات.',
        ),
        VocabularyItem(
          word: 'fünf',
          translation: '5 - خمسة',
          example: 'Fünf Minuten.',
          exampleTranslation: 'خمس دقائق.',
        ),
        VocabularyItem(
          word: 'sechs',
          translation: '6 - ستة',
          example: 'Sechs Bücher.',
          exampleTranslation: 'ستة كتب.',
        ),
        VocabularyItem(
          word: 'sieben',
          translation: '7 - سبعة',
          example: 'Sieben Tage.',
          exampleTranslation: 'سبعة أيام.',
        ),
        VocabularyItem(
          word: 'acht',
          translation: '8 - ثمانية',
          example: 'Acht Uhr.',
          exampleTranslation: 'الساعة الثامنة.',
        ),
        VocabularyItem(
          word: 'neun',
          translation: '9 - تسعة',
          example: 'Neun Schüler.',
          exampleTranslation: 'تسعة طلاب.',
        ),
        VocabularyItem(
          word: 'zehn',
          translation: '10 - عشرة',
          example: 'Zehn Finger.',
          exampleTranslation: 'عشرة أصابع.',
        ),
        VocabularyItem(
          word: 'elf',
          translation: '11 - أحد عشر',
          example: 'Elf Spieler.',
          exampleTranslation: 'أحد عشر لاعبا.',
        ),
        VocabularyItem(
          word: 'zwölf',
          translation: '12 - اثنا عشر',
          example: 'Zwölf Monate.',
          exampleTranslation: 'اثنا عشر شهرا.',
        ),
        VocabularyItem(
          word: 'dreizehn',
          translation: '13 - ثلاثة عشر',
          example: 'Dreizehn Kinder.',
          exampleTranslation: 'ثلاثة عشر طفلا.',
        ),
        VocabularyItem(
          word: 'vierzehn',
          translation: '14 - أربعة عشر',
          example: 'Vierzehn Tage.',
          exampleTranslation: 'أربعة عشر يوما.',
        ),
        VocabularyItem(
          word: 'fünfzehn',
          translation: '15 - خمسة عشر',
          example: 'Fünfzehn Euro.',
          exampleTranslation: 'خمسة عشر يوروا.',
        ),
        VocabularyItem(
          word: 'zwanzig',
          translation: '20 - عشرون',
          example: 'Zwanzig Jahre.',
          exampleTranslation: 'عشرون عاما.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "drei" in numbers?',
          correctAnswer: '3',
          options: ['3', '2', '4', '5'],
        ),
        QuizQuestion(
          question: 'How do you say 7 in German?',
          correctAnswer: 'sieben',
          options: ['sieben', 'sechs', 'acht', 'neun'],
        ),
        QuizQuestion(
          question: 'What number is "zwölf"?',
          correctAnswer: '12',
          options: ['12', '11', '13', '20'],
        ),
        QuizQuestion(
          question: '"fünf" means...',
          correctAnswer: '5',
          options: ['5', '4', '6', '15'],
        ),
        QuizQuestion(
          question: 'How do you say 20?',
          correctAnswer: 'zwanzig',
          options: ['zwanzig', 'zehn', 'zwölf', 'vierzehn'],
        ),
      ],
    ),
    LessonModel(
      id: 'a1_vocab_3',
      title: 'Familie',
      description: 'Family members',
      level: 'A1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 50,
      vocabulary: [
        VocabularyItem(
          word: 'die Mutter',
          translation: 'الأم / Mother',
          example: 'Meine Mutter kocht gut.',
          exampleTranslation: 'أمي تطبخ جيدا.',
        ),
        VocabularyItem(
          word: 'der Vater',
          translation: 'الأب / Father',
          example: 'Mein Vater arbeitet viel.',
          exampleTranslation: 'أبي يعمل كثيرا.',
        ),
        VocabularyItem(
          word: 'die Schwester',
          translation: 'الأخت / Sister',
          example: 'Meine Schwester ist nett.',
          exampleTranslation: 'أختي لطيفة.',
        ),
        VocabularyItem(
          word: 'der Bruder',
          translation: 'الأخ / Brother',
          example: 'Mein Bruder spielt Fußball.',
          exampleTranslation: 'أخي يلعب كرة القدم.',
        ),
        VocabularyItem(
          word: 'die Großmutter',
          translation: 'الجدة / Grandmother',
          example: 'Meine Großmutter erzählt Geschichten.',
          exampleTranslation: 'جدي تحكي القصص.',
        ),
        VocabularyItem(
          word: 'der Großvater',
          translation: 'الجد / Grandfather',
          example: 'Mein Großvater ist 80 Jahre alt.',
          exampleTranslation: 'جدي عمره 80 عاما.',
        ),
        VocabularyItem(
          word: 'die Eltern',
          translation: 'الوالدان / Parents',
          example: 'Meine Eltern wohnen in Berlin.',
          exampleTranslation: 'والداي يعيشان في برلين.',
        ),
        VocabularyItem(
          word: 'das Kind',
          translation: 'الطفل / Child',
          example: 'Das Kind spielt im Garten.',
          exampleTranslation: 'الطفل يلعب في الحديقة.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How do you say "mother" in German?',
          correctAnswer: 'die Mutter',
          options: ['die Mutter', 'der Vater', 'die Schwester', 'der Bruder'],
        ),
        QuizQuestion(
          question: 'What does "der Bruder" mean?',
          correctAnswer: 'Brother',
          options: ['Brother', 'Sister', 'Father', 'Uncle'],
        ),
        QuizQuestion(
          question: '"die Eltern" means...',
          correctAnswer: 'Parents',
          options: ['Parents', 'Children', 'Grandparents', 'Siblings'],
        ),
        QuizQuestion(
          question: 'How do you say "grandfather"?',
          correctAnswer: 'der Großvater',
          options: [
            'der Großvater',
            'die Großmutter',
            'der Vater',
            'der Onkel',
          ],
        ),
      ],
    ),
    // GRAMMAR
    LessonModel(
      id: 'a1_grammar_1',
      title: 'Verb "sein"',
      description: 'The verb "to be"',
      level: 'A1',
      language: 'German',
      category: 'Grammar',
      xpReward: 50,
      grammar: [
        GrammarRule(
          title: 'Das Verb "sein" (to be)',
          explanation:
              'The verb "sein" is the most important verb in German. It is irregular and must be memorized.',
          examples: [
            'ich bin (I am) - Ich bin Student.',
            'du bist (you are informal) - Du bist nett.',
            'er/sie ist (he/she is) - Er ist groß.',
            'wir sind (we are) - Wir sind Freunde.',
            'ihr seid (you all are) - Ihr seid lustig.',
            'sie/Sie sind (they/you formal are) - Sie sind Lehrer.',
          ],
          tip: 'The verb "sein" is irregular - each form is different!',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Ich ___ Student.',
          correctAnswer: 'bin',
          options: ['bin', 'bist', 'ist', 'sind'],
        ),
        QuizQuestion(
          question: 'Du ___ nett.',
          correctAnswer: 'bist',
          options: ['bist', 'bin', 'ist', 'sind'],
        ),
        QuizQuestion(
          question: 'Er ___ groß.',
          correctAnswer: 'ist',
          options: ['ist', 'bin', 'bist', 'sind'],
        ),
        QuizQuestion(
          question: 'Wir ___ Freunde.',
          correctAnswer: 'sind',
          options: ['sind', 'bin', 'bist', 'ist'],
        ),
      ],
    ),
    LessonModel(
      id: 'a1_grammar_2',
      title: 'Akkusativ',
      description: 'Accusative case for direct objects',
      level: 'A1',
      language: 'German',
      category: 'Grammar',
      xpReward: 50,
      grammar: [
        GrammarRule(
          title: 'Der Akkusativ (Accusative Case)',
          explanation:
              'The accusative case is used for the direct object of a sentence. Only the article changes for masculine nouns.',
          examples: [
            'der → den (masculine): Ich sehe den Mann.',
            'die → die (feminine): Ich sehe die Frau.',
            'das → das (neuter): Ich sehe das Kind.',
            'die → die (plural): Ich sehe die Kinder.',
          ],
          tip: 'Only masculine articles change in the accusative: der → den',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Ich sehe ___ Mann. (the man)',
          correctAnswer: 'den',
          options: ['den', 'der', 'das', 'die'],
        ),
        QuizQuestion(
          question: 'Ich kaufe ___ Auto. (the car)',
          correctAnswer: 'das',
          options: ['das', 'der', 'die', 'den'],
        ),
        QuizQuestion(
          question: 'Ich mag ___ Frau. (the woman)',
          correctAnswer: 'die',
          options: ['die', 'der', 'den', 'das'],
        ),
      ],
    ),
    // LISTENING
    LessonModel(
      id: 'a1_listen_1',
      title: 'Vorstellung',
      description: 'Introducing yourself',
      level: 'A1',
      language: 'German',
      category: 'Listening',
      xpReward: 50,
      vocabulary: [
        VocabularyItem(
          word: 'Ich heiße...',
          translation: 'اسمي / My name is...',
          example: 'Ich heiße Anna.',
          exampleTranslation: 'اسمي أنا.',
        ),
        VocabularyItem(
          word: 'Ich komme aus...',
          translation: 'أنا من / I come from...',
          example: 'Ich komme aus Ägypten.',
          exampleTranslation: 'أنا من مصر.',
        ),
        VocabularyItem(
          word: 'Ich bin ... Jahre alt.',
          translation: 'عمري ... سنة / I am ... years old',
          example: 'Ich bin 25 Jahre alt.',
          exampleTranslation: 'عمري 25 سنة.',
        ),
        VocabularyItem(
          word: 'Ich spreche...',
          translation: 'أتحدث / I speak...',
          example: 'Ich spreche Arabisch und Deutsch.',
          exampleTranslation: 'أتحدث العربية والألمانية.',
        ),
        VocabularyItem(
          word: 'Freut mich!',
          translation: 'تشرفت! / Nice to meet you!',
          example: 'Freut mich, dich kennenzulernen!',
          exampleTranslation: 'تشرفت بمعرفتك!',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How do you introduce yourself?',
          correctAnswer: 'Ich heiße...',
          options: [
            'Ich heiße...',
            'Ich bin...',
            'Ich komme...',
            'Ich spreche...',
          ],
        ),
        QuizQuestion(
          question: '"Freut mich" means...',
          correctAnswer: 'Nice to meet you',
          options: ['Nice to meet you', 'Goodbye', 'Thank you', 'Please'],
        ),
      ],
    ),
  ];

  // ==================== A2 ELEMENTARY ====================
  static List<LessonModel> _a2Lessons() => [
    LessonModel(
      id: 'a2_vocab_1',
      title: 'Im Restaurant',
      description: 'At the restaurant',
      level: 'A2',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 60,
      vocabulary: [
        VocabularyItem(
          word: 'die Speisekarte',
          translation: 'قائمة الطعام / Menu',
          example: 'Die Speisekarte, bitte!',
          exampleTranslation: 'القائمة، من فضلك!',
        ),
        VocabularyItem(
          word: 'das Frühstück',
          translation: 'الفطور / Breakfast',
          example: 'Das Frühstück ist fertig.',
          exampleTranslation: 'الفطور جاهز.',
        ),
        VocabularyItem(
          word: 'das Mittagessen',
          translation: 'الغداء / Lunch',
          example: 'Wir essen das Mittagessen um 12 Uhr.',
          exampleTranslation: 'نتغدى الساعة 12.',
        ),
        VocabularyItem(
          word: 'das Abendessen',
          translation: 'العشاء / Dinner',
          example: 'Das Abendessen schmeckt gut.',
          exampleTranslation: 'العشاء لذيذ.',
        ),
        VocabularyItem(
          word: 'der Kaffee',
          translation: 'القهوة / Coffee',
          example: 'Einen Kaffee, bitte.',
          exampleTranslation: 'قهوة، من فضلك.',
        ),
        VocabularyItem(
          word: 'das Bier',
          translation: 'البيرة / Beer',
          example: 'Ein Bier, bitte.',
          exampleTranslation: 'بيرة، من فضلك.',
        ),
        VocabularyItem(
          word: 'die Rechnung',
          translation: 'الفاتورة / Bill',
          example: 'Die Rechnung, bitte!',
          exampleTranslation: 'الفاتورة، من فضلك!',
        ),
        VocabularyItem(
          word: 'lecker',
          translation: 'لذيذ / Delicious',
          example: 'Das Essen ist lecker!',
          exampleTranslation: 'الطعام لذيذ!',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How do you ask for the menu?',
          correctAnswer: 'Die Speisekarte, bitte!',
          options: [
            'Die Speisekarte, bitte!',
            'Die Rechnung, bitte!',
            'Ein Kaffee, bitte!',
            'Danke!',
          ],
        ),
        QuizQuestion(
          question: 'What is "das Abendessen"?',
          correctAnswer: 'Dinner',
          options: ['Dinner', 'Lunch', 'Breakfast', 'Snack'],
        ),
        QuizQuestion(
          question: '"Lecker" means...',
          correctAnswer: 'Delicious',
          options: ['Delicious', 'Expensive', 'Cheap', 'Hot'],
        ),
      ],
    ),
    LessonModel(
      id: 'a2_grammar_1',
      title: 'Perfekt',
      description: 'Past tense with haben',
      level: 'A2',
      language: 'German',
      category: 'Grammar',
      xpReward: 60,
      grammar: [
        GrammarRule(
          title: 'Das Perfekt (Present Perfect)',
          explanation:
              'The Perfekt is formed with haben/sein + past participle. It\'s the most common past tense in spoken German.',
          examples: [
            'Ich habe gegessen. (I have eaten / I ate)',
            'Er hat getrunken. (He has drunk / He drank)',
            'Wir sind gegangen. (We have gone / We went)',
            'Sie hat gelesen. (She has read / She read)',
          ],
          tip:
              'Use "sein" with movement verbs (gehen, kommen, fahren) and "haben" with most others.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Ich ___ gegessen. (I ate)',
          correctAnswer: 'habe',
          options: ['habe', 'bin', 'hat', 'ist'],
        ),
        QuizQuestion(
          question: 'Wir ___ gegangen. (We went)',
          correctAnswer: 'sind',
          options: ['sind', 'haben', 'hat', 'ist'],
        ),
        QuizQuestion(
          question: 'Er ___ getrunken. (He drank)',
          correctAnswer: 'hat',
          options: ['hat', 'ist', 'habe', 'sind'],
        ),
      ],
    ),
    LessonModel(
      id: 'a2_vocab_2',
      title: 'Kleidung',
      description: 'Clothing items',
      level: 'A2',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 60,
      vocabulary: [
        VocabularyItem(
          word: 'das Hemd',
          translation: 'قميص / Shirt',
          example: 'Das Hemd ist blau.',
          exampleTranslation: 'القميص أزرق.',
        ),
        VocabularyItem(
          word: 'die Hose',
          translation: 'بنطلون / Pants',
          example: 'Die Hose ist lang.',
          exampleTranslation: 'البنطلون طويل.',
        ),
        VocabularyItem(
          word: 'das Kleid',
          translation: 'فستان / Dress',
          example: 'Das Kleid ist schön.',
          exampleTranslation: 'الفستان جميل.',
        ),
        VocabularyItem(
          word: 'der Schuh',
          translation: 'حذاء / Shoe',
          example: 'Die Schuhe sind neu.',
          exampleTranslation: 'الحذاء جديد.',
        ),
        VocabularyItem(
          word: 'der Mantel',
          translation: 'معطف / Coat',
          example: 'Der Mantel ist warm.',
          exampleTranslation: 'المعطف دافئ.',
        ),
        VocabularyItem(
          word: 'die Jacke',
          translation: 'سترة / Jacket',
          example: 'Ich brauche eine Jacke.',
          exampleTranslation: 'أحتاج سترة.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "die Hose"?',
          correctAnswer: 'Pants',
          options: ['Pants', 'Shirt', 'Dress', 'Shoes'],
        ),
        QuizQuestion(
          question: 'How do you say "shoe" in German?',
          correctAnswer: 'der Schuh',
          options: ['der Schuh', 'die Hose', 'das Hemd', 'die Jacke'],
        ),
      ],
    ),
    LessonModel(
      id: 'a2_grammar_2',
      title: 'Dativ',
      description: 'Dative case for indirect objects',
      level: 'A2',
      language: 'German',
      category: 'Grammar',
      xpReward: 60,
      grammar: [
        GrammarRule(
          title: 'Der Dativ (Dative Case)',
          explanation:
              'The dative case is used for the indirect object (to whom/for whom).',
          examples: [
            'der → dem (masculine): Ich gebe dem Mann Geld.',
            'die → der (feminine): Ich gebe der Frau Geld.',
            'das → dem (neuter): Ich gebe dem Kind Geld.',
            'die → den (plural): Ich gebe den Kindern Geld.',
          ],
          tip:
              'In dative plural, add -n to the noun (except if it already ends in -n).',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Ich gebe ___ Mann Geld. (to the man)',
          correctAnswer: 'dem',
          options: ['dem', 'der', 'den', 'das'],
        ),
        QuizQuestion(
          question: 'Ich gebe ___ Frau Geld. (to the woman)',
          correctAnswer: 'der',
          options: ['der', 'die', 'dem', 'den'],
        ),
      ],
    ),
  ];

  // ==================== B1 INTERMEDIATE ====================
  static List<LessonModel> _b1Lessons() => [
    LessonModel(
      id: 'b1_vocab_1',
      title: 'Im Büro',
      description: 'At the office',
      level: 'B1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 70,
      vocabulary: [
        VocabularyItem(
          word: 'der Meeting',
          translation: 'اجتماع / Meeting',
          example: 'Das Meeting beginnt um 10 Uhr.',
          exampleTranslation: 'الاجتماع يبدأ الساعة 10.',
        ),
        VocabularyItem(
          word: 'der Computer',
          translation: 'حاسوب / Computer',
          example: 'Ich arbeite am Computer.',
          exampleTranslation: 'أعمل على الحاسوب.',
        ),
        VocabularyItem(
          word: 'das Telefon',
          translation: 'هاتف / Telephone',
          example: 'Das Telefon klingelt.',
          exampleTranslation: 'الهاتف يرن.',
        ),
        VocabularyItem(
          word: 'die Besprechung',
          translation: 'مناقشة / Discussion',
          example: 'Die Besprechung war produktiv.',
          exampleTranslation: 'المناقشة كانت مثمرة.',
        ),
        VocabularyItem(
          word: 'der Chef',
          translation: 'المدير / Boss',
          example: 'Der Chef ist im Büro.',
          exampleTranslation: 'المدير في المكتب.',
        ),
        VocabularyItem(
          word: 'die Kollegin',
          translation: 'زميلة العمل / Female colleague',
          example: 'Meine Kollegin ist nett.',
          exampleTranslation: 'زميلتي لطيفة.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "das Meeting"?',
          correctAnswer: 'Meeting',
          options: ['Meeting', 'Office', 'Computer', 'Phone'],
        ),
        QuizQuestion(
          question: '"Der Chef" means...',
          correctAnswer: 'Boss',
          options: ['Boss', 'Colleague', 'Employee', 'Manager'],
        ),
      ],
    ),
    LessonModel(
      id: 'b1_grammar_1',
      title: 'Konjunktiv II',
      description: 'Subjunctive II for hypotheticals',
      level: 'B1',
      language: 'German',
      category: 'Grammar',
      xpReward: 70,
      grammar: [
        GrammarRule(
          title: 'Konjunktiv II (Subjunctive II)',
          explanation:
              'Used for hypothetical, unreal, or polite situations. Often uses "würde" + infinitive.',
          examples: [
            'Ich würde gerne reisen. (I would like to travel.)',
            'Wenn ich reich wäre, würde ich ein Haus kaufen. (If I were rich, I would buy a house.)',
            'Könnten Sie mir helfen? (Could you help me?)',
            'Hätte ich mehr Zeit... (If I had more time...)',
          ],
          tip: '"würde" + infinitive is the easiest way to form Konjunktiv II.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Ich ___ gerne reisen. (I would like to travel)',
          correctAnswer: 'würde',
          options: ['würde', 'werde', 'habe', 'bin'],
        ),
        QuizQuestion(
          question: 'How do you say "Could you help me?"',
          correctAnswer: 'Könnten Sie mir helfen?',
          options: [
            'Könnten Sie mir helfen?',
            'Können Sie mir helfen?',
            'Helfen Sie mir!',
            'Sie helfen mir.',
          ],
        ),
      ],
    ),
    LessonModel(
      id: 'b1_vocab_2',
      title: 'Reisen',
      description: 'Travel vocabulary',
      level: 'B1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 70,
      vocabulary: [
        VocabularyItem(
          word: 'der Flughafen',
          translation: 'مطار / Airport',
          example: 'Wir fahren zum Flughafen.',
          exampleTranslation: 'نسافر إلى المطار.',
        ),
        VocabularyItem(
          word: 'der Bahnhof',
          translation: 'محطة القطار / Train station',
          example: 'Der Bahnhof ist groß.',
          exampleTranslation: 'محطة القطار كبيرة.',
        ),
        VocabularyItem(
          word: 'das Hotel',
          translation: 'فندق / Hotel',
          example: 'Das Hotel ist teuer.',
          exampleTranslation: 'الفندق غالي.',
        ),
        VocabularyItem(
          word: 'der Reisepass',
          translation: 'جواز السفر / Passport',
          example: 'Ich brauche meinen Reisepass.',
          exampleTranslation: 'أحتاج جواز سفري.',
        ),
        VocabularyItem(
          word: 'die Fahrkarte',
          translation: 'تذكرة / Ticket',
          example: 'Eine Fahrkarte nach Berlin, bitte.',
          exampleTranslation: 'تذكرة إلى برلين، من فضلك.',
        ),
        VocabularyItem(
          word: 'die Unterkunft',
          translation: 'إقامة / Accommodation',
          example: 'Die Unterkunft ist gut.',
          exampleTranslation: 'الإقامة جيدة.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "der Flughafen"?',
          correctAnswer: 'Airport',
          options: ['Airport', 'Train station', 'Hotel', 'Bus stop'],
        ),
        QuizQuestion(
          question: '"Die Fahrkarte" means...',
          correctAnswer: 'Ticket',
          options: ['Ticket', 'Passport', 'Map', 'Luggage'],
        ),
      ],
    ),
  ];

  // ==================== B2 UPPER INTERMEDIATE ====================
  static List<LessonModel> _b2Lessons() => [
    LessonModel(
      id: 'b2_vocab_1',
      title: 'Politik & Gesellschaft',
      description: 'Politics and society',
      level: 'B2',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 80,
      vocabulary: [
        VocabularyItem(
          word: 'die Demokratie',
          translation: 'ديمقراطية / Democracy',
          example: 'Die Demokratie ist wichtig.',
          exampleTranslation: 'الديمقراطية مهمة.',
        ),
        VocabularyItem(
          word: 'die Regierung',
          translation: 'حكومة / Government',
          example: 'Die Regierung hat entschieden.',
          exampleTranslation: 'الحكومة قررت.',
        ),
        VocabularyItem(
          word: 'die Wahlen',
          translation: 'انتخابات / Elections',
          example: 'Die Wahlen finden statt.',
          exampleTranslation: 'الانتخابات تجري.',
        ),
        VocabularyItem(
          word: 'das Gesetz',
          translation: 'قانون / Law',
          example: 'Das Gesetz ist streng.',
          exampleTranslation: 'القانون صارم.',
        ),
        VocabularyItem(
          word: 'die Meinung',
          translation: 'رأي / Opinion',
          example: 'Was ist Ihre Meinung?',
          exampleTranslation: 'ما رأيك؟',
        ),
        VocabularyItem(
          word: 'die Gesellschaft',
          translation: 'مجتمع / Society',
          example: 'Die Gesellschaft verändert sich.',
          exampleTranslation: 'المجتمع يتغير.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "die Demokratie"?',
          correctAnswer: 'Democracy',
          options: ['Democracy', 'Government', 'Law', 'Society'],
        ),
        QuizQuestion(
          question: '"Die Regierung" means...',
          correctAnswer: 'Government',
          options: ['Government', 'Elections', 'Society', 'Opinion'],
        ),
      ],
    ),
    LessonModel(
      id: 'b2_grammar_1',
      title: 'Passiv',
      description: 'Passive voice',
      level: 'B2',
      language: 'German',
      category: 'Grammar',
      xpReward: 80,
      grammar: [
        GrammarRule(
          title: 'Das Passiv (Passive Voice)',
          explanation:
              'Formed with "werden" + past participle. Used when the action is more important than the doer.',
          examples: [
            'Das Buch wird gelesen. (The book is being read.)',
            'Die Arbeit wurde erledigt. (The work was done.)',
            'Hier wird Deutsch gelernt. (German is learned here.)',
            'Das Haus wird gebaut. (The house is being built.)',
          ],
          tip:
              'Use "von" + dative to express the doer: Das Buch wird von dem Schüler gelesen.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Das Buch wird ___. (The book is being read)',
          correctAnswer: 'gelesen',
          options: ['gelesen', 'lesen', 'liest', 'las'],
        ),
        QuizQuestion(
          question: 'Die Arbeit wurde ___. (The work was done)',
          correctAnswer: 'erledigt',
          options: ['erledigt', 'erledigen', 'erledigt', 'erledigte'],
        ),
      ],
    ),
    LessonModel(
      id: 'b2_vocab_2',
      title: 'Wissenschaft',
      description: 'Science vocabulary',
      level: 'B2',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 80,
      vocabulary: [
        VocabularyItem(
          word: 'die Forschung',
          translation: 'بحث / Research',
          example: 'Die Forschung ist wichtig.',
          exampleTranslation: 'البحث مهم.',
        ),
        VocabularyItem(
          word: 'das Experiment',
          translation: 'تجربة / Experiment',
          example: 'Das Experiment war erfolgreich.',
          exampleTranslation: 'التجربة نجحت.',
        ),
        VocabularyItem(
          word: 'die Theorie',
          translation: 'نظرية / Theory',
          example: 'Die Theorie ist komplex.',
          exampleTranslation: 'النظرية معقدة.',
        ),
        VocabularyItem(
          word: 'die Ergebnis',
          translation: 'نتيجة / Result',
          example: 'Das Ergebnis ist überraschend.',
          exampleTranslation: 'النتيجة مفاجئة.',
        ),
        VocabularyItem(
          word: 'die Technologie',
          translation: 'تكنولوجيا / Technology',
          example: 'Die Technologie schreitet voran.',
          exampleTranslation: 'التكنولوجيا تتقدم.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "die Forschung"?',
          correctAnswer: 'Research',
          options: ['Research', 'Experiment', 'Theory', 'Technology'],
        ),
        QuizQuestion(
          question: '"Das Experiment" means...',
          correctAnswer: 'Experiment',
          options: ['Experiment', 'Research', 'Result', 'Theory'],
        ),
      ],
    ),
  ];

  // ==================== C1 ADVANCED ====================
  static List<LessonModel> _c1Lessons() => [
    LessonModel(
      id: 'c1_vocab_1',
      title: 'Wirtschaft',
      description: 'Economics vocabulary',
      level: 'C1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 90,
      vocabulary: [
        VocabularyItem(
          word: 'die Inflation',
          translation: 'تضخم / Inflation',
          example: 'Die Inflation steigt.',
          exampleTranslation: 'التضخم يرتفع.',
        ),
        VocabularyItem(
          word: 'die Konjunktur',
          translation: 'ازدهار اقتصادي / Economy',
          example: 'Die Konjunktur verbessert sich.',
          exampleTranslation: 'الاقتصاد يتحسن.',
        ),
        VocabularyItem(
          word: 'die Börse',
          translation: 'بورصة / Stock exchange',
          example: 'Die Börse öffnet um 9 Uhr.',
          exampleTranslation: 'البورصة تفتح الساعة 9.',
        ),
        VocabularyItem(
          word: 'die Steuer',
          translation: 'ضريبة / Tax',
          example: 'Die Steuern sind hoch.',
          exampleTranslation: 'الضرائب مرتفعة.',
        ),
        VocabularyItem(
          word: 'die Investition',
          translation: 'استثمار / Investment',
          example: 'Die Investition war klug.',
          exampleTranslation: 'الاستثمار كان ذكيا.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "die Inflation"?',
          correctAnswer: 'Inflation',
          options: ['Inflation', 'Economy', 'Tax', 'Investment'],
        ),
        QuizQuestion(
          question: '"Die Börse" means...',
          correctAnswer: 'Stock exchange',
          options: ['Stock exchange', 'Bank', 'Tax', 'Economy'],
        ),
      ],
    ),
    LessonModel(
      id: 'c1_grammar_1',
      title: 'Konjunktiv I',
      description: 'Subjunctive I for reported speech',
      level: 'C1',
      language: 'German',
      category: 'Grammar',
      xpReward: 90,
      grammar: [
        GrammarRule(
          title: 'Konjunktiv I (Subjunctive I)',
          explanation:
              'Used for reported/indirect speech. Forms: ich sei, du sei, er/sie sei, wir seien, ihr seiet, sie seien.',
          examples: [
            'Er sagt, er sei krank. (He says he is sick.)',
            'Sie meint, das Essen sei lecker. (She thinks the food is delicious.)',
            'Er sagt, er habe keine Zeit. (He says he has no time.)',
            'Sie sagt, sie komme aus Berlin. (She says she comes from Berlin.)',
          ],
          tip:
              'Use Konjunktiv I to report what someone else said without saying if it\'s true.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Er sagt, er ___ krank. (He says he is sick)',
          correctAnswer: 'sei',
          options: ['sei', 'ist', 'war', 'hat'],
        ),
        QuizQuestion(
          question:
              'Sie sagt, sie ___ aus Berlin. (She says she comes from Berlin)',
          correctAnswer: 'komme',
          options: ['komme', 'kommt', 'kam', 'hat'],
        ),
      ],
    ),
    LessonModel(
      id: 'c1_vocab_2',
      title: 'Philosophie',
      description: 'Philosophy vocabulary',
      level: 'C1',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 90,
      vocabulary: [
        VocabularyItem(
          word: 'die Ethik',
          translation: 'أخلاقيات / Ethics',
          example: 'Die Ethik ist ein wichtiges Fach.',
          exampleTranslation: 'الأخلاقيات مادة مهمة.',
        ),
        VocabularyItem(
          word: 'die Logik',
          translation: 'منطق / Logic',
          example: 'Die Logik hilft beim Denken.',
          exampleTranslation: 'المنطق يساعد في التفكير.',
        ),
        VocabularyItem(
          word: 'die Wahrheit',
          translation: 'حقيقة / Truth',
          example: 'Die Wahrheit ist wichtig.',
          exampleTranslation: 'الحقيقة مهمة.',
        ),
        VocabularyItem(
          word: 'das Bewusstsein',
          translation: 'وعي / Consciousness',
          example: 'Das Bewusstsein ist komplex.',
          exampleTranslation: 'الوعي معقد.',
        ),
        VocabularyItem(
          word: 'die Freiheit',
          translation: 'حرية / Freedom',
          example: 'Die Freiheit ist ein Grundrecht.',
          exampleTranslation: 'الحرية حق أساسي.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "die Ethik"?',
          correctAnswer: 'Ethics',
          options: ['Ethics', 'Logic', 'Truth', 'Freedom'],
        ),
        QuizQuestion(
          question: '"Die Wahrheit" means...',
          correctAnswer: 'Truth',
          options: ['Truth', 'Freedom', 'Logic', 'Consciousness'],
        ),
      ],
    ),
  ];

  // ==================== C2 MASTERY ====================
  static List<LessonModel> _c2Lessons() => [
    LessonModel(
      id: 'c2_vocab_1',
      title: 'Literatur',
      description: 'Literature vocabulary',
      level: 'C2',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 100,
      vocabulary: [
        VocabularyItem(
          word: 'die Prosa',
          translation: 'نثر / Prose',
          example: 'Die Prosa ist schön geschrieben.',
          exampleTranslation: 'النثر مكتوب بجمال.',
        ),
        VocabularyItem(
          word: 'das Epos',
          translation: 'ملحمة / Epic',
          example: 'Das Epos erzählt eine Geschichte.',
          exampleTranslation: 'الملحمة تحكي قصة.',
        ),
        VocabularyItem(
          word: 'die Lyrik',
          translation: 'شعر / Poetry',
          example: 'Die Lyrik ist ausdrucksstark.',
          exampleTranslation: 'الشعر تعبيري.',
        ),
        VocabularyItem(
          word: 'die Allegorie',
          translation: 'استعارة / Allegory',
          example: 'Die Allegorie hat eine tiefere Bedeutung.',
          exampleTranslation: 'الاستعارة لها معنى أعمق.',
        ),
        VocabularyItem(
          word: 'die Metapher',
          translation: 'استعارة / Metaphor',
          example: 'Die Metapher macht den Text lebendig.',
          exampleTranslation: 'الاستعارة تجعل النص حيا.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "die Lyrik"?',
          correctAnswer: 'Poetry',
          options: ['Poetry', 'Prose', 'Epic', 'Allegory'],
        ),
        QuizQuestion(
          question: '"Das Epos" means...',
          correctAnswer: 'Epic',
          options: ['Epic', 'Poetry', 'Prose', 'Metaphor'],
        ),
      ],
    ),
    LessonModel(
      id: 'c2_grammar_1',
      title: 'Erweitertes Passiv',
      description: 'Advanced passive constructions',
      level: 'C2',
      language: 'German',
      category: 'Grammar',
      xpReward: 100,
      grammar: [
        GrammarRule(
          title: 'Erweitertes Passiv (Extended Passive)',
          explanation:
              'Advanced passive constructions with modal verbs, perfect tense, and prepositional phrases.',
          examples: [
            'Das Buch sollte gelesen werden. (The book should be read.)',
            'Das Haus ist gebaut worden. (The house has been built.)',
            'Hier kann man Deutsch lernen. (German can be learned here.)',
            'Das Projekt wurde von allen Mitgliedern unterstützt. (The project was supported by all members.)',
          ],
          tip:
              'Combine modal verbs with passive: konnte + past participle + werden',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Das Buch sollte ___ werden. (The book should be read)',
          correctAnswer: 'gelesen',
          options: ['gelesen', 'lesen', 'liest', 'las'],
        ),
        QuizQuestion(
          question: 'Das Haus ist ___ worden. (The house has been built)',
          correctAnswer: 'gebaut',
          options: ['gebaut', 'bauen', 'baute', 'gebaut'],
        ),
      ],
    ),
    LessonModel(
      id: 'c2_vocab_2',
      title: 'Kunst & Kultur',
      description: 'Art and culture',
      level: 'C2',
      language: 'German',
      category: 'Vocabulary',
      xpReward: 100,
      vocabulary: [
        VocabularyItem(
          word: 'die Ästhetik',
          translation: 'جماليات / Aesthetics',
          example: 'Die Ästhetik des Gebäudes ist beeindruckend.',
          exampleTranslation: 'جماليات المبنى مذهلة.',
        ),
        VocabularyItem(
          word: 'das Meisterwerk',
          translation: 'تحفة / Masterpiece',
          example: 'Das Gemälde ist ein Meisterwerk.',
          exampleTranslation: 'اللوحة تحفة فنية.',
        ),
        VocabularyItem(
          word: 'die Ausstellung',
          translation: 'معرض / Exhibition',
          example: 'Die Ausstellung ist sehenswert.',
          exampleTranslation: 'المعرض يستحق المشاهدة.',
        ),
        VocabularyItem(
          word: 'die Tradition',
          translation: 'تقليد / Tradition',
          example: 'Die Tradition ist alt.',
          exampleTranslation: 'التقاليد قديمة.',
        ),
        VocabularyItem(
          word: 'das Erbe',
          translation: 'تراث / Heritage',
          example: 'Das kulturelle Erbe ist wichtig.',
          exampleTranslation: 'التراث الثقافي مهم.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What is "das Meisterwerk"?',
          correctAnswer: 'Masterpiece',
          options: ['Masterpiece', 'Exhibition', 'Tradition', 'Heritage'],
        ),
        QuizQuestion(
          question: '"Die Ausstellung" means...',
          correctAnswer: 'Exhibition',
          options: ['Exhibition', 'Museum', 'Gallery', 'Heritage'],
        ),
      ],
    ),
  ];
}
