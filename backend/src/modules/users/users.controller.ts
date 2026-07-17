import { Controller, Get, Patch, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpdateProfileDto, SpendGemsDto } from './dto/users.dto';

@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get user profile' })
  async getProfile(@Request() req) {
    return this.usersService.getProfile(req.user.sub);
  }

  @Patch('profile')
  @ApiOperation({ summary: 'Update user profile' })
  async updateProfile(@Request() req, @Body() body: UpdateProfileDto) {
    return this.usersService.updateProfile(req.user.sub, body);
  }

  @Get('achievements')
  @ApiOperation({ summary: 'Get user achievements' })
  async getAchievements(@Request() req) {
    return this.usersService.getAchievements(req.user.sub);
  }

  @Get('wallet')
  @ApiOperation({ summary: 'Get gems wallet' })
  async getWallet(@Request() req) {
    return this.usersService.getWallet(req.user.sub);
  }

  @Post('wallet/spend')
  @ApiOperation({ summary: 'Spend gems' })
  async spendGems(
    @Request() req,
    @Body() body: SpendGemsDto,
  ) {
    return this.usersService.spendGems(req.user.sub, body.amount, body.description ?? '');
  }

  @Get('growth')
  @ApiOperation({ summary: 'Get growth stats' })
  async getGrowth(@Request() req) {
    return this.usersService.getGrowth(req.user.sub);
  }
}
