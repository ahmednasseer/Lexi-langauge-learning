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
    return this.prisma.$transaction(async (tx) => {
      // 1) Validate item with server-authoritative price — never trust client input.
      const item = await tx.storeItem.findUnique({ where: { id: itemId } });
      if (!item) throw new NotFoundException('Item not found');
      if (!item.isActive) throw new BadRequestException('Item not available');

      // 2) Ensure wallet exists (welcome bonus path is idempotent).
      const wallet = await tx.gemsWallet.upsert({
        where: { userId },
        create: { userId },
        update: {},
      });

      // 3) Atomic conditional deduction — fails when balance is insufficient.
      const deducted = await tx.gemsWallet.updateMany({
        where: { id: wallet.id, gems: { gte: item.price } },
        data: {
          gems: { decrement: item.price },
          totalSpent: { increment: item.price },
        },
      });
      if (deducted.count === 0) {
        throw new BadRequestException('Not enough gems');
      }

      await tx.transaction.create({
        data: {
          userId,
          type: 'spending',
          amount: item.price,
          description: `Purchased ${item.name}`,
        },
      });

      // 4) Inventory creation relies on the @@unique([userId, itemId]) constraint;
      //    a concurrent duplicate raises P2002 and rolls the whole transaction back.
      let inventory;
      try {
        inventory = await tx.userInventory.create({
          data: { userId, itemId },
        });
      } catch (e: any) {
        if (e?.code === 'P2002') {
          throw new BadRequestException('Item already owned');
        }
        throw e;
      }

      const updatedWallet = await tx.gemsWallet.findUnique({ where: { id: wallet.id } });
      return { data: inventory, gems: updatedWallet?.gems ?? 0 };
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
