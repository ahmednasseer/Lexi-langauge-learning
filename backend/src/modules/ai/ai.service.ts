import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class AiService {
  private openai: OpenAI;
  private readonly MAX_FREE_MESSAGES = 10;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
  ) {
    this.openai = new OpenAI({
      apiKey: this.config.get('OPENAI_API_KEY'),
    });
  }

  async chat(userId: string, message: string, learningLanguage: string, nativeLanguage: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    if (!user.isPremium) {
      const todayMessages = await this.prisma.chatHistory.count({
        where: {
          userId,
          createdAt: { gte: new Date(new Date().setHours(0, 0, 0, 0)) },
        },
      });
      if (todayMessages >= this.MAX_FREE_MESSAGES) {
        throw new BadRequestException('Daily free message limit reached. Upgrade to Premium for unlimited.');
      }
    }

    const history = await this.prisma.chatHistory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });

    const messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
      { role: 'system', content: this.systemPrompt(learningLanguage, nativeLanguage) },
      ...history.reverse().flatMap(h => [
        { role: 'user' as const, content: h.message },
        { role: 'assistant' as const, content: h.aiResponse },
      ]),
      { role: 'user', content: message },
    ];

    const completion = await this.openai.chat.completions.create({
      model: this.config.get('OPENAI_MODEL', 'gpt-4o-mini'),
      messages,
      max_tokens: 500,
      temperature: 0.7,
    });

    const aiResponse = completion.choices[0].message.content;
    const tokensUsed = completion.usage?.total_tokens || 0;

    let correction: string | null = null;
    let explanation: string | null = null;

    if (this.hasGrammarError(message)) {
      correction = this.extractCorrection(aiResponse);
      explanation = this.extractExplanation(aiResponse);
    }

    await this.prisma.chatHistory.create({
      data: { userId, message, aiResponse, correction, explanation, tokensUsed },
    });

    return { response: aiResponse, correction, explanation, tokensUsed };
  }

  async getChatHistory(userId: string, limit = 50) {
    return this.prisma.chatHistory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async clearChatHistory(userId: string) {
    await this.prisma.chatHistory.deleteMany({ where: { userId } });
    return { success: true };
  }

  private systemPrompt(learning: string, native: string) {
    return `You are a friendly and professional language tutor for someone learning ${learning}.
Their native language is ${native}.

RULES:
1. Always respond in ${learning} with clear, simple sentences.
2. If the user makes grammar mistakes, gently correct them and explain WHY.
3. Keep responses conversational and encouraging (2-4 sentences).
4. Use emoji occasionally to make conversations friendly.
5. When explaining grammar, provide clear examples.
6. Adapt vocabulary to the user's level.
7. Suggest new vocabulary and phrases when appropriate.
8. Be patient, supportive, and professional.
9. If asked to explain a rule, give 2-3 examples.
10. Correct format for corrections:
   - State the correct sentence
   - Explain the grammar rule
   - Give a similar example`;
  }

  private hasGrammarError(message: string): boolean {
    const patterns = [
      /yesterday.*\bgo\b/i, /\bI is\b/i, /\bhe are\b/i, /\bthey is\b/i,
      /\bshe are\b/i, /\bwe is\b/i, /\bdoes.*didn/i, /\bmore better\b/i,
    ];
    return patterns.some(p => p.test(message));
  }

  private extractCorrection(response: string): string | null {
    const match = response.match(/(?:Correct|correction)[\s\S]*?:\s*(.+?)(?:\.|$)/i);
    return match ? match[1] : null;
  }

  private extractExplanation(response: string): string | null {
    const match = response.match(/(?:because|since|explanation)[\s\S]*?:\s*(.+?)(?:\.|$)/i);
    return match ? match[1] : null;
  }
}
