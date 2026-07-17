import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class StoreService {
  constructor(private prisma: PrismaService) {}

  async getItems(category?: string) {
    const where = category ? { category, isActive: true } : { isActive: true };
    const items = await this.prisma.storeItem.findMany({
      where,
      orderBy: { createdAt: 'asc' },
    });
    return { data: items };
  }

  async getInventory(userId: string) {
    const inventory = await this.prisma.userInventory.findMany({
      where: { userId },
      include: { item: true },
    });
    return { data: inventory };
  }

  async purchase(userId: string, itemId: string) {
    const item = await this.prisma.storeItem.findUnique({ where: { id: itemId } });
    if (!item) throw new NotFoundException('Item not found');
    if (!item.isActive) throw new BadRequestException('Item not available');

    const wallet = await this.prisma.gemsWallet.findUnique({ where: { userId } });
    if (!wallet) throw new NotFoundException('Wallet not found');
    if (wallet.gems < item.price) throw new BadRequestException('Not enough gems');

    const alreadyOwned = await this.prisma.userInventory.findUnique({
      where: { userId_itemId: { userId, itemId } },
    });
    if (alreadyOwned) throw new BadRequestException('Item already owned');

    return this.prisma.$transaction(async (tx) => {
      await tx.gemsWallet.update({
        where: { userId },
        data: { gems: { decrement: item.price }, totalSpent: { increment: item.price } },
      });
      await tx.transaction.create({
        data: {
          userId,
          type: 'spending',
          amount: item.price,
          description: `Purchased ${item.name}`,
        },
      });
      const inventory = await tx.userInventory.create({
        data: { userId, itemId },
      });
      return { data: inventory, gems: wallet.gems - item.price };
    });
  }

  async equip(userId: string, itemId: string) {
    const owned = await this.prisma.userInventory.findUnique({
      where: { userId_itemId: { userId, itemId } },
    });
    if (!owned) throw new BadRequestException('Item not owned');

    const item = await this.prisma.storeItem.findUnique({ where: { id: itemId } });
    if (!item) throw new NotFoundException('Item not found');

    const avatar = await this.prisma.userAvatar.upsert({
      where: { userId },
      create: { userId, avatarId: 'avatar_1' },
      update: {},
    });

    const updateData: any = {};
    if (item.category === 'avatar') updateData.avatarId = item.id;
    if (item.category === 'frame') updateData.frameId = item.id;
    if (item.category === 'background') updateData.backgroundId = item.id;

    await this.prisma.userAvatar.update({ where: { id: avatar.id }, data: updateData });
    return { data: { equipped: itemId } };
  }
}
