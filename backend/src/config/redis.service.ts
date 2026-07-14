import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleDestroy {
  private client: Redis;
  private subscriber: Redis;

  constructor(private config: ConfigService) {
    this.client = new Redis({
      host: config.get('REDIS_HOST', 'localhost'),
      port: config.get('REDIS_PORT', 6379),
      maxRetriesPerRequest: 3,
    });
    this.subscriber = this.client.duplicate();
  }

  async onModuleDestroy() {
    await this.client.quit();
    await this.subscriber.quit();
  }

  // ==================== CACHE ====================
  async get<T>(key: string): Promise<T | null> {
    const data = await this.client.get(key);
    return data ? JSON.parse(data) : null;
  }

  async set(key: string, value: any, ttlSeconds = 3600): Promise<void> {
    await this.client.set(key, JSON.stringify(value), 'EX', ttlSeconds);
  }

  async del(key: string): Promise<void> {
    await this.client.del(key);
  }

  async delPattern(pattern: string): Promise<void> {
    const keys = await this.client.keys(pattern);
    if (keys.length > 0) await this.client.del(...keys);
  }

  // ==================== RATE LIMITING ====================
  async checkRateLimit(key: string, maxRequests: number, windowSeconds: number): Promise<{ allowed: boolean; remaining: number; resetAt: number }> {
    const now = Date.now();
    const windowKey = `${key}:${Math.floor(now / (windowSeconds * 1000))}`;

    const current = await this.client.incr(windowKey);
    if (current === 1) {
      await this.client.expire(windowKey, windowSeconds);
    }

    return {
      allowed: current <= maxRequests,
      remaining: Math.max(0, maxRequests - current),
      resetAt: Math.ceil(now / 1000) + windowSeconds,
    };
  }

  // ==================== LEADERBOARD ====================
  async updateLeaderboard(leaderboardKey: string, userId: string, score: number): Promise<void> {
    await this.client.zadd(leaderboardKey, score, userId);
  }

  async getLeaderboard(leaderboardKey: string, top = 100): Promise<{ userId: string; score: number; rank: number }[]> {
    const results = await this.client.zrevrange(leaderboardKey, 0, top - 1, 'WITHSCORES');
    const leaderboard: { userId: string; score: number; rank: number }[] = [];
    for (let i = 0; i < results.length; i += 2) {
      leaderboard.push({
        userId: results[i],
        score: parseInt(results[i + 1]),
        rank: (i / 2) + 1,
      });
    }
    return leaderboard;
  }

  async getUserRank(leaderboardKey: string, userId: string): Promise<number> {
    const rank = await this.client.zrevrank(leaderboardKey, userId);
    return rank !== null ? rank + 1 : -1;
  }

  // ==================== STREAK ====================
  async updateStreak(userId: string): Promise<{ current: number; best: number }> {
    const today = new Date().toISOString().split('T')[0];
    const streakKey = `streak:${userId}`;
    const lastActiveKey = `streak:last:${userId}`;

    const lastActive = await this.client.get(lastActiveKey);
    let current = parseInt(await this.client.get(streakKey) || '0');

    if (lastActive === today) return { current, best: current };

    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    if (lastActive === yesterday) {
      current++;
    } else {
      current = 1;
    }

    await this.client.set(streakKey, current);
    await this.client.set(lastActiveKey, today);

    const bestKey = `streak:best:${userId}`;
    const best = parseInt(await this.client.get(bestKey) || '0');
    if (current > best) {
      await this.client.set(bestKey, current);
      return { current, best: current };
    }

    return { current, best };
  }

  // ==================== AI USAGE TRACKING ====================
  async trackAiUsage(userId: string): Promise<{ count: number; allowed: boolean }> {
    const today = new Date().toISOString().split('T')[0];
    const key = `ai_usage:${userId}:${today}`;

    const count = await this.client.incr(key);
    if (count === 1) {
      await this.client.expire(key, 86400); // 24 hours
    }

    return { count, allowed: true };
  }

  async getAiUsageCount(userId: string): Promise<number> {
    const today = new Date().toISOString().split('T')[0];
    const key = `ai_usage:${userId}:${today}`;
    return parseInt(await this.client.get(key) || '0');
  }

  // ==================== SESSION ====================
  async setSession(token: string, userId: string, ttlSeconds = 86400): Promise<void> {
    await this.client.set(`session:${token}`, userId, 'EX', ttlSeconds);
  }

  async getSession(token: string): Promise<string | null> {
    return this.client.get(`session:${token}`);
  }

  async deleteSession(token: string): Promise<void> {
    await this.client.del(`session:${token}`);
  }

  // ==================== LOCKS ====================
  async acquireLock(key: string, ttlSeconds = 10): Promise<boolean> {
    const result = await this.client.set(`lock:${key}`, '1', 'EX', ttlSeconds, 'NX');
    return result === 'OK';
  }

  async releaseLock(key: string): Promise<void> {
    await this.client.del(`lock:${key}`);
  }
}
