import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { LessonsModule } from './modules/lessons/lessons.module';
import { ProgressModule } from './modules/progress/progress.module';
import { AiModule } from './modules/ai/ai.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { AdminModule } from './modules/admin/admin.module';
import { RedisService } from './config/redis.service';
import { QueueService } from './config/queue.service';
import { MonitoringService } from './common/monitoring/monitoring.service';
import {
  RateLimitMiddleware,
  SecurityHeadersMiddleware,
} from './common/middleware/security.middleware';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    UsersModule,
    LessonsModule,
    ProgressModule,
    AiModule,
    PaymentsModule,
    AdminModule,
  ],
  providers: [
    RedisService,
    QueueService,
    MonitoringService,
  ],
  exports: [RedisService, QueueService, MonitoringService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(SecurityHeadersMiddleware, RateLimitMiddleware)
      .forRoutes('*');
  }
}
