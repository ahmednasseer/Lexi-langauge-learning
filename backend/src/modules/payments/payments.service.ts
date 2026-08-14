import { Injectable, BadRequestException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class PaymentsService {
  private stripe: Stripe | null = null;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
  ) {}

  private getStripe(): Stripe {
    if (!this.stripe) {
      const apiKey = this.config.get('STRIPE_SECRET_KEY');
      if (!apiKey || apiKey === 'sk_test_placeholder' || apiKey === 'sk_test_your-stripe-key') {
        throw new ServiceUnavailableException('Payment service is not configured. STRIPE_SECRET_KEY is missing.');
      }
      this.stripe = new Stripe(apiKey, { apiVersion: '2023-10-16' });
    }
    return this.stripe;
  }

  async createCheckoutSession(userId: string, planId: string) {
    const stripe = this.getStripe();
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new BadRequestException('User not found');

    const priceId = planId === 'yearly'
      ? this.config.get('STRIPE_PRICE_YEARLY')
      : this.config.get('STRIPE_PRICE_MONTHLY');

    const session = await stripe.checkout.sessions.create({
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

  /**
   * Verifies the Stripe webhook signature using the RAW request body.
   * The body must NOT be re-parsed/re-stringified before this call.
   *
   * Returns the verified Stripe event, or throws when the signature is
   * missing/invalid or when the webhook secret is not configured.
   */
  async verifyWebhookSignature(rawBody: Buffer, sig?: string): Promise<Stripe.Event> {
    const webhookSecret = this.config.get('STRIPE_WEBHOOK_SECRET');
    if (!webhookSecret || webhookSecret === 'whsec_your-webhook-secret' || webhookSecret === 'whsec_placeholder') {
      throw new ServiceUnavailableException('Stripe webhook secret is not configured. Live webhook verification is BLOCKED.');
    }

    if (!sig) {
      throw new BadRequestException('Missing Stripe signature');
    }

    // Use a minimal Stripe instance: constructEvent only needs the webhook secret,
    // not the publishable/secret key.
    const stripe = new Stripe('sk_test_dummy_for_construct_event', { apiVersion: '2023-10-16' });

    try {
      return stripe.webhooks.constructEvent(rawBody, sig, webhookSecret);
    } catch (err) {
      throw new BadRequestException(`Invalid Stripe signature: ${err.message ?? 'verification failed'}`);
    }
  }

  async handleWebhook(event: Stripe.Event) {
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session;
      const userId = session.metadata?.userId;
      const planId = session.metadata?.planId;

      if (!userId || !planId) {
        throw new Error('Missing metadata in session');
      }

      const externalId = session.subscription as string;
      if (!externalId) {
        throw new Error('Missing subscription id in session');
      }

      const endDate = new Date();
      endDate.setMonth(endDate.getMonth() + (planId === 'yearly' ? 12 : 1));

      // Idempotent processing: the same event (identified by its unique externalId)
      // must never credit/activate the subscription twice.
      await this.prisma.$transaction(async (tx) => {
        const existing = await tx.subscription.findUnique({
          where: { externalId },
        });
        if (existing) {
          return; // already processed
        }

        const subscription = await tx.subscription.create({
          data: {
            userId,
            planId,
            status: 'active',
            provider: 'stripe',
            externalId,
            endDate,
          },
        });

        await tx.user.update({
          where: { id: userId },
          data: { isPremium: true, subscriptionId: subscription.id, subscriptionEnd: endDate },
        });

        await tx.paymentTransaction.create({
          data: {
            userId,
            subscriptionId: subscription.id,
            amount: 0, // amount is not trusted from the client/payload
            currency: 'usd',
            status: 'completed',
            provider: 'stripe',
            externalId,
            metadata: { eventId: event.id, planId },
          },
        });
      });
    }

    if (event.type === 'customer.subscription.deleted') {
      const subscription = event.data.object as Stripe.Subscription;
      const sub = await this.prisma.subscription.findUnique({
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