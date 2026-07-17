import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';

export interface ReferralCode {
  id: string;
  userId: string;
  code: string;
  maxUses: number;
  currentUses: number;
  createdAt: Date;
  expiresAt: Date;
}

export interface Referral {
  id: string;
  referrerId: string;
  referrerName: string;
  inviteeId: string;
  inviteeName: string;
  referralCode: string;
  status: string;
  createdAt: Date;
  acceptedAt?: Date;
}

export interface UserLevel {
  level: number;
  title: string;
  minXp: number;
  maxXp: number;
  reward: { gems: number; frameId?: string; badgeId?: string };
}

export interface SeasonalEvent {
  id: string;
  title: string;
  description: string;
  type: string;
  status: string;
  startDate: Date;
  endDate: Date;
  goals: EventGoal[];
  reward: EventReward;
  participantsCount: number;
}

export interface EventGoal {
  id: string;
  title: string;
  targetValue: number;
  currentValue: number;
  unit: string;
}

export interface EventReward {
  xp: number;
  gems: number;
  badgeId?: string;
  frameId?: string;
}

@Injectable()
export class GrowthService {
  private referralCodes: Map<string, ReferralCode> = new Map();
  private referrals: Map<string, Referral> = new Map();
  private userXp: Map<string, number> = new Map();
  private events: Map<string, SeasonalEvent> = new Map();

  constructor() {
    this.initializeDemoData();
  }

  private initializeDemoData() {
    // Demo referral code
    const demoCode: ReferralCode = {
      id: 'ref_code_1',
      userId: 'user_1',
      code: 'LEXI2024',
      maxUses: 10,
      currentUses: 3,
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 30 * 86400000),
    };
    this.referralCodes.set(demoCode.code, demoCode);

    // Demo seasonal event
    const demoEvent: SeasonalEvent = {
      id: 'event_1',
      title: 'German Summer Challenge',
      description: 'Master German this summer with daily practice!',
      type: 'challenge',
      status: 'active',
      startDate: new Date(Date.now() - 5 * 86400000),
      endDate: new Date(Date.now() + 25 * 86400000),
      goals: [
        { id: 'goal_1', title: 'Speaking Practice', targetValue: 100, currentValue: 35, unit: 'minutes' },
        { id: 'goal_2', title: 'Vocabulary Building', targetValue: 500, currentValue: 180, unit: 'words' },
        { id: 'goal_3', title: 'Goethe Tasks', targetValue: 20, currentValue: 8, unit: 'exercises' },
      ],
      reward: { xp: 5000, gems: 1000, badgeId: 'summer_master', frameId: 'summer_frame' },
      participantsCount: 8500,
    };
    this.events.set(demoEvent.id, demoEvent);
  }

  // Referral System
  generateReferralCode(userId: string): ReferralCode {
    const code = `LEXI${userId.substring(0, 4).toUpperCase()}${Math.floor(Math.random() * 9999).toString().padStart(4, '0')}`;

    const referralCode: ReferralCode = {
      id: `ref_${Date.now()}`,
      userId,
      code,
      maxUses: 10,
      currentUses: 0,
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 30 * 86400000),
    };

    this.referralCodes.set(code, referralCode);
    return referralCode;
  }

  applyReferralCode(code: string, inviteeId: string, inviteeName: string): Referral {
    const referralCode = this.referralCodes.get(code);
    if (!referralCode) throw new NotFoundException('Invalid referral code');
    if (referralCode.currentUses >= referralCode.maxUses) throw new BadRequestException('Code usage limit reached');
    if (new Date() > referralCode.expiresAt) throw new BadRequestException('Code expired');

    referralCode.currentUses++;

    const referral: Referral = {
      id: `ref_${Date.now()}`,
      referrerId: referralCode.userId,
      referrerName: 'User',
      inviteeId,
      inviteeName,
      referralCode: code,
      status: 'accepted',
      createdAt: new Date(),
      acceptedAt: new Date(),
    };

    this.referrals.set(referral.id, referral);
    return referral;
  }

  getReferralStats(userId: string) {
    const userReferrals = Array.from(this.referrals.values()).filter(r => r.referrerId === userId);
    return {
      totalReferrals: userReferrals.length,
      successfulReferrals: userReferrals.filter(r => r.status === 'accepted').length,
      totalGemsEarned: userReferrals.filter(r => r.status === 'accepted').length * 500,
      totalPremiumDaysEarned: userReferrals.filter(r => r.status === 'accepted').length * 7,
    };
  }

  // Gamification
  getUserXp(userId: string): number {
    return this.userXp.get(userId) || 0;
  }

  addXp(userId: string, xp: number): { totalXp: number; level: number } {
    const currentXp = this.getUserXp(userId);
    const totalXp = currentXp + xp;
    this.userXp.set(userId, totalXp);

    return {
      totalXp,
      level: this.calculateLevel(totalXp),
    };
  }

  calculateLevel(xp: number): number {
    let level = 1;
    let requiredXp = 100;

    while (xp >= requiredXp) {
      level++;
      requiredXp += level * 50;
    }

    return level;
  }

  getLevels(): UserLevel[] {
    return [
      { level: 1, title: 'Beginner', minXp: 0, maxXp: 100, reward: { gems: 0 } },
      { level: 5, title: 'Explorer', minXp: 500, maxXp: 1000, reward: { gems: 100, frameId: 'explorer_frame' } },
      { level: 10, title: 'Adventurer', minXp: 2000, maxXp: 3000, reward: { gems: 200, frameId: 'adventurer_frame' } },
      { level: 15, title: 'Scholar', minXp: 5000, maxXp: 7500, reward: { gems: 300, badgeId: 'scholar_badge' } },
      { level: 20, title: 'Expert', minXp: 10000, maxXp: 15000, reward: { gems: 500, frameId: 'expert_frame' } },
      { level: 25, title: 'German Student', minXp: 20000, maxXp: 30000, reward: { gems: 750, badgeId: 'german_student_badge' } },
      { level: 30, title: 'Linguist', minXp: 40000, maxXp: 60000, reward: { gems: 1000, frameId: 'linguist_frame' } },
      { level: 40, title: 'Master', minXp: 100000, maxXp: 150000, reward: { gems: 2000, badgeId: 'master_badge' } },
      { level: 50, title: 'Language Master', minXp: 250000, maxXp: 300000, reward: { gems: 5000, frameId: 'master_frame' } },
    ];
  }

  // Seasonal Events
  getEvents(): SeasonalEvent[] {
    return Array.from(this.events.values());
  }

  joinEvent(eventId: string, userId: string): SeasonalEvent {
    const event = this.events.get(eventId);
    if (!event) throw new NotFoundException('Event not found');
    event.participantsCount++;
    return event;
  }

  // Analytics
  getAnalytics() {
    return {
      totalReferrals: this.referrals.size,
      totalCodes: this.referralCodes.size,
      totalEvents: this.events.size,
      activeEvents: Array.from(this.events.values()).filter(e => e.status === 'active').length,
    };
  }
}
