import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { RedisService } from '../../config/redis.service';

interface UsageLimits {
  free: { messagesPerDay: number; tokensPerDay: number };
  premium: { messagesPerDay: number; tokensPerDay: number };
}

@Injectable()
export class AiUsageService {
  private readonly limits: UsageLimits = {
    free: { messagesPerDay: 20, tokensPerDay: 50000 },
    premium: { messagesPerDay: -1, tokensPerDay: -1 }, // unlimited
  };

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {}

  async checkUsage(userId: string, isPremium: boolean): Promise<{ allowed: boolean; remaining: number }> {
    const today = new Date().toISOString().split('T')[0];

    // Check Redis first (fast)
    const cachedCount = await this.redis.getAiUsageCount(userId);
    if (cachedCount > 0) {
      const limit = isPremium ? this.limits.premium : this.limits.free;
      if (limit.messagesPerDay === -1) return { allowed: true, remaining: -1 };
      return { allowed: cachedCount < limit.messagesPerDay, remaining: limit.messagesPerDay - cachedCount };
    }

    // Fallback to database
    const dbUsage = await this.prisma.aiUsage.findUnique({
      where: { userId_date: { userId, date: new Date(today) } },
    });

    const count = dbUsage?.messagesCount || 0;
    const limit = isPremium ? this.limits.premium : this.limits.free;
    if (limit.messagesPerDay === -1) return { allowed: true, remaining: -1 };

    return { allowed: count < limit.messagesPerDay, remaining: limit.messagesPerDay - count };
  }

  async recordUsage(userId: string, tokensUsed: number): Promise<void> {
    const today = new Date().toISOString().split('T')[0];

    // Update Redis
    await this.redis.trackAiUsage(userId);

    // Update database
    await this.prisma.aiUsage.upsert({
      where: { userId_date: { userId, date: new Date(today) } },
      update: {
        messagesCount: { increment: 1 },
        tokensUsed: { increment: tokensUsed },
      },
      create: {
        userId,
        date: new Date(today),
        messagesCount: 1,
        tokensUsed,
      },
    });
  }

  async getUsageStats(userId: string) {
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [dailyUsage, monthlyUsage] = await Promise.all([
      this.prisma.aiUsage.findUnique({
        where: { userId_date: { userId, date: today } },
      }),
      this.prisma.aiUsage.aggregate({
        where: { userId, date: { gte: startOfMonth } },
        _sum: { messagesCount: true, tokensUsed: true },
        _count: true,
      }),
    ]);

    return {
      today: {
        messages: dailyUsage?.messagesCount || 0,
        tokens: dailyUsage?.tokensUsed || 0,
      },
      thisMonth: {
        totalMessages: monthlyUsage._sum.messagesCount || 0,
        totalTokens: monthlyUsage._sum.tokensUsed || 0,
        activeDays: monthlyUsage._count,
      },
    };
  }

  async estimateCost(totalTokens: number): Promise<number> {
    // GPT-4o-mini pricing: $0.15 per 1M input tokens, $0.60 per 1M output tokens
    const avgTokensPerMessage = 800;
    const inputTokens = totalTokens * 0.6;
    const outputTokens = totalTokens * 0.4;
    const cost = (inputTokens * 0.15 + outputTokens * 0.60) / 1000000;
    return Math.round(cost * 100) / 100;
  }
}
