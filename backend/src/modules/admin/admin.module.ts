import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { PrismaService } from '../../config/prisma.service';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PaymentsModule } from '../payments/payments.module';

@Module({
  imports: [PaymentsModule],
  controllers: [AdminController],
  providers: [AdminService, PrismaService, RolesGuard],
  exports: [AdminService],
})
export class AdminModule {}
