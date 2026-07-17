import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

interface AppNotification {
  id: string;
  title: string;
  body: string;
  type: string;
  createdAt: Date;
  isRead: boolean;
}

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async getNotifications(userId: string, page: number, pageSize = 20) {
    const skip = (page - 1) * pageSize;
    const notifications: AppNotification[] = [];

    const [achievements, missions, user] = await Promise.all([
      this.prisma.userAchievement.findMany({
        where: { userId },
        include: { achievement: true },
        orderBy: { unlockedAt: 'desc' },
        take: 10,
      }),
      this.prisma.dailyMission.findMany({
        where: { userId, isCompleted: true, isClaimed: false },
        orderBy: { date: 'desc' },
        take: 5,
      }),
      this.prisma.user.findUnique({
        where: { id: userId },
        select: { streak: true, name: true },
      }),
    ]);

    for (const ua of achievements) {
      notifications.push({
        id: `ach_${ua.id}`,
        title: 'New Achievement 🏆',
        body: `You unlocked "${ua.achievement.title}"`,
        type: 'achievement',
        createdAt: ua.unlockedAt,
        isRead: false,
      });
    }

    for (const m of missions) {
      notifications.push({
        id: `mission_${m.id}`,
        title: 'Mission Ready 🎯',
        body: `${m.title} is ready to claim!`,
        type: 'mission',
        createdAt: m.date,
        isRead: false,
      });
    }

    if (user && user.streak > 0 && user.streak % 7 === 0) {
      notifications.push({
        id: `streak_${userId}`,
        title: 'Weekly Streak! 🔥',
        body: `You are on a ${user.streak}-day streak. Keep it up!`,
        type: 'streak',
        createdAt: new Date(),
        isRead: false,
      });
    }

    notifications.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
    const paged = notifications.slice(skip, skip + pageSize);
    return { data: paged };
  }

  async markRead(userId: string, id: string) {
    return { data: { id, read: true, userId } };
  }
}
