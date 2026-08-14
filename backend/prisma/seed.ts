import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

interface CurriculumLesson {
  id: string;
  title: string;
  titleArabic: string;
  order: number;
  type: string;
  content: Record<string, unknown>;
}

interface CurriculumUnit {
  id: string;
  title: string;
  titleArabic: string;
  description: string;
  order: number;
  lessons: CurriculumLesson[];
}

interface Curriculum {
  version: string;
  language: string;
  level: string;
  title: string;
  description: string;
  units: CurriculumUnit[];
}

interface Question {
  id: string;
  lessonId?: string;
  type: string;
  level: string;
  question: string;
  options: string[];
  correctAnswer: string | number | boolean;
  explanation: string;
  audioUrl?: string;
}

interface QuestionBank {
  version: string;
  language: string;
  level: string;
  questionTypes: string[];
  questions: Question[];
}

function isGrammarItem(item: unknown, key?: string): item is { pronoun?: string; verbForm?: string; possessiv?: string; german?: string; arabic?: string; example?: string } {
  if (typeof item !== 'object' || item === null) return false;
  if (!('example' in item)) return false;
  if ('verbForm' in item || 'possessiv' in item) return true;
  // Prepositions are grammar items when in a key named 'prepositions'
  if (key === 'prepositions' && 'german' in item) return true;
  return false;
}

function isVocabItem(item: unknown): item is { german: string; arabic: string; example?: string; article?: string; female?: string } {
  return typeof item === 'object' && item !== null && 'german' in item && 'arabic' in item;
}

function extractLessonId(question: Question): string {
  if (question.lessonId && question.lessonId.trim().length > 0) {
    return question.lessonId.trim();
  }
  const parts = question.id.split('_');
  if (parts.length >= 2 && parts[0] === 'L') {
    const unitNum = parts[0].substring(1);
    const lessonNum = parts[1];
    return `L${unitNum}_${lessonNum}`;
  }
  return 'default';
}

