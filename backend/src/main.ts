import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import * as express from 'express';
import { AppModule } from './app.module';
import { RedisService } from './config/redis.service';
import { SentryExceptionFilter } from './common/filters/sentry.filter';
import { MonitoringService } from './common/monitoring/monitoring.service';

async function bootstrap() {
  const jwtSecret = process.env.JWT_SECRET;
  if (!jwtSecret || jwtSecret.includes('change-this') || jwtSecret.length < 32) {
    throw new Error(
      'JWT_SECRET is not configured or too weak. ' +
      'Generate a secure random string (e.g. `openssl rand -hex 64`) and set it in .env',
    );
  }

  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
    rawBody: true,
  });

  // ==================== SECURITY ====================
  app.use(helmet());
  app.use(express.json({ limit: '1mb' }));
  app.setGlobalPrefix('api/v1');

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  const corsOrigin = process.env.CORS_ORIGIN;
  const allowedOrigins = (corsOrigin && corsOrigin !== '*')
    ? corsOrigin.split(',').map((o) => o.trim())
    : ['http://localhost:3000', 'http://10.0.2.2:3000'];

  app.enableCors({
    origin: allowedOrigins,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  });

  // ==================== EXCEPTION FILTERS ====================
  // Sentry is optional - only initialize if DSN is provided
  if (process.env.SENTRY_DSN) {
    const monitoring = app.get(MonitoringService);
    app.useGlobalFilters(new SentryExceptionFilter(monitoring));
  }

  // ==================== SWAGGER ====================
  const isProduction = process.env.NODE_ENV === 'production';
  if (!isProduction) {
    const config = new DocumentBuilder()
      .setTitle('Lexi API')
      .setDescription('AI-Powered Language Learning Platform')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('Auth', 'Authentication endpoints')
      .addTag('Users', 'User management')
      .addTag('Lessons', 'Language lessons')
      .addTag('AI Tutor', 'AI-powered tutoring')
      .addTag('Admin', 'Admin dashboard')
      .addTag('Payments', 'Subscription management')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  // ==================== START ====================
  const port = process.env.PORT || 8080;
  await app.listen(port, '0.0.0.0');

  console.log('=================================');
  console.log(`Lexi API v1 running on port ${port}`);
  if (!isProduction) {
    console.log(`Swagger docs: http://localhost:${port}/api/docs`);
  }
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('=================================');
}
bootstrap();
