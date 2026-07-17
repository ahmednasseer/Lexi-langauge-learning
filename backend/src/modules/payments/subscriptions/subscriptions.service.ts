import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

@Injectable()
export class SubscriptionsService {
  constructor(private prisma: PrismaService) {}

  async getSubscription(userId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: {
        userId,
        status: 'active',
      },
      orderBy: { createdAt: 'desc' },
    });

    return subscription || null;
  }

  async createSubscription(userId: string, planId: string, paymentId: string) {
    const now = new Date();
    const endDate = new Date(now);

    if (planId === 'premium_yearly') {
      endDate.setFullYear(endDate.getFullYear() + 1);
    } else {
      endDate.setMonth(endDate.getMonth() + 1);
    }

    // Cancel any existing active subscription
    await this.prisma.subscription.updateMany({
      where: {
        userId,
        status: 'active',
      },
      data: {
        status: 'cancelled',
      },
    });

    const subscription = await this.prisma.subscription.create({
      data: {
        userId,
        planId,
        status: 'active',
        provider: 'stripe',
        externalId: paymentId,
        startDate: now,
        endDate,
      },
    });

    // Update user premium status
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        isPremium: true,
        subscriptionId: subscription.id,
        subscriptionEnd: endDate,
      },
    });

    return subscription;
  }

  async cancelSubscription(userId: string) {
    const subscription = await this.getSubscription(userId);
    if (!subscription) {
      throw new Error('No active subscription found');
    }

    await this.prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        status: 'cancelled',
        cancelledAt: new Date(),
      },
    });

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        isPremium: false,
      },
    });

    return { success: true };
  }

  async checkPremiumAccess(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user?.isPremium) return false;

    if (user.subscriptionEnd && user.subscriptionEnd > new Date()) {
      return true;
    }

    return false;
  }
}
