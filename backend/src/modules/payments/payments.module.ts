import { Module } from '@nestjs/common';
import { PaymentsController } from './payments.controller';
import { WalletController } from './wallet/wallet.controller';
import { PaymentsService } from './payments.service';
import { WalletService } from './wallet/wallet.service';
import { SubscriptionsService } from './subscriptions/subscriptions.service';
import { PrismaService } from '../../config/prisma.service';

@Module({
  controllers: [PaymentsController, WalletController],
  providers: [PaymentsService, WalletService, SubscriptionsService, PrismaService],
  exports: [WalletService, SubscriptionsService],
})
export class PaymentsModule {}
