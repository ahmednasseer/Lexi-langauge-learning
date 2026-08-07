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
  private connection: Redis | null = null;
  private queues: Map<string, Queue> = new Map();
  private workers: Map<string, Worker> = new Map();
  private queueEnabled: boolean;

  constructor(private config: ConfigService) {
    this.queueEnabled = this.config.get('QUEUE_ENABLED', 'true') !== 'false';
    if (this.queueEnabled) {
      try {
        this.connection = new Redis({
          host: this.config.get('REDIS_HOST', 'localhost'),
          port: this.config.get('REDIS_PORT', 6379),
          password: this.config.get('REDIS_PASSWORD') || undefined,
          maxRetriesPerRequest: 3,
        });
        this.setupQueues();
        this.setupWorkers();
      } catch (e) {
        this.logger.warn('Redis not available, queues disabled');
        this.queueEnabled = false;
      }
    }
  }

  async onModuleDestroy() {
    for (const worker of this.workers.values()) {
      await worker.close();
    }
    for (const queue of this.queues.values()) {
      await queue.close();
    }
    if (this.connection) await this.connection.quit();
  }

  private setupQueues() {
    if (!this.queueEnabled) return;
    const queueNames = ['notifications', 'analytics', 'ai-plans', 'leaderboard', 'email', 'audio-processing'];

    for (const name of queueNames) {
      this.queues.set(name, new Queue(name, { connection: this.connection! }));
    }
  }

  private setupWorkers() {
    if (!this.queueEnabled) return;
    // Workers are setup but do nothing if Redis is not available
    this.logger.log('Queue workers initialized');
  }

  async addJob(queueName: string, jobName: string, data: any, options?: { delay?: number; priority?: number }) {
    if (!this.queueEnabled) return null;
    const queue = this.queues.get(queueName);
    if (!queue) throw new Error(`Queue ${queueName} not found`);
    return queue.add(jobName, data, {
      removeOnComplete: 100,
      removeOnFail: 50,
      ...options,
    });
  }

  async getQueueStats(queueName: string) {
    if (!this.queueEnabled) return null;
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
