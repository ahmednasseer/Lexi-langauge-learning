import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../config/prisma.service';

@Injectable()
export class WalletService {
  constructor(private prisma: PrismaService) {}

  async getWallet(userId: string) {
    let wallet = await this.prisma.gemsWallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      wallet = await this.prisma.gemsWallet.create({
        data: {
          userId,
          gems: 100, // Welcome bonus
        },
      });
    }

    return wallet;
  }

  async addGems(userId: string, amount: number, description: string) {
    const wallet = await this.getWallet(userId);

    await this.prisma.gemsWallet.update({
      where: { userId },
      data: {
        gems: wallet.gems + amount,
        totalPurchased: wallet.totalPurchased + amount,
      },
    });

    await this.prisma.transaction.create({
      data: {
        userId,
        type: 'purchase',
        amount,
        description,
      },
    });

    return this.getWallet(userId);
  }

  async spendGems(userId: string, amount: number, description: string) {
    const wallet = await this.getWallet(userId);

    if (wallet.gems < amount) {
      throw new Error('Insufficient gems');
    }

    await this.prisma.gemsWallet.update({
      where: { userId },
      data: {
        gems: wallet.gems - amount,
        totalSpent: wallet.totalSpent + amount,
      },
    });

    await this.prisma.transaction.create({
      data: {
        userId,
        type: 'spending',
        amount: -amount,
        description,
      },
    });

    return this.getWallet(userId);
  }

  async getTransactions(userId: string) {
    return this.prisma.transaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }
}
