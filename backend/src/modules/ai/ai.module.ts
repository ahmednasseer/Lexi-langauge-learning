import { Module } from '@nestjs/common';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { AiLearningPlanService } from './ai-learning-plan.service';
import { AiUsageService } from './ai-usage.service';
import { AudioService } from './audio.service';
import { PrismaService } from '../../config/prisma.service';
import { RedisService } from '../../config/redis.service';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [UsersModule],
  controllers: [AiController],
  providers: [
    AiService,
    AiLearningPlanService,
    AiUsageService,
    AudioService,
    PrismaService,
    RedisService,
  ],
  exports: [AiService, AiUsageService, AudioService],
})
export class AiModule {}
