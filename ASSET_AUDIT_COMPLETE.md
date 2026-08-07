# Lexi App — Audit شامل للأصول (Assets)

> تاريخ التحليل: يوليو 2026  
> المصادر: فحص كود المصدر + المسارات على القرص + وثائق المشروع

---

## 1. الأصول الموجودة فعلياً على القرص

| المسار | المحتوى |
|---|---|
| `assets/images/` | `.gitkeep` فقط (فاضي) |
| `assets/icons/` | `.gitkeep` فقط (فاضي) |
| `assets/animations/` | فاضي بالكامل |
| `assets/lottie/` | فاضي بالكامل |

**ملاحظة:** ملفات `LexiLogo.jpg` و `LexiCharchtar.jpg` المذكورة في `ASSET_REPORT.md` غير موجودة على القرص ولا في Git.

---

## 2. الأصول المصرّح بها في pubspec.yaml

| التصريح | الحالة |
|---|---|
| `assets/images/` | ✅ مصرّح به |
| `assets/icons/` | ✅ مصرّح به |
| `assets/animations/` | ❌ غير مصرّح |
| `assets/lottie/` | ❌ غير مصرّح |
| `fonts:` section | ❌ غير موجود (كل الخطوط عبر Google Fonts API) |

---

## 3. استخدام الأصول في الكود

| نوع الأصل | عدد مرات الاستخدام | الحالة |
|---|---|---|
| `Image.asset` / `AssetImage` | 0 | لا يوجد |
| `SvgPicture.asset` | 0 | لا يوجد |
| `Lottie.asset` | 0 | لا يوجد |
| `AudioPlayer.load` من assets | 0 | لا يوجد |
| `Icons.*` (Material icons) | 100+ | ✅ مستخدم حالياً |
| `GoogleFonts.poppins(...)` | 100+ | ✅ مستخدم حالياً |

---

## 4. البدائل المؤقتة المستخدمة حالياً (بدون أصول)

| العنصر | ما يستخدم بدلاً منه | أين |
|---|---|---|
| شخصية Lexi (الترحيب) | دائرة متدرجة + نص `Lexi` | `onboarding_screen.dart:263-321` |
| شخصية Lexi (الدعم) | مربع متدرج + حرف `L` | `support_screen.dart:77-156` |
| شخصية Lexi (AI Learning) | `Icons.person` في دائرة | `ai_learning_screen.dart:100` |
| الأفاتار (البروفايل) | أول حرف من اسم المستخدم | `profile_screen.dart:96-100` |
| معاينة الإطارات | `CustomPaint` + `Icons.person` | `frames_workshop_screen.dart:320-348` |
| معاينة الخلفيات | `LinearGradient` ملون | `backgrounds_shop_screen.dart` |
| معاينة المنتجات (متجر) | `Icons.person`, `Icons.crop_square`, إلخ | `store_item_card.dart:200-212` |
| العلم الألماني | 3 مستطيلات ملونة (أسود-أحمر-أصفر) | `onboarding_screen.dart:240-247` |
| Confetti (شهادات) | `AnimationController` + `CustomPainter` | `certificates_screen.dart` |
| Confetti (دفع ناجح) | `AnimationController` + `CustomPainter` | `success_screen.dart` |
| Splash screen | Emoji `🇩🇪` في Container أبيض | `splash_screen.dart:49-57` |
| مكافآت Streak/XP/Gems | `Icons.*` + ألوان متدرجة | مواقع متعددة |
| شارات المستويات | نص متدرج داخل Container | `onboarding_screen.dart:785-817` |

---

## 5. الأصول المطلوبة حسب الوثائق

### 5.1 شخصيات Lexi (8 — CRITICAL)

| الملف | الحجم | الاستخدام |
|---|---|---|
| `lexi_happy.png` | 512×512 | Onboarding welcome, correct answers |
| `lexi_thinking.png` | 512×512 | Level test, flashcards |
| `lexi_waving.png` | 512×512 | Onboarding screen 1 |
| `lexi_welcoming.png` | 512×512 | Level result screen |
| `lexi_studying.png` | 512×512 | Dashboard "Continue Learning" |
| `lexi_celebrating.png` | 512×512 | Certificate/achievement |
| `lexi_speaking.png` | 512×512 | AI Coach, speaking exercises |
| `lexi_listening.png` | 512×512 | Listening exercises |

### 5.2 أيقونات UI (20 — CRITICAL)

