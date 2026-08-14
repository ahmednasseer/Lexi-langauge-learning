import { Controller, Get, Post, Body, Param, HttpCode, HttpStatus, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { GrowthService } from './growth.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('growth')
@UseGuards(JwtAuthGuard)
export class GrowthController {
  constructor(private readonly growthService: GrowthService) {}

  /** Resolves the acting user from the verified token; rejects any client-supplied mismatch. */
  private self(sub: string, provided?: string): string {
    if (provided && provided !== sub) {
      throw new ForbiddenException('Cannot operate on another user');
    }
    return sub;
  }

  // Referral System
  @Post('referral/generate')
  @HttpCode(HttpStatus.CREATED)
  generateReferralCode(@Req() req, @Body() body: { userId?: string }) {
    const userId = this.self(req.user.sub, body.userId);
    const code = this.growthService.generateReferralCode(userId);
    return { success: true, data: code };
  }

  @Post('referral/apply')
  @HttpCode(HttpStatus.OK)
  applyReferralCode(@Req() req, @Body() body: { code: string; inviteeId?: string; inviteeName?: string }) {
    const inviteeId = this.self(req.user.sub, body.inviteeId);
    const referral = this.growthService.applyReferralCode(body.code, inviteeId, body.inviteeName || '');
    return { success: true, data: referral };
  }

  @Get('referral/stats/:userId')
  getReferralStats(@Req() req, @Param('userId') userId: string) {
    const stats = this.growthService.getReferralStats(this.self(req.user.sub, userId));
    return { success: true, data: stats };
  }

  // Gamification
  @Get('levels')
  getLevels() {
    const levels = this.growthService.getLevels();
    return { success: true, data: levels };
  }

  @Get('xp/:userId')
  getUserXp(@Req() req, @Param('userId') userId: string) {
    const sub = this.self(req.user.sub, userId);
    const xp = this.growthService.getUserXp(sub);
    const level = this.growthService.calculateLevel(xp);
    return { success: true, data: { xp, level } };
  }

  // Seasonal Events
  @Get('events')
  getEvents() {
    const events = this.growthService.getEvents();
    return { success: true, data: events };
  }

  @Post('events/:id/join')
  @HttpCode(HttpStatus.OK)
  joinEvent(@Req() req, @Param('id') id: string, @Body() body: { userId?: string }) {
    const event = this.growthService.joinEvent(id, this.self(req.user.sub, body.userId));
    return { success: true, data: event };
  }

  // Analytics
  @Get('analytics')
  getAnalytics() {
    const analytics = this.growthService.getAnalytics();
    return { success: true, data: analytics };
  }
}