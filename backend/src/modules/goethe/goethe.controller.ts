import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { GoetheService } from './goethe.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('goethe')
@UseGuards(JwtAuthGuard)
export class GoetheController {
  constructor(private readonly goetheService: GoetheService) {}

  @Get('levels')
  async getExamLevels() {
    return this.goetheService.getExamLevels();
  }

  @Get(':level/exams')
  async getExamsForLevel(@Param('level') level: string) {
    return this.goetheService.getExamsForLevel(level);
  }

  @Post('mock/start')
  async startMockExam(@Request() req, @Body() data: { level: string }) {
    return this.goetheService.startMockExam(req.user.id, data.level);
  }

  @Post('mock/submit')
  async submitMockExam(@Request() req, @Body() data: {
    examId: string;
    answers: Record<string, string>;
    timeSpentSeconds: number;
  }) {
    return this.goetheService.submitMockExam(req.user.id, data.examId, data);
  }

  @Post('writing/analyze')
  async analyzeWriting(@Request() req, @Body() data: {
    level: string;
    prompt: string;
    text: string;
  }) {
    return this.goetheService.analyzeWriting(req.user.id, data);
  }

  @Post('speaking/analyze')
  async analyzeSpeaking(@Request() req, @Body() data: {
    level: string;
    prompt: string;
    audioTranscript: string;
  }) {
    return this.goetheService.analyzeSpeaking(req.user.id, data);
  }

  @Get('progress')
  async getProgress(@Request() req) {
    return this.goetheService.getProgress(req.user.id);
  }
}
