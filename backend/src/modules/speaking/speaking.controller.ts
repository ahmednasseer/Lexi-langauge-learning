import { Controller, Post, Get, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { SpeakingService } from './speaking.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Speaking')
@Controller('speaking')
export class SpeakingController {
  constructor(private readonly speakingService: SpeakingService) {}

  @Post('pronunciation/analyze')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Analyze pronunciation' })
  @ApiResponse({ status: 200, description: 'Pronunciation analyzed successfully' })
  async analyzePronunciation(
    @Request() req,
    @Body() body: { spokenText: string; targetText: string; level: string },
  ) {
    return this.speakingService.analyzePronunciation(
      req.user.id,
      body.spokenText,
      body.targetText,
      body.level,
    );
  }

  @Get('exercises/:level')
  @ApiOperation({ summary: 'Get speaking exercises by level' })
  @ApiResponse({ status: 200, description: 'Exercises retrieved successfully' })
  async getExercises(@Param('level') level: string) {
    return this.speakingService.getExercises(level);
  }

  @Get('listening/:level')
  @ApiOperation({ summary: 'Get listening questions by level' })
  @ApiResponse({ status: 200, description: 'Listening questions retrieved successfully' })
  async getListeningQuestions(@Param('level') level: string) {
    return this.speakingService.getListeningQuestions(level);
  }

  @Get('stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user speaking stats' })
  @ApiResponse({ status: 200, description: 'Stats retrieved successfully' })
  async getStats(@Request() req) {
    return this.speakingService.getStats(req.user.id);
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user speaking history' })
  @ApiResponse({ status: 200, description: 'History retrieved successfully' })
  async getHistory(@Request() req) {
    return this.speakingService.getHistory(req.user.id);
  }
}
