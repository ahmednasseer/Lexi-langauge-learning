const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccountPath = path.join(__dirname, 'lexi-33b14-firebase-adminsdk-fbsvc-133d5568e2.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

async function uploadData() {
  console.log('Uploading curriculum...');
  
  // Upload curriculum
  const curriculumData = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../assets/data/curriculum_a1.json'), 'utf8')
  );

  for (const unit of curriculumData.units) {
    await db.collection('curriculum').doc('a1').collection('units').doc(unit.id).set(unit);
    console.log(`  ✓ Unit: ${unit.title}`);
    
    for (const lesson of unit.lessons) {
      await db.collection('curriculum').doc('a1').collection('units').doc(unit.id).collection('lessons').doc(lesson.id).set(lesson);
    }
  }

  console.log('Uploading questions...');
  
  // Upload questions
  const questionsData = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../assets/data/questions_a1.json'), 'utf8')
  );

  let batch = db.batch();
  let count = 0;

  for (const question of questionsData.questions) {
    const ref = db.collection('questions').doc('a1').collection('questions').doc(question.id);
    batch.set(ref, question);
    count++;

    if (count % 500 === 0) {
      await batch.commit();
      console.log(`  ✓ Uploaded ${count} questions`);
      batch = db.batch();
    }
  }

  if (count % 500 !== 0) {
    await batch.commit();
  }

  if (count % 500 !== 0) {
    await batch.commit();
  }
  console.log(`  ✓ Uploaded ${questionsData.questions.length} questions total`);

  console.log('\nDone! Data uploaded to Firestore.');
  process.exit(0);
}

uploadData().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