| الملف | الحجم | الاستخدام |
|---|---|---|
| `icon_germany.png` | 64×64 | علم ألمانيا |
| `icon_vocabulary.png` | 64×64 | قسم المفردات |
| `icon_grammar.png` | 64×64 | قسم القواعد |
| `icon_listening.png` | 64×64 | قسم الاستماع |
| `icon_speaking.png` | 64×64 | قسم التحدث |
| `icon_writing.png` | 64×64 | قسم الكتابة |
| `icon_certificate.png` | 64×64 | الشهادات |
| `icon_streak.png` | 64×64 | Streak fire |
| `icon_xp.png` | 64×64 | XP points |
| `icon_gems.png` | 64×64 | Gems currency |
| `icon_crown.png` | 64×64 | Premium badge |
| `icon_trophy.png` | 64×64 | Leaderboard |
| `icon_medal_gold.png` | 48×48 | 1st place |
| `icon_medal_silver.png` | 48×48 | 2nd place |
| `icon_medal_bronze.png` | 48×48 | 3rd place |
| `icon_passport.png` | 64×64 | Language Passport |
| `icon_search.png` | 64×64 | Search |
| `icon_inbox.png` | 64×64 | Inbox |
| `icon_notification.png` | 64×64 | Notifications |
| `icon_frames.png` | 64×64 | Frames workshop |
| `icon_background.png` | 64×64 | Backgrounds shop |

### 5.3 شارات المستويات (6 — CRITICAL)

| الملف | الحجم |
|---|---|
| `badge_a1.png` | 80×80 |
| `badge_a2.png` | 80×80 |
| `badge_b1.png` | 80×80 |
| `badge_b2.png` | 80×80 |
| `badge_c1.png` | 80×80 |
| `badge_c2.png` | 80×80 |

### 5.4 شارات الإنجازات (10 — HIGH)

| الملف | الحجم |
|---|---|
| `achievement_first_word.png` | 96×96 |
| `achievement_streak_7.png` | 96×96 |
| `achievement_streak_30.png` | 96×96 |
| `achievement_100_words.png` | 96×96 |
| `achievement_fluency.png` | 96×96 |
| `achievement_perfect_score.png` | 96×96 |
| `achievement_early_bird.png` | 96×96 |
| `achievement_night_owl.png` | 96×96 |
| `achievement_social.png` | 96×96 |
| `achievement_goethe.png` | 96×96 |

### 5.5 أجزاء الأفاتار (10 — HIGH)

| الملف | الحجم |
|---|---|
| `avatar_default.png` | 200×200 |
| `avatar_hair_1.png` | 200×200 |
| `avatar_hair_2.png` | 200×200 |
| `avatar_hair_3.png` | 200×200 |
| `avatar_shirt_1.png` | 200×200 |
| `avatar_shirt_2.png` | 200×200 |
| `avatar_shirt_3.png` | 200×200 |
| `avatar_accessory_glasses.png` | 200×200 |
| `avatar_accessory_hat.png` | 200×200 |
| `avatar_accessory_headphones.png` | 200×200 |

### 5.6 الإطارات (6 — HIGH)

| الملف | الحجم |
|---|---|
| `frame_gold.png` | 300×300 |
| `frame_silver.png` | 300×300 |
| `frame_neon.png` | 300×300 |
| `frame_diamond.png` | 300×300 |
| `frame_fire.png` | 300×300 |
| `frame_nature.png` | 300×300 |

### 5.7 الخلفيات (6 — MEDIUM)

| الملف | الحجم | الاستخدام |
|---|---|---|
| `bg_space.jpg` | 1080×1920 | خلفية profile/chat |
| `bg_ocean.jpg` | 1080×1920 | خلفية profile/chat |
| `bg_forest.jpg` | 1080×1920 | خلفية profile/chat |
| `bg_city.jpg` | 1080×1920 | خلفية profile/chat |
| `bg_mountain.jpg` | 1080×1920 | خلفية profile/chat |
| `bg_abstract.jpg` | 1080×1920 | خلفية profile/chat |

### 5.8 Lottie Animations (8 — LOW)

| الملف | الاستخدام |
|---|---|
| `lottie_confetti.json` | Achievement unlock |
| `lottie_streak.json` | Streak fire animation |
| `lottie_xp_gain.json` | XP gain popup |
| `lottie_gem_reward.json` | Gem reward |
| `lottie_success.json` | Correct answer checkmark |
| `lottie_loading.json` | Loading spinner |
| `lottie_microphone.json` | Speaking exercise mic |
| `lottie_wave.json` | Audio wave animation |

