import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class AiCoachService {
  constructor(private prisma: PrismaService) {}

  async chat(userId: string, data: { message: string; category?: string; level?: string }) {
    const { message, category = 'free', level = 'A1' } = data;

    if (!message || message.trim().length === 0) {
      throw new BadRequestException('Message cannot be empty');
    }

    // Check rate limit
    const todayUsage = await this.prisma.aiUsage.findFirst({
      where: {
        userId,
        createdAt: {
          gte: new Date(new Date().setHours(0, 0, 0, 0)),
        },
      },
    });

    const dailyLimit = 20;
    if (todayUsage && todayUsage.messagesUsed >= dailyLimit) {
      throw new BadRequestException('Daily limit reached. Upgrade to Premium for unlimited.');
    }

    // Get user context
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    const recentMistakes = await this.prisma.aiLearningMemory.findMany({
      where: { userId, languageLevel: level },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    // Build context for AI
    const context = this.buildContext(user, recentMistakes, level);

    // Generate AI response (simulated for now)
    const aiResponse = await this.generateResponse(message, category, context);

    // Save to history
    await this.prisma.aiConversation.create({
      data: {
        userId,
        message,
        response: aiResponse.response,
        category,
        level,
        hasCorrection: aiResponse.hasCorrection,
        xpEarned: aiResponse.xpEarned,
      },
    });

    // Save mistake if correction
    if (aiResponse.hasCorrection && aiResponse.correctSentence) {
      await this.prisma.aiLearningMemory.create({
        data: {
          userId,
          mistakeType: 'grammar',
          wrongSentence: message,
          correctSentence: aiResponse.correctSentence,
          explanation: aiResponse.explanation || '',
          languageLevel: level,
        },
      });
    }

    // Update usage
    await this.prisma.aiUsage.upsert({
      where: {
        userId_date: {
          userId,
          date: new Date(new Date().setHours(0, 0, 0, 0)),
        },
      },
      update: {
        messagesUsed: { increment: 1 },
        tokensUsed: { increment: message.length + aiResponse.response.length },
      },
      create: {
        userId,
        date: new Date(new Date().setHours(0, 0, 0, 0)),
        messagesUsed: 1,
        tokensUsed: message.length + aiResponse.response.length,
      },
    });

    // Update user XP
    await this.prisma.user.update({
      where: { id: userId },
      data: { xp: { increment: aiResponse.xpEarned } },
    });

    return {
      response: aiResponse.response,
      correction: aiResponse.correction,
      original: aiResponse.original,
      correctedSentence: aiResponse.correctSentence,
      explanation: aiResponse.explanation,
      betterAlternative: aiResponse.betterAlternative,
      xpEarned: aiResponse.xpEarned,
      remaining: dailyLimit - (todayUsage?.messagesUsed || 0) - 1,
    };
  }

  async getHistory(userId: string) {
    return this.prisma.aiConversation.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async getMistakes(userId: string) {
    return this.prisma.aiLearningMemory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getStats(userId: string) {
    const todayUsage = await this.prisma.aiUsage.findFirst({
      where: {
        userId,
        createdAt: {
          gte: new Date(new Date().setHours(0, 0, 0, 0)),
        },
      },
    });

    const totalMistakes = await this.prisma.aiLearningMemory.count({
      where: { userId },
    });

    return {
      todayMessages: todayUsage?.messagesUsed || 0,
      dailyLimit: 20,
      totalMistakes,
      totalConversations: await this.prisma.aiConversation.count({ where: { userId } }),
    };
  }

  async clearHistory(userId: string) {
    await this.prisma.aiConversation.deleteMany({ where: { userId } });
    return { success: true };
  }

  private buildContext(user: any, mistakes: any[], level: string) {
    return `User: ${user?.name || 'Student'}\nLevel: ${level}\nRecent mistakes: ${mistakes.map(m => m.wrongSentence + ' -> ' + m.correctSentence).join(', ')}`;
  }

  private async generateResponse(message: string, category: string, context: string) {
    // Simple rule-based AI for demo
    const msgLower = message.toLowerCase();

    // Check for common German mistakes
    if (msgLower.includes('ich habe gehen') || msgLower.includes('ich habe gehe')) {
      return {
        response: 'Good attempt! Let me help you with that. 🎯',
        hasCorrection: true,
        correction: 'Use "sein" instead of "haben" with movement verbs',
        original: message,
        correctSentence: 'Ich bin gegangen',
        explanation: 'When using "gehen" (to go), use "sein" (not "haben") as the auxiliary verb in Perfekt.',
        betterAlternative: 'Ich bin nach Hause gegangen.',
        xpEarned: 10,
      };
    }

    if (msgLower.includes('ich bin gut') || msgLower.includes('mir geht')) {
      return {
        response: 'Sehr gut! 👏 That\'s correct! Keep up the great work!',
        hasCorrection: false,
        xpEarned: 5,
      };
    }

    // Default response
    return {
      response: 'Interesting! Can you tell me more about that? 🤔 Try using different sentence structures.',
      hasCorrection: false,
      xpEarned: 5,
    };
  }
}
