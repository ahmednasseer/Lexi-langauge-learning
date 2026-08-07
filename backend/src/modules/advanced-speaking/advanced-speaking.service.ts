import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';

export enum ConversationScenario {
  restaurant = 'restaurant',
  travel = 'travel',
  jobInterview = 'jobInterview',
  university = 'university',
  doctorVisit = 'doctorVisit',
  shopping = 'shopping',
  dailyLife = 'dailyLife',
  goetheSpeakingExam = 'goetheSpeakingExam',
}

export enum ConversationState {
  idle = 'idle',
  listening = 'listening',
  processing = 'processing',
  aiSpeaking = 'aiSpeaking',
  userSpeaking = 'userSpeaking',
  ended = 'ended',
}

export interface ConversationMessage {
  id: string;
  role: 'ai' | 'user';
  content: string;
  germanText?: string;
  timestamp: Date;
  isCorrected: boolean;
  correction?: string;
  pronunciationAnalysis?: PronunciationAnalysis;
}

export interface PronunciationAnalysis {
  pronunciation: number;
  accent: number;
  speakingSpeed: number;
  pauses: number;
  confidence: number;
  wordAccuracy: number;
  mispronouncedWords: string[];
  suggestions: string[];
}

export interface ConversationSession {
  id: string;
  userId: string;
  scenario: ConversationScenario;
  messages: ConversationMessage[];
  startedAt: Date;
  endedAt?: Date;
  state: ConversationState;
  totalScore: number;
  xpEarned: number;
  wordsSpoken: number;
  durationSeconds: number;
}

export interface SpeakingProgress {
  totalSpeakingMinutes: number;
  totalWordsSpoken: number;
  averagePronunciationScore: number;
  averageFluencyScore: number;
  totalSessions: number;
  currentStreak: number;
  longestStreak: number;
  totalXpEarned: number;
  currentLevel: string;
  commonMistakes: MistakePattern[];
  scenarioPracticeCount: Record<string, number>;
}

export interface MistakePattern {
  pattern: string;
  description: string;
  frequency: number;
  suggestion: string;
}

export interface SpeakingChallenge {
  id: string;
  title: string;
  description: string;
  type: 'daily' | 'weekly' | 'monthly';
  targetDays: number;
  completedDays: number;
  currentDay: number;
  isActive: boolean;
  startDate: Date;
  endDate?: Date;
  reward: ChallengeReward;
}

export interface ChallengeReward {
  xp: number;
  gems: number;
  badgeId?: string;
}

