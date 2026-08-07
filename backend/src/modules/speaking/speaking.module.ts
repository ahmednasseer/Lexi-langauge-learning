import { Module } from '@nestjs/common';
import { SpeakingController } from './speaking.controller';
import { SpeakingService } from './speaking.service';
import { PrismaService } from '../../config/prisma.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [SpeakingController],
  providers: [SpeakingService, PrismaService],
  exports: [SpeakingService],
})
export class SpeakingModule {}
