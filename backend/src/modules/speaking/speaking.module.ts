import { Module } from '@nestjs/common';
import { SpeakingController } from './speaking.controller';
import { SpeakingService } from './speaking.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [SpeakingController],
  providers: [SpeakingService],
  exports: [SpeakingService],
})
export class SpeakingModule {}
