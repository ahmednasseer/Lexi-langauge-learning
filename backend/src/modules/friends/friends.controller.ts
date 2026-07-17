import { Controller, Get, Post, Param, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FriendsService } from './friends.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Friends')
@Controller('friends')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FriendsController {
  constructor(private friendsService: FriendsService) {}

  @Get()
  @ApiOperation({ summary: 'Get friends list (accepted mutual requests)' })
  async getFriends(@Request() req) {
    return this.friendsService.getFriends(req.user.sub);
  }

  @Get('requests')
  @ApiOperation({ summary: 'Get pending friend requests' })
  async getRequests(@Request() req) {
    return this.friendsService.getRequests(req.user.sub);
  }

  @Post('requests/:requestId')
  @ApiOperation({ summary: 'Accept or reject a friend request' })
  async respond(@Request() req, @Param('requestId') requestId: string, @Body() body: { accept: boolean }) {
    return this.friendsService.respond(req.user.sub, requestId, body.accept);
  }
}
