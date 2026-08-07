const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

const serviceAccountPath = path.join(__dirname, 'lexi-33b14-firebase-adminsdk-fbsvc-133d5568e2.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

async function uploadAll() {
  console.log('=== Uploading All Data to Firestore ===\n');

  // 1. Curriculum (already done, but included for completeness)
  console.log('[1/15] Curriculum...');
  const projectRoot = path.join(__dirname, '..');
  const curriculum = JSON.parse(fs.readFileSync(path.join(projectRoot, 'assets/data/curriculum_a1.json'), 'utf8'));
  for (const unit of curriculum.units) {
    await db.collection('curriculum').doc('a1').collection('units').doc(unit.id).set(unit);
    for (const lesson of unit.lessons) {
      await db.collection('curriculum').doc('a1').collection('units').doc(unit.id).collection('lessons').doc(lesson.id).set(lesson);
    }
  }

  // 2. Questions
  console.log('[2/15] Questions...');
  const questions = JSON.parse(fs.readFileSync(path.join(projectRoot, 'assets/data/questions_a1.json'), 'utf8'));
  const qBatch = db.batch();
  questions.questions.forEach(q => {
    qBatch.set(db.collection('questions').doc('a1').collection('questions').doc(q.id), q);
  });
  await qBatch.commit();

  // 3. Audio Lessons
  console.log('[3/15] Audio Lessons...');
  const audioData = [
    { id: 'audio_1', lessonId: 'L1_1', title: 'Begrüßungen', url: 'https://example.com/audio/greetings.mp3', duration: 120 },
    { id: 'audio_2', lessonId: 'L1_2', title: 'Zahlen 1-20', url: 'https://example.com/audio/numbers.mp3', duration: 180 },
    { id: 'audio_3', lessonId: 'L2_1', title: 'Familie', url: 'https://example.com/audio/family.mp3', duration: 150 },
    { id: 'audio_4', lessonId: 'L3_1', title: 'Uhrzeit', url: 'https://example.com/audio/time.mp3', duration: 200 },
  ];
  for (const audio of audioData) {
    await db.collection('audio').doc(audio.id).set(audio);
  }

  // 4. Pronunciation
  console.log('[4/15] Pronunciation...');
  const pronunciationData = [
    { id: 'pron_1', word: 'Hallo', phonetic: 'haˈloː', audioUrl: 'https://example.com/pron/hallo.mp3', lessonId: 'L1_1' },
    { id: 'pron_2', word: 'Guten Tag', phonetic: 'ˈɡuːtn̩ taːk', audioUrl: 'https://example.com/pron/gutentag.mp3', lessonId: 'L1_1' },
    { id: 'pron_3', word: 'Tschüss', phonetic: 'tʃʏs', audioUrl: 'https://example.com/pron/tschuss.mp3', lessonId: 'L1_1' },
    { id: 'pron_4', word: 'Familie', phonetic: 'faˈmiːli̯ə', audioUrl: 'https://example.com/pron/familie.mp3', lessonId: 'L2_1' },
    { id: 'pron_5', word: 'Haus', phonetic: 'haʊ̯s', audioUrl: 'https://example.com/pron/haus.mp3', lessonId: 'L1_4' },
  ];
  for (const pron of pronunciationData) {
    await db.collection('pronunciation').doc(pron.id).set(pron);
  }

  // 5. Speaking / Conversation
  console.log('[5/15] Speaking Exercises...');
  const speakingData = [
    { id: 'speak_1', lessonId: 'L1_1', scenario: 'Vorstellung', prompt: 'Stellen Sie sich vor. Wie heißen Sie?', difficulty: 'easy' },
    { id: 'speak_2', lessonId: 'L1_1', scenario: 'Begrüßung', prompt: 'Begrüßen Sie einen Freund.', difficulty: 'easy' },
    { id: 'speak_3', lessonId: 'L2_1', scenario: 'Familie', prompt: 'Beschreiben Sie Ihre Familie.', difficulty: 'medium' },
    { id: 'speak_4', lessonId: 'L4_2', scenario: 'Im Restaurant', prompt: 'Bestellen Sie ein Essen.', difficulty: 'medium' },
  ];
  for (const speak of speakingData) {
    await db.collection('speaking').doc(speak.id).set(speak);
  }

  // 6. Store Items
  console.log('[6/15] Store Items...');
  const storeItems = [
    { id: 'frame_gold', type: 'frame', name: 'Goldener Rahmen', price: 500, currency: 'gems', rarity: 'rare' },
    { id: 'frame_silver', type: 'frame', name: 'Silberner Rahmen', price: 200, currency: 'gems', rarity: 'common' },
    { id: 'frame_diamond', type: 'frame', name: 'Diamant Rahmen', price: 1000, currency: 'gems', rarity: 'legendary' },
    { id: 'bg_space', type: 'background', name: 'Weltraum', price: 300, currency: 'gems', rarity: 'rare' },
    { id: 'bg_ocean', type: 'background', name: 'Ozean', price: 200, currency: 'gems', rarity: 'common' },
    { id: 'avatar_bird', type: 'avatar', name: 'Papagei', price: 150, currency: 'gems', rarity: 'common' },
    { id: 'avatar_student', type: 'avatar', name: 'Student', price: 100, currency: 'gems', rarity: 'common' },
  ];
  for (const item of storeItems) {
    await db.collection('store').doc(item.id).set(item);
  }

  // 7. Daily Missions
  console.log('[7/15] Daily Missions...');
  const missions = [
    { id: 'mission_1', title: 'Lektion abschließen', description: 'Schließen Sie eine Lektion ab', reward: { xp: 50, gems: 10 }, type: 'daily' },
    { id: 'mission_2', title: '5 Wörter lernen', description: 'Lernen Sie 5 neue Wörter', reward: { xp: 30, gems: 5 }, type: 'daily' },
    { id: 'mission_3', title: 'Quiz machen', description: 'Machen Sie ein Quiz', reward: { xp: 20, gems: 5 }, type: 'daily' },
    { id: 'mission_4', title: 'Sprechen üben', description: 'Üben Sie 5 Minuten Sprechen', reward: { xp: 40, gems: 8 }, type: 'daily' },
  ];
  for (const mission of missions) {
    await db.collection('daily_missions').doc(mission.id).set(mission);
  }

  // 8. Events
  console.log('[8/15] Events...');
  const events = [
    { id: 'event_1', title: 'Winter Challenge', description: 'Mach 7 Tage am Stück mit!', reward: { xp: 500, gems: 100 }, startDate: '2026-01-01', endDate: '2026-01-31' },
    { id: 'event_2', title: 'Goethe Vorbereitung', description: 'Bereite dich auf Goethe A1 vor', reward: { xp: 300, gems: 50 }, startDate: '2026-02-01', endDate: '2026-02-28' },
  ];
  for (const event of events) {
    await db.collection('events').doc(event.id).set(event);
  }

  // 9. Achievements
  console.log('[9/15] Achievements...');
  const achievements = [
    { id: 'ach_first_word', title: 'Erstes Wort', description: 'Lerne dein erstes Wort', icon: '📚', condition: 'words_learned >= 1', reward: { xp: 10, gems: 5 } },
    { id: 'ach_100_words', title: '100 Wörter', description: 'Lerne 100 Wörter', icon: '📖', condition: 'words_learned >= 100', reward: { xp: 100, gems: 50 } },
    { id: 'ach_streak_7', title: '7 Tage Serie', description: '7 Tage am Stück gelernt', icon: '🔥', condition: 'streak >= 7', reward: { xp: 70, gems: 20 } },
    { id: 'ach_streak_30', title: '30 Tage Serie', description: '30 Tage am Stück gelernt', icon: '🔥', condition: 'streak >= 30', reward: { xp: 300, gems: 100 } },
    { id: 'ach_first_lesson', title: 'Erste Lektion', description: 'Schließe deine erste Lektion ab', icon: '🎓', condition: 'lessons_completed >= 1', reward: { xp: 20, gems: 10 } },
    { id: 'ach_goethe_a1', title: 'Goethe A1', description: 'Bestehe die Goethe A1 Prüfung', icon: '🏆', condition: 'goethe_a1_passed == true', reward: { xp: 500, gems: 200 } },
  ];
  for (const ach of achievements) {
    await db.collection('achievements').doc(ach.id).set(ach);
  }

  // 10. Goethe Exams
  console.log('[10/15] Goethe Exams...');
  const exams = [
    { id: 'goethe_a1', level: 'A1', title: 'Goethe-Zertifikat A1', sections: ['Lesen', 'Hören', 'Schreiben', 'Sprechen'], duration: 60 },
  ];
  for (const exam of exams) {
    await db.collection('exams').doc(exam.id).set(exam);
  }

  // 11. Flashcard Decks
  console.log('[11/15] Flashcard Decks...');
  const flashcardDecks = [
    { id: 'deck_1', title: 'Grundwortschatz', lessonId: 'L1_1', wordCount: 10 },
    { id: 'deck_2', title: 'Familie', lessonId: 'L2_1', wordCount: 10 },
    { id: 'deck_3', title: 'Zahlen', lessonId: 'L3_1', wordCount: 20 },
    { id: 'deck_4', title: 'Essen', lessonId: 'L4_1', wordCount: 15 },
  ];
  for (const deck of flashcardDecks) {
    await db.collection('flashcards').doc(deck.id).set(deck);
  }

  // 12. Daily Quests
  console.log('[12/15] Daily Quests...');
  const quests = [
    { id: 'quest_1', title: 'Täglicher Lerner', description: 'Lerne etwas Neues heute', reward: { xp: 25, gems: 5 }, difficulty: 'easy' },
    { id: 'quest_2', title: 'Quiz Master', description: 'Beantworte 5 Fragen richtig', reward: { xp: 50, gems: 10 }, difficulty: 'medium' },
    { id: 'quest_3', title: 'Sprechkünstler', description: 'Übe 10 Minuten Sprechen', reward: { xp: 40, gems: 8 }, difficulty: 'medium' },
    { id: 'quest_4', title: 'Perfektionist', description: 'Mach ein Quiz mit 100%', reward: { xp: 100, gems: 25 }, difficulty: 'hard' },
  ];
  for (const quest of quests) {
    await db.collection('quests').doc(quest.id).set(quest);
  }

  // 13. Seasonal Events
  console.log('[13/15] Seasonal Events...');
  const seasonalEvents = [
    { id: 'seasonal_winter', title: 'Winter Challenge 2026', description: 'Lerne Deutsch im Winter', startMonth: 12, endMonth: 2, reward: { xp: 1000, gems: 200 } },
    { id: 'seasonal_summer', title: 'Sommer Lernen', description: 'Lerne Deutsch im Sommer', startMonth: 6, endMonth: 8, reward: { xp: 1000, gems: 200 } },
  ];
  for (const seasonal of seasonalEvents) {
    await db.collection('seasonal').doc(seasonal.id).set(seasonal);
  }

  // 14. Growth / Levels
  console.log('[14/15] Growth System...');
  const levels = [
    { level: 1, title: 'Anfänger', minXp: 0, maxXp: 100 },
    { level: 2, title: 'Fortgeschrittener', minXp: 100, maxXp: 300 },
    { level: 3, title: 'Profi', minXp: 300, maxXp: 600 },
    { level: 4, title: 'Meister', minXp: 600, maxXp: 1000 },
    { level: 5, title: 'Experte', minXp: 1000, maxXp: 10000 },
  ];
  for (const level of levels) {
    await db.collection('levels').doc(`level_${level.level}`).set(level);
  }

  // 15. Referral Rewards
  console.log('[15/15] Referral System...');
  const referralRewards = [
    { referrals: 1, reward: { gems: 50, xp: 100 } },
    { referrals: 5, reward: { gems: 200, xp: 500 } },
    { referrals: 10, reward: { gems: 500, xp: 1000 } },
  ];
  await db.collection('settings').doc('referral').set({ tiers: referralRewards });

  console.log('\n=== All Data Uploaded Successfully! ===');
  process.exit(0);
}

uploadAll().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
