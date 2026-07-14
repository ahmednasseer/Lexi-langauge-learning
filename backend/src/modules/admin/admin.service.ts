import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  // ==================== DASHBOARD ====================
  async getDashboard() {
    const [
      totalUsers,
      premiumUsers,
      totalLessons,
      totalLanguages,
      aiUsageToday,
      recentUsers,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { isPremium: true } }),
      this.prisma.lesson.count(),
      this.prisma.language.count(),
      this.prisma.aiUsage.aggregate({
        where: { date: new Date(new Date().setHours(0, 0, 0, 0)) },
        _sum: { messagesCount: true, tokensUsed: true },
      }),
      this.prisma.user.findMany({
        orderBy: { createdAt: 'desc' },
        take: 10,
        select: { id: true, name: true, email: true, createdAt: true, isPremium: true },
      }),
    ]);

    return {
      stats: {
        totalUsers,
        premiumUsers,
        freeUsers: totalUsers - premiumUsers,
        premiumRate: totalUsers > 0 ? Math.round((premiumUsers / totalUsers) * 100) : 0,
        totalLessons,
        totalLanguages,
        aiMessagesToday: aiUsageToday._sum.messagesCount || 0,
        aiTokensToday: aiUsageToday._sum.tokensUsed || 0,
      },
      recentUsers,
    };
  }

  // ==================== USERS ====================
  async getUsers(page = 1, limit = 20, search?: string) {
    const where = search ? {
      OR: [
        { name: { contains: search, mode: 'insensitive' as const } },
        { email: { contains: search, mode: 'insensitive' as const } },
      ],
    } : {};

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true, name: true, email: true, isPremium: true,
          createdAt: true, lastLoginAt: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return { users, total, page, totalPages: Math.ceil(total / limit) };
  }

  async getUserById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        progress: { include: { lesson: true } },
        achievements: { include: { achievement: true } },
        subscriptions: true,
        aiUsage: { orderBy: { date: 'desc' }, take: 30 },
      },
    });
    return user;
  }

  async updateUserRole(id: string, isPremium: boolean) {
    return this.prisma.user.update({
      where: { id },
      data: { isPremium },
    });
  }

  async banUser(id: string) {
    return this.prisma.user.update({
      where: { id },
      data: { isActive: false } as any,
    });
  }

  // ==================== LANGUAGES ====================
  async getLanguages() {
    return this.prisma.language.findMany({
      include: { _count: { select: { lessons: true } } },
    });
  }

  async createLanguage(data: { name: string; code: string; nativeName: string; flag: string }) {
    return this.prisma.language.create({ data });
  }

  async updateLanguage(id: string, data: { name?: string; nativeName?: string; flag?: string }) {
    return this.prisma.language.update({ where: { id }, data });
  }

  async deleteLanguage(id: string) {
    return this.prisma.language.delete({ where: { id } });
  }

  // ==================== LESSONS ====================
  async getLessons(languageId?: string, level?: string) {
    const where: any = {};
    if (languageId) where.languageId = languageId;
    if (level) where.level = level;

    return this.prisma.lesson.findMany({
      where,
      include: {
        language: true,
        vocabulary: true,
        grammarRules: true,
        quizQuestions: true,
        _count: { select: { progress: true } },
      },
      orderBy: { order: 'asc' },
    });
  }

  async createLesson(data: any) {
    return this.prisma.lesson.create({
      data,
      include: { language: true },
    });
  }

  async updateLesson(id: string, data: any) {
    return this.prisma.lesson.update({
      where: { id },
      data,
      include: { language: true },
    });
  }

  async deleteLesson(id: string) {
    return this.prisma.lesson.delete({ where: { id } });
  }

  async bulkCreateLessons(lessons: any[]) {
    return this.prisma.lesson.createMany({ data: lessons });
  }

  // ==================== VOCABULARY ====================
  async getVocabulary(lessonId: string) {
    return this.prisma.vocabulary.findMany({
      where: { lessonId },
      orderBy: { createdAt: 'asc' },
    });
  }

  async createVocabulary(data: any) {
    return this.prisma.vocabulary.create({ data });
  }

  async bulkCreateVocabulary(items: any[]) {
    return this.prisma.vocabulary.createMany({ data: items });
  }

  // ==================== ACHIEVEMENTS ====================
  async getAchievements() {
    return this.prisma.achievement.findMany({
      include: { _count: { select: { userAchievements: true } } },
    });
  }

  async createAchievement(data: any) {
    return this.prisma.achievement.create({ data });
  }

  async updateAchievement(id: string, data: any) {
    return this.prisma.achievement.update({ where: { id }, data });
  }

  async deleteAchievement(id: string) {
    return this.prisma.achievement.delete({ where: { id } });
  }

  // ==================== ANALYTICS ====================
  async getAnalytics(days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const [dailySignups, dailyAiUsage, topLanguages] = await Promise.all([
      this.prisma.user.groupBy({
        by: ['createdAt'],
        where: { createdAt: { gte: startDate } },
        _count: true,
      }),
      this.prisma.aiUsage.findMany({
        where: { date: { gte: startDate } },
        orderBy: { date: 'asc' },
      }),
      this.prisma.lesson.groupBy({
        by: ['languageId'],
        _count: true,
        orderBy: { _count: { languageId: 'desc' } },
      }),
    ]);

    return { dailySignups, dailyAiUsage, topLanguages };
  }
}
