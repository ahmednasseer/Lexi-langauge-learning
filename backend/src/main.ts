import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { RedisService } from './config/redis.service';
import { SentryExceptionFilter } from './common/filters/sentry.filter';
import { MonitoringService } from './common/monitoring/monitoring.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  // ==================== SECURITY ====================
  app.use(helmet());
  app.setGlobalPrefix('api/v1');
  app.set('trust proxy', 1);

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
  const monitoring = app.get(MonitoringService);
  app.useGlobalFilters(new SentryExceptionFilter(monitoring));

  // ==================== SWAGGER ====================
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

  // ==================== START ====================
  const port = process.env.PORT || 3000;
  await app.listen(port);

  console.log('=================================');
  console.log(`Lexi API v1 running on http://localhost:${port}`);
  console.log(`Swagger docs: http://localhost:${port}/api/docs`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('=================================');
}
bootstrap();
