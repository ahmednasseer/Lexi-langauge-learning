import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class ProgressService {
  constructor(
    private prisma: PrismaService,
    private usersService: UsersService,
  ) {}

  async completeLesson(userId: string, lessonId: string, score: number, timeSpent: number) {
    const lesson = await this.prisma.lesson.findUnique({ where: { id: lessonId } });
    const xpEarned = Math.round(lesson.xpReward * (score / 100));

    const progress = await this.prisma.userProgress.upsert({
      where: { userId_lessonId: { userId, lessonId } },
      update: { score, completed: score >= 70, timeSpent, xpEarned },
      create: { userId, lessonId, score, completed: score >= 70, timeSpent, xpEarned },
    });

    if (score >= 70) {
      await this.usersService.addXp(userId, xpEarned);
      await this.usersService.updateStreak(userId);
    }

    return progress;
  }

  async getUserProgress(userId: string) {
    return this.prisma.userProgress.findMany({
      where: { userId },
      include: { lesson: { select: { id: true, title: true, level: true, category: true } } },
      orderBy: { completedAt: 'desc' },
    });
  }

  async getStats(userId: string) {
    const [totalLessons, completedLessons, totalXp, achievements] = await Promise.all([
      this.prisma.lesson.count({ where: { isPublished: true } }),
      this.prisma.userProgress.count({ where: { userId, completed: true } }),
      this.prisma.userProgress.aggregate({ where: { userId }, _sum: { xpEarned: true } }),
      this.prisma.userAchievement.count({ where: { userId } }),
    ]);

    return {
      totalLessons,
      completedLessons,
      totalXp: totalXp._sum.xpEarned || 0,
      achievements,
      completionRate: totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0,
    };
  }
}
