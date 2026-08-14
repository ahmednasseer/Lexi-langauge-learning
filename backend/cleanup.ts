import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.quizQuestion.deleteMany({});
  await prisma.grammarRule.deleteMany({});
  await prisma.vocabulary.deleteMany({});
  await prisma.lesson.deleteMany({});
  console.log('Cleaned up old curriculum data');
}

main()
  .catch(e => { console.error(e); process.exit(1); })
  .finally(async () => await prisma.$disconnect());
