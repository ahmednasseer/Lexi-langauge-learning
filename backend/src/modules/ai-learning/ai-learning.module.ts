import { Module } from '@nestjs/common';
import { AILearningController } from './ai-learning.controller';
import { AILearningService } from './ai-learning.service';
import { PrismaService } from '../../config/prisma.service';

@Module({
  controllers: [AILearningController],
  providers: [AILearningService, PrismaService],
  exports: [AILearningService],
})
export class AILearningModule {}
