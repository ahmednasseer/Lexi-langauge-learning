import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CertificatesService {
  constructor(private prisma: PrismaService) {}

  async getUserCertificates(userId: string) {
    return this.prisma.certificate.findMany({
      where: { userId },
      orderBy: { issuedAt: 'desc' },
    });
  }

  async generateCertificate(userId: string, level: string) {
    const existingCertificate = await this.prisma.certificate.findFirst({
      where: { userId, level },
    });

    if (existingCertificate) {
      return existingCertificate;
    }

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new Error('User not found');
    }

    const levelTitles: Record<string, string> = {
      A1: 'Beginner',
      A2: 'Elementary',
      B1: 'Intermediate',
      B2: 'Upper Intermediate',
      C1: 'Advanced',
      C2: 'Mastery',
    };

    const certificateCode = `LEXI-${level}-${Date.now().toString(36).toUpperCase()}`;

    const certificate = await this.prisma.certificate.create({
      data: {
        userId,
        userName: user.name,
        level,
        levelTitle: levelTitles[level] || level,
        totalXp: user.totalXp,
        certificateCode,
      },
    });

    return certificate;
  }

  async verifyCertificate(code: string) {
    const certificate = await this.prisma.certificate.findFirst({
      where: { certificateCode: code },
      include: { user: { select: { name: true, email: true } } },
    });

    if (!certificate) {
      return { valid: false, message: 'Certificate not found' };
    }

    return {
      valid: true,
      certificate: {
        userName: certificate.userName,
        level: certificate.level,
        levelTitle: certificate.levelTitle,
        issuedAt: certificate.issuedAt,
        certificateCode: certificate.certificateCode,
      },
    };
  }
}
