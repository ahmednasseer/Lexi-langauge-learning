import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class GoetheService {
  constructor(private prisma: PrismaService) {}

  async getExamLevels() {
    return [
      {
        id: 'goethe_a1',
        name: 'Goethe A1',
        cefrLevel: 'A1',
        description: 'Start Deutsch 1 - Basic language use for beginners',
        totalQuestions: 60,
        passingScore: 60,
        timeLimitMinutes: 60,
      },
      {
        id: 'goethe_a2',
        name: 'Goethe A2',
        cefrLevel: 'A2',
        description: 'Start Deutsch 2 - Elementary language use',
        totalQuestions: 65,
        passingScore: 60,
        timeLimitMinutes: 70,
      },
      {
        id: 'goethe_b1',
        name: 'Goethe B1',
        cefrLevel: 'B1',
        description: 'Zertifikat Deutsch - Intermediate language use',
        totalQuestions: 75,
        passingScore: 60,
        timeLimitMinutes: 90,
      },
      {
        id: 'goethe_b2',
        name: 'Goethe B2',
        cefrLevel: 'B2',
        description: 'Zertifikat Deutsch - Upper intermediate language use',
        totalQuestions: 80,
        passingScore: 60,
        timeLimitMinutes: 105,
      },
    ];
  }

  async getExamsForLevel(level: string) {
    return this.prisma.mockExam.findMany({
      where: { level: level.toUpperCase() },
      include: {
        user: { select: { name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async startMockExam(userId: string, level: string) {
    const sections = await this.getSectionsForLevel(level);
    
    const exam = await this.prisma.mockExam.create({
      data: {
        userId,
        level: level.toUpperCase(),
        score: 0,
        totalPoints: sections.reduce((sum, s) => sum + s.totalPoints, 0),
        timeSpentSeconds: 0,
        completedSections: [],
        result: {},
        startedAt: new Date(),
      },
    });

    return { exam, sections };
  }

  async submitMockExam(userId: string, examId: string, data: {
    answers: Record<string, string>;
    timeSpentSeconds: number;
  }) {
    const exam = await this.prisma.mockExam.findUnique({ where: { id: examId } });
    if (!exam || exam.userId !== userId) {
      throw new NotFoundException('Exam not found');
    }

    const sections = await this.getSectionsForLevel(exam.level);
    let totalScore = 0;
    const sectionResults = [];

    for (const section of sections) {
      let sectionScore = 0;
      let correctAnswers = 0;

      for (const question of section.questions) {
        if (data.answers[question.id] === question.correctAnswer) {
          sectionScore += question.points;
          correctAnswers++;
        }
      }

      sectionResults.push({
        type: section.type,
        score: sectionScore,
        totalPoints: section.totalPoints,
        timeSpentSeconds: Math.floor(data.timeSpentSeconds / sections.length),
        correctAnswers,
        totalQuestions: section.questions.length,
      });

      totalScore += sectionScore;
    }

    const percentage = exam.totalPoints > 0 ? (totalScore / exam.totalPoints * 100) : 0;
    const passed = percentage >= 60;

    const result = {
      passed,
      scorePercentage: percentage,
      grade: this.calculateGrade(percentage),
      feedback: this.generateFeedback(percentage),
      strengths: sectionResults.filter(s => (s.score / s.totalPoints * 100) >= 80).map(s => s.type),
      weaknesses: sectionResults.filter(s => (s.score / s.totalPoints * 100) < 60).map(s => s.type),
      recommendation: this.generateRecommendation(percentage),
    };

    return this.prisma.mockExam.update({
      where: { id: examId },
      data: {
        score: totalScore,
        timeSpentSeconds: data.timeSpentSeconds,
        completedSections: sectionResults,
        result,
        completedAt: new Date(),
      },
    });
  }

  async analyzeWriting(userId: string, data: {
    level: string;
    prompt: string;
    text: string;
  }) {
    let wordCount = data.text.split(' ').length;
    const hasGreeting = data.text.includes('Sehr geehrte') || data.text.includes('Hallo');
    const hasClosing = data.text.includes('Mit freundlichen Grüßen') || data.text.includes('Viele Grüße');

    let grammarScore = this._scoreGrammar(data.text, data.level);
    let vocabularyScore = this._scoreVocabulary(data.text, data.level);
    let structureScore = 60;

    if (hasGreeting) structureScore = Math.min(100, structureScore + 10);
    if (hasClosing) structureScore = Math.min(100, structureScore + 10);
    if (wordCount >= 30) structureScore = Math.min(100, structureScore + 10);
    if (wordCount < 30) {
      grammarScore = Math.min(100, Math.round(grammarScore * 0.85));
      vocabularyScore = Math.min(100, Math.round(vocabularyScore * 0.85));
    }

    const overallScore = Math.round((grammarScore + vocabularyScore + structureScore) / 3);

    const evaluation = {
      grammarScore,
      vocabularyScore,
      structureScore,
      overallScore,
      corrections: this.generateWritingCorrections(data.text, data.level),
      suggestions: this.generateWritingSuggestions(data.level),
      feedback: this.generateWritingFeedback(overallScore),
    };

    await this.prisma.writingSubmission.create({
      data: {
        userId,
        level: data.level,
        prompt: data.prompt,
        submissionText: data.text,
        feedback: evaluation,
      },
    });

    return evaluation;
  }

  async analyzeSpeaking(userId: string, data: {
    level: string;
    prompt: string;
    audioTranscript: string;
  }) {
    const pronunciationScore = this._scorePronunciation(data.audioTranscript);
    const fluencyScore = this._scoreFluency(data.audioTranscript);
    const grammarScore = this._scoreGrammar(data.audioTranscript, data.level);
    const vocabularyScore = this._scoreVocabulary(data.audioTranscript, data.level);

    const overallScore = (pronunciationScore + fluencyScore + grammarScore + vocabularyScore) / 4;

    return {
      pronunciationScore,
      fluencyScore,
      grammarScore,
      vocabularyScore,
      overallScore,
      mistakes: this.generateSpeakingMistakes(data.level),
      suggestions: this.generateSpeakingSuggestions(data.level),
      feedback: this.generateSpeakingFeedback(overallScore),
    };
  }

  async getProgress(userId: string) {
    const exams = await this.prisma.mockExam.findMany({
      where: { userId, completedAt: { not: null } },
      orderBy: { completedAt: 'desc' },
    });

    const levelProgress = {};
    for (const level of ['A1', 'A2', 'B1', 'B2']) {
      const levelExams = exams.filter(e => e.level === level);
      const passed = levelExams.filter(e => (e.result as any)?.passed).length;
      
      levelProgress[level] = {
        examsTaken: levelExams.length,
        examsPassed: passed,
        bestScore: levelExams.length > 0 
          ? Math.max(...levelExams.map(e => (e.result as any)?.scorePercentage || 0))
          : 0,
        averageScore: levelExams.length > 0
          ? levelExams.reduce((sum, e) => sum + ((e.result as any)?.scorePercentage || 0), 0) / levelExams.length
          : 0,
      };
    }

    return {
      userId,
      levelProgress,
      totalExamsTaken: exams.length,
      examsPassed: exams.filter(e => (e.result as any)?.passed).length,
      averageScore: exams.length > 0
        ? exams.reduce((sum, e) => sum + ((e.result as any)?.scorePercentage || 0), 0) / exams.length
        : 0,
      lastExamDate: exams.length > 0 ? exams[0].completedAt : null,
    };
  }

  private async getSectionsForLevel(level: string) {
    return [
      {
        type: 'reading',
        name: 'Lesen (Reading)',
        questionCount: this.getQuestionCount(level, 'reading'),
        timeLimitMinutes: this.getTimeLimit(level, 'reading'),
        totalPoints: this.getQuestionCount(level, 'reading') * 2,
        questions: await this.generateReadingQuestions(level),
      },
      {
        type: 'listening',
        name: 'Hören (Listening)',
        questionCount: this.getQuestionCount(level, 'listening'),
        timeLimitMinutes: this.getTimeLimit(level, 'listening'),
        totalPoints: this.getQuestionCount(level, 'listening') * 2,
        questions: await this.generateListeningQuestions(level),
      },
      {
        type: 'writing',
        name: 'Schreiben (Writing)',
        questionCount: this.getQuestionCount(level, 'writing'),
        timeLimitMinutes: this.getTimeLimit(level, 'writing'),
        totalPoints: this.getQuestionCount(level, 'writing') * 5,
        questions: await this.generateWritingPrompts(level),
      },
      {
        type: 'speaking',
        name: 'Sprechen (Speaking)',
        questionCount: this.getQuestionCount(level, 'speaking'),
        timeLimitMinutes: this.getTimeLimit(level, 'speaking'),
        totalPoints: this.getQuestionCount(level, 'speaking') * 5,
        questions: await this.generateSpeakingPrompts(level),
      },
    ];
  }

  private getQuestionCount(level: string, section: string): number {
    const counts: Record<string, Record<string, number>> = {
      A1: { reading: 15, listening: 15, writing: 2, speaking: 3 },
      A2: { reading: 15, listening: 15, writing: 2, speaking: 3 },
      B1: { reading: 20, listening: 20, writing: 3, speaking: 4 },
      B2: { reading: 20, listening: 20, writing: 3, speaking: 4 },
    };
    return counts[level]?.[section] || 10;
  }

  private getTimeLimit(level: string, section: string): number {
    const times: Record<string, Record<string, number>> = {
      A1: { reading: 15, listening: 15, writing: 15, speaking: 15 },
      A2: { reading: 15, listening: 15, writing: 20, speaking: 20 },
      B1: { reading: 20, listening: 20, writing: 25, speaking: 25 },
      B2: { reading: 25, listening: 25, writing: 30, speaking: 25 },
    };
    return times[level]?.[section] || 20;
  }

  private async generateReadingQuestions(level: string) {
    const questions = await this.prisma.quizQuestion.findMany({
      where: {
        type: { in: ['multipleChoice', 'trueFalse'] },
      },
      take: this.getQuestionCount(level, 'reading'),
    });

    return questions.map((q, i) => ({
      id: `reading_${level}_${i}`,
      type: q.type,
      question: q.question,
      options: q.options,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
      difficulty: this._difficultyForIndex(i),
      points: 2,
    }));
  }

  private async generateListeningQuestions(level: string) {
    const questions = await this.prisma.quizQuestion.findMany({
      where: {
        type: 'multipleChoice',
        question: { contains: 'hören' },
      },
      take: this.getQuestionCount(level, 'listening'),
    });

    return questions.map((q, i) => ({
      id: `listening_${level}_${i}`,
      type: q.type,
      question: q.question,
      options: q.options,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
      difficulty: this._difficultyForIndex(i),
      points: 2,
    }));
  }

  private async generateWritingPrompts(level: string) {
    const prompts = [
      {
        id: `writing_${level}_0`,
        type: 'essay',
        question: 'Schreiben Sie einen Brief, in dem Sie sich einer Freundin/Ihrem Freund vorstellen.',
        options: [],
        correctAnswer: '',
        explanation: 'Bewertungskriterien: Begrüßung, Vorstellung, Fragen stellen, Abschied',
        difficulty: 'medium',
        points: 5,
      },
      {
        id: `writing_${level}_1`,
        type: 'essay',
        question: 'Beschreiben Sie Ihren Wohnsitz. Welche Möbel hat Ihr Zimmer?',
        options: [],
        correctAnswer: '',
        explanation: 'Bewertungskriterien: Artikelverwendung, Adjektive, Satzbau',
        difficulty: 'medium',
        points: 5,
      },
    ];
    return prompts.slice(0, this.getQuestionCount(level, 'writing'));
  }

  private async generateSpeakingPrompts(level: string) {
    const prompts = [
      {
        id: `speaking_${level}_0`,
        type: 'shortAnswer',
        question: 'Vorstellen: Woher kommen Sie? Was ist Ihr Name?',
        options: [],
        correctAnswer: '',
        explanation: 'Bewertungskriterien: Aussprache, Grammatik, Flüssigkeit',
        difficulty: 'medium',
        points: 5,
      },
      {
        id: `speaking_${level}_1`,
        type: 'shortAnswer',
        question: 'Beschreiben Sie einen Tag in Ihrer Stadt.',
        options: [],
        correctAnswer: '',
        explanation: 'Bewertungskriterien: Wortschatz, Satzstruktur, Verständlichkeit',
        difficulty: 'medium',
        points: 5,
      },
      {
        id: `speaking_${level}_2`,
        type: 'shortAnswer',
        question: 'Erklären Sie, was Sie in Ihrer Freizeit machen.',
        options: [],
        correctAnswer: '',
        explanation: 'Bewertungskriterien: Konjugation, Präpositionen, natürliche Sprache',
        difficulty: 'medium',
        points: 5,
      },
    ];
    return prompts.slice(0, this.getQuestionCount(level, 'speaking'));
  }

  private _difficultyForIndex(index: number): string {
    const difficulties = ['easy', 'medium', 'hard'];
    return difficulties[index % difficulties.length];
  }

  private calculateGrade(percentage: number): string {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  private generateFeedback(percentage: number): string {
    if (percentage >= 80) return 'Excellent performance! You are well-prepared for the exam.';
    if (percentage >= 60) return 'Good job! You passed, but there is room for improvement.';
    return 'Keep practicing! Focus on your weak areas to improve.';
  }

  private generateRecommendation(percentage: number): string {
    if (percentage >= 80) return 'You are ready for the exam! Take a final practice test to confirm.';
    if (percentage >= 60) return 'Focus on improving your weak areas before the exam.';
    return 'Spend more time studying and practice regularly. Consider taking a course.';
  }

  private generateWritingCorrections(text: string, level: string): string[] {
    return [
      'Check article usage (der/die/das)',
      'Consider using more complex sentence structures',
      'Add transitional words for better flow',
    ];
  }

  private generateWritingSuggestions(level: string): string[] {
    return [
      'Use formal greetings for business letters',
      'Include specific details and examples',
      'Proofread for spelling and grammar',
    ];
  }

  private generateWritingFeedback(score: number): string {
    if (score >= 80) return 'Excellent writing! Your text is clear and well-structured.';
    if (score >= 60) return 'Good writing! Focus on grammar and vocabulary variety.';
    return 'Keep practicing! Work on sentence structure and word choice.';
  }

  private generateSpeakingMistakes(level: string): string[] {
    return [
      'Watch your pronunciation of "ch" sounds',
      'Practice verb conjugation in past tense',
      'Work on word order in subordinate clauses',
    ];
  }

  private generateSpeakingSuggestions(level: string): string[] {
    return [
      'Practice speaking slowly and clearly',
      'Use linking words for better fluency',
      'Expand your vocabulary for more variety',
    ];
  }

  private generateSpeakingFeedback(score: number): string {
    if (score >= 80) return 'Excellent speaking! You communicate clearly and fluently.';
    if (score >= 60) return 'Good speaking! Work on pronunciation and fluency.';
    return 'Keep practicing! Focus on pronunciation and sentence structure.';
  }

  private _scoreGrammar(text: string, level: string): number {
    let score = 70;
    const lower = text.toLowerCase();
    const hasUmlauts = /ä|ö|ü|ß/.test(lower);
    if (hasUmlauts) score += 10;
    if (lower.includes('der ') || lower.includes('die ') || lower.includes('das ')) score += 10;
    const levelBase = { A1: 0, A2: 5, B1: 10, B2: 15, C1: 20, C2: 25 }[level as keyof typeof levelBase] || 0;
    return Math.min(100, score + levelBase);
  }

  private _scoreVocabulary(text: string, level: string): number {
    let score = 65;
    const lower = text.toLowerCase();
    const uniqueWords = new Set(lower.split(/\s+/).filter(w => w.length > 2));
    if (uniqueWords.size >= 10) score += 10;
    if (uniqueWords.size >= 20) score += 5;
    const levelBase = { A1: 0, A2: 5, B1: 10, B2: 15, C1: 20, C2: 25 }[level as keyof typeof levelBase] || 0;
    return Math.min(100, score + levelBase);
  }

  private _scorePronunciation(transcript: string): number {
    let score = 65;
    const lower = transcript.toLowerCase();
    const hasUmlauts = /ä|ö|ü|ß/.test(lower);
    if (hasUmlauts) score += 10;
    const words = lower.split(/\s+/).filter(w => w.length > 2);
    if (words.length >= 5) score += 10;
    return Math.min(100, score);
  }

  private _scoreFluency(transcript: string): number {
    let score = 60;
    const sentences = transcript.split(/[.!?]+/).filter(s => s.trim().length > 3);
    if (sentences.length >= 3) score += 15;
    else if (sentences.length >= 2) score += 10;
    else if (sentences.length >= 1) score += 5;
    const words = transcript.split(/\s+/).filter(w => w.length > 0);
    if (words.length >= 25) score += 10;
    return Math.min(100, score);
  }
}
