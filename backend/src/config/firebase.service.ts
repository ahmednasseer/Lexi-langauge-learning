import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  App,
  AppOptions,
  cert,
  initializeApp,
  deleteApp,
} from 'firebase-admin';
import { DecodedIdToken, getAuth } from 'firebase-admin/auth';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleDestroy {
  private readonly logger = new Logger(FirebaseService.name);
  private app: App | null = null;

  constructor(private config: ConfigService) {}

  getInstance(): App {
    if (this.app) return this.app;

    const serviceAccountPath = this.ensureServiceAccountPath();
    if (!serviceAccountPath) {
      throw new Error(
        'Firebase Admin SDK: no service account found. Set FIREBASE_SERVICE_ACCOUNT_PATH or place a ' +
          '[project-id]-firebase-adminsdk-*.json under scripts/',
      );
    }

    const projectId =
      this.config.get<string>('FIREBASE_PROJECT_ID') ?? 'lexi-33b14';

    const options: AppOptions = {
      credential: cert(serviceAccountPath),
      projectId,
    };

    this.app = initializeApp(options);

    this.logger.log(`Firebase Admin initialized for project ${projectId}`);
    return this.app;
  }

  private ensureServiceAccountPath(): string | null {
    const fromEnv = this.config.get<string>('FIREBASE_SERVICE_ACCOUNT_PATH');
    if (fromEnv) {
      try {
        const resolved = path.resolve(process.cwd(), fromEnv);
        if (fs.existsSync(resolved)) return resolved;
        if (fs.existsSync(fromEnv)) return fromEnv;
      } catch (e) {
        console.warn(`Failed to resolve Firebase service account path: ${e}`);
      }
    }

    const candidates = [
      path.resolve(process.cwd(), 'scripts'),
      path.resolve(process.cwd(), '..', 'scripts'),
    ];
    for (const dir of candidates) {
      if (!fs.existsSync(dir)) continue;
      const found = fs.readdirSync(dir).find(
        (f) =>
          f.startsWith('lexi-') &&
          f.includes('firebase-adminsdk-') &&
          f.endsWith('.json'),
      );
      if (found) return path.join(dir, found);
    }

    return null;
  }

  async verifyIdToken(token: string): Promise<DecodedIdToken> {
    const auth = getAuth(this.getInstance());
    return auth.verifyIdToken(token);
  }

  async onModuleDestroy() {
    if (this.app) {
      await deleteApp(this.app).catch(() => {});
      this.app = null;
    }
  }
}