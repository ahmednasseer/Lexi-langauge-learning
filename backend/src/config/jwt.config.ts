import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class JwtConfigService {
  constructor(
    private config: ConfigService,
    private jwt: JwtService,
  ) {}

  get secret() {
    return this.config.get<string>('JWT_SECRET');
  }

  get expiresIn() {
    return this.config.get<string>('JWT_EXPIRES_IN', '7d');
  }

  sign(payload: Record<string, any>) {
    return this.jwt.sign(payload, { expiresIn: this.expiresIn });
  }

  verify(token: string) {
    return this.jwt.verify(token);
  }
}
