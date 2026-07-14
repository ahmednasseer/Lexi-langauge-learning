import { Injectable, NestMiddleware, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { RedisService } from '../../config/redis.service';

@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  constructor(private redis: RedisService) {}

  async use(req: Request, res: Response, next: NextFunction) {
    const ip = req.ip || req.headers['x-forwarded-for'] || 'unknown';
    const key = `ratelimit:${ip}`;

    const { allowed, remaining, resetAt } = await this.redis.checkRateLimit(key, 100, 60);

    res.setHeader('X-RateLimit-Limit', '100');
    res.setHeader('X-RateLimit-Remaining', remaining.toString());
    res.setHeader('X-RateLimit-Reset', resetAt.toString());

    if (!allowed) {
      throw new HttpException('Rate limit exceeded. Try again later.', HttpStatus.TOO_MANY_REQUESTS);
    }

    next();
  }
}

@Injectable()
export class AiRateLimitMiddleware implements NestMiddleware {
  constructor(private redis: RedisService) {}

  async use(req: Request, res: Response, next: NextFunction) {
    const userId = (req as any).user?.sub;
    if (!userId) return next();

    const isPremium = (req as any).user?.isPremium;
    const maxRequests = isPremium ? 200 : 20;
    const key = `ai_ratelimit:${userId}`;

    const { allowed, remaining, resetAt } = await this.redis.checkRateLimit(key, maxRequests, 86400);

    res.setHeader('X-AI-RateLimit-Limit', maxRequests.toString());
    res.setHeader('X-AI-RateLimit-Remaining', remaining.toString());

    if (!allowed) {
      throw new HttpException(
        'Daily AI message limit reached. Upgrade to Premium for unlimited.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    next();
  }
}

@Injectable()
export class SecurityHeadersMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
    res.setHeader('Permissions-Policy', 'camera=(), microphone=(self), geolocation=()');
    next();
  }
}
