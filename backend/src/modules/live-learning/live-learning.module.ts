import { Module } from '@nestjs/common';
import { LiveLearningController } from './live-learning.controller';
import { LiveLearningService } from './live-learning.service';

@Module({
  controllers: [LiveLearningController],
  providers: [LiveLearningService],
  exports: [LiveLearningService],
})
export class LiveLearningModule {}
