import { Module } from '@nestjs/common';
import { DailyMissionsController } from './daily-missions.controller';
import { DailyMissionsService } from './daily-missions.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [DailyMissionsController],
  providers: [DailyMissionsService],
  exports: [DailyMissionsService],
})
export class DailyMissionsModule {}
