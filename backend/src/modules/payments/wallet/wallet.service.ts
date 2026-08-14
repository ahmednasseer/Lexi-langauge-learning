import { Injectable, BadRequestException } from '@nestjs/common';
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

  /**
   * INTERNAL ONLY — must never be reachable directly by a client request.
   * Only trusted server-side business logic (missions, rewards, admin) may credit a wallet.
   */
  async addGems(userId: string, amount: number, description: string) {
    this.assertPositive(amount);

    await this.getWallet(userId);

    return this.prisma.$transaction(async (tx) => {
      await tx.gemsWallet.update({
        where: { userId },
        data: {
          gems: { increment: amount },
          totalPurchased: { increment: amount },
        },
      });

      await tx.transaction.create({
        data: {
          userId,
          type: 'purchase',
          amount,
          description,
        },
      });

      return tx.gemsWallet.findUnique({ where: { userId } });
    });
  }

  async spendGems(userId: string, amount: number, description: string) {
    this.assertPositive(amount);

    await this.getWallet(userId);

    return this.prisma.$transaction(async (tx) => {
      // Atomic conditional decrement: only succeeds when the wallet has enough gems.
      const result = await tx.gemsWallet.updateMany({
        where: { userId, gems: { gte: amount } },
        data: {
          gems: { decrement: amount },
          totalSpent: { increment: amount },
        },
      });

      if (result.count === 0) {
        throw new BadRequestException('Insufficient gems');
      }

      await tx.transaction.create({
        data: {
          userId,
          type: 'spending',
          amount: -amount,
          description,
        },
      });

      return tx.gemsWallet.findUnique({ where: { userId } });
    });
  }

  async getTransactions(userId: string) {
    return this.prisma.transaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  private assertPositive(amount: number) {
    if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0) {
      throw new BadRequestException('Amount must be a positive number');
    }
  }
}
