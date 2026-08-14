import { Controller, Get, Post, Body, Param, HttpCode, HttpStatus, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AdvancedSpeakingService, ConversationScenario, ConversationMessage, PronunciationAnalysis } from './advanced-speaking.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Advanced Speaking')
@Controller('speaking')
@UseGuards(JwtAuthGuard)
export class AdvancedSpeakingController {
  constructor(private readonly speakingService: AdvancedSpeakingService) {}

  /** Resolve acting user from token, rejecting client-supplied userId mismatches. */
  private self(sub: string, provided?: string): string {
    if (provided && provided !== sub) {
      throw new ForbiddenException('Cannot operate on another user');
    }
    return sub;
  }

  @Post('session/start')
  @HttpCode(HttpStatus.CREATED)
  startSession(@Req() req, @Body() body: { userId?: string; scenario: ConversationScenario }) {
    const session = this.speakingService.startSession(this.self(req.user.sub, body.userId), body.scenario);
    return {
      success: true,
      data: session,
    };
  }

  @Post('analyze')
  @HttpCode(HttpStatus.OK)
  analyzePronunciation(@Body() body: { spokenText: string; targetText: string }) {
    const analysis = this.speakingService.analyzePronunciation(body.spokenText, body.targetText);
    return {
      success: true,
      data: analysis,
    };
  }

  @Post('response')
  @HttpCode(HttpStatus.OK)
  getAIResponse(@Req() req, @Body() body: { sessionId: string; userResponse: string }) {
    const response = this.speakingService.getAIResponse(body.sessionId, body.userResponse, req.user.sub);
    return {
      success: true,
      data: { response },
    };
  }

  @Post('message')
  @HttpCode(HttpStatus.OK)
  addMessage(@Req() req, @Body() body: {
    sessionId: string;
    role: 'ai' | 'user';
    content: string;
    germanText?: string;
    correction?: string;
    pronunciationAnalysis?: PronunciationAnalysis;
  }) {
    const message: ConversationMessage = {
      id: `msg_${Date.now()}`,
      role: body.role,
      content: body.content,
      germanText: body.germanText,
      timestamp: new Date(),
      isCorrected: !!body.correction,
      correction: body.correction,
      pronunciationAnalysis: body.pronunciationAnalysis,
    };

    this.speakingService.addMessage(body.sessionId, message, req.user.sub);
    return {
      success: true,
      data: { message },
    };
  }

  @Post('session/end')
  @HttpCode(HttpStatus.OK)
  endSession(@Req() req, @Body() body: { sessionId: string }) {
    const session = this.speakingService.endSession(body.sessionId, req.user.sub);
    return {
      success: true,
      data: session,
    };
  }

  @Post('feedback')
  @HttpCode(HttpStatus.OK)
  getFeedback(@Req() req, @Body() body: { sessionId: string }) {
    const feedback = this.speakingService.generateFeedback(body.sessionId, req.user.sub);
    return {
      success: true,
      data: feedback,
    };
  }

  @Get('history/:userId')
  getHistory(@Req() req, @Param('userId') userId: string) {
    const history = this.speakingService.getHistory(this.self(req.user.sub, userId));
    return {
      success: true,
      data: history,
    };
  }

  @Get('progress/:userId')
  getProgress(@Req() req, @Param('userId') userId: string) {
    const progress = this.speakingService.getProgress(this.self(req.user.sub, userId));
    return {
      success: true,
      data: progress,
    };
  }

  @Get('challenges/:userId')
  getChallenges(@Req() req, @Param('userId') userId: string) {
    const challenges = this.speakingService.getChallenges(this.self(req.user.sub, userId));
    return {
      success: true,
      data: challenges,
    };
  }

  @Get('analytics')
  getAnalytics() {
    return {
      success: true,
      data: {
        totalSessions: 0,
        averageScore: 0,
        commonErrors: [],
        topScenarios: [],
      },
    };
  }
}