import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Queue, Worker, Job } from 'bullmq';
import Redis from 'ioredis';

export interface JobData {
  type: string;
  payload: any;
}

@Injectable()
export class QueueService implements OnModuleDestroy {
  private readonly logger = new Logger(QueueService.name);
  private connection: Redis;
  private queues: Map<string, Queue> = new Map();
  private workers: Map<string, Worker> = new Map();

  constructor(private config: ConfigService) {
    this.connection = new Redis({
      host: config.get('REDIS_HOST', 'localhost'),
      port: config.get('REDIS_PORT', 6379),
      maxRetriesPerRequest: 3,
    });

    this.setupQueues();
    this.setupWorkers();
  }

  async onModuleDestroy() {
    for (const worker of this.workers.values()) {
      await worker.close();
    }
    for (const queue of this.queues.values()) {
      await queue.close();
    }
    await this.connection.quit();
  }

  private setupQueues() {
    const queueNames = [
      'notifications',
      'analytics',
      'ai-plans',
      'leaderboard',
      'email',
      'audio-processing',
    ];

    for (const name of queueNames) {
      this.queues.set(name, new Queue(name, { connection: this.connection }));
    }
  }

  private setupWorkers() {
    // Notification Worker
    this.workers.set('notifications', new Worker('notifications', async (job: Job) => {
      this.logger.log(`Processing notification: ${job.name}`);
      // TODO: Send push notification via Firebase
      return { success: true };
    }, { connection: this.connection }));

    // Analytics Worker
    this.workers.set('analytics', new Worker('analytics', async (job: Job) => {
      this.logger.log(`Processing analytics: ${job.name}`);
      // TODO: Process analytics data
      return { success: true };
    }, { connection: this.connection }));

    // AI Plans Worker
    this.workers.set('ai-plans', new Worker('ai-plans', async (job: Job) => {
      this.logger.log(`Generating AI plan: ${job.name}`);
      // TODO: Generate AI learning plan asynchronously
      return { success: true };
    }, { connection: this.connection }));

    // Leaderboard Worker
    this.workers.set('leaderboard', new Worker('leaderboard', async (job: Job) => {
      this.logger.log(`Updating leaderboard: ${job.name}`);
      // TODO: Recalculate leaderboard rankings
      return { success: true };
    }, { connection: this.connection }));

    // Email Worker
    this.workers.set('email', new Worker('email', async (job: Job) => {
      this.logger.log(`Sending email: ${job.name}`);
      // TODO: Send email via SendGrid/SES
      return { success: true };
    }, { connection: this.connection }));

    // Audio Processing Worker
    this.workers.set('audio-processing', new Worker('audio-processing', async (job: Job) => {
      this.logger.log(`Processing audio: ${job.name}`);
      // TODO: Process audio files (TTS, compression)
      return { success: true };
    }, { connection: this.connection }));

    // Error handlers
    for (const [name, worker] of this.workers) {
      worker.on('failed', (job, err) => {
        this.logger.error(`Job ${job.name} in ${name} failed: ${err.message}`);
      });
      worker.on('completed', (job) => {
        this.logger.debug(`Job ${job.name} in ${name} completed`);
      });
    }
  }

  async addJob(queueName: string, jobName: string, data: any, options?: { delay?: number; priority?: number }) {
    const queue = this.queues.get(queueName);
    if (!queue) throw new Error(`Queue ${queueName} not found`);
    return queue.add(jobName, data, {
      removeOnComplete: 100,
      removeOnFail: 50,
      ...options,
    });
  }

  async getQueueStats(queueName: string) {
    const queue = this.queues.get(queueName);
    if (!queue) return null;
    const [waiting, active, completed, failed] = await Promise.all([
      queue.getWaitingCount(),
      queue.getActiveCount(),
      queue.getCompletedCount(),
      queue.getFailedCount(),
    ]);
    return { waiting, active, completed, failed };
  }
}
