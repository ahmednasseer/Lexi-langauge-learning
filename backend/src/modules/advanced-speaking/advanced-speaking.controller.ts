import { Controller, Get, Post, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { AdvancedSpeakingService, ConversationScenario, ConversationState, ConversationMessage, PronunciationAnalysis } from './advanced-speaking.service';

@Controller('speaking')
export class AdvancedSpeakingController {
  constructor(private readonly speakingService: AdvancedSpeakingService) {}

  @Post('session/start')
  @HttpCode(HttpStatus.CREATED)
  startSession(@Body() body: { userId: string; scenario: ConversationScenario }) {
    const session = this.speakingService.startSession(body.userId, body.scenario);
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
  getAIResponse(@Body() body: { sessionId: string; userResponse: string }) {
    const response = this.speakingService.getAIResponse(body.sessionId, body.userResponse);
    return {
      success: true,
      data: { response },
    };
  }

  @Post('message')
  @HttpCode(HttpStatus.OK)
  addMessage(@Body() body: {
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

    this.speakingService.addMessage(body.sessionId, message);
    return {
      success: true,
      data: { message },
    };
  }

  @Post('session/end')
  @HttpCode(HttpStatus.OK)
  endSession(@Body() body: { sessionId: string }) {
    const session = this.speakingService.endSession(body.sessionId);
    return {
      success: true,
      data: session,
    };
  }

  @Post('feedback')
  @HttpCode(HttpStatus.OK)
  getFeedback(@Body() body: { sessionId: string }) {
    const feedback = this.speakingService.generateFeedback(body.sessionId);
    return {
      success: true,
      data: feedback,
    };
  }

  @Get('history/:userId')
  getHistory(@Param('userId') userId: string) {
    const history = this.speakingService.getHistory(userId);
    return {
      success: true,
      data: history,
    };
  }

  @Get('progress/:userId')
  getProgress(@Param('userId') userId: string) {
    const progress = this.speakingService.getProgress(userId);
    return {
      success: true,
      data: progress,
    };
  }

  @Get('challenges/:userId')
  getChallenges(@Param('userId') userId: string) {
    const challenges = this.speakingService.getChallenges(userId);
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