const scenarioData: Record<ConversationScenario, { initial: string; responses: string[] }> = {
  [ConversationScenario.restaurant]: {
    initial: 'Willkommen im Restaurant! Was möchten Sie bestellen?',
    responses: [
      'Haben Sie bereits eine Bestellung im Sinn?',
      'Möchten Sie die Speisekarte sehen?',
      'Haben Sie Allergien, die wir beachten sollten?',
      'Ist der Tisch in Ordnung für Sie?',
      'Vielen Dank für Ihren Besuch! Ich wünsche Ihnen einen schönen Abend.',
    ],
  },
  [ConversationScenario.travel]: {
    initial: 'Guten Tag! Wo möchten Sie hinfahren?',
    responses: [
      'Haben Sie eine Reservierung?',
      'Wie lange möchten Sie bleiben?',
      'Brauchen Sie Hilfe mit dem Gepäck?',
      'Möchten Sie eine Stadtführung buchen?',
      'Ich wünsche Ihnen eine gute Reise! Kommen Sie bald wieder.',
    ],
  },
  [ConversationScenario.jobInterview]: {
    initial: 'Guten Tag! Bitte stellen Sie sich vor.',
    responses: [
      'Warum interessiert Sie diese Stelle?',
      'Was sind Ihre Stärken?',
      'Erzählen Sie mir von Ihrer Erfahrung.',
      'Haben Sie Fragen an uns?',
      'Vielen Dank für das Gespräch. Wir melden uns bei Ihnen.',
    ],
  },
  [ConversationScenario.university]: {
    initial: 'Guten Tag! Wie kann ich Ihnen helfen?',
    responses: [
      'Für welches Fach interessieren Sie sich?',
      'Haben Sie Fragen zum Stundenplan?',
      'Möchten Sie sich für eine Vorlesung anmelden?',
      'Kann ich Ihnen bei der Bibliothek helfen?',
      'Viel Erfolg in Ihrem Studium!',
    ],
  },
  [ConversationScenario.doctorVisit]: {
    initial: 'Guten Tag! Was beschwert Sie?',
    responses: [
      'Seit wann haben Sie diese Beschwerden?',
      'Nehmen Sie Medikamente?',
      'Haben Sie Fieber gemessen?',
      'Ich schreibe Ihnen ein Rezept.',
      'Gute Besserung! Kommen Sie in einer Woche wieder.',
    ],
  },
  [ConversationScenario.shopping]: {
    initial: 'Guten Tag! Kann ich Ihnen helfen?',
    responses: [
      'Suchen Sie etwas Bestimmtes?',
      'Welche Größe brauchen Sie?',
      'Möchten Sie das anprobieren?',
      'Das kostet 29,99 Euro.',
      'Vielen Dank für Ihren Einkauf!',
    ],
  },
  [ConversationScenario.dailyLife]: {
    initial: 'Hallo! Wie geht es Ihnen heute?',
    responses: [
      'Was haben Sie heute vor?',
      'Möchten Sie einen Kaffee trinken gehen?',
      'Wie war Ihr Wochenende?',
      'Haben Sie Lust auf eine Pause?',
      'Es war schön, mit Ihnen zu reden! Bis bald!',
    ],
  },
  [ConversationScenario.goetheSpeakingExam]: {
    initial: 'Willkommen zur mündlichen Prüfung. Bitte stellen Sie sich vor.',
    responses: [
      'Beschreiben Sie das Bild.',
      'Erzählen Sie mir von Ihrem Alltag.',
      'Was würden Sie in dieser Situation tun?',
      'Vielen Dank. Das war die Prüfung.',
    ],
  },
};

@Injectable()
export class AdvancedSpeakingService {
  private sessions: Map<string, ConversationSession> = new Map();
  private progress: Map<string, SpeakingProgress> = new Map();
  private challenges: Map<string, SpeakingChallenge[]> = new Map();

  startSession(userId: string, scenario: ConversationScenario): ConversationSession {
    const data = scenarioData[scenario];
    const session: ConversationSession = {
      id: `session_${Date.now()}`,
      userId,
      scenario,
      messages: [
        {
          id: 'msg_0',
          role: 'ai',
          content: data.initial,
          timestamp: new Date(),
          isCorrected: false,
        },
      ],
      startedAt: new Date(),
      state: ConversationState.aiSpeaking,
      totalScore: 0,
      xpEarned: 0,
      wordsSpoken: 0,
      durationSeconds: 0,
    };

    this.sessions.set(session.id, session);
    return session;
  }

  analyzePronunciation(spokenText: string, targetText: string): PronunciationAnalysis {
    const spokenLower = spokenText.toLowerCase().trim();
    const targetLower = targetText.toLowerCase().trim();

    const pronunciation = this.calculatePronunciationScore(spokenLower, targetLower);
    const accent = this.calculateAccentScore(spokenLower);
    const speakingSpeed = this.calculateSpeakingSpeed(spokenText);
    const pauses = this.calculatePauseScore(spokenText);
    const confidence = this.calculateConfidence(spokenText);
    const wordAccuracy = this.calculateWordAccuracy(spokenLower, targetLower);
    const mispronouncedWords = this.findMispronouncedWords(spokenLower, targetLower);
    const suggestions = this.generateSuggestions(pronunciation, accent, speakingSpeed, mispronouncedWords);

    return {
      pronunciation,
      accent,
      speakingSpeed,
      pauses,
      confidence,
      wordAccuracy,
      mispronouncedWords,
      suggestions,
    };
  }

  private calculatePronunciationScore(spoken: string, target: string): number {
    if (spoken.length === 0) return 0;
    if (spoken === target) return 100;

    const similarity = this.calculateSimilarity(spoken, target);
    let score = 50 + (similarity * 50);

    const germanPatterns = ['ch', 'sch', 'ei', 'eu', 'au', 'ü', 'ö', 'ä'];
    for (const pattern of germanPatterns) {
      if (spoken.includes(pattern)) score += 2;
    }

    return Math.min(100, Math.max(0, score));
  }

