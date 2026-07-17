import { Controller, Get, Post, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { LiveLearningService, RoomLevel } from './live-learning.service';

@Controller('live')
export class LiveLearningController {
  constructor(private readonly liveService: LiveLearningService) {}

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
  createRoom(@Body() body: {
    hostId: string;
    hostName: string;
    title: string;
    topic: string;
    description: string;
    level: RoomLevel;
    maxParticipants?: number;
    durationMinutes?: number;
    tags?: string[];
  }) {
    const room = this.liveService.createRoom(body);
    return { success: true, data: room };
  }

  @Post('rooms/:id/join')
  @HttpCode(HttpStatus.OK)
  joinRoom(@Param('id') id: string, @Body() body: { userId: string; userName: string }) {
    const room = this.liveService.joinRoom(id, body.userId, body.userName);
    return { success: true, data: room };
  }

  @Post('rooms/:id/leave')
  @HttpCode(HttpStatus.OK)
  leaveRoom(@Param('id') id: string, @Body() body: { userId: string }) {
    const room = this.liveService.leaveRoom(id, body.userId);
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
  findMatch(@Body() body: {
    userId: string;
    nativeLanguage: string;
    learningLanguage: string;
    level: string;
    goal: string;
  }) {
    const match = this.liveService.findMatch(body);
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
  joinGroup(@Param('id') id: string, @Body() body: { userId: string; userName: string }) {
    const group = this.liveService.joinGroup(id, body.userId, body.userName);
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
  joinEvent(@Param('id') id: string, @Body() body: { userId: string; userName: string }) {
    const event = this.liveService.joinEvent(id, body.userId, body.userName);
    return { success: true, data: event };
  }

  // Analytics
  @Get('analytics')
  getAnalytics() {
    const analytics = this.liveService.getAnalytics();
    return { success: true, data: analytics };
  }
}
