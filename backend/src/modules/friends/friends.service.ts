import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class FriendsService {
  constructor(private prisma: PrismaService) {}

  async getFriends(userId: string) {
    const accepted = await this.prisma.messageRequest.findMany({
      where: {
        status: 'ACCEPTED',
        OR: [{ senderId: userId }, { receiverId: userId }],
      },
      include: {
        sender: { select: { id: true, name: true, level: true, totalXp: true, streak: true, avatar: true } },
        receiver: { select: { id: true, name: true, level: true, totalXp: true, streak: true, avatar: true } },
      },
    });

    const friends = accepted.map((r) => {
      const other = r.senderId === userId ? r.receiver : r.sender;
      return {
        id: other.id,
        name: other.name,
        level: other.level,
        xp: other.totalXp,
        streak: other.streak,
        avatar: other.avatar,
        isPremium: false,
        isFriend: true,
        lastActiveAt: new Date(),
      };
    });
    return { data: friends };
  }

  async getRequests(userId: string) {
    const requests = await this.prisma.messageRequest.findMany({
      where: { receiverId: userId, status: 'PENDING' },
      include: {
        sender: { select: { id: true, name: true, level: true, avatar: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    return {
      data: requests.map((r) => ({
        id: r.id,
        senderId: r.senderId,
        senderName: r.sender.name,
        senderAvatar: r.sender.avatar,
        receiverId: r.receiverId,
        status: 'pending',
        createdAt: r.createdAt,
      })),
    };
  }

  async respond(userId: string, requestId: string, accept: boolean) {
    const request = await this.prisma.messageRequest.findUnique({ where: { id: requestId } });
    if (!request) throw new NotFoundException('Request not found');
    if (request.receiverId !== userId) throw new BadRequestException('Not authorized');

    await this.prisma.messageRequest.update({
      where: { id: requestId },
      data: { status: accept ? 'ACCEPTED' : 'REJECTED' },
    });
    return { data: { id: requestId, accepted: accept } };
  }
}
