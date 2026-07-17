import { Controller, Get, Post, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { GrowthService } from './growth.service';

@Controller('growth')
export class GrowthController {
  constructor(private readonly growthService: GrowthService) {}

  // Referral System
  @Post('referral/generate')
  @HttpCode(HttpStatus.CREATED)
  generateReferralCode(@Body() body: { userId: string }) {
    const code = this.growthService.generateReferralCode(body.userId);
    return { success: true, data: code };
  }

  @Post('referral/apply')
  @HttpCode(HttpStatus.OK)
  applyReferralCode(@Body() body: { code: string; inviteeId: string; inviteeName: string }) {
    const referral = this.growthService.applyReferralCode(body.code, body.inviteeId, body.inviteeName);
    return { success: true, data: referral };
  }

  @Get('referral/stats/:userId')
  getReferralStats(@Param('userId') userId: string) {
    const stats = this.growthService.getReferralStats(userId);
    return { success: true, data: stats };
  }

  // Gamification
  @Get('levels')
  getLevels() {
    const levels = this.growthService.getLevels();
    return { success: true, data: levels };
  }

  @Get('xp/:userId')
  getUserXp(@Param('userId') userId: string) {
    const xp = this.growthService.getUserXp(userId);
    const level = this.growthService.calculateLevel(xp);
    return { success: true, data: { xp, level } };
  }

  @Post('xp/add')
  @HttpCode(HttpStatus.OK)
  addXp(@Body() body: { userId: string; xp: number }) {
    const result = this.growthService.addXp(body.userId, body.xp);
    return { success: true, data: result };
  }

  // Seasonal Events
  @Get('events')
  getEvents() {
    const events = this.growthService.getEvents();
    return { success: true, data: events };
  }

  @Post('events/:id/join')
  @HttpCode(HttpStatus.OK)
  joinEvent(@Param('id') id: string, @Body() body: { userId: string }) {
    const event = this.growthService.joinEvent(id, body.userId);
    return { success: true, data: event };
  }

  // Analytics
  @Get('analytics')
  getAnalytics() {
    const analytics = this.growthService.getAnalytics();
    return { success: true, data: analytics };
  }
}
