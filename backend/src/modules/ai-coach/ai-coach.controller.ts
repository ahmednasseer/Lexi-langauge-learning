import { Controller, Post, Get, Body, Req, HttpCode, HttpStatus, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AiCoachService } from './ai-coach.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('AI Coach')
@ApiBearerAuth()
@Controller('ai-coach')
@UseGuards(JwtAuthGuard)
export class AiCoachController {
  constructor(private readonly aiCoachService: AiCoachService) {}

  @Post('chat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send message to AI Coach' })
  async chat(
    @Req() req,
    @Body() body: {
      message: string;
      category?: string;
      level?: string;
    },
  ) {
    return this.aiCoachService.chat(req.user.id, body);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get conversation history' })
  async getHistory(@Req() req) {
    return this.aiCoachService.getHistory(req.user.id);
  }

  @Get('mistakes')
  @ApiOperation({ summary: 'Get learning mistakes' })
  async getMistakes(@Req() req) {
    return this.aiCoachService.getMistakes(req.user.id);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get AI Coach statistics' })
  async getStats(@Req() req) {
    return this.aiCoachService.getStats(req.user.id);
  }

  @Post('clear-history')
  @ApiOperation({ summary: 'Clear conversation history' })
  async clearHistory(@Req() req) {
    return this.aiCoachService.clearHistory(req.user.id);
  }
}
