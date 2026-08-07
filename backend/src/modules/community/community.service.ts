import { Injectable, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class CommunityService {
  private readonly FREE_USER_DAILY_LIMIT = 10;
  private readonly PREMIUM_USER_DAILY_LIMIT = 50;
  private readonly RATE_LIMIT_WINDOW_MS = 60000;
  private readonly MAX_MESSAGES_PER_MINUTE = 5;

  constructor(private prisma: PrismaService) {}

  async getFeed(userId: string) {
    const blockedUserIds = await this.getBlockedUserIds(userId);

    const posts = await this.prisma.post.findMany({
      where: {
        userId: { notIn: blockedUserIds },
      },
      include: {
        user: { select: { name: true, level: true, totalXp: true } },
        likes: { select: { userId: true } },
        _count: { select: { likes: true, comments: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    return posts.map(post => ({
      ...post,
      likesCount: post._count.likes,
      commentsCount: post._count.comments,
      isLiked: post.likes.some(like => like.userId === userId),
    }));
  }

  async createPost(userId: string, data: { content: string; type: string; groupId?: string }) {
    if (!data.content || data.content.trim().length === 0) {
      throw new BadRequestException('Post content cannot be empty');
    }
    if (data.content.length > 1000) {
      throw new BadRequestException('Post content too long (max 1000 characters)');
    }

    return this.prisma.post.create({
      data: {
        userId,
        content: data.content.trim(),
        type: data.type,
        groupId: data.groupId,
      },
    });
  }

  async toggleLike(userId: string, postId: string) {
    const post = await this.prisma.post.findUnique({ where: { id: postId } });
    if (!post) throw new BadRequestException('Post not found');
    if (post.userId === userId) throw new BadRequestException('Cannot like your own post');

    const existingLike = await this.prisma.like.findUnique({
      where: { userId_postId: { userId, postId } },
    });

    if (existingLike) {
      await this.prisma.like.delete({ where: { id: existingLike.id } });
      return { liked: false };
    } else {
      await this.prisma.like.create({ data: { userId, postId } });
      return { liked: true };
    }
  }

  async addComment(userId: string, postId: string, text: string) {
    if (!text || text.trim().length === 0) {
      throw new BadRequestException('Comment cannot be empty');
    }
    if (text.length > 500) {
      throw new BadRequestException('Comment too long (max 500 characters)');
    }

    const post = await this.prisma.post.findUnique({ where: { id: postId } });
    if (!post) throw new BadRequestException('Post not found');

    return this.prisma.comment.create({
      data: {
        postId,
        userId,
        text: text.trim(),
      },
    });
  }

  async getGroups(userId: string) {
    const blockedUserIds = await this.getBlockedUserIds(userId);
    
    const groups = await this.prisma.communityGroup.findMany({
      where: {
        members: { none: { userId: { in: blockedUserIds } } },
      },
      include: {
        _count: { select: { members: true, posts: true } },
        members: { where: { userId } },
      },
    });

    return groups.map(group => ({
      ...group,
      memberCount: group._count.members,
      postCount: group._count.posts,
      isJoined: group.members.length > 0,
    }));
  }

  async toggleGroupJoin(userId: string, groupId: string) {
    const group = await this.prisma.communityGroup.findUnique({ where: { id: groupId } });
    if (!group) throw new BadRequestException('Group not found');

    const existingMembership = await this.prisma.groupMember.findUnique({
      where: { userId_groupId: { userId, groupId } },
    });

    if (existingMembership) {
      await this.prisma.groupMember.delete({ where: { id: existingMembership.id } });
      return { joined: false };
    } else {
      await this.prisma.groupMember.create({ data: { userId, groupId } });
      return { joined: true };
    }
  }

  async getLeaderboard() {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        name: true,
        level: true,
        totalXp: true,
        streak: true,
        isPremium: true,
      },
      orderBy: { totalXp: 'desc' },
      take: 50,
    });

    return users.map((user, index) => ({
      ...user,
      rank: index + 1,
    }));
  }

  async getChallenges() {
    return this.prisma.challenge.findMany({
      where: { isActive: true },
      include: {
        _count: { select: { participants: true } },
      },
    });
  }

  async joinChallenge(userId: string, challengeId: string) {
    const challenge = await this.prisma.challenge.findUnique({ where: { id: challengeId } });
    if (!challenge) throw new BadRequestException('Challenge not found');

    const existing = await this.prisma.userChallenge.findUnique({
      where: { userId_challengeId: { userId, challengeId } },
    });

    if (existing) throw new BadRequestException('Already joined this challenge');

    return this.prisma.userChallenge.create({
      data: {
        userId,
        challengeId,
      },
    });
  }

  async getConversations(userId: string) {
    const blockedUserIds = await this.getBlockedUserIds(userId);

    const messages = await this.prisma.message.findMany({
      where: {
        OR: [
          { senderId: userId },
          { receiverId: userId },
        ],
        AND: [
          { senderId: { notIn: blockedUserIds } },
          { receiverId: { notIn: blockedUserIds } },
        ],
      },
      include: {
        sender: { select: { id: true, name: true } },
        receiver: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    const conversationMap = new Map();

    for (const message of messages) {
      const otherUserId = message.senderId === userId ? message.receiverId : message.senderId;
      const otherUser = message.senderId === userId ? message.receiver : message.sender;

      if (!conversationMap.has(otherUserId)) {
        conversationMap.set(otherUserId, {
          id: `conv_${otherUserId}`,
          otherUserId,
          otherUserName: otherUser.name,
          lastMessage: message,
          unreadCount: message.receiverId === userId && !message.isRead ? 1 : 0,
        });
      }
    }

    return Array.from(conversationMap.values());
  }

  async getMessages(userId: string, conversationId: string) {
    const otherUserId = conversationId.startsWith('conv_')
      ? conversationId.slice(5)
      : conversationId;

    const blockedUserIds = await this.getBlockedUserIds(userId);

    return this.prisma.message.findMany({
      where: {
        OR: [
          { senderId: userId, receiverId: otherUserId },
          { senderId: otherUserId, receiverId: userId },
        ],
        AND: [
          { senderId: { notIn: blockedUserIds } },
          { receiverId: { notIn: blockedUserIds } },
        ],
      },
      include: {
        sender: { select: { id: true, name: true } },
        receiver: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async sendMessageRequest(senderId: string, receiverId: string) {
    if (senderId === receiverId) {
      throw new BadRequestException('Cannot send message request to yourself');
    }

    const receiver = await this.prisma.user.findUnique({ where: { id: receiverId } });
    if (!receiver) throw new BadRequestException('User not found');

    const isBlocked = await this.isUserBlocked(senderId, receiverId);
    if (isBlocked) throw new ForbiddenException('Cannot send message request to this user');

    const receiverProfile = await this.prisma.userProfile.findUnique({ where: { userId: receiverId } });
    if (receiverProfile?.privacySetting === 'DISABLED') {
      throw new ForbiddenException('This user has disabled messaging');
    }

    await this.checkRateLimit(senderId, receiver.isPremium);

    const existing = await this.prisma.messageRequest.findFirst({
      where: {
        senderId,
        receiverId,
        status: 'PENDING',
      },
    });

    if (existing) throw new BadRequestException('Request already sent');

    return this.prisma.messageRequest.create({
      data: {
        senderId,
        receiverId,
      },
    });
  }

  async sendMessage(senderId: string, receiverId: string, content: string) {
    if (senderId === receiverId) {
      throw new BadRequestException('Cannot send message to yourself');
    }

    if (!content || content.trim().length === 0) {
      throw new BadRequestException('Message content cannot be empty');
    }

    if (content.length > 1000) {
      throw new BadRequestException('Message too long (max 1000 characters)');
    }

    const isBlocked = await this.isUserBlocked(senderId, receiverId);
    if (isBlocked) throw new ForbiddenException('Cannot send message to this user');

    const hasAcceptedRequest = await this.prisma.messageRequest.findFirst({
      where: {
        OR: [
          { senderId, receiverId, status: 'ACCEPTED' },
          { senderId: receiverId, receiverId: senderId, status: 'ACCEPTED' },
        ],
      },
    });

    if (!hasAcceptedRequest) {
      throw new ForbiddenException('Message request must be accepted first');
    }

    const receiver = await this.prisma.user.findUnique({ where: { id: receiverId } });
    await this.checkRateLimit(senderId, receiver?.isPremium ?? false);

    return this.prisma.message.create({
      data: {
        senderId,
        receiverId,
        content: content.trim(),
      },
    });
  }

  async acceptMessageRequest(userId: string, requestId: string) {
    const request = await this.prisma.messageRequest.findUnique({ where: { id: requestId } });
    if (!request || request.receiverId !== userId) throw new BadRequestException('Request not found');

    const isBlocked = await this.isUserBlocked(userId, request.senderId);
    if (isBlocked) throw new ForbiddenException('Cannot accept request from blocked user');

    return this.prisma.messageRequest.update({
      where: { id: requestId },
      data: { status: 'ACCEPTED' },
    });
  }

  async rejectMessageRequest(userId: string, requestId: string) {
    const request = await this.prisma.messageRequest.findUnique({ where: { id: requestId } });
    if (!request || request.receiverId !== userId) throw new BadRequestException('Request not found');

    return this.prisma.messageRequest.update({
      where: { id: requestId },
      data: { status: 'REJECTED' },
    });
  }

  async blockUser(userId: string, targetUserId: string) {
    if (userId === targetUserId) {
      throw new BadRequestException('Cannot block yourself');
    }

    await this.prisma.blockedUser.upsert({
      where: {
        blockerId_blockedId: { blockerId: userId, blockedId: targetUserId },
      },
      update: {},
      create: {
        blockerId: userId,
        blockedId: targetUserId,
      },
    });

    await this.prisma.messageRequest.updateMany({
      where: {
        OR: [
          { senderId: userId, receiverId: targetUserId },
          { senderId: targetUserId, receiverId: userId },
        ],
      },
      data: { status: 'BLOCKED' },
    });

    return { blocked: true };
  }

  async unblockUser(userId: string, targetUserId: string) {
    await this.prisma.blockedUser.deleteMany({
      where: {
        blockerId: userId,
        blockedId: targetUserId,
      },
    });

    return { unblocked: true };
  }

  async reportUser(reporterId: string, data: {
    reportedUserId: string;
    messageId?: string;
    reason: string;
    description?: string;
  }) {
    if (reporterId === data.reportedUserId) {
      throw new BadRequestException('Cannot report yourself');
    }

    const reportedUser = await this.prisma.user.findUnique({ where: { id: data.reportedUserId } });
    if (!reportedUser) throw new BadRequestException('User not found');

    if (data.messageId) {
      const message = await this.prisma.message.findUnique({ where: { id: data.messageId } });
      if (!message) throw new BadRequestException('Message not found');
    }

    const existingReport = await this.prisma.userReport.findFirst({
      where: {
        reporterId,
        reportedUserId: data.reportedUserId,
      },
    });

    if (existingReport) throw new BadRequestException('You have already reported this user');

    return this.prisma.userReport.create({
      data: {
        reporterId,
        reportedUserId: data.reportedUserId,
        messageId: data.messageId,
        reason: data.reason,
        description: data.description,
      },
    });
  }

  async getBlockedUsers(userId: string) {
    return this.prisma.blockedUser.findMany({
      where: { blockerId: userId },
      include: {
        blocked: { select: { id: true, name: true } },
      },
    });
  }

  private async getBlockedUserIds(userId: string): Promise<string[]> {
    const blocked = await this.prisma.blockedUser.findMany({
      where: {
        OR: [
          { blockerId: userId },
          { blockedId: userId },
        ],
      },
      select: {
        blockerId: true,
        blockedId: true,
      },
    });

    const blockedIds = new Set<string>();
    for (const b of blocked) {
      if (b.blockerId === userId) blockedIds.add(b.blockedId);
      if (b.blockedId === userId) blockedIds.add(b.blockerId);
    }

    return Array.from(blockedIds);
  }

  private async isUserBlocked(userId: string, targetUserId: string): Promise<boolean> {
    const blocked = await this.prisma.blockedUser.findUnique({
      where: {
        blockerId_blockedId: { blockerId: userId, blockedId: targetUserId },
      },
    });
    return blocked !== null;
  }

  private async checkRateLimit(userId: string, isPremium: boolean) {
    const now = new Date();
    const oneMinuteAgo = new Date(now.getTime() - this.RATE_LIMIT_WINDOW_MS);

    const recentMessages = await this.prisma.message.count({
      where: {
        senderId: userId,
        createdAt: { gte: oneMinuteAgo },
      },
    });

    if (recentMessages >= this.MAX_MESSAGES_PER_MINUTE) {
      throw new BadRequestException('Too many messages. Please wait a moment.');
    }

    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const dailyMessages = await this.prisma.message.count({
      where: {
        senderId: userId,
        createdAt: { gte: today },
      },
    });

    const limit = isPremium ? this.PREMIUM_USER_DAILY_LIMIT : this.FREE_USER_DAILY_LIMIT;
    if (dailyMessages >= limit) {
      throw new BadRequestException(`Daily message limit reached (${limit}). ${isPremium ? '' : 'Upgrade to Premium for higher limits.'}`);
    }
  }
}
