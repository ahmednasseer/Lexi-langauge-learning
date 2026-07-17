import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

interface PronunciationResult {
  accuracy: number;
  fluency: number;
  grammar: number;
  mistakes: string[];
  suggestions: string[];
  xpEarned: number;
  grade: string;
}

interface SpeakingExercise {
  id: string;
  level: string;
  sentence: string;
  translation: string;
  category: string;
  difficulty: number;
}

interface ListeningQuestion {
  id: string;
  audioText: string;
  question: string;
  options: string[];
  correctIndex: number;
  explanation: string;
  translation: string;
}

@Injectable()
export class SpeakingService {
  constructor(private prisma: PrismaService) {}

  async analyzePronunciation(
    userId: string,
    spokenText: string,
    targetText: string,
    level: string,
  ): Promise<PronunciationResult> {
    const spokenLower = spokenText.toLowerCase().trim();
    const targetLower = targetText.toLowerCase().trim();

    const accuracy = this.calculateSimilarity(spokenLower, targetLower);
    const grammar = this.checkGrammar(spokenLower, targetLower);
    const fluency = this.calculateFluency(spokenLower, targetLower);
    const mistakes = this.findMistakes(spokenLower, targetLower);
    const suggestions = this.generateSuggestions(accuracy, grammar, mistakes);

    const overallScore = (accuracy + fluency + grammar) / 3;
    const xpEarned = overallScore >= 90 ? 100 : overallScore >= 70 ? 50 : 20;
    const grade = this.getGrade(overallScore);

    // Save to database
    await this.prisma.pronunciationAttempt.create({
      data: {
        userId,
        spokenText,
        targetText,
        accuracy,
        fluency,
        grammar,
        overallScore,
        xpEarned,
        level,
      },
    });

    // Update user XP
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        totalXp: { increment: xpEarned },
      },
    });

    return {
      accuracy,
      fluency,
      grammar,
      mistakes,
      suggestions,
      xpEarned,
      grade,
    };
  }

  async getExercises(level: string): Promise<SpeakingExercise[]> {
    return this.getExercisesByLevel(level);
  }

  async getListeningQuestions(level: string): Promise<ListeningQuestion[]> {
    return this.getQuestionsByLevel(level);
  }

  async getStats(userId: string) {
    const attempts = await this.prisma.pronunciationAttempt.findMany({
      where: { userId },
    });

    const totalAttempts = attempts.length;
    const averageScore = totalAttempts > 0
      ? attempts.reduce((sum, a) => sum + a.overallScore, 0) / totalAttempts
      : 0;
    const perfectCount = attempts.filter(a => a.overallScore >= 95).length;
    const totalXp = attempts.reduce((sum, a) => sum + a.xpEarned, 0);

    return {
      totalAttempts,
      averageScore: Math.round(averageScore * 100) / 100,
      perfectCount,
      totalXp,
    };
  }

  async getHistory(userId: string) {
    return this.prisma.pronunciationAttempt.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  private calculateSimilarity(a: string, b: string): number {
    if (a === b) return 100;
    const aWords = a.split(' ');
    const bWords = b.split(' ');
    let matches = 0;
    for (const word of aWords) {
      if (bWords.includes(word)) matches++;
    }
    if (bWords.length === 0) return 0;
    return Math.min(100, Math.round((matches / bWords.length) * 100));
  }

  private checkGrammar(spoken: string, target: string): number {
    let score = 100;
    if (target.includes(' ist ') && !spoken.includes(' ist ')) score -= 10;
    if (target.includes(' habe ') && !spoken.includes(' habe ')) score -= 10;
    if (target.includes(' werden ') && !spoken.includes(' werden ')) score -= 10;
    if (target.includes(' der ') && !spoken.includes(' der ')) score -= 5;
    if (target.includes(' die ') && !spoken.includes(' die ')) score -= 5;
    if (target.includes(' das ') && !spoken.includes(' das ')) score -= 5;
    return Math.max(0, Math.min(100, score));
  }

  private calculateFluency(spoken: string, target: string): number {
    if (spoken.length === 0) return 0;
    const hasPunctuation = spoken.includes('.') || spoken.includes('!') || spoken.includes('?');
    const lengthRatio = spoken.length / target.length;
    let score = 80;
    if (hasPunctuation) score += 10;
    if (lengthRatio > 0.7 && lengthRatio < 1.3) score += 10;
    return Math.max(0, Math.min(100, score));
  }

  private findMistakes(spoken: string, target: string): string[] {
    const mistakes: string[] = [];
    const targetWords = target.split(' ');
    const spokenWords = spoken.split(' ');
    for (let i = 0; i < targetWords.length && i < spokenWords.length; i++) {
      if (targetWords[i] !== spokenWords[i]) {
        mistakes.push(`Expected "${targetWords[i]}" but said "${spokenWords[i]}"`);
      }
    }
    if (spokenWords.length < targetWords.length) {
      mistakes.push('Sentence incomplete');
    } else if (spokenWords.length > targetWords.length) {
      mistakes.push('Too many words');
    }
    return mistakes;
  }

  private generateSuggestions(accuracy: number, grammar: number, mistakes: string[]): string[] {
    const suggestions: string[] = [];
    if (accuracy < 70) suggestions.push('Focus on pronunciation of each word');
    if (grammar < 80) suggestions.push('Review sentence structure');
    if (mistakes.length > 2) suggestions.push('Try speaking slower');
    if (suggestions.length === 0) suggestions.push('Great job! Keep practicing!');
    return suggestions;
  }

  private getGrade(score: number): string {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  private getExercisesByLevel(level: string): SpeakingExercise[] {
    const exercises: Record<string, SpeakingExercise[]> = {
      A1: [
        { id: 's1', level: 'A1', sentence: 'Ich heiße Ahmed.', translation: 'My name is Ahmed.', category: 'introduction', difficulty: 1 },
        { id: 's2', level: 'A1', sentence: 'Guten Morgen!', translation: 'Good morning!', category: 'greetings', difficulty: 1 },
        { id: 's3', level: 'A1', sentence: 'Wie geht es Ihnen?', translation: 'How are you?', category: 'greetings', difficulty: 1 },
        { id: 's4', level: 'A1', sentence: 'Ich möchte einen Kaffee bestellen.', translation: 'I would like to order a coffee.', category: 'restaurant', difficulty: 2 },
        { id: 's5', level: 'A1', sentence: 'Wo ist der Bahnhof?', translation: 'Where is the train station?', category: 'travel', difficulty: 2 },
        { id: 's6', level: 'A1', sentence: 'Das ist sehr gut!', translation: 'That is very good!', category: 'general', difficulty: 1 },
      ],
      A2: [
        { id: 's7', level: 'A2', sentence: 'Ich habe gestern einen Film gesehen.', translation: 'I watched a movie yesterday.', category: 'past tense', difficulty: 2 },
        { id: 's8', level: 'A2', sentence: 'Können Sie mir bitte helfen?', translation: 'Can you please help me?', category: 'requests', difficulty: 2 },
        { id: 's9', level: 'A2', sentence: 'Ich gehe jeden Tag zur Arbeit.', translation: 'I go to work every day.', category: 'daily routine', difficulty: 2 },
        { id: 's10', level: 'A2', sentence: 'Das Essen war sehr lecker.', translation: 'The food was very delicious.', category: 'restaurant', difficulty: 2 },
      ],
      B1: [
        { id: 's11', level: 'B1', sentence: 'Obwohl es regnet, gehe ich spazieren.', translation: 'Although it is raining, I am going for a walk.', category: 'conjunctions', difficulty: 3 },
        { id: 's12', level: 'B1', sentence: 'Ich hätte gerne einen Tisch für zwei Personen.', translation: 'I would like a table for two.', category: 'restaurant', difficulty: 3 },
        { id: 's13', level: 'B1', sentence: 'Können Sie das bitte langsamer sagen?', translation: 'Can you please speak slower?', category: 'requests', difficulty: 3 },
        { id: 's14', level: 'B1', sentence: 'Ich interessiere mich für deutsche Kultur.', translation: 'I am interested in German culture.', category: 'hobbies', difficulty: 3 },
      ],
      B2: [
        { id: 's15', level: 'B2', sentence: 'Trotz der Schwierigkeiten habe ich es geschafft.', translation: 'Despite the difficulties, I managed it.', category: 'complex sentences', difficulty: 4 },
        { id: 's16', level: 'B2', sentence: 'Ich würde gerne meine Meinung dazu äußern.', translation: 'I would like to express my opinion on this.', category: 'opinions', difficulty: 4 },
        { id: 's17', level: 'B2', sentence: 'Die Situation hat sich grundlegend verändert.', translation: 'The situation has fundamentally changed.', category: 'current events', difficulty: 4 },
      ],
      C1: [
        { id: 's18', level: 'C1', sentence: 'Man kann sagen, dass die Globalisierung sowohl Chancen als auch Risiken birgt.', translation: 'One can say that globalization entails both opportunities and risks.', category: 'academic', difficulty: 5 },
        { id: 's19', level: 'C1', sentence: 'Die Forschungsergebnisse deuten darauf hin, dass...', translation: 'The research results suggest that...', category: 'academic', difficulty: 5 },
      ],
      C2: [
        { id: 's20', level: 'C2', sentence: 'Es ist unbestreitbar, dass die digitale Transformation die Art und Weise, wie wir kommunizieren, revolutioniert hat.', translation: 'It is undeniable that the digital transformation has revolutionized the way we communicate.', category: 'academic', difficulty: 5 },
      ],
    };
    return exercises[level] || [];
  }

  private getQuestionsByLevel(level: string): ListeningQuestion[] {
    const questions: Record<string, ListeningQuestion[]> = {
      A1: [
        {
          id: 'l1',
          audioText: 'Guten Morgen! Wie geht es Ihnen?',
          question: 'Was sagt die Person?',
          options: ['Gute Nacht', 'Guten Morgen', 'Auf Wiedersehen', 'Tschüss'],
          correctIndex: 1,
          explanation: 'The person says "Guten Morgen" which means "Good morning".',
          translation: 'Good morning! How are you?',
        },
        {
          id: 'l2',
          audioText: 'Ich möchte einen Kaffee bestellen.',
          question: 'Was möchte die Person?',
          options: ['Tee', 'Kaffee', 'Wasser', 'Saft'],
          correctIndex: 1,
          explanation: 'The person says "einen Kaffee bestellen" which means "order a coffee".',
          translation: 'I would like to order a coffee.',
        },
      ],
      A2: [
        {
          id: 'l3',
          audioText: 'Ich habe gestern einen Film im Kino gesehen.',
          question: 'Was hat die Person gestern gemacht?',
          options: ['Ein Buch gelesen', 'Einen Film gesehen', 'Musik gehört', 'Ein Lied gesungen'],
          correctIndex: 1,
          explanation: 'The person says "einen Film gesehen" which means "watched a movie".',
          translation: 'I watched a movie in the cinema yesterday.',
        },
        {
          id: 'l4',
          audioText: 'Der Zug fährt um acht Uhr ab.',
          question: 'Wann fährt der Zug?',
          options: ['Um sieben Uhr', 'Um acht Uhr', 'Um neun Uhr', 'Um zehn Uhr'],
          correctIndex: 1,
          explanation: 'The person says "um acht Uhr" which means "at eight o\'clock".',
          translation: 'The train departs at eight o\'clock.',
        },
      ],
      B1: [
        {
          id: 'l5',
          audioText: 'Obwohl es sehr kalt ist, gehe ich jeden Tag zur Arbeit.',
          question: 'Was macht die Person trotz des Wetters?',
          options: ['Bleibt sie zu Hause', 'Geht sie zur Arbeit', 'Fährt sie in den Urlaub', 'Trinkt sie einen Kaffee'],
          correctIndex: 1,
          explanation: 'The person says "gehe ich jeden Tag zur Arbeit" which means "I go to work every day".',
          translation: 'Although it is very cold, I go to work every day.',
        },
      ],
      B2: [
        {
          id: 'l7',
          audioText: 'Die Situation hat sich grundlegend verändert.',
          question: 'Was ist passiert?',
          options: ['Nichts hat sich geändert', 'Die Situation hat sich verändert', 'Die Person ist umgezogen', 'Das Wetter hat sich verändert'],
          correctIndex: 1,
          explanation: 'The person says "Die Situation hat sich grundlegend verändert" which means "The situation has fundamentally changed".',
          translation: 'The situation has fundamentally changed.',
        },
      ],
      C1: [
        {
          id: 'l9',
          audioText: 'Die Forschungsergebnisse deuten darauf hin, dass die Klimaveränderungen schneller voranschreiten als erwartet.',
          question: 'Was sagen die Forschungsergebnisse?',
          options: ['Das Klima verbessert sich', 'Die Klimaveränderungen sind langsamer', 'Die Klimaveränderungen sind schneller', 'Das Klima ist stabil'],
          correctIndex: 2,
          explanation: 'The research results suggest that climate changes are progressing faster than expected.',
          translation: 'The research results suggest that climate changes are progressing faster than expected.',
        },
      ],
      C2: [
        {
          id: 'l10',
          audioText: 'Es ist unbestreitbar, dass die digitale Transformation die Art und Weise, wie wir kommunizieren, revolutioniert hat.',
          question: 'Was hat die digitale Transformation gemacht?',
          options: ['Die Kommunikation verschlechtert', 'Die Kommunikation revolutioniert', 'Die Kommunikation verlangsamt', 'Die Kommunikation beendet'],
          correctIndex: 1,
          explanation: 'The digital transformation has revolutionized the way we communicate.',
          translation: 'It is undeniable that the digital transformation has revolutionized the way we communicate.',
        },
      ],
    };
    return questions[level] || [];
  }
}
