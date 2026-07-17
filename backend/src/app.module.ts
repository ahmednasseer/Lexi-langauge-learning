import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { LessonsModule } from './modules/lessons/lessons.module';
import { ProgressModule } from './modules/progress/progress.module';
import { AiModule } from './modules/ai/ai.module';
import { AiCoachModule } from './modules/ai-coach/ai-coach.module';
import { SpeakingModule } from './modules/speaking/speaking.module';
import { DailyMissionsModule } from './modules/daily-missions/daily-missions.module';
import { CertificatesModule } from './modules/certificates/certificates.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { CommunityModule } from './modules/community/community.module';
import { AdminModule } from './modules/admin/admin.module';
import { AILearningModule } from './modules/ai-learning/ai-learning.module';
import { GoetheModule } from './modules/goethe/goethe.module';
import { AdvancedSpeakingModule } from './modules/advanced-speaking/advanced-speaking.module';
import { LiveLearningModule } from './modules/live-learning/live-learning.module';
import { GrowthModule } from './modules/growth/growth.module';
import { StoreModule } from './modules/store/store.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { SearchModule } from './modules/search/search.module';
import { FriendsModule } from './modules/friends/friends.module';
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
    AiCoachModule,
    SpeakingModule,
    DailyMissionsModule,
    CertificatesModule,
    PaymentsModule,
    CommunityModule,
    AdminModule,
    AILearningModule,
    GoetheModule,
    AdvancedSpeakingModule,
    LiveLearningModule,
    GrowthModule,
    StoreModule,
    NotificationsModule,
    SearchModule,
    FriendsModule,
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
