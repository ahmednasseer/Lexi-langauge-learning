import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DailyMissionsService } from './daily-missions.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Daily Missions')
@Controller('daily-missions')
export class DailyMissionsController {
  constructor(private readonly missionsService: DailyMissionsService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get today missions' })
  async getTodayMissions(@Request() req) {
    return this.missionsService.getTodayMissions(req.user.id);
  }

  @Post('progress')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update mission progress' })
  async updateProgress(
    @Request() req,
    @Body() body: { type: string; amount: number },
  ) {
    return this.missionsService.updateProgress(req.user.id, body.type, body.amount);
  }

  @Post('claim/:missionId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Claim mission reward' })
  async claimReward(
    @Request() req,
    @Param('missionId') missionId: string,
  ) {
    return this.missionsService.claimReward(req.user.id, missionId);
  }

  @Post('daily-bonus')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Claim daily bonus' })
  async claimDailyBonus(@Request() req) {
    return this.missionsService.claimDailyBonus(req.user.id);
  }

  @Get('stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get mission stats' })
  async getStats(@Request() req) {
    return this.missionsService.getStats(req.user.id);
  }
}
