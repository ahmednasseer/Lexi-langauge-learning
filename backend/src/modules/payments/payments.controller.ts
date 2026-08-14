import { Controller, Post, Get, Body, Req, UseGuards, RawBodyRequest, HttpCode, HttpStatus, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { SubscriptionsService } from './subscriptions/subscriptions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Request } from 'express';
import { CheckoutDto } from './dto/checkout.dto';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  constructor(
    private paymentsService: PaymentsService,
    private subscriptionsService: SubscriptionsService,
  ) {}

  @Post('checkout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create checkout session' })
  async createCheckout(@Req() req, @Body() body: CheckoutDto) {
    return this.paymentsService.createCheckoutSession(req.user.sub, body.planId);
  }

  @Get('subscription')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get active subscription' })
  async getSubscription(@Req() req) {
    return this.subscriptionsService.getSubscription(req.user.sub);
  }

  @Post('subscription/cancel')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cancel active subscription' })
  async cancelSubscription(@Req() req) {
    return this.subscriptionsService.cancelSubscription(req.user.sub);
  }

  @Post('webhook')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Stripe webhook' })
  async webhook(@Req() req: RawBodyRequest<Request>) {
    const sigHeader = req.headers['stripe-signature'];
    const sig = Array.isArray(sigHeader) ? sigHeader[0] : sigHeader;

    // Raw body is required for signature verification. Do NOT re-parse/stringify.
    const rawBody = req.rawBody ?? (req.body === undefined ? undefined : Buffer.from(JSON.stringify(req.body)));
    if (!rawBody || rawBody.length === 0) {
      throw new BadRequestException('Missing request body');
    }

    const event = await this.paymentsService.verifyWebhookSignature(rawBody, sig);
    await this.paymentsService.handleWebhook(event);
    return { received: true };
  }
}
