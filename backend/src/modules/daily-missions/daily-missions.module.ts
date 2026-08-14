import { Module } from '@nestjs/common';
import { DailyMissionsController } from './daily-missions.controller';
import { DailyMissionsService } from './daily-missions.service';
import { PrismaService } from '../../config/prisma.service';
import { WalletService } from '../payments/wallet/wallet.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [DailyMissionsController],
  providers: [DailyMissionsService, PrismaService, WalletService],
  exports: [DailyMissionsService],
})
export class DailyMissionsModule {}
