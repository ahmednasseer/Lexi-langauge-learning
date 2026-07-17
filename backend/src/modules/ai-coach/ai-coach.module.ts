import { Module } from '@nestjs/common';
import { AiCoachController } from './ai-coach.controller';
import { AiCoachService } from './ai-coach.service';
import { PrismaService } from '../../config/prisma.service';

@Module({
  controllers: [AiCoachController],
  providers: [AiCoachService, PrismaService],
  exports: [AiCoachService],
})
export class AiCoachModule {}
