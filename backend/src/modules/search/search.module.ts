import { Module } from '@nestjs/common';
import { SearchController } from './search.controller';
import { SearchService } from './search.service';
import { PrismaService } from '../../config/prisma.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [SearchController],
  providers: [SearchService, PrismaService],
  exports: [SearchService],
})
export class SearchModule {}