### 5.9 المؤثرات الصوتية (5 — LOW)

| الملف | المدة | الاستخدام |
|---|---|---|
| `sfx_correct.mp3` | 0.4s | Quiz correct |
| `sfx_wrong.mp3` | 0.4s | Quiz wrong |
| `sfx_levelup.mp3` | 0.8s | Level up |
| `sfx_gem.mp3` | 0.3s | Gem earned |
| `listening_a1_1.mp3` | varies | Listening exercises |

### 5.10 أصول إضافية من asset_generation_prompts.md

| الملف | الاستخدام |
|---|---|
| `lexi_teacher_happy.webp` | Home/Lessons mascot |
| `lexi_teacher_thinking.webp` | AI Coach |
| `lexi_teacher_celebrate.webp` | Success states |
| `frame_gold.webp` | Profile frame (gem store) |
| `frame_neon.webp` | Profile frame (premium) |
| `bg_cosmic.webp` | Chat/profile background |
| `bg_aurora.webp` | Chat/profile background (premium) |
| `badge_streak.webp` | Achievements |
| `badge_fluent.webp` | Achievements |
| `empty_friends.webp` | Friends empty state |
| `empty_inbox.webp` | Inbox empty state |
| `gem_pack.webp` | Shop item |
| `reward_card_premium.webp` | Premium reward |

---

## 6. ملخص إجمالي

| الفئة | العدد | الأولوية | موجود فعلياً |
|---|---|---|---|
| شخصيات | 8 | CRITICAL | ❌ 0 |
| أيقونات UI | 20 | CRITICAL | ❌ 0 |
| شارات مستويات | 6 | CRITICAL | ❌ 0 |
| شارات إنجازات | 10 | HIGH | ❌ 0 |
| أجزاء أفاتار | 10 | HIGH | ❌ 0 |
| إطارات | 6 | HIGH | ❌ 0 |
| خلفيات | 6 | MEDIUM | ❌ 0 |
| Lottie | 8 | LOW | ❌ 0 |
| مؤثرات صوتية | 5 | LOW | ❌ 0 |
| أصول إضافية | 13 | VARIES | ❌ 0 |
| **المجموع الكلي** | **92** | | **0/92** |

---

## 7. الإجراءات المطلوبة

### عاجل (لربط الأصول)
1. **إضافة الملفات** إلى المجلدات الصحيحة تحت `assets/`
2. **تحديث `pubspec.yaml`** ليشمل كل مجلدات الأصول الجديدة:
   ```yaml
   assets:
     - assets/images/
     - assets/icons/
     - assets/animations/
     - assets/lottie/
     - assets/fonts/    # إذا أضفنا خطوط محلية
   ```
3. **تحديث الكود** في الـ 100+ موقع يستخدم حالياً `Icons.*` ليستخدم `Image.asset()`
4. **إضافة خطوط Poppins محلياً** لتفادي الاعتماد على CDN (راجع `fonts_report.md`)
5. **ربط Lottie** بدلاً من CustomPainter في `certificates_screen.dart` و `success_screen.dart`
6. **ربط الصوت** عبر `AudioPlayer` من `assets/audio/`

### هيكل المجلدات المقترح بعد إضافة الأصول
```
assets/
├── images/
│   ├── characters/     → lexi_happy.png, lexi_thinking.png, ...
│   ├── icons/          → icon_germany.png, icon_vocabulary.png, ...
│   ├── badges/         → badge_a1.png, badge_a2.png, ...
│   ├── achievements/   → achievement_first_word.png, ...
│   ├── avatars/        → avatar_default.png, avatar_hair_1.png, ...
│   ├── frames/         → frame_gold.png, frame_silver.png, ...
│   ├── backgrounds/    → bg_space.jpg, bg_ocean.jpg, ...
│   └── empty/          → empty_friends.png, empty_inbox.png
├── icons/              → (أيقونات إضافية)
├── lottie/             → confetti.json, success_check.json, ...
├── animations/         → (رسوم متحركة مستقبلية)
├── audio/              → sfx_correct.mp3, sfx_wrong.mp3, ...
└── fonts/              → Poppins-Regular.ttf, Poppins-Bold.ttf, ...
```
