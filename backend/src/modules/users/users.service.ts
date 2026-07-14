import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true, name: true, email: true, avatar: true,
        nativeLanguage: true, learningLanguage: true, level: true,
        xp: true, totalXp: true, streak: true, bestStreak: true,
        dailyXp: true, dailyGoal: true, learningGoal: true,
        isPremium: true, createdAt: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updateProfile(userId: string, data: {
    name?: string; nativeLanguage?: string; learningLanguage?: string;
    learningGoal?: string; dailyGoal?: number;
  }) {
    return this.prisma.user.update({ where: { id: userId }, data });
  }

  async addXp(userId: string, amount: number) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const newTotalXp = user.totalXp + amount;
    const newLevel = this.calculateLevel(newTotalXp);

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        xp: { increment: amount },
        totalXp: { increment: amount },
        dailyXp: { increment: amount },
        level: newLevel,
      },
    });
  }

  async updateStreak(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const now = new Date();
    const lastActive = user.lastActiveAt;
    let newStreak = user.streak;

    if (lastActive) {
      const diffDays = Math.floor((now.getTime() - lastActive.getTime()) / (1000 * 60 * 60 * 24));
      if (diffDays === 1) newStreak++;
      else if (diffDays > 1) newStreak = 1;
    } else {
      newStreak = 1;
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        streak: newStreak,
        bestStreak: Math.max(newStreak, user.bestStreak),
        lastActiveAt: now,
        dailyXp: lastActive && Math.floor((now.getTime() - lastActive.getTime()) / (1000 * 60 * 60 * 24)) >= 1 ? 0 : undefined,
      },
    });
  }

  private calculateLevel(totalXp: number): string {
    if (totalXp >= 10000) return 'C2';
    if (totalXp >= 5000) return 'C1';
    if (totalXp >= 2000) return 'B2';
    if (totalXp >= 1000) return 'B1';
    if (totalXp >= 500) return 'A2';
    return 'A1';
  }
}
