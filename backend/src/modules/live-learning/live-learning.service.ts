import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';

export enum RoomStatus {
  waiting = 'waiting',
  active = 'active',
  ended = 'ended',
}

export enum RoomLevel {
  a1 = 'a1',
  a2 = 'a2',
  b1 = 'b1',
  b2 = 'b2',
  c1 = 'c1',
  c2 = 'c2',
  all = 'all',
}

export interface LiveRoom {
  id: string;
  hostId: string;
  hostName: string;
  title: string;
  topic: string;
  description: string;
  level: RoomLevel;
  status: RoomStatus;
  maxParticipants: number;
  participants: RoomParticipant[];
  createdAt: Date;
  startedAt?: Date;
  endedAt?: Date;
  durationMinutes: number;
  tags: string[];
}

export interface RoomParticipant {
  userId: string;
  userName: string;
  isMuted: boolean;
  isSpeaking: boolean;
  isHost: boolean;
  joinedAt: Date;
}

export interface LanguagePartner {
  id: string;
  userId: string;
  userName: string;
  nativeLanguage: string;
  learningLanguage: string;
  level: string;
  goal: string;
  status: string;
  createdAt: Date;
}

export interface LearningGroup {
  id: string;
  name: string;
  description: string;
  level: string;
  category: string;
  maxMembers: number;
  members: GroupMember[];
  frequency: string;
  teacherName: string;
  tags: string[];
  totalSessions: number;
}

export interface GroupMember {
  userId: string;
  userName: string;
  role: string;
  joinedAt: Date;
  attendanceCount: number;
}

export interface CommunityEvent {
  id: string;
  title: string;
  description: string;
  type: string;
  status: string;
  startDate: Date;
  endDate: Date;
  maxParticipants: number;
  participants: EventParticipant[];
  reward: EventReward;
  rules: string[];
  tags: string[];
}

export interface EventParticipant {
  userId: string;
  userName: string;
  joinedAt: Date;
  progress: number;
  completed: boolean;
}

export interface EventReward {
  xp: number;
  gems: number;
  badgeId?: string;
  badgeName?: string;
}

@Injectable()
export class LiveLearningService {
  private rooms: Map<string, LiveRoom> = new Map();
  private partners: Map<string, LanguagePartner> = new Map();
  private groups: Map<string, LearningGroup> = new Map();
  private events: Map<string, CommunityEvent> = new Map();

  constructor() {
    this.initializeDemoData();
  }

  private initializeDemoData() {
    // Demo rooms
    const demoRoom: LiveRoom = {
      id: 'room_1',
      hostId: 'host_1',
      hostName: 'Lexi AI',
      title: 'German Café',
      topic: 'Talking about Travel',
      description: 'Practice German conversation about travel experiences',
      level: RoomLevel.b1,
      status: RoomStatus.waiting,
      maxParticipants: 10,
      participants: [
        { userId: 'user_1', userName: 'Ahmed', isMuted: false, isSpeaking: false, isHost: false, joinedAt: new Date() },
        { userId: 'user_2', userName: 'Lena', isMuted: false, isSpeaking: false, isHost: false, joinedAt: new Date() },
      ],
      createdAt: new Date(),
      durationMinutes: 30,
      tags: ['Travel', 'Conversation', 'B1'],
    };
    this.rooms.set(demoRoom.id, demoRoom);

    // Demo partners
    const demoPartner: LanguagePartner = {
      id: 'partner_1',
      userId: 'user_lena',
      userName: 'Lena',
      nativeLanguage: 'German',
      learningLanguage: 'Arabic',
      level: 'B2',
      goal: 'conversation',
      status: 'pending',
      createdAt: new Date(),
    };
    this.partners.set(demoPartner.id, demoPartner);

    // Demo groups
    const demoGroup: LearningGroup = {
      id: 'group_1',
      name: 'B1 Speaking Club',
      description: 'Practice speaking German at B1 level with fellow learners',
      level: 'B1',
      category: 'Speaking',
      maxMembers: 50,
      members: Array.from({ length: 25 }, (_, i) => ({
        userId: `user_${i + 1}`,
        userName: `Member ${i + 1}`,
        role: 'member',
        joinedAt: new Date(),
        attendanceCount: 10 - (i % 5),
      })),
      frequency: 'weekly',
      teacherName: 'Lexi AI',
      tags: ['Speaking', 'B1', 'Practice'],
      totalSessions: 12,
    };
    this.groups.set(demoGroup.id, demoGroup);

    // Demo events
    const demoEvent: CommunityEvent = {
      id: 'event_1',
      title: '30 Days German Challenge',
      description: 'Practice German every day for 30 days and earn exclusive rewards!',
      type: 'challenge',
      status: 'upcoming',
      startDate: new Date(Date.now() + 86400000),
      endDate: new Date(Date.now() + 31 * 86400000),
      maxParticipants: 10000,
      participants: Array.from({ length: 500 }, (_, i) => ({
        userId: `user_${i + 1}`,
        userName: `Participant ${i + 1}`,
        joinedAt: new Date(),
        progress: 0,
        completed: false,
      })),
      reward: { xp: 5000, gems: 500, badgeId: 'german_master_30', badgeName: 'German Master 30' },
      rules: ['Practice at least 15 minutes daily', 'Complete daily missions'],
      tags: ['Challenge', '30 Days', 'German'],
    };
    this.events.set(demoEvent.id, demoEvent);
  }

