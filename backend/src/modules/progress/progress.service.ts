import { Injectable, NotFoundException } from '@nestjs/common';
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
    if (!lesson) throw new NotFoundException('Lesson not found');

    // Clamp client-supplied performance values so they cannot inflate XP.
    const safeScore = Math.max(0, Math.min(100, Math.round(Number(score) || 0)));
    const safeTimeSpent = Math.max(0, Math.round(Number(timeSpent) || 0));
    // XP is derived from server-known lesson metadata, never from client-sent XP.
    const xpEarned = Math.round(lesson.xpReward * (safeScore / 100));

    return this.prisma.$transaction(async (tx) => {
      // Only award XP the FIRST time a user completes a lesson.
      // The @@unique([userId, lessonId]) constraint makes creation concurrency-safe.
      const existing = await tx.userProgress.findUnique({
        where: { userId_lessonId: { userId, lessonId } },
      });

      const passes = safeScore >= 70;
      let isFirstCompletion = passes && !existing?.completed;

      let progress;
      if (existing) {
        progress = await tx.userProgress.update({
          where: { userId_lessonId: { userId, lessonId } },
          data: {
            score: safeScore,
            completed: existing.completed || passes,
            timeSpent: safeTimeSpent,
            ...(isFirstCompletion ? { xpEarned } : {}),
          },
        });
      } else {
        try {
          progress = await tx.userProgress.create({
            data: { userId, lessonId, score: safeScore, completed: passes, timeSpent: safeTimeSpent, xpEarned },
          });
        } catch (e: any) {
          // Lost a concurrent create race (P2002 unique violation): a parallel request
          // already created+completed this lesson. Do NOT award XP again.
          if (e?.code === 'P2002') {
            isFirstCompletion = false;
            progress = await tx.userProgress.findUnique({
              where: { userId_lessonId: { userId, lessonId } },
            });
          } else {
            throw e;
          }
        }
      }

       if (isFirstCompletion) {
        // Server-authoritative XP from lesson metadata; atomic and race-safe.
        const user = await tx.user.findUnique({ where: { id: userId }, select: { totalXp: true, bestStreak: true, streak: true, lastActiveAt: true } });
        const lastDay = user?.lastActiveAt ? new Date(user.lastActiveAt) : null;
        if (lastDay) lastDay.setHours(0, 0, 0, 0);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const saneStreak = Math.max(0, Number(user?.streak) || 0);
        const newStreak =
          lastDay && lastDay.getTime() === today.getTime()
            ? saneStreak
            : saneStreak + 1;

        await tx.user.update({
          where: { id: userId },
          data: {
            xp: { increment: xpEarned },
            totalXp: { increment: xpEarned },
            dailyXp: { increment: xpEarned },
            streak: newStreak,
            bestStreak: Math.max(Number(user?.bestStreak) || 0, newStreak),
            lastActiveAt: new Date(),
            level: this.levelFromXp((Number(user?.totalXp) || 0) + xpEarned),
          },
        });
      }

      return { ...progress, xpEarned: isFirstCompletion ? xpEarned : 0 };
    });
  }

  private levelFromXp(totalXp: number): string {
    if (totalXp >= 10000) return 'C2';
    if (totalXp >= 5000) return 'C1';
    if (totalXp >= 2000) return 'B2';
    if (totalXp >= 1000) return 'B1';
    if (totalXp >= 500) return 'A2';
    return 'A1';
  }

  async getUserProgress(userId: string) {
    return this.prisma.userProgress.findMany({
      where: { userId },
      include: { lesson: { select: { id: true, title: true, level: true, category: true } } },
      orderBy: { completedAt: 'desc' },
    });
  }

   async getStats(userId: string) {
    const [totalLessons, completedLessons, totalXpResult, achievements, user] = await Promise.all([
      this.prisma.lesson.count({ where: { isPublished: true } }),
      this.prisma.userProgress.count({ where: { userId, completed: true } }),
      this.prisma.userProgress.aggregate({ where: { userId }, _sum: { xpEarned: true } }),
      this.prisma.userAchievement.count({ where: { userId } }),
      this.prisma.user.findUnique({ where: { id: userId }, select: { streak: true, level: true } }),
    ]);

    const totalXp = totalXpResult._sum.xpEarned || 0;
    return {
      totalLessons,
      completedLessons,
      totalXp,
      achievements,
      completionRate: totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0,
      streak: user?.streak || 0,
      level: user?.level || 'A1',
    };
   }
}
