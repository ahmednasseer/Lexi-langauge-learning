import { Controller, Get, Post, Param, UseGuards, Request, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get user notifications' })
  async getNotifications(@Request() req, @Query('page') page = '1') {
    return this.notificationsService.getNotifications(req.user.sub, parseInt(page, 10));
  }

  @Post(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  async markRead(@Request() req, @Param('id') id: string) {
    return this.notificationsService.markRead(req.user.sub, id);
  }
}
