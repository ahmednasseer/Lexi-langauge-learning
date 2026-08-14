import { Controller, Get, Post, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { LessonsService } from './lessons.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Lessons')
@Controller('lessons')
export class LessonsController {
  constructor(private lessonsService: LessonsService) {}

   @Get('languages')
  @ApiOperation({ summary: 'Get available languages' })
  async getLanguages() {
    return this.lessonsService.getLanguages();
  }

  @Get('questions/:level')
  @ApiOperation({ summary: 'Get quiz questions for a CEFR level' })
  async getQuestionsForLevel(@Param('level') level: string) {
    return this.lessonsService.getQuestionsForLevel(level);
  }

  @Get(':language')
  @ApiOperation({ summary: 'Get lessons for a language' })
  @ApiQuery({ name: 'level', required: false })
  @ApiQuery({ name: 'category', required: false })
  async getLessons(
    @Param('language') language: string,
    @Query('level') level?: string,
    @Query('category') category?: string,
  ) {
    return this.lessonsService.getLessons(language, level, category);
  }

  @Get('detail/:id')
  @ApiOperation({ summary: 'Get lesson detail by id' })
  async getLessonDetail(@Param('id') id: string) {
    return this.lessonsService.getLessonDetail(id);
  }

  @Get(':language/:id')
  @ApiOperation({ summary: 'Get lesson detail (legacy, by language + id)' })
  async getLessonDetailLegacy(@Param('id') id: string) {
    return this.lessonsService.getLessonDetail(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create lesson (admin)' })
  async createLesson(@Body() body: any) {
    return this.lessonsService.createLesson(body);
  }
}
