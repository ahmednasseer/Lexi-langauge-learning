import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class PaymentsService {
  private stripe: Stripe;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
  ) {
    this.stripe = new Stripe(this.config.get('STRIPE_SECRET_KEY'), { apiVersion: '2024-06-20' });
  }

  async createCheckoutSession(userId: string, planId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new BadRequestException('User not found');

    const priceId = planId === 'yearly'
      ? this.config.get('STRIPE_PRICE_YEARLY')
      : this.config.get('STRIPE_PRICE_MONTHLY');

    const session = await this.stripe.checkout.sessions.create({
      customer_email: user.email,
      payment_method_types: ['card'],
      line_items: [{ price: priceId, quantity: 1 }],
      mode: 'subscription',
      success_url: `${this.config.get('APP_URL')}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${this.config.get('APP_URL')}/payment/cancel`,
      metadata: { userId, planId },
    });

    return { sessionId: session.id, url: session.url };
  }

  async handleWebhook(event: Stripe.Event) {
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session;
      const userId = session.metadata.userId;
      const planId = session.metadata.planId;

      const endDate = new Date();
      endDate.setMonth(endDate.getMonth() + (planId === 'yearly' ? 12 : 1));

      await this.prisma.subscription.create({
        data: {
          userId,
          planId,
          status: 'active',
          provider: 'stripe',
          externalId: session.subscription as string,
          endDate,
        },
      });

      await this.prisma.user.update({
        where: { id: userId },
        data: { isPremium: true, subscriptionEnd: endDate },
      });
    }

    if (event.type === 'customer.subscription.deleted') {
      const subscription = event.data.object as Stripe.Subscription;
      const sub = await this.prisma.subscription.findFirst({
        where: { externalId: subscription.id },
      });
      if (sub) {
        await this.prisma.subscription.update({
          where: { id: sub.id },
          data: { status: 'cancelled', cancelledAt: new Date() },
        });
        await this.prisma.user.update({
          where: { id: sub.userId },
          data: { isPremium: false },
        });
      }
    }
  }
}