async function main() {
  const curriculumPath = path.resolve(__dirname, '../../assets/data/curriculum_a1.json');
  const questionsPath = path.resolve(__dirname, '../../assets/data/questions_a1.json');

  const curriculum: Curriculum = JSON.parse(
    fs.readFileSync(curriculumPath, 'utf-8'),
  );
  const questionBank: QuestionBank = JSON.parse(
    fs.readFileSync(questionsPath, 'utf-8'),
  );

  const language = await prisma.language.upsert({
    where: { code: 'de' },
    update: {},
    create: {
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
      isActive: true,
    },
  });

  const vocabByLesson = new Map<string, Array<{ german: string; arabic: string; example: string; article?: string; female?: string }>>();
  const grammarByLesson = new Map<string, Array<{ pronoun?: string; verbForm?: string; possessiv?: string; german?: string; arabic?: string; example?: string }>>();
  const quizByLesson = new Map<string, Question[]>();

  for (const unit of curriculum.units) {
    for (const lesson of unit.lessons) {
      const content = lesson.content as Record<string, unknown>;
      const vocab: Array<{ german: string; arabic: string; example: string; article?: string; female?: string }> = [];

      for (const [_key, value] of Object.entries(content)) {
        if (Array.isArray(value)) {
          for (const item of value) {
            if (isGrammarItem(item, _key)) {
              const existing = grammarByLesson.get(lesson.id) ?? [];
              existing.push({
                pronoun: item.pronoun ?? item.german ?? '',
                verbForm: item.verbForm ?? item.possessiv ?? '',
                german: item.german,
                arabic: item.arabic,
                example: item.example ?? '',
              });
              grammarByLesson.set(lesson.id, existing);
            } else if (isVocabItem(item)) {
              vocab.push({
                german: item.german,
                arabic: item.arabic,
                example: item.example ?? '',
                article: item.article,
                female: item.female,
              });
            }
          }
        }
      }

      vocabByLesson.set(lesson.id, vocab);
    }
  }

  for (const q of questionBank.questions) {
    const lessonId = extractLessonId(q);
    const existing = quizByLesson.get(lessonId) ?? [];
    existing.push(q);
    quizByLesson.set(lessonId, existing);
  }

  for (const unit of curriculum.units) {
    for (const lesson of unit.lessons) {
      const vocab = vocabByLesson.get(lesson.id) ?? [];
      const grammar = grammarByLesson.get(lesson.id) ?? [];
      const quiz = quizByLesson.get(lesson.id) ?? [];

      const categoryMap: Record<string, string> = {
        vocabulary: 'Vocabulary',
        grammar: 'Grammar',
        listening: 'Listening',
        speaking: 'Speaking',
      };
      const category = categoryMap[lesson.type] ?? 'Vocabulary';
      const xpReward = lesson.type === 'vocabulary' ? 50 : lesson.type === 'grammar' ? 60 : 50;

       try {
        await prisma.lesson.upsert({
          where: { id: lesson.id },
          update: {
            title: lesson.title,
            description: lesson.titleArabic,
            level: curriculum.level,
            category,
            orderIndex: lesson.order,
            isPublished: true,
            content: lesson.content as any,
            xpReward,
          },
          create: {
            id: lesson.id,
            language: { connect: { id: language.id } },
            title: lesson.title,
            description: lesson.titleArabic,
            level: curriculum.level,
            category,
            content: lesson.content as any,
            xpReward,
            orderIndex: lesson.order,
            isPublished: true,
          },
        });

        await prisma.vocabulary.deleteMany({ where: { lessonId: lesson.id } });
        for (let i = 0; i < vocab.length; i++) {
          const v = vocab[i];
          await prisma.vocabulary.create({
            data: {
              lessonId: lesson.id,
              word: v.german,
              translation: v.arabic,
              pronunciation: v.german,
              example: v.example,
              exampleTranslation: '',
              orderIndex: i,
            },
          });
        }

        await prisma.grammarRule.deleteMany({ where: { lessonId: lesson.id } });
        if (grammar.length > 0) {
          const examples = grammar.map((g) => g.example ?? '');
          const title = grammar[0].pronoun ?? grammar[0].german ?? grammar[0].verbForm ?? '';
          const explanationParts = grammar.map((g) => {
            if (g.pronoun && g.verbForm) return `${g.pronoun} ${g.verbForm}`;
            if (g.german && g.arabic) return `${g.german} = ${g.arabic}`;
            return g.verbForm ?? g.possessiv ?? '';
          });
          const explanation = explanationParts.join(', ');
          await prisma.grammarRule.create({
            data: {
              lessonId: lesson.id,
              title,
              explanation,
              examples,
            },
          });
        }

        await prisma.quizQuestion.deleteMany({ where: { lessonId: lesson.id } });
        for (let i = 0; i < quiz.length; i++) {
          const q = quiz[i];
          let correctAnswerStr: string;
          let options: string[];
          if (typeof q.correctAnswer === 'number') {
            correctAnswerStr = q.options[q.correctAnswer] ?? '';
            options = q.options;
          } else if (typeof q.correctAnswer === 'boolean') {
            correctAnswerStr = q.correctAnswer.toString();
            options = ['true', 'false'];
          } else {
            correctAnswerStr = q.correctAnswer;
            options = q.options;
          }
          await prisma.quizQuestion.create({
            data: {
              lessonId: lesson.id,
              question: q.question,
              correctAnswer: correctAnswerStr,
              options: options,
              explanation: q.explanation,
              type: q.type,
              orderIndex: i,
            },
          });
        }
      } catch (e) {
        console.error(`Failed to seed lesson ${lesson.id}:`, e);
        continue;
      }
    }
  }

  const totalLessons = curriculum.units.reduce((acc, u) => acc + u.lessons.length, 0);
  console.log('Seed complete:');
  console.log(`  Language: ${language.name}`);
  console.log(`  Units: ${curriculum.units.length}`);
  console.log(`  Lessons: ${totalLessons}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
