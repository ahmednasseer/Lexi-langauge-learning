import {
  Controller, Get, Post, Put, Delete, Body, Param, Query,
  UseGuards, Request, HttpCode, HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/guards/roles.decorator';
import { UserRole } from '../../common/guards/roles.guard';
import { AdminService } from './admin.service';

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get admin dashboard stats' })
  async getDashboard() {
    return this.adminService.getDashboard();
  }

  @Get('users')
  @ApiOperation({ summary: 'Get all users' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  async getUsers(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('search') search?: string,
  ) {
    return this.adminService.getUsers(page || 1, limit || 20, search);
  }

  @Get('users/:id')
  @ApiOperation({ summary: 'Get user details' })
  async getUserById(@Param('id') id: string) {
    return this.adminService.getUserById(id);
  }

  @Put('users/:id/role')
  @ApiOperation({ summary: 'Update user role' })
  async updateUserRole(@Param('id') id: string, @Body('isPremium') isPremium: boolean) {
    return this.adminService.updateUserRole(id, isPremium);
  }

  @Post('users/:id/ban')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Ban user' })
  async banUser(@Param('id') id: string) {
    return this.adminService.banUser(id);
  }

  // ==================== LANGUAGES ====================
  @Get('languages')
  @ApiOperation({ summary: 'Get all languages' })
  async getLanguages() {
    return this.adminService.getLanguages();
  }

  @Post('languages')
  @ApiOperation({ summary: 'Create language' })
  async createLanguage(@Body() body: { name: string; code: string; nativeName: string; flag: string }) {
    return this.adminService.createLanguage(body);
  }

  @Put('languages/:id')
  @ApiOperation({ summary: 'Update language' })
  async updateLanguage(@Param('id') id: string, @Body() body: any) {
    return this.adminService.updateLanguage(id, body);
  }

  @Delete('languages/:id')
  @ApiOperation({ summary: 'Delete language' })
  async deleteLanguage(@Param('id') id: string) {
    return this.adminService.deleteLanguage(id);
  }

  // ==================== LESSONS ====================
  @Get('lessons')
  @ApiOperation({ summary: 'Get all lessons' })
  @ApiQuery({ name: 'languageId', required: false, type: String })
  @ApiQuery({ name: 'level', required: false, type: String })
  async getLessons(
    @Query('languageId') languageId?: string,
    @Query('level') level?: string,
  ) {
    return this.adminService.getLessons(languageId, level);
  }

  @Post('lessons')
  @ApiOperation({ summary: 'Create lesson' })
  async createLesson(@Body() body: any) {
    return this.adminService.createLesson(body);
  }

  @Put('lessons/:id')
  @ApiOperation({ summary: 'Update lesson' })
  async updateLesson(@Param('id') id: string, @Body() body: any) {
    return this.adminService.updateLesson(id, body);
  }

  @Delete('lessons/:id')
  @ApiOperation({ summary: 'Delete lesson' })
  async deleteLesson(@Param('id') id: string) {
    return this.adminService.deleteLesson(id);
  }

  @Post('lessons/bulk')
  @ApiOperation({ summary: 'Bulk create lessons' })
  async bulkCreateLessons(@Body() body: { lessons: any[] }) {
    return this.adminService.bulkCreateLessons(body.lessons);
  }

  // ==================== VOCABULARY ====================
  @Get('lessons/:lessonId/vocabulary')
  @ApiOperation({ summary: 'Get vocabulary for lesson' })
  async getVocabulary(@Param('lessonId') lessonId: string) {
    return this.adminService.getVocabulary(lessonId);
  }

  @Post('vocabulary')
  @ApiOperation({ summary: 'Create vocabulary item' })
  async createVocabulary(@Body() body: any) {
    return this.adminService.createVocabulary(body);
  }

  @Post('vocabulary/bulk')
  @ApiOperation({ summary: 'Bulk create vocabulary' })
  async bulkCreateVocabulary(@Body() body: { items: any[] }) {
    return this.adminService.bulkCreateVocabulary(body.items);
  }

  // ==================== ACHIEVEMENTS ====================
  @Get('achievements')
  @ApiOperation({ summary: 'Get all achievements' })
  async getAchievements() {
    return this.adminService.getAchievements();
  }

  @Post('achievements')
  @ApiOperation({ summary: 'Create achievement' })
  async createAchievement(@Body() body: any) {
    return this.adminService.createAchievement(body);
  }

  @Put('achievements/:id')
  @ApiOperation({ summary: 'Update achievement' })
  async updateAchievement(@Param('id') id: string, @Body() body: any) {
    return this.adminService.updateAchievement(id, body);
  }

  @Delete('achievements/:id')
  @ApiOperation({ summary: 'Delete achievement' })
  async deleteAchievement(@Param('id') id: string) {
    return this.adminService.deleteAchievement(id);
  }

  // ==================== ANALYTICS ====================
  @Get('analytics')
  @ApiOperation({ summary: 'Get analytics data' })
  @ApiQuery({ name: 'days', required: false, type: Number })
  async getAnalytics(@Query('days') days?: number) {
    return this.adminService.getAnalytics(days || 30);
  }
}
