import { Module } from '@nestjs/common';
import { GoetheController } from './goethe.controller';
import { GoetheService } from './goethe.service';
import { PrismaService } from '../../config/prisma.service';

@Module({
  controllers: [GoetheController],
  providers: [GoetheService, PrismaService],
  exports: [GoetheService],
})
export class GoetheModule {}
