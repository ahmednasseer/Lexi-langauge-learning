import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class LessonsService {
  constructor(private prisma: PrismaService) {}

  async getLanguages() {
    return this.prisma.language.findMany({ where: { isActive: true } });
  }

  async getLessons(languageCode: string, level?: string, category?: string) {
    const language = await this.prisma.language.findUnique({ where: { code: languageCode } });
    if (!language) throw new NotFoundException('Language not found');

    const where: any = { languageId: language.id, isPublished: true };
    if (level) where.level = level;
    if (category) where.category = category;

    return this.prisma.lesson.findMany({
      where,
      include: { _count: { select: { vocabulary: true, quiz: true } } },
      orderBy: { orderIndex: 'asc' },
    });
  }

  async getLessonDetail(lessonId: string) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: lessonId },
      include: { vocabulary: true, grammar: true, quiz: true },
    });
    if (!lesson) throw new NotFoundException('Lesson not found');
    return lesson;
  }

  async createLesson(data: {
    languageId: string; level: string; category: string;
    title: string; description: string; content: any;
    xpReward?: number; vocabulary?: any[]; grammar?: any[]; quiz?: any[];
  }) {
    return this.prisma.lesson.create({
      data: {
        languageId: data.languageId,
        level: data.level,
        category: data.category,
        title: data.title,
        description: data.description,
        content: data.content || {},
        xpReward: data.xpReward || 50,
        vocabulary: data.vocabulary ? { create: data.vocabulary } : undefined,
        grammar: data.grammar ? { create: data.grammar } : undefined,
        quiz: data.quiz ? { create: data.quiz } : undefined,
      },
      include: { vocabulary: true, grammar: true, quiz: true },
    });
  }
}
