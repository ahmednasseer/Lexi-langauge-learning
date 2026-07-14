import { Controller, Post, Get, Body, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AiService } from './ai.service';
import { AiLearningPlanService } from './ai-learning-plan.service';
import { AiUsageService } from './ai-usage.service';
import { AudioService } from './audio.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('AI Tutor')
@Controller('ai')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AiController {
  constructor(
    private aiService: AiService,
    private planService: AiLearningPlanService,
    private usageService: AiUsageService,
    private audioService: AudioService,
  ) {}

  @Post('chat')
  @ApiOperation({ summary: 'Send message to AI tutor' })
  async chat(@Request() req, @Body() body: {
    message: string;
    learningLanguage: string;
    nativeLanguage: string;
  }) {
    // Check AI usage limits
    const usage = await this.usageService.checkUsage(req.user.sub, req.user.isPremium);
    if (!usage.allowed) {
      throw new Error('Daily AI message limit reached. Upgrade to Premium for unlimited.');
    }

    const result = await this.aiService.chat(req.user.sub, body.message, body.learningLanguage, body.nativeLanguage);

    // Record usage
    await this.usageService.recordUsage(req.user.sub, result.tokensUsed || 100);

    return { ...result, remaining: usage.remaining - 1 };
  }

  @Get('history')
  @ApiOperation({ summary: 'Get chat history' })
  async getHistory(@Request() req) {
    return this.aiService.getChatHistory(req.user.sub);
  }

  @Post('clear-history')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Clear chat history' })
  async clearHistory(@Request() req) {
    return this.aiService.clearChatHistory(req.user.sub);
  }

  @Post('learning-plan')
  @ApiOperation({ summary: 'Generate AI learning plan' })
  async generatePlan(@Request() req, @Body() body: {
    goal: string; level: string; language: string; dailyMinutes: number;
  }) {
    return this.planService.generatePlan(req.user.sub, body);
  }

  @Get('learning-plan')
  @ApiOperation({ summary: 'Get current learning plan' })
  async getPlan(@Request() req) {
    return this.planService.getUserPlan(req.user.sub);
  }

  @Get('usage')
  @ApiOperation({ summary: 'Get AI usage stats' })
  async getUsage(@Request() req) {
    return this.usageService.getUsageStats(req.user.sub);
  }

  @Post('tts')
  @ApiOperation({ summary: 'Generate text-to-speech audio' })
  async generateTTS(@Body() body: {
    text: string;
    language: string;
    voice?: string;
  }) {
    return this.audioService.generateTTS(body);
  }
}
