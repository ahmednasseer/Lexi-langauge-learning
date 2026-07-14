import { Controller, Post, Get, Body, Req, UseGuards, RawBodyRequest } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Request } from 'express';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post('checkout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create checkout session' })
  async createCheckout(@Req() req, @Body() body: { planId: string }) {
    return this.paymentsService.createCheckoutSession(req.user.sub, body.planId);
  }

  @Post('webhook')
  @ApiOperation({ summary: 'Stripe webhook' })
  async webhook(@Req() req: RawBodyRequest<Request>) {
    const sig = req.headers['stripe-signature'];
    // In production, verify webhook signature
    await this.paymentsService.handleWebhook(req.body as any);
    return { received: true };
  }
}
