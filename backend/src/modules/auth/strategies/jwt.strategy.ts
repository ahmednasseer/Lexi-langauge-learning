import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy as PassportBaseStrategy } from 'passport';
import { ExtractJwt } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseService } from '../../../config/firebase.service';
import { PrismaService } from '../../../config/prisma.service';

/**
 * Accepts the Authorization: Bearer <token> header and supports two token types:
 *
 *  1. Firebase ID tokens (issued by Firebase Auth — what the Flutter always sends).
 *     Verified with the Firebase Admin SDK; the Firebase uid is mapped to the
 *     PostgreSQL `users.providerId` (creating/linking the user on first contact).
 *  2. Legacy NestJS JWTs (signed with JWT_SECRET) — backwards compatibility for
 *     any backend-created users / admin tooling.
 *
 * `req.user` always exposes `sub` = the PostgreSQL user id (ServerS).
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(PassportBaseStrategy, 'jwt') {
  constructor(
    private firebase: FirebaseService,
    private prisma: PrismaService,
    private config: ConfigService,
  ) {
    super();
  }

  authenticate(req: any): void {
    const token = ExtractJwt.fromAuthHeaderAsBearerToken()(req);
    if (!token) {
      return this.fail('No bearer token provided', 401);
    }

    this.tryFirebase(token)
      .then((user) => {
        if (user) {
          this.success(user);
        } else {
          this.tryLegacyJwt(token);
        }
      })
      .catch(() => {
        this.fail('Invalid token', 401);
      });
  }

  /** Returns mapped user or null when the token is not a Firebase ID token. */
  private async tryFirebase(
    token: string,
  ): Promise<{ sub: string; id?: string; email?: string; role?: string; isPremium?: boolean } | null> {
    let decoded: DecodedIdToken | null = null;
    try {
      decoded = await this.firebase.verifyIdToken(token);
    } catch {
      return null; // not a firebase token
    }
    return this.mapFirebaseUser(decoded);
  }

  private async mapFirebaseUser(
    decoded: DecodedIdToken,
  ): Promise<{ sub: string; id?: string; email?: string; role?: string; isPremium?: boolean }> {
    const uid = decoded.uid;
    const email = decoded.email ?? null;
    const name = (decoded as any).name ?? (decoded as any).display_name ?? null;
    const picture = decoded.picture ?? null;

    // 1) Existing user already linked to this firebase uid
    let user = await this.prisma.user.findFirst({
      where: { provider: 'firebase', providerId: uid },
    });

    // 2) Link an existing account that has the same verified email
    if (!user && email) {
      const byEmail = await this.prisma.user.findUnique({ where: { email } });
      if (byEmail) {
        user = await this.prisma.user.update({
          where: { id: byEmail.id },
          data: {
            provider: 'firebase',
            providerId: uid,
            ...(picture ? { avatar: picture } : {}),
          },
        });
      }
    }

    // 3) Otherwise create a brand new user record
    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: email ?? `${uid}@firebase.local`,
          name: name || (email ? email.split('@')[0] : 'Lexi User'),
          provider: 'firebase',
          providerId: uid,
          avatar: picture ?? undefined,
        },
      });
    }

    return {
      sub: user.id,
      id: user.id,
      email: user.email,
      role: user.role ?? 'user',
      isPremium: user.isPremium ?? false,
    };
  }

  private tryLegacyJwt(token: string): void {
    try {
      const secret = this.config.get<string>('JWT_SECRET');
      if (!secret) throw new Error('JWT_SECRET not configured');
      const payload = verifyHS256(token, secret);
      if (!payload || !payload.sub) {
        return this.fail('Invalid token', 401);
      }
      this.success({
        sub: payload.sub,
        id: payload.sub,
        email: payload.email,
        isPremium: payload.isPremium ?? false,
        role: payload.role ?? 'user',
      });
    } catch {
      this.fail('Invalid token', 401);
    }
  }
}

/** Minimal HS256 JWT verifier for legacy tokens (no extra dependency). */
function verifyHS256(token: string, secret: string): any {
  const parts = token.split('.');
  if (parts.length !== 3) throw new Error('Malformed token');

  const decodeB64 = (input: string): string =>
    Buffer.from(input.replace(/-/g, '+').replace(/_/g, '/'), 'base64').toString('utf-8');

  const header = JSON.parse(decodeB64(parts[0]));
  if (header.alg !== 'HS256') throw new Error('Unsupported algorithm');

  const expected = require('crypto')
    .createHmac('sha256', secret)
    .update(`${parts[0]}.${parts[1]}`)
    .digest('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');

  if (expected !== parts[2]) throw new Error('Signature mismatch');

  const payload = JSON.parse(decodeB64(parts[1]));
  if (payload.exp && payload.exp * 1000 < Date.now()) {
    throw new Error('Token expired');
  }
  return payload;
}