import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CommunityService } from './community.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreatePostDto, AddCommentDto, SendMessageRequestDto, SendMessageDto } from './dto/community.dto';

@ApiTags('Community')
@Controller('community')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Get('feed')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get community feed' })
  async getFeed(@Request() req) {
    return this.communityService.getFeed(req.user.id);
  }

  @Post('posts')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a post' })
  async createPost(
    @Request() req,
    @Body() body: CreatePostDto,
  ) {
    return this.communityService.createPost(req.user.id, body);
  }

  @Post('posts/:postId/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Like/unlike a post' })
  async toggleLike(
    @Request() req,
    @Param('postId') postId: string,
  ) {
    return this.communityService.toggleLike(req.user.id, postId);
  }

  @Post('posts/:postId/comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add comment to post' })
  async addComment(
    @Request() req,
    @Param('postId') postId: string,
    @Body() body: AddCommentDto,
  ) {
    return this.communityService.addComment(req.user.id, postId, body.text);
  }

  @Get('groups')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all groups' })
  async getGroups(@Request() req) {
    return this.communityService.getGroups(req.user.id);
  }

  @Post('groups/:groupId/join')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Join/leave a group' })
  async toggleGroupJoin(
    @Request() req,
    @Param('groupId') groupId: string,
  ) {
    return this.communityService.toggleGroupJoin(req.user.id, groupId);
  }

  @Get('leaderboard')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get leaderboard' })
  async getLeaderboard(@Request() req) {
    return this.communityService.getLeaderboard();
  }

  @Get('challenges')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get active challenges' })
  async getChallenges(@Request() req) {
    return this.communityService.getChallenges();
  }

  @Post('challenges/:challengeId/join')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Join a challenge' })
  async joinChallenge(
    @Request() req,
    @Param('challengeId') challengeId: string,
  ) {
    return this.communityService.joinChallenge(req.user.id, challengeId);
  }

  @Get('messages')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get conversations' })
  async getConversations(@Request() req) {
    return this.communityService.getConversations(req.user.id);
  }

  @Get('messages/:conversationId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get messages for a conversation' })
  async getMessages(
    @Request() req,
    @Param('conversationId') conversationId: string,
  ) {
    return this.communityService.getMessages(req.user.id, conversationId);
  }

  @Post('messages')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Send a direct message' })
  async sendMessage(
    @Request() req,
    @Body() body: SendMessageDto,
  ) {
    return this.communityService.sendMessage(req.user.id, body.receiverId, body.content);
  }

  @Post('messages/request')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Send message request' })
  async sendMessageRequest(
    @Request() req,
    @Body() body: SendMessageRequestDto,
  ) {
    return this.communityService.sendMessageRequest(req.user.id, body.receiverId);
  }

  @Post('messages/request/:requestId/accept')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Accept message request' })
  async acceptMessageRequest(
    @Request() req,
    @Param('requestId') requestId: string,
  ) {
    return this.communityService.acceptMessageRequest(req.user.id, requestId);
  }

  @Post('messages/request/:requestId/reject')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Reject message request' })
  async rejectMessageRequest(
    @Request() req,
    @Param('requestId') requestId: string,
  ) {
    return this.communityService.rejectMessageRequest(req.user.id, requestId);
  }

  @Post('messages/block/:userId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Block a user' })
  async blockUser(
    @Request() req,
    @Param('userId') userId: string,
  ) {
    return this.communityService.blockUser(req.user.id, userId);
  }
}
