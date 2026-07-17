import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class SearchService {
  constructor(private prisma: PrismaService) {}

  async search(q: string, type?: string) {
    if (!q || q.trim().length === 0) {
      throw new BadRequestException('Search query is required');
    }
    const query = q.trim();
    const results: any[] = [];

    if (!type || type === 'lesson' || type === 'vocabulary') {
      const vocabulary = await this.prisma.vocabulary.findMany({
        where: {
          OR: [
            { word: { contains: query, mode: 'insensitive' } },
            { translation: { contains: query, mode: 'insensitive' } },
          ],
        },
        include: { lesson: { select: { title: true, level: true } } },
        take: 10,
      });
      for (const v of vocabulary) {
        results.push({
          id: v.id,
          type: 'vocabulary',
          title: v.word,
          subtitle: v.translation,
          description: v.example,
        });
      }
    }

    if (!type || type === 'item') {
      const items = await this.prisma.storeItem.findMany({
        where: {
          isActive: true,
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: 10,
      });
      for (const item of items) {
        results.push({
          id: item.id,
          type: 'item',
          title: item.name,
          subtitle: item.description,
          imageUrl: item.imageUrl,
        });
      }
    }

    if (!type || type === 'user') {
      const users = await this.prisma.user.findMany({
        where: {
          isActive: true,
          name: { contains: query, mode: 'insensitive' },
        },
        select: { id: true, name: true, level: true, avatar: true },
        take: 10,
      });
      for (const u of users) {
        results.push({
          id: u.id,
          type: 'user',
          title: u.name,
          subtitle: `Level ${u.level}`,
          imageUrl: u.avatar,
        });
      }
    }

    return { data: results };
  }
}
