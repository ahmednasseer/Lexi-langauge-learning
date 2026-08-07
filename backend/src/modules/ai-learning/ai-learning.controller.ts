import { Controller, Get, Post, Put, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AILearningService } from './ai-learning.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('ai-learning')
@UseGuards(JwtAuthGuard)
export class AILearningController {
  constructor(private readonly aiLearningService: AILearningService) {}

  @Get('profile')
  async getProfile(@Request() req) {
    return this.aiLearningService.getLearningProfile(req.user.id);
  }

  @Put('profile')
  async updateProfile(@Request() req, @Body() data: {
    currentLevel?: string;
    learningGoal?: string;
    dailyMinutes?: number;
    learningSpeed?: string;
    preferredTopics?: string[];
  }) {
    return this.aiLearningService.updateLearningProfile(req.user.id, data);
  }

  @Post('analyze')
  async analyzePerformance(@Request() req, @Body() data: {
    quizResults: Array<{ category: string; correct: boolean; mistake?: string }>;
    flashcardResults: Array<{ word: string; category: string; remembered: boolean }>;
    speakingResults: Array<{ category: string; score: number; mistakes: string[] }>;
    aiConversationMistakes: Array<{ category: string; error: string }>;
  }) {
    return this.aiLearningService.analyzePerformance(req.user.id, data);
  }

  @Get('recommendations')
  async getRecommendations(@Request() req) {
    return this.aiLearningService.getRecommendations(req.user.id);
  }

  @Post('generate-plan')
  async generateStudyPlan(@Request() req) {
    return this.aiLearningService.generateStudyPlan(req.user.id);
  }

  @Get('study-plan')
  async getStudyPlan(@Request() req) {
    return this.aiLearningService.getStudyPlan(req.user.id);
  }

  @Get('analytics')
  async getAnalytics() {
    return this.aiLearningService.getAnalytics();
  }
}
