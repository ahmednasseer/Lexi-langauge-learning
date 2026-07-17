import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AILearningService {
  constructor(private prisma: PrismaService) {}

  async getLearningProfile(userId: string) {
    let profile = await this.prisma.learningProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      profile = await this.prisma.learningProfile.create({
        data: {
          userId,
          currentLevel: 'A1',
          learningGoal: 'conversation',
          dailyMinutes: 15,
          weakAreas: [],
          strongAreas: [],
          preferredTopics: ['Greetings', 'Numbers', 'Colors'],
          learningSpeed: 'normal',
          lastAnalysisDate: new Date(),
          totalStudyHours: 0,
          overallProgress: 0,
        },
      });
    }

    return profile;
  }

  async updateLearningProfile(userId: string, data: {
    currentLevel?: string;
    learningGoal?: string;
    dailyMinutes?: number;
    learningSpeed?: string;
    preferredTopics?: string[];
  }) {
    return this.prisma.learningProfile.upsert({
      where: { userId },
      update: data,
      create: {
        userId,
        currentLevel: data.currentLevel || 'A1',
        learningGoal: data.learningGoal || 'conversation',
        dailyMinutes: data.dailyMinutes || 15,
        learningSpeed: data.learningSpeed || 'normal',
        preferredTopics: data.preferredTopics || ['Greetings'],
        lastAnalysisDate: new Date(),
      },
    });
  }

  async analyzePerformance(userId: string, data: {
    quizResults: Array<{ category: string; correct: boolean; mistake?: string }>;
    flashcardResults: Array<{ word: string; category: string; remembered: boolean }>;
    speakingResults: Array<{ category: string; score: number; mistakes: string[] }>;
    aiConversationMistakes: Array<{ category: string; error: string }>;
  }) {
    const profile = await this.getLearningProfile(userId);
    const weakAreas = profile.weakAreas as any[] || [];
    const strongAreas = profile.strongAreas as any[] || [];

    const weaknessMap = new Map<string, any>();
    const strengthMap = new Map<string, any>();

    for (const quiz of data.quizResults) {
      if (quiz.correct) {
        const existing = strengthMap.get(quiz.category) || { correctCount: 0, mastery: 0 };
        strengthMap.set(quiz.category, {
          ...existing,
          category: quiz.category,
          correctCount: existing.correctCount + 1,
          mastery: Math.min(1, existing.mastery + 0.05),
          lastPracticedAt: new Date(),
        });
      } else if (quiz.mistake) {
        const existing = weaknessMap.get(quiz.category) || { mistakeCount: 0, severity: 0, commonMistakes: [] };
        weaknessMap.set(quiz.category, {
          ...existing,
          category: quiz.category,
          mistakeCount: existing.mistakeCount + 1,
          severity: Math.min(1, existing.severity + 0.05),
          lastMistakeAt: new Date(),
          commonMistakes: [...new Set([...existing.commonMistakes, quiz.mistake])].slice(0, 5),
        });
      }
    }

    for (const card of data.flashcardResults) {
      if (card.remembered) {
        const existing = strengthMap.get(card.category) || { correctCount: 0, mastery: 0 };
        strengthMap.set(card.category, {
          ...existing,
          category: card.category,
          correctCount: existing.correctCount + 1,
          mastery: Math.min(1, existing.mastery + 0.05),
          lastPracticedAt: new Date(),
        });
      } else {
        const existing = weaknessMap.get(card.category) || { mistakeCount: 0, severity: 0, commonMistakes: [] };
        weaknessMap.set(card.category, {
          ...existing,
          category: card.category,
          mistakeCount: existing.mistakeCount + 1,
          severity: Math.min(1, existing.severity + 0.05),
          lastMistakeAt: new Date(),
          commonMistakes: [...new Set([...existing.commonMistakes, `Forgot: ${card.word}`])].slice(0, 5),
        });
      }
    }

    for (const speaking of data.speakingResults) {
      if (speaking.score >= 0.8) {
        const existing = strengthMap.get(speaking.category) || { correctCount: 0, mastery: 0 };
        strengthMap.set(speaking.category, {
          ...existing,
          category: speaking.category,
          correctCount: existing.correctCount + 1,
          mastery: Math.min(1, existing.mastery + 0.05),
          lastPracticedAt: new Date(),
        });
      } else {
        for (const mistake of speaking.mistakes) {
          const existing = weaknessMap.get(speaking.category) || { mistakeCount: 0, severity: 0, commonMistakes: [] };
          weaknessMap.set(speaking.category, {
            ...existing,
            category: speaking.category,
            mistakeCount: existing.mistakeCount + 1,
            severity: Math.min(1, existing.severity + 0.05),
            lastMistakeAt: new Date(),
            commonMistakes: [...new Set([...existing.commonMistakes, mistake])].slice(0, 5),
          });
        }
      }
    }

    for (const mistake of data.aiConversationMistakes) {
      const existing = weaknessMap.get(mistake.category) || { mistakeCount: 0, severity: 0, commonMistakes: [] };
      weaknessMap.set(mistake.category, {
        ...existing,
        category: mistake.category,
        mistakeCount: existing.mistakeCount + 1,
        severity: Math.min(1, existing.severity + 0.05),
        lastMistakeAt: new Date(),
        commonMistakes: [...new Set([...existing.commonMistakes, mistake.error])].slice(0, 5),
      });
    }

    const sortedWeaknesses = Array.from(weaknessMap.values())
      .sort((a, b) => b.severity - a.severity)
      .slice(0, 5);

    const sortedStrengths = Array.from(strengthMap.values())
      .sort((a, b) => b.mastery - a.mastery)
      .slice(0, 5);

    const totalAttempts = data.quizResults.length + data.flashcardResults.length;
    const correctAttempts = data.quizResults.filter(q => q.correct).length +
        data.flashcardResults.filter(c => c.remembered).length;
    const progress = totalAttempts > 0 ? correctAttempts / totalAttempts : 0;

    return this.prisma.learningProfile.update({
      where: { userId },
      data: {
        weakAreas: sortedWeaknesses,
        strongAreas: sortedStrengths,
        lastAnalysisDate: new Date(),
        overallProgress: progress,
      },
    });
  }

  async getRecommendations(userId: string) {
    const profile = await this.getLearningProfile(userId);
    const weakAreas = profile.weakAreas as any[] || [];
    const strongAreas = profile.strongAreas as any[] || [];
    
    const recommendations = [];
    let priority = 10;

    for (const weakness of weakAreas.slice(0, 3)) {
      recommendations.push({
        id: `rec_weak_${weakness.category}_${Date.now()}`,
        type: 'weakness_fix',
        title: `Practice ${weakness.category}`,
        description: this.getWeaknessDescription(weakness),
        category: weakness.category,
        estimatedMinutes: this.estimateMinutes(weakness.severity),
        priority: priority--,
        isCompleted: false,
      });
    }

    if (strongAreas.length > 0) {
      const weakestStrong = strongAreas[strongAreas.length - 1];
      if (weakestStrong.mastery < 0.8) {
        recommendations.push({
          id: `rec_review_${Date.now()}`,
          type: 'review',
          title: `Review ${weakestStrong.category}`,
          description: `Maintain your progress in ${weakestStrong.category} with a quick review session.`,
          category: weakestStrong.category,
          estimatedMinutes: 10,
          priority: priority--,
          isCompleted: false,
        });
      }
    }

    recommendations.push({
      id: `rec_daily_${Date.now()}`,
      type: 'daily',
      title: this.getDailyTitle(profile),
      description: this.getDailyDescription(profile),
      category: 'Daily',
      estimatedMinutes: profile.dailyMinutes as number,
      priority: 5,
      isCompleted: false,
    });

    return recommendations;
  }

  async generateStudyPlan(userId: string) {
    const profile = await this.getLearningProfile(userId);
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const activities = this.getActivitiesForGoal(profile.learningGoal as string);
    
    const days = dayNames.map((dayName, dayIndex) => {
      const dayActivities = [];
      let remainingMinutes = profile.dailyMinutes as number;
      let activityIndex = dayIndex * 2;

      while (remainingMinutes > 0 && dayActivities.length < 4) {
        const activity = activities[activityIndex % activities.length];
        const minutes = Math.min(activity.minutes, remainingMinutes);
        dayActivities.push({
          ...activity,
          minutes,
        });
        remainingMinutes -= minutes;
        activityIndex++;
      }

      return {
        dayName,
        activities: dayActivities,
        totalMinutes: (profile.dailyMinutes as number) - remainingMinutes,
      };
    });

    const plan = await this.prisma.studyPlan.create({
      data: {
        userId,
        title: `${this.getGoalTitle(profile.learningGoal as string)} - ${profile.currentLevel} Level`,
        startDate: new Date(),
        endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        days,
        isActive: true,
      },
    });

    return plan;
  }

  async getStudyPlan(userId: string) {
    return this.prisma.studyPlan.findFirst({
      where: { userId, isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getAnalytics() {
    const [
      totalProfiles,
      levelDistribution,
      goalDistribution,
      avgProgress,
      avgDailyMinutes,
    ] = await Promise.all([
      this.prisma.learningProfile.count(),
      this.prisma.learningProfile.groupBy({
        by: ['currentLevel'],
        _count: true,
      }),
      this.prisma.learningProfile.groupBy({
        by: ['learningGoal'],
        _count: true,
      }),
      this.prisma.learningProfile.aggregate({
        _avg: { overallProgress: true },
      }),
      this.prisma.learningProfile.aggregate({
        _avg: { dailyMinutes: true },
      }),
    ]);

    const weakTopics = await this.prisma.$queryRaw`
      SELECT 
        jsonb_array_elements("weakAreas")->>'category' as category,
        COUNT(*) as count
      FROM "LearningProfile"
      WHERE "weakAreas" != '[]'::jsonb
      GROUP BY category
      ORDER BY count DESC
      LIMIT 10
    `;

    return {
      totalProfiles,
      levelDistribution,
      goalDistribution,
      avgProgress: avgProgress._avg.overallProgress || 0,
      avgDailyMinutes: avgDailyMinutes._avg.dailyMinutes || 15,
      weakTopics,
    };
  }

  private getWeaknessDescription(weakness: any): string {
    const descriptions: Record<string, string> = {
      'Articles': `You've made ${weakness.mistakeCount} mistakes with German articles. Focus on der/die/das patterns.`,
      'Verb Conjugation': 'Practice verb conjugations to improve your sentence structure.',
      'Cases': 'Work on Nominative, Accusative, Dative, and Genitive cases.',
      'Word Order': 'German word order can be tricky. Practice placing verbs correctly.',
      'Vocabulary': 'Review vocabulary in this category to strengthen your word bank.',
      'Pronunciation': 'Practice pronunciation to sound more natural in German.',
      'Listening': 'Improve your listening skills with targeted exercises.',
    };
    return descriptions[weakness.category] || `Focus on ${weakness.category} to improve your overall skills.`;
  }

  private estimateMinutes(severity: number): number {
    if (severity >= 0.8) return 20;
    if (severity >= 0.6) return 15;
    if (severity >= 0.4) return 10;
    return 5;
  }

  private getDailyTitle(goal: string): string {
    const titles: Record<string, string> = {
      'travel': 'Practice Travel Phrases!',
      'work': 'Business German Time!',
      'study': 'Academic Practice Session',
      'conversation': 'Daily Conversation Practice',
      'hobby': 'Explore German Culture!',
      'goetheExam': 'Exam Prep Time!',
    };
    return titles[goal] || 'Keep Learning German!';
  }

  private getDailyDescription(profile: any): string {
    const weakAreas = profile.weakAreas as any[] || [];
    if (weakAreas.length > 0) {
      return `Spend ${profile.dailyMinutes} minutes practicing ${weakAreas[0].category}. You're making progress!`;
    }
    return `Practice German for ${profile.dailyMinutes} minutes today to maintain your streak!`;
  }

  private getActivitiesForGoal(goal: string): any[] {
    const activities: Record<string, any[]> = {
      'goetheExam': [
        { type: 'grammar', title: 'Grammar Focus', minutes: 10, description: 'Practice exam-style grammar' },
        { type: 'vocabulary', title: 'Vocabulary Builder', minutes: 10, description: 'Learn exam-level vocabulary' },
        { type: 'listening', title: 'Listening Comprehension', minutes: 10, description: 'Practice with exam audio' },
        { type: 'quiz', title: 'Practice Quiz', minutes: 10, description: 'Test your knowledge' },
      ],
      'work': [
        { type: 'vocabulary', title: 'Business Vocabulary', minutes: 10, description: 'Learn professional terms' },
        { type: 'ai_chat', title: 'Meeting Practice', minutes: 10, description: 'Practice business conversations' },
        { type: 'grammar', title: 'Formal Grammar', minutes: 10, description: 'Master formal expressions' },
      ],
      'travel': [
        { type: 'vocabulary', title: 'Travel Phrases', minutes: 10, description: 'Essential travel vocabulary' },
        { type: 'ai_chat', title: 'Hotel & Restaurant', minutes: 10, description: 'Practice booking and ordering' },
        { type: 'speaking', title: 'Pronunciation', minutes: 10, description: 'Sound natural when traveling' },
      ],
      'default': [
        { type: 'vocabulary', title: 'Daily Vocabulary', minutes: 10, description: 'Build your word bank' },
        { type: 'grammar', title: 'Grammar Practice', minutes: 10, description: 'Strengthen grammar foundation' },
        { type: 'ai_chat', title: 'Conversation Practice', minutes: 10, description: 'Chat with AI in German' },
        { type: 'listening', title: 'Listening Exercise', minutes: 10, description: 'Improve comprehension' },
      ],
    };
    return activities[goal] || activities['default'];
  }

  private getGoalTitle(goal: string): string {
    const titles: Record<string, string> = {
      'travel': 'Travel & Tourism',
      'work': 'Business German',
      'study': 'Academic Studies',
      'conversation': 'Daily Conversation',
      'hobby': 'Hobby & Culture',
      'goetheExam': 'Goethe Exam Preparation',
    };
    return titles[goal] || 'General Learning';
  }
}
