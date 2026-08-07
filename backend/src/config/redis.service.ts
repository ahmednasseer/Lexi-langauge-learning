import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleDestroy {
  private client: Redis | null = null;
  private subscriber: Redis | null = null;
  private redisEnabled: boolean;

  constructor(private config: ConfigService) {
    this.redisEnabled = this.config.get('REDIS_ENABLED', 'true') !== 'false';
  }

  private getClient(): Redis {
    if (!this.client) {
      this.client = new Redis({
        host: this.config.get('REDIS_HOST', 'localhost'),
        port: this.config.get('REDIS_PORT', 6379),
        password: this.config.get('REDIS_PASSWORD') || undefined,
        maxRetriesPerRequest: 3,
        lazyConnect: true,
      });
    }
    return this.client;
  }

  private getSubscriber(): Redis {
    if (!this.subscriber) {
      this.subscriber = this.getClient().duplicate();
    }
    return this.subscriber;
  }

  async onModuleDestroy() {
    if (this.client) await this.client.quit();
    if (this.subscriber) await this.subscriber.quit();
  }

  isRedisEnabled(): boolean {
    return this.redisEnabled;
  }

  async get<T>(key: string): Promise<T | null> {
    if (!this.redisEnabled) return null;
    try {
      const data = await this.getClient().get(key);
      return data ? JSON.parse(data) : null;
    } catch {
      return null;
    }
  }

  async set(key: string, value: any, ttlSeconds = 3600): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      await this.getClient().set(key, JSON.stringify(value), 'EX', ttlSeconds);
    } catch {
      // Ignore cache errors
    }
  }

  async del(key: string): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      await this.getClient().del(key);
    } catch {
      // Ignore cache errors
    }
  }

  async delPattern(pattern: string): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      const keys = await this.getClient().keys(pattern);
      if (keys.length > 0) await this.getClient().del(...keys);
    } catch {
      // Ignore cache errors
    }
  }

  async checkRateLimit(key: string, maxRequests: number, windowSeconds: number): Promise<{ allowed: boolean; remaining: number; resetAt: number }> {
    if (!this.redisEnabled) return { allowed: true, remaining: maxRequests, resetAt: 0 };
    try {
      const now = Date.now();
      const windowKey = `${key}:${Math.floor(now / (windowSeconds * 1000))}`;

      const current = await this.getClient().incr(windowKey);
      if (current === 1) {
        await this.getClient().expire(windowKey, windowSeconds);
      }

      return {
        allowed: current <= maxRequests,
        remaining: Math.max(0, maxRequests - current),
        resetAt: Math.ceil(now / 1000) + windowSeconds,
      };
    } catch {
      return { allowed: true, remaining: maxRequests, resetAt: 0 };
    }
  }

  async updateLeaderboard(leaderboardKey: string, userId: string, score: number): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      await this.getClient().zadd(leaderboardKey, score, userId);
    } catch {
      // Ignore leaderboard errors
    }
  }

  async getLeaderboard(leaderboardKey: string, top = 100): Promise<{ userId: string; score: number; rank: number }[]> {
    if (!this.redisEnabled) return [];
    try {
      const results = await this.getClient().zrevrange(leaderboardKey, 0, top - 1, 'WITHSCORES');
      const leaderboard: { userId: string; score: number; rank: number }[] = [];
      for (let i = 0; i < results.length; i += 2) {
        leaderboard.push({
          userId: results[i],
          score: parseInt(results[i + 1]),
          rank: (i / 2) + 1,
        });
      }
      return leaderboard;
    } catch {
      return [];
    }
  }

  async getUserRank(leaderboardKey: string, userId: string): Promise<number> {
    if (!this.redisEnabled) return -1;
    try {
      const rank = await this.getClient().zrevrank(leaderboardKey, userId);
      return rank !== null ? rank + 1 : -1;
    } catch {
      return -1;
    }
  }

  async updateStreak(userId: string): Promise<{ current: number; best: number }> {
    if (!this.redisEnabled) return { current: 0, best: 0 };
    try {
      const today = new Date().toISOString().split('T')[0];
      const streakKey = `streak:${userId}`;
      const lastActiveKey = `streak:last:${userId}`;

      const lastActive = await this.getClient().get(lastActiveKey);
      let current = parseInt(await this.getClient().get(streakKey) || '0');

      if (lastActive === today) return { current, best: current };

      const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
      if (lastActive === yesterday) {
        current++;
      } else {
        current = 1;
      }

      await this.getClient().set(streakKey, current);
      await this.getClient().set(lastActiveKey, today);

      const bestKey = `streak:best:${userId}`;
      const best = parseInt(await this.getClient().get(bestKey) || '0');
      if (current > best) {
        await this.getClient().set(bestKey, current);
        return { current, best: current };
      }

      return { current, best };
    } catch {
      return { current: 0, best: 0 };
    }
  }

  async trackAiUsage(userId: string): Promise<{ count: number; allowed: boolean }> {
    if (!this.redisEnabled) return { count: 0, allowed: true };
    try {
      const today = new Date().toISOString().split('T')[0];
      const key = `ai_usage:${userId}:${today}`;

      const count = await this.getClient().incr(key);
      if (count === 1) {
        await this.getClient().expire(key, 86400);
      }

      return { count, allowed: true };
    } catch {
      return { count: 0, allowed: true };
    }
  }

  async getAiUsageCount(userId: string): Promise<number> {
    if (!this.redisEnabled) return 0;
    try {
      const today = new Date().toISOString().split('T')[0];
      const key = `ai_usage:${userId}:${today}`;
      return parseInt(await this.getClient().get(key) || '0');
    } catch {
      return 0;
    }
  }

  async setSession(token: string, userId: string, ttlSeconds = 86400): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      await this.getClient().set(`session:${token}`, userId, 'EX', ttlSeconds);
    } catch {
      // Ignore session errors
    }
  }

  async getSession(token: string): Promise<string | null> {
    if (!this.redisEnabled) return null;
    try {
      return this.getClient().get(`session:${token}`);
    } catch {
      return null;
    }
  }

  async deleteSession(token: string): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      await this.getClient().del(`session:${token}`);
    } catch {
      // Ignore session errors
    }
  }

  async acquireLock(key: string, ttlSeconds = 10): Promise<boolean> {
    if (!this.redisEnabled) return true;
    try {
      const result = await this.getClient().set(`lock:${key}`, '1', 'EX', ttlSeconds, 'NX');
      return result === 'OK';
    } catch {
      return true;
    }
  }

  async releaseLock(key: string): Promise<void> {
    if (!this.redisEnabled) return;
    try {
      await this.getClient().del(`lock:${key}`);
    } catch {
      // Ignore lock errors
    }
  }
}