  // Rooms
  getRooms(): LiveRoom[] {
    return Array.from(this.rooms.values());
  }

  getRoom(id: string): LiveRoom {
    const room = this.rooms.get(id);
    if (!room) throw new NotFoundException('Room not found');
    return room;
  }

  createRoom(data: {
    hostId: string;
    hostName: string;
    title: string;
    topic: string;
    description: string;
    level: RoomLevel;
    maxParticipants?: number;
    durationMinutes?: number;
    tags?: string[];
  }): LiveRoom {
    const room: LiveRoom = {
      id: `room_${Date.now()}`,
      hostId: data.hostId,
      hostName: data.hostName,
      title: data.title,
      topic: data.topic,
      description: data.description,
      level: data.level,
      status: RoomStatus.waiting,
      maxParticipants: data.maxParticipants || 10,
      participants: [],
      createdAt: new Date(),
      durationMinutes: data.durationMinutes || 30,
      tags: data.tags || [],
    };

    this.rooms.set(room.id, room);
    return room;
  }

  joinRoom(roomId: string, userId: string, userName: string): LiveRoom {
    const room = this.getRoom(roomId);

    if (room.participants.length >= room.maxParticipants) {
      throw new BadRequestException('Room is full');
    }

    const participant: RoomParticipant = {
      userId,
      userName,
      isMuted: false,
      isSpeaking: false,
      isHost: false,
      joinedAt: new Date(),
    };

    room.participants.push(participant);
    return room;
  }

  leaveRoom(roomId: string, userId: string): LiveRoom {
    const room = this.getRoom(roomId);
    room.participants = room.participants.filter(p => p.userId !== userId);
    return room;
  }

  // Partners
  getPartners(): LanguagePartner[] {
    return Array.from(this.partners.values());
  }

  findMatch(data: {
    userId: string;
    nativeLanguage: string;
    learningLanguage: string;
    level: string;
    goal: string;
  }): LanguagePartner | null {
    const availablePartners = Array.from(this.partners.values()).filter(p =>
      p.userId !== data.userId &&
      p.status === 'pending' &&
      p.nativeLanguage === data.learningLanguage &&
      p.learningLanguage === data.nativeLanguage
    );

    return availablePartners.length > 0 ? availablePartners[0] : null;
  }

  // Groups
  getGroups(): LearningGroup[] {
    return Array.from(this.groups.values());
  }

  joinGroup(groupId: string, userId: string, userName: string): LearningGroup {
    const group = this.groups.get(groupId);
    if (!group) throw new NotFoundException('Group not found');

    if (group.members.length >= group.maxMembers) {
      throw new BadRequestException('Group is full');
    }

    const member: GroupMember = {
      userId,
      userName,
      role: 'member',
      joinedAt: new Date(),
      attendanceCount: 0,
    };

    group.members.push(member);
    return group;
  }

  // Events
  getEvents(): CommunityEvent[] {
    return Array.from(this.events.values());
  }

  joinEvent(eventId: string, userId: string, userName: string): CommunityEvent {
    const event = this.events.get(eventId);
    if (!event) throw new NotFoundException('Event not found');

    if (event.participants.length >= event.maxParticipants) {
      throw new BadRequestException('Event is full');
    }

    const participant: EventParticipant = {
      userId,
      userName,
      joinedAt: new Date(),
      progress: 0,
      completed: false,
    };

    event.participants.push(participant);
    return event;
  }

  // Analytics
  getAnalytics() {
    return {
      totalRooms: this.rooms.size,
      activeRooms: Array.from(this.rooms.values()).filter(r => r.status === RoomStatus.active).length,
      totalPartners: this.partners.size,
      totalGroups: this.groups.size,
      totalEvents: this.events.size,
      activeEvents: Array.from(this.events.values()).filter(e => e.status === 'active').length,
      totalParticipants: Array.from(this.rooms.values()).reduce((sum, r) => sum + r.participants.length, 0),
    };
  }
}
