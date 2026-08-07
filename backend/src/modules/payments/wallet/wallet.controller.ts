import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Wallet')
@Controller('users/wallet')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class WalletController {
  constructor(private walletService: WalletService) {}

  @Get()
  @ApiOperation({ summary: 'Get wallet balance' })
  async getWallet(@Req() req) {
    return this.walletService.getWallet(req.user.sub);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get transaction history' })
  async getTransactions(@Req() req) {
    return this.walletService.getTransactions(req.user.sub);
  }

  @Post('spend')
  @ApiOperation({ summary: 'Spend gems' })
  async spendGems(@Req() req, @Body() body: { amount: number; description: string }) {
    return this.walletService.spendGems(req.user.sub, body.amount, body.description);
  }

  @Post('add')
  @ApiOperation({ summary: 'Add gems (admin reward)' })
  async addGems(@Req() req, @Body() body: { amount: number; description: string }) {
    return this.walletService.addGems(req.user.sub, body.amount, body.description);
  }
}
