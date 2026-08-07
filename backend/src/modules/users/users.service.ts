import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { WalletService } from '../payments/wallet/wallet.service';

@Injectable()
export class UsersService {
  constructor(
    private prisma: PrismaService,
    private walletService: WalletService,
  ) {}

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

  async getAchievements(userId: string) {
    const achievements = await this.prisma.achievement.findMany({
      include: { users: { where: { userId } } },
    });
    return achievements.map((a: any) => ({
      id: a.id,
      title: a.title,
      description: a.description,
      icon: a.icon,
      type: a.type,
      xpReward: a.xpReward,
      isUnlocked: a.users.length > 0,
      unlockedAt: a.users[0]?.unlockedAt ?? null,
    }));
  }

  async getWallet(userId: string) {
    const wallet = await this.walletService.getWallet(userId);
    const transactions = await this.walletService.getTransactions(userId);
    return {
      gems: wallet.gems,
      totalPurchased: wallet.totalPurchased,
      totalSpent: wallet.totalSpent,
      transactions: transactions.map(t => ({
        id: t.id,
        type: t.type,
        amount: t.amount,
        description: t.description,
        createdAt: t.createdAt,
      })),
    };
  }

  async spendGems(userId: string, amount: number, description: string) {
    if (!amount || amount <= 0) {
      throw new BadRequestException('Amount must be greater than zero');
    }
    return this.walletService.spendGems(userId, amount, description || 'Gem purchase');
  }

  async getGrowth(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        xp: true, totalXp: true, streak: true, bestStreak: true,
        dailyXp: true, createdAt: true, isPremium: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');
    const daysActive = Math.max(1, Math.floor((Date.now() - user.createdAt.getTime()) / (1000 * 60 * 60 * 24)));
    return {
      totalXp: user.totalXp,
      currentStreak: user.streak,
      bestStreak: user.bestStreak,
      dailyXp: user.dailyXp,
      daysActive,
      isPremium: user.isPremium,
      level: this.calculateLevel(user.totalXp),
    };
  }
}
