import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const langs = await prisma.language.findMany();
  const levels = await prisma.lesson.findMany({ select: { level: true } });
  const pubLessons = await prisma.lesson.count({ where: { isPublished: true } });
  const totalLessons = await prisma.lesson.count();
  const vocab = await prisma.vocabulary.count();
  const grammar = await prisma.grammarRule.count();
  const grammarByLesson = await prisma.grammarRule.findMany({
    select: { lessonId: true, title: true },
  });
  const quiz = await prisma.quizQuestion.count();
  const users = await prisma.user.count();
  
  console.log(JSON.stringify({
    languages: langs.length,
    languageCodes: langs.map(l => l.code),
    levels: [...new Set(levels.map(l => l.level))],
    publishedLessons: pubLessons,
    totalLessons,
    vocabulary: vocab,
    grammarRules: grammar,
    grammarByLesson,
    quizQuestions: quiz,
    users
  }, null, 2));
}

main()
  .catch(e => { console.error(e); process.exit(1); })
  .finally(async () => await prisma.$disconnect());
