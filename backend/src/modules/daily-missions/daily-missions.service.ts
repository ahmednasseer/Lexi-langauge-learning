import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

interface DailyMission {
  id: string;
  title: string;
  description: string;
  type: string;
  target: number;
  rewardXp: number;
  rewardGems: number;
  icon: string;
}

@Injectable()
export class DailyMissionsService {
  constructor(private prisma: PrismaService) {}

  async getTodayMissions(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let missions = await this.prisma.dailyMission.findMany({
      where: {
        userId,
        date: today,
      },
    });

    if (missions.length === 0) {
      missions = await this.createTodayMissions(userId, today);
    }

    return missions;
  }

  async createTodayMissions(userId: string, date: Date) {
    const defaultMissions: DailyMission[] = [
      { id: 'm1', title: 'Learn Vocabulary', description: 'Learn 15 new vocabulary words', type: 'vocabulary', target: 15, rewardXp: 50, rewardGems: 5, icon: '📚' },
      { id: 'm2', title: 'Grammar Lesson', description: 'Complete 1 grammar lesson', type: 'grammar', target: 1, rewardXp: 75, rewardGems: 10, icon: '📝' },
      { id: 'm3', title: 'Speaking Practice', description: 'Practice speaking for 5 minutes', type: 'speaking', target: 5, rewardXp: 100, rewardGems: 15, icon: '🎤' },
      { id: 'm4', title: 'AI Coach Chat', description: 'Complete an AI Coach conversation', type: 'aiChat', target: 1, rewardXp: 50, rewardGems: 5, icon: '🤖' },
      { id: 'm5', title: 'Listening Exercise', description: 'Finish 1 listening exercise', type: 'listening', target: 1, rewardXp: 50, rewardGems: 5, icon: '🎧' },
    ];

    const createdMissions = await Promise.all(
      defaultMissions.map(async (mission) => {
        return this.prisma.dailyMission.create({
          data: {
            userId,
            missionId: mission.id,
            title: mission.title,
            description: mission.description,
            type: mission.type,
            target: mission.target,
            progress: 0,
            rewardXp: mission.rewardXp,
            rewardGems: mission.rewardGems,
            icon: mission.icon,
            date,
          },
        });
      }),
    );

    return createdMissions;
  }

  async updateProgress(userId: string, type: string, amount: number) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const missions = await this.prisma.dailyMission.findMany({
      where: {
        userId,
        type,
        date: today,
        isCompleted: false,
      },
    });

    for (const mission of missions) {
      const newProgress = mission.progress + amount;
      const isCompleted = newProgress >= mission.target;

      await this.prisma.dailyMission.update({
        where: { id: mission.id },
        data: {
          progress: newProgress,
          isCompleted,
        },
      });
    }

    return this.getTodayMissions(userId);
  }

  async claimReward(userId: string, missionId: string) {
    const mission = await this.prisma.dailyMission.findFirst({
      where: {
        id: missionId,
        userId,
        isCompleted: true,
        isClaimed: false,
      },
    });

    if (!mission) {
      throw new Error('Mission not found or already claimed');
    }

    await this.prisma.dailyMission.update({
      where: { id: missionId },
      data: { isClaimed: true },
    });

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        totalXp: { increment: mission.rewardXp },
      },
    });

    return {
      xp: mission.rewardXp,
      gems: mission.rewardGems,
    };
  }

  async claimDailyBonus(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const missions = await this.prisma.dailyMission.findMany({
      where: {
        userId,
        date: today,
      },
    });

    const allCompleted = missions.every((m) => m.isCompleted);
    if (!allCompleted) {
      throw new Error('Not all missions completed');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        totalXp: { increment: 100 },
      },
    });

    return { xp: 100, gems: 20 };
  }

  async getStats(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayMissions = await this.prisma.dailyMission.findMany({
      where: { userId, date: today },
    });

    const completedDays = await this.prisma.dailyMission.groupBy({
      by: ['date'],
      where: {
        userId,
        isCompleted: true,
      },
    });

    return {
      todayCompleted: todayMissions.filter((m) => m.isCompleted).length,
      todayTotal: todayMissions.length,
      totalDays: completedDays.length,
    };
  }
}
