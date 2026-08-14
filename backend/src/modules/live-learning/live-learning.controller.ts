import { Controller, Get, Post, Body, Param, HttpCode, HttpStatus, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LiveLearningService, RoomLevel } from './live-learning.service';

@Controller('live')
@UseGuards(JwtAuthGuard)
export class LiveLearningController {
  constructor(private readonly liveService: LiveLearningService) {}

  /** Resolve acting user from token, rejecting client-supplied userId mismatches. */
  private self(sub: string, provided?: string): string {
    if (provided && provided !== sub) {
      throw new ForbiddenException('Cannot operate on another user');
    }
    return sub;
  }

  // Rooms
  @Get('rooms')
  getRooms() {
    const rooms = this.liveService.getRooms();
    return { success: true, data: rooms };
  }

  @Get('rooms/:id')
  getRoom(@Param('id') id: string) {
    const room = this.liveService.getRoom(id);
    return { success: true, data: room };
  }

  @Post('rooms/create')
  @HttpCode(HttpStatus.CREATED)
  createRoom(@Req() req, @Body() body: {
    hostId?: string;
    hostName: string;
    title: string;
    topic: string;
    description: string;
    level: RoomLevel;
    maxParticipants?: number;
    durationMinutes?: number;
    tags?: string[];
  }) {
    const room = this.liveService.createRoom({
      hostId: this.self(req.user.sub, body.hostId),
      hostName: body.hostName,
      title: body.title,
      topic: body.topic,
      description: body.description,
      level: body.level,
      maxParticipants: body.maxParticipants,
      durationMinutes: body.durationMinutes,
      tags: body.tags,
    });
    return { success: true, data: room };
  }

  @Post('rooms/:id/join')
  @HttpCode(HttpStatus.OK)
  joinRoom(@Req() req, @Param('id') id: string, @Body() body: { userId?: string; userName: string }) {
    const room = this.liveService.joinRoom(id, this.self(req.user.sub, body.userId), body.userName);
    return { success: true, data: room };
  }

  @Post('rooms/:id/leave')
  @HttpCode(HttpStatus.OK)
  leaveRoom(@Req() req, @Param('id') id: string, @Body() body: { userId?: string }) {
    const room = this.liveService.leaveRoom(id, this.self(req.user.sub, body.userId));
    return { success: true, data: room };
  }

  // Partners
  @Get('partners')
  getPartners() {
    const partners = this.liveService.getPartners();
    return { success: true, data: partners };
  }

  @Post('partners/match')
  @HttpCode(HttpStatus.OK)
  findMatch(@Req() req, @Body() body: {
    userId?: string;
    nativeLanguage: string;
    learningLanguage: string;
    level: string;
    goal: string;
  }) {
    const match = this.liveService.findMatch({
      userId: this.self(req.user.sub, body.userId),
      nativeLanguage: body.nativeLanguage,
      learningLanguage: body.learningLanguage,
      level: body.level,
      goal: body.goal,
    });
    return {
      success: true,
      data: match,
      message: match ? 'Match found!' : 'No match available. Try again later.',
    };
  }

  // Groups
  @Get('groups')
  getGroups() {
    const groups = this.liveService.getGroups();
    return { success: true, data: groups };
  }

  @Post('groups/:id/join')
  @HttpCode(HttpStatus.OK)
  joinGroup(@Req() req, @Param('id') id: string, @Body() body: { userId?: string; userName: string }) {
    const group = this.liveService.joinGroup(id, this.self(req.user.sub, body.userId), body.userName);
    return { success: true, data: group };
  }

  // Events
  @Get('events')
  getEvents() {
    const events = this.liveService.getEvents();
    return { success: true, data: events };
  }

  @Post('events/:id/join')
  @HttpCode(HttpStatus.OK)
  joinEvent(@Req() req, @Param('id') id: string, @Body() body: { userId?: string; userName: string }) {
    const event = this.liveService.joinEvent(id, this.self(req.user.sub, body.userId), body.userName);
    return { success: true, data: event };
  }

  // Analytics
  @Get('analytics')
  getAnalytics() {
    const analytics = this.liveService.getAnalytics();
    return { success: true, data: analytics };
  }
}
