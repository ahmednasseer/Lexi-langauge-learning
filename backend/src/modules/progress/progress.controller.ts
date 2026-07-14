import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ProgressService } from './progress.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Progress')
@Controller('progress')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ProgressController {
  constructor(private progressService: ProgressService) {}

  @Post('complete')
  @ApiOperation({ summary: 'Mark lesson as completed' })
  async completeLesson(@Request() req, @Body() body: {
    lessonId: string; score: number; timeSpent: number;
  }) {
    return this.progressService.completeLesson(req.user.sub, body.lessonId, body.score, body.timeSpent);
  }

  @Get()
  @ApiOperation({ summary: 'Get user progress' })
  async getProgress(@Request() req) {
    return this.progressService.getUserProgress(req.user.sub);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get user stats' })
  async getStats(@Request() req) {
    return this.progressService.getStats(req.user.sub);
  }
}