  private calculateAccentScore(spoken: string): number {
    let score = 75;
    const germanPatterns: Record<string, number> = {
      'ch': 3, 'sch': 3, 'ei': 3, 'eu': 3, 'au': 3,
      'ß': 4, 'st': 2, 'sp': 2,
    };

    for (const [pattern, bonus] of Object.entries(germanPatterns)) {
      if (spoken.includes(pattern)) score += bonus;
    }

    return Math.min(100, Math.max(0, score));
  }

  private calculateSpeakingSpeed(spoken: string): number {
    const words = spoken.split(' ').length;
    const estimatedSeconds = (words / 150) * 60;

    if (estimatedSeconds < 1) return 60;
    if (estimatedSeconds < 3) return 80;
    if (estimatedSeconds < 5) return 90;
    if (estimatedSeconds < 10) return 85;
    return 70;
  }

  private calculatePauseScore(spoken: string): number {
    let score = 70;
    if (spoken.includes('.') || spoken.includes('!') || spoken.includes('?')) score += 15;
    if (spoken.includes(',')) score += 10;
    return Math.min(100, Math.max(0, score));
  }

  private calculateConfidence(spoken: string): number {
    const words = spoken.split(' ').length;
    let score = 60;
    if (words > 3) score += 10;
    if (words > 6) score += 10;
    if (spoken.includes('.') || spoken.includes('!') || spoken.includes('?')) score += 10;
    return Math.min(100, Math.max(0, score));
  }

  private calculateWordAccuracy(spoken: string, target: string): number {
    if (spoken.length === 0 || target.length === 0) return 0;

    const spokenWords = spoken.split(' ');
    const targetWords = target.split(' ');

    let matches = 0;
    for (const word of spokenWords) {
      if (targetWords.includes(word)) matches++;
    }

    if (targetWords.length === 0) return 0;
    return Math.min(100, Math.max(0, (matches / targetWords.length) * 100));
  }

  private findMispronouncedWords(spoken: string, target: string): string[] {
    const mispronounced: string[] = [];
    const spokenWords = spoken.split(' ');
    const targetWords = target.split(' ');

    for (let i = 0; i < targetWords.length && i < spokenWords.length; i++) {
      if (spokenWords[i] !== targetWords[i]) {
        mispronounced.push(targetWords[i]);
      }
    }

    return mispronounced;
  }

  private generateSuggestions(
    pronunciation: number,
    accent: number,
    speakingSpeed: number,
    mispronouncedWords: string[],
  ): string[] {
    const suggestions: string[] = [];

    if (pronunciation < 70) suggestions.push('Focus on pronouncing each word clearly');
    if (accent < 70) suggestions.push('Practice German sounds like "ch", "sch", "ei"');
    if (speakingSpeed < 60) suggestions.push('Try speaking at a moderate pace');
    if (mispronouncedWords.length > 0) {
      suggestions.push(`Pay attention to: ${mispronouncedWords.join(', ')}`);
    }

    if (suggestions.length === 0) suggestions.push('Great pronunciation! Keep practicing!');

    return suggestions;
  }

  private calculateSimilarity(a: string, b: string): number {
    if (a === b) return 1;

    const aWords = a.split(' ');
    const bWords = b.split(' ');

    let matches = 0;
    for (const word of aWords) {
      if (bWords.includes(word)) matches++;
    }

    if (bWords.length === 0) return 0;
    return matches / bWords.length;
  }

  getAIResponse(sessionId: string, userResponse: string): string {
    const session = this.sessions.get(sessionId);
    if (!session) throw new NotFoundException('Session not found');

    const data = scenarioData[session.scenario];
    const turnCount = session.messages.filter(m => m.role === 'user').length;

    if (turnCount >= data.responses.length) {
      return data.responses[data.responses.length - 1];
    }

    return data.responses[turnCount];
  }

  addMessage(sessionId: string, message: ConversationMessage): void {
    const session = this.sessions.get(sessionId);
    if (!session) throw new NotFoundException('Session not found');

    session.messages.push(message);
    session.wordsSpoken += message.content.split(' ').length;
  }

