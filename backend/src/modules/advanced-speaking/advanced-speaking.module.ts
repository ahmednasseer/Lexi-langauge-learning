import { Module } from '@nestjs/common';
import { AdvancedSpeakingController } from './advanced-speaking.controller';
import { AdvancedSpeakingService } from './advanced-speaking.service';

@Module({
  controllers: [AdvancedSpeakingController],
  providers: [AdvancedSpeakingService],
  exports: [AdvancedSpeakingService],
})
export class AdvancedSpeakingModule {}
