import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class AiLearningPlanService {
  private openai: OpenAI;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
  ) {
    this.openai = new OpenAI({ apiKey: this.config.get('OPENAI_API_KEY') });
  }

  async generatePlan(userId: string, data: {
    goal: string;
    level: string;
    language: string;
    dailyMinutes: number;
  }) {
    const prompt = `Create a personalized 30-day learning plan for a ${data.level} level student learning ${data.language}.
Goal: ${data.goal}
Available time: ${data.dailyMinutes} minutes per day

Return a JSON object with this exact structure:
{
  "title": "Plan title",
  "description": "Brief description",
  "weeks": [
    {
      "week": 1,
      "days": [
        {
          "day": 1,
          "focus": "Vocabulary",
          "tasks": ["Learn 10 new words", "Complete exercise"],
          "estimatedMinutes": ${data.dailyMinutes}
        }
      ]
    }
  ]
}

Make the plan progressive, starting with basics and building up.
Focus on the student's goal (${data.goal}).`;

    const completion = await this.openai.chat.completions.create({
      model: this.config.get('OPENAI_MODEL', 'gpt-4o-mini'),
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 2000,
      temperature: 0.7,
      response_format: { type: 'json_object' },
    });

    const planData = JSON.parse(completion.choices[0].message.content);

    const plan = await this.prisma.learningPlan.create({
      data: {
        userId,
        title: planData.title,
        description: planData.description,
        planData: planData,
      },
    });

    return plan;
  }

  async getUserPlan(userId: string) {
    return this.prisma.learningPlan.findFirst({
      where: { userId, isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