  endSession(sessionId: string): ConversationSession {
    const session = this.sessions.get(sessionId);
    if (!session) throw new NotFoundException('Session not found');

    session.endedAt = new Date();
    session.state = ConversationState.ended;
    session.durationSeconds = Math.floor(
      (session.endedAt.getTime() - session.startedAt.getTime()) / 1000
    );

    const userMessages = session.messages.filter(m => m.role === 'user');
    const totalScore = userMessages.reduce((sum, m) => {
      return sum + (m.pronunciationAnalysis?.pronunciation ?? 50);
    }, 0) / (userMessages.length || 1);

    session.totalScore = Math.round(totalScore);
    session.xpEarned = Math.round(totalScore * 2);

    this.updateProgress(session.userId, session);

    return session;
  }

  private updateProgress(userId: string, session: ConversationSession): void {
    const current = this.progress.get(userId) || {
      totalSpeakingMinutes: 0,
      totalWordsSpoken: 0,
      averagePronunciationScore: 0,
      averageFluencyScore: 0,
      totalSessions: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalXpEarned: 0,
      currentLevel: 'A1',
      commonMistakes: [],
      scenarioPracticeCount: {},
    };

    current.totalSpeakingMinutes += Math.floor(session.durationSeconds / 60);
    current.totalWordsSpoken += session.wordsSpoken;
    current.totalSessions += 1;
    current.averagePronunciationScore = (
      (current.averagePronunciationScore * (current.totalSessions - 1)) + session.totalScore
    ) / current.totalSessions;
    current.totalXpEarned += session.xpEarned;
    current.scenarioPracticeCount[session.scenario] =
      (current.scenarioPracticeCount[session.scenario] || 0) + 1;

    this.progress.set(userId, current);
  }

  getProgress(userId: string): SpeakingProgress {
    return this.progress.get(userId) || {
      totalSpeakingMinutes: 0,
      totalWordsSpoken: 0,
      averagePronunciationScore: 0,
      averageFluencyScore: 0,
      totalSessions: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalXpEarned: 0,
      currentLevel: 'A1',
      commonMistakes: [],
      scenarioPracticeCount: {},
    };
  }

  getHistory(userId: string): ConversationSession[] {
    return Array.from(this.sessions.values())
      .filter(s => s.userId === userId)
      .sort((a, b) => b.startedAt.getTime() - a.startedAt.getTime());
  }

  getChallenges(userId: string): SpeakingChallenge[] {
    return this.challenges.get(userId) || [];
  }

  generateFeedback(sessionId: string) {
    const session = this.sessions.get(sessionId);
    if (!session) throw new NotFoundException('Session not found');

    const userMessages = session.messages.filter(m => m.role === 'user');
    const whatYouDidWell: string[] = [];
    const mistakes: string[] = [];
    const betterSentences: string[] = [];

    const perfectCount = userMessages.filter(m =>
      m.pronunciationAnalysis && m.pronunciationAnalysis.pronunciation >= 90
    ).length;

    if (perfectCount > 0) {
      whatYouDidWell.push(`Excellent pronunciation in ${perfectCount} sentences!`);
    }
    if (userMessages.length >= 5) {
      whatYouDidWell.push('Great conversation flow and engagement!');
    }

    for (const msg of userMessages) {
      if (msg.correction) {
        mistakes.push(`You said: "${msg.content}"`);
        betterSentences.push(`Better: "${msg.correction}"`);
      }
    }

    const averageScore = userMessages.length > 0
      ? userMessages.reduce((sum, m) => sum + (m.pronunciationAnalysis?.pronunciation ?? 50), 0) / userMessages.length
      : 0;

    return {
      sessionId,
      whatYouDidWell: whatYouDidWell.length > 0 ? whatYouDidWell : ['Good effort!'],
      mistakes,
      betterSentences,
      nextPractice: this.generateNextPractice(session.scenario, averageScore),
      overallScore: averageScore,
      xpEarned: Math.round(averageScore * 2),
    };
  }

  private generateNextPractice(scenario: ConversationScenario, score: number): string {
    if (score >= 90) return 'Excellent work! Try a more challenging scenario.';
    if (score >= 70) return 'Good progress! Practice the same scenario again to improve.';
    return 'Keep practicing! Try reviewing basic vocabulary for this scenario.';
  }
}
