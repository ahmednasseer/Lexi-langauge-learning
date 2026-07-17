import { Controller, Get, Post, Body, UseGuards, Request, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { StoreService } from './store.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Store')
@Controller('store')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class StoreController {
  constructor(private storeService: StoreService) {}

  @Get('items')
  @ApiOperation({ summary: 'List store items' })
  async getItems(@Request() req, @Query('category') category?: string) {
    return this.storeService.getItems(category);
  }

  @Get('inventory')
  @ApiOperation({ summary: 'Get user inventory' })
  async getInventory(@Request() req) {
    return this.storeService.getInventory(req.user.sub);
  }

  @Post('purchase')
  @ApiOperation({ summary: 'Purchase a store item' })
  async purchase(@Request() req, @Body() body: { itemId: string }) {
    return this.storeService.purchase(req.user.sub, body.itemId);
  }

  @Post('equip')
  @ApiOperation({ summary: 'Equip an owned item' })
  async equip(@Request() req, @Body() body: { itemId: string }) {
    return this.storeService.equip(req.user.sub, body.itemId);
  }
}
