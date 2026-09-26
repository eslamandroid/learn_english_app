# تطبيق تعلم الإنجليزية — خطة التحويل لـ Flutter والتوسع العالمي (v2)

> هذا الملف هو المرجع الرئيسي للمشروع. اقرأه كاملًا قبل أي كود. أي تعارض بين الكود الحالي وهذا الملف يُحسم لصالح هذا الملف. النسخة v2 تحل محل النسخة الأولى بالكامل.
>
> **تاريخ:** 2026-09-26 — **الحالة:** متفق عليه، جاهز للتنفيذ عبر ملفات `tasks/`.

---

## 0. الحالة الحالية للكود (نقطة البداية)

الكود الموجود في `lib/` (~338 ملف، ~29.6k سطر) **ليس مسودة** — هو أساس نبني عليه:

| الوحدة | الحالة | ملاحظات |
|---|---|---|
| البنية | ✅ | Clean Architecture + BLoC، injectable/get_it، go_router بـ `StatefulShellRoute` (5 تابات)، l10n ar/en، Firebase Crashlytics/Analytics |
| DB | ✅ | **sqflite** عبر `core/database/database_helper.dart`، تُنسخ من asset عند أول تشغيل |
| Phonetics | ✅ كامل | 53 ملف — list → topics → detail + progress |
| Grammar | ✅ كامل | 45 ملف — topics → lesson → test + progress |
| Vocabulary | 🟡 قراءة فقط | topics → subtopics → words + detail. لا practice ولا progress |
| Dashboard | 🟡 | grid الأقسام، اسم المستخدم placeholder |
| Settings / Language / Onboarding | ✅ | voice accent/gender + CEFR level موجودان في الإعدادات |
| Progress | 🟡 | grammar + phonetics فقط، مخزّن في SharedPreferences كـ JSON |
| Speech | ✅ | `core/speech/sentence_assessor.dart` — word-level alignment مع وزن أقل للـ function words. **أفضل من الوصف في الخطة القديمة، يُبقى كما هو** |
| Audio | 🟡 | `core/audio/` cache + player، لكن المصدر الحالي Google Translate TTS (غير رسمي) — **يُستبدل** |
| Sentences / Conversations / Word list | ❌ | `_PlaceholderScreen` |

**الكود القديم (Android native) مرجع للسلوك والمحتوى فقط، لا مصدر للكود.**

---

## 1. السياق

**التطبيق الحالي:** Android native على Google Play من 2018/2020، +100k تحميل، تقييم 4.6، آخر تحديث قديم جدًا. MAU ~1,000 — المشكلة **retention** لا محتوى.

**المحتوى:** SQLite ~7.5MB، 37 جدول، 6 modules:
- 2,514 كلمة (14 topic → 101 subtopic) + 5,586 كلمة CEFR A1–C2
- 2,089 جملة بقواعدها (20 → 100 subtopic)، مع عمود `answers` جاهز للتمارين
- 2,932 جملة محادثة في 138 درس / 14 مستوى، مع `start`/`end` وphonetic وترجمة
- قواعد normalized: 114 → 1,159 قاعدة → 2,284 مثال → 646 اختبار
- نطق: 967 section (us/uk) + 1,815 مثال
- **59,744 ملف صوتي × 4 أصوات (us/uk × male/female) — مرفوعة بالكامل على S3**، مسار الملف = `audio_files.file_path` (مثال `us_male/vocabulary/1.mp3`)
- الصوت **لكل جملة محادثة على حدة** (11,728 ملف)، ليس لكل درس

**الهدف:**
1. تحويل كامل لـ Flutter (Android + iOS) بتصميم جديد
2. التحول من **مكتبة محتوى** إلى **مسار تعلم يومي**
3. **Shadowing** offline بدون أي AI خارجي
4. جاهزية للعالمية: الإنجليزي هدف ثابت، لغة الشرح متغيرة
5. Monetization: بانر خفيف + Pro، بدون إعلانات مقاطِعة

**القيود:**
- لا API خارجي (LLM/TTS/STT سحابي). كل شيء offline أو on-device
- نفس `applicationId` والـ keystore القديم على Android
- Clean Architecture + BLoC حسب skill `flutter-clean-architecture-bloc`
- **sqflite** ثابت. لا drift.

---

## 2. رؤية المنتج

### 2.1 من "أقسام" إلى "درس اليوم" (يُنفَّذ في 1.1)
الشاشة الرئيسية في 1.1 = زر واحد كبير "درسك اليوم" (كلمات + جمل + قاعدة + shadowing + مراجعة SRS) + ستريك + تقدم المستوى + "استكشف" للأقسام الكاملة.
في 1.0 تبقى الشاشة الرئيسية الحالية (grid) مع إضافة "استمر من حيث توقفت".

### 2.2 تحديد المستوى (1.1)
اختبار سريع عند أول فتح (10–15 سؤال من `word_list` + 3 جمل) يحدد A1–C2. قابل للتغيير من الإعدادات. كل المحتوى مربوط بمستوى عبر `content_level`.

### 2.3 التموضع العالمي
- الإنجليزي هدف ثابت، لغة الشرح `explanation_locale` يختارها المستخدم في الـ onboarding
- USP: "تعلم الإنجليزية بالتدريب على الكلام (Shadowing) بدون إنترنت"
- **ترتيب اللغات:** عربي (1.0) → **التركي وحده** (1.1/1.2، يُقاس) → ألماني، فرنسي → إسباني، إندونيسي، إلخ
- **لا تُطلق أكثر من لغة جديدة في إصدار واحد.** كل لغة = سوق يحتاج دعم ومراجعات بلغته.

---

## 3. قاعدة البيانات

### 3.1 القرار: content.db كما هي + user.db منفصلة
- **`content.db`** (= `learn_db.db` الحالي): تُشحن في الـ APK كـ asset، read-only منطقيًا، تُستبدل كاملة عند التحديث. **الأعمدة العربية تبقى مكانها** (لا نقل لجدول translation).
- **`user.db`**: تُنشأ على الجهاز بـ sqflite مع `onCreate`/`onUpgrade`، تحفظ كل بيانات المستخدم، **لا تُمس أبدًا** عند تحديث المحتوى.

### 3.2 تغييرات content.db (سكريبت migration خارج التطبيق، مع عدّ قبل/بعد)
| الحالي | التغيير |
|---|---|
| 9 جداول `level_*` | جدول واحد `content_level(source_table, source_id, level)` مع index |
| `grammar_topics` / `grammar_sub_topics` / `grammar_test` | **يُبقى مؤقتًا** لأن الكود الحالي يقرأ منها؛ يُحذف `grammar_test` فقط (test كـ TEXT واحد لا يُستخدم). المراجعة النهائية عند بناء grammar practice |
| `grammar_content` (ids فقط) | يُضاف `sub_topic_id` لربطه بـ `grammar_sub_topics` |
| `my_word_list` | **يُحذف** من content.db (ينتقل لـ user.db) |
| `audio_files` | يبقى كما هو. لا `remote_url` — الـ URL = `AUDIO_BASE_URL + file_path` |
| جدول جديد `meta(key, value)` | `schema_version`, `content_version` |
| جدول جديد `translation` | انظر 3.4 — فارغ في 1.0 |
| التسمية المختلطة، `imageResourceId` | **لا تُلمس** في 1.0 |

### 3.3 جداول user.db (v1)
```sql
user_settings(key TEXT PK, value TEXT)
  -- level, explanation_locale, voice_key, daily_goal_minutes, migration_done, legacy_migration_done
user_progress(source_table, source_id, status, score, attempts, started_at, completed_at, PK(source_table, source_id))
  -- status: 0 none, 1 in_progress, 2 completed
srs_card(source_table, source_id, ease, interval_days, due_at, reps, lapses, last_review, PK(source_table, source_id))
  -- SM-2, index على due_at
daily_activity(date TEXT PK 'YYYY-MM-DD', minutes, items_done, lesson_completed)
shadowing_attempt(id PK, sentence_id, recorded_path, similarity, timing_score, total, is_favorite, created_at)
my_word_list(id PK, word, translation, note, source_table, source_id, created_at, UNIQUE(word COLLATE NOCASE))
```
التواريخ epoch ms كـ INTEGER عدا `daily_activity.date` (نص، بالتاريخ المحلي للستريك).
الـ progress الحالي في SharedPreferences يُنقل لـ `user_progress` مرة واحدة عند أول تشغيل.

### 3.4 لغات الشرح — جدول `translation`
```sql
translation(source_table, source_id, field, locale, text, PK(source_table, source_id, field, locale))
```
- **العربي يبقى في أعمدته الأصلية.** الجدول للغات الجديدة فقط.
- الشرح العربي موجود في 23 عمود عبر 17 جدول (~418k حرف). كل لغة جديدة = صفوف في `translation` بنفس (source_table, source_id, field).
- **`ContentLocalizer`** (interface في `core/`) هو نقطة القراءة الوحيدة:
  `locale == ar` → العمود العربي · غير ذلك → `translation` · غير موجود → الإنجليزي + تسجيل الحدث.
- الـ repositories الحالية تتحول لتقرأ عبر `ContentLocalizer` **بدون تغيير الـ entities**.
- الترجمة الآلية للغات الجديدة من **الإنجليزي** (لا من العربي) عبر سكريبت خارجي، مع مراجعة بشرية إجبارية لـ grammar وonboarding.

### 3.5 الصوت
- المصدر الأساسي: **S3** (`AUDIO_BASE_URL` في `EnvironmentConfig`) + `SoundCache` الحالي.
- **يُحذف** مسار Google Translate TTS. device TTS يبقى fallback أخير فقط عند غياب الملف والشبكة.
- **الأصوات الأربعة متاحة للجميع من 1.0** (الإعدادات جاهزة بالفعل). Pro = "تحميل المستوى كامل للأوفلاين"، لا الأصوات.
- في الـ APK: صوت أول درسين من كل مستوى فقط (≤ 15MB) لتجربة أولى بدون إنترنت.
- Pre-cache صوت الدرس قبل فتحه مع مؤشر تقدم صغير — **بدون شاشة انتظار مصطنعة وبدون interstitial**.

### 3.6 تحديث المحتوى بدون release (بعد 1.0)
`version.json` على S3 → عند فتح التطبيق قارن `content_version` → نزّل content.db الجديدة في الخلفية → بدّل عند الفتح التالي. user.db لا تتأثر. **لا Supabase ولا سيرفر في هذه المرحلة.**

---

## 4. Shadowing (الأولوية الأولى في التميّز)

### 4.1 الأوضاع
1. **Listen** — تشغيل الدرس جملة جملة (ملف لكل جملة) مع highlight وترجمة قابلة للإخفاء — **1.0**
2. **Repeat** — لكل جملة: يسمع → يسجل → يسمع نفسه بجانب الأصل → نتيجة — **1.0**
3. **Role-play** — يختار `character`، التطبيق يقول الأدوار الأخرى. في المستوى الأعلى تختفي الترجمة ثم النص — **1.1**
4. **Speed** 0.75× / 1× / 1.25× — 1.0 إن دعمها المشغّل الحالي

### 4.2 التقييم بدون AI خارجي
- **الطبقة 1:** `speech_to_text` بـ `onDevice: true` عند التوفر، وfallback واضح (تسجيل + timing فقط) إن لم يتوفر
- **الطبقة 2:** `SentenceAssessor` الموجود (word-level alignment، function words بوزن أقل). يُحط خلف interface `PronunciationScorer` في الـ domain
- **Timing:** مدة تسجيل المستخدم مقابل مدة الملف الأصلي (±25% = ممتاز). ملاحظة: `start`/`end` في `conversation_sentence` قد تكون offsets قديمة لملف واحد — **تُتحقق** عند بناء الـ feature، وإن لم تطابق تُستخدم مدة الملف الفعلية
- **الدرجة:** `0.7 × similarity + 0.3 × timing` → `shadowing_attempt`
- إبراز الكلمات الخاطئة بالأحمر + زر لسماع الكلمة وحدها (صوت الكلمة موجود)
- **ليس الآن:** تقييم فونيمي. `PronunciationScorer` interface يسمح بإضافته لاحقًا بدون تغيير UI

### 4.3 التسجيل
- `record` (m4a/aac) + المشغّل الحالي. طلب صلاحية الميكروفون **عند أول Shadowing فقط** مع شرح
- حذف تسجيلات أقدم من 7 أيام (إلا `is_favorite`)

---

## 5. Retention (1.1)
- درس يومي 5–10 دقائق كنقطة دخول
- SRS (SM-2) للكلمات والجمل — **`srs_card` يُملأ من 1.0** حتى قبل تفعيل المراجعة
- ستريك + إشعار يومي ذكي (وقت آخر استخدام ±30 دقيقة، رسائل متنوعة، إيقاف سهل)
- شهادة عند إكمال المستوى (قابلة للمشاركة)
- ميزة overlay القديمة: **معطّلة افتراضيًا**، خيار متقدم Android فقط، **1.2+**

---

## 6. Monetization

### 6.1 الإعلانات (1.0: بانر فقط)
- Banner adaptive في: الرئيسية، استكشف، نتائج الدرس. **أبدًا** داخل الدرس/الـ Shadowing/الاختبار/شاشة تحميل
- Interstitial (1.1): مرة كحد أقصى **بعد** إكمال درس، ولا في أول 3 أيام
- **مرفوض:** أي إعلان على شاشة تحميل أو قبل فتح المحتوى (مخالف لسياسة AdMob ويقتل retention)
- AdMob: Max content rating = G

### 6.2 Pro (1.1، RevenueCat)
بدون إعلانات · تحميل المستويات للأوفلاين · إحصائيات + تصدير · Shadowing غير محدود (المجاني: 3 محادثات/يوم) · شهري/سنوي (خصم 50%+) · تجربة 7 أيام · تسعير حسب الدولة · العرض **بعد 3 دروس** · Restore Purchases + روابط Terms/Privacy داخل الـ paywall (شرط Apple)

---

## 7. Localization
- UI: `.arb` (ar, en في 1.0؛ tr لاحقًا)
- المحتوى: عبر `ContentLocalizer` (قسم 3.4)
- RTL/LTR يُختبر على كل شاشة من اليوم الأول
- خط لاتيني واضح للإنجليزي + خط عربي للشرح؛ لا خط عربي لعرض الإنجليزي

---

## 8. البنية التقنية
- Features: `onboarding`, `dashboard`, `vocabulary`, `sentences`, `conversation` (+shadowing), `grammar`, `phonetics`, `dictionary`, `progress`, `settings`, `language`; لاحقًا `daily_lesson`, `srs`, `monetization`, `notifications`
- DB: sqflite — `content_database.dart` + `user_database.dart`
- صوت: المشغّل الحالي + `record` + `speech_to_text`
- إشعارات (1.1): `flutter_local_notifications` + `timezone` (iOS: 64 حد → جدولة أسبوع)
- Ads/IAP: `google_mobile_ads`، RevenueCat (1.1)
- Analytics: lesson_start/complete, shadowing_attempt, srs_review, paywall_view, purchase
- **يُراجع:** `cloud_firestore` و`shorebird_code_push` موجودان في الـ deps — يُحدد استخدامهما أو يُحذفان

### 8.1 ترحيل بيانات المستخدم القديم (Android)
Flutter يقرأ `FlutterSharedPreferences` فقط، لذا **MethodChannel بـ Kotlin** يقرأ ملف prefs القديم بالاسم القديم + DB القديمة (`my_word_list`) ويعيدهما مرة واحدة → `user.db` → `legacy_migration_done=true`. أسماء الملفات والـ keys تُوثَّق في `KEEP.md`. **فقدان كلمات المستخدم = تقييمات سلبية.**

---

## 9. خارطة الطريق

### الإصدار 1.0 — "إحياء التطبيق" (4–5 أسابيع)
الهدف: يظهر على الأجهزة الجديدة، يطلع على iOS، يوقف نزيف المستخدمين، ويجمع بيانات.

| # | المهمة | ملف task |
|---|---|---|
| 1 | user.db + نقل progress من prefs | `tasks/01_user_db.md` |
| 2 | migration سكريبت على content.db (content_level, meta, translation, grammar_content) | `tasks/02_content_migration.md` |
| 3 | الصوت: S3 كمصدر أساسي + حذف Google TTS | `tasks/03_audio_s3.md` |
| 4 | `ContentLocalizer` + `explanation_locale` في onboarding/settings | `tasks/04_content_localizer.md` |
| 5 | Sentences: topics → subtopics → content + تمرين `answers` | `tasks/05_sentences.md` |
| 6 | Dictionary: `word_list` بفلتر A1–C2 + بحث + my_word_list | `tasks/06_dictionary.md` |
| 7 | Conversations: Listen mode | `tasks/07_conversation_listen.md` |
| 8 | Shadowing: Repeat mode + `PronunciationScorer` + `shadowing_attempt` | `tasks/08_shadowing_repeat.md` |
| 9 | Vocabulary practice: 2–3 games حسب `vocabulary-quiz-design.md` + كتابة `srs_card` | `tasks/09_vocabulary_practice.md` |
| 10 | Dashboard: "استمر من حيث توقفت" + إحصائيات من user.db | `tasks/10_dashboard.md` |
| 11 | ترحيل بيانات القديم (MethodChannel) | `tasks/11_legacy_migration.md` |
| 12 | بانر AdMob | `tasks/12_ads_banner.md` |
| 13 | RTL على كل شاشة + أجهزة حقيقية (Xiaomi/Samsung/Oppo + iPhone) | `tasks/13_qa_release.md` |
| 14 | Android rollout 10→50→100% · iOS TestFlight → نشر | — |

### الإصدار 1.1 — "التحول" (+4 أسابيع بعد الإطلاق)
اختبار المستوى → `daily_lesson` + SRS → الشاشة الرئيسية الجديدة → Role-play + ستريك + إشعارات → Pro (RevenueCat) → interstitial بعد الدرس

### الإصدار 1.2
التركي كأول لغة شرح جديدة (تُقاس قبل أي لغة أخرى) · version.json وتحديث المحتوى بدون release · Widget · شهادات

### لاحقًا
ألماني، فرنسي، إسباني… · Pronunciation scoring · حسابات + مزامنة (هنا مكان Supabase إن احتجناه) · باقات موجهة (عمل / IELTS)

---

## 10. مؤشرات النجاح
| المؤشر | الحالي | الهدف |
|---|---|---|
| Day-1 retention | — | > 35% |
| Day-7 retention | ~1–5% | > 20% |
| إكمال الدرس اليومي (1.1) | — | > 50% من DAU |
| Shadowing attempts / DAU | — | > 1 |
| تحويل Pro (1.1) | — | 1.5–3% من MAU |
| تقييم المتجر | 4.6 | ≥ 4.6 |

---

## 11. قواعد العمل لـ Claude Code
1. الكود القديم مرجع للسلوك والمحتوى، لا مصدر للكود
2. **مهمة واحدة من `tasks/` في الجلسة**، بـ unit tests على الـ usecases قبل الانتقال، وتحديث حالة المهمة في نهاية الجلسة
3. **لا تعدّل نصوص المحتوى.** أي خطأ في المحتوى يُبلَّغ ولا يُصلَّح
4. لا API خارجي. أي شيء يحتاج سيرفر يُكتب خلف interface في الـ domain
5. كل platform-specific code خلف interface مع fallback لا يُسقط التطبيق
6. الصلاحيات تُطلب عند الحاجة الفعلية مع شرح
7. لا إعلانات داخل شاشات التعلم أو التحميل. أي PR يخالف ذلك مرفوض
8. RTL يُختبر مع كل شاشة
9. **لا تغيّر schema بدون task صريح.** content.db لا تُكتب من التطبيق أبدًا
10. الـ features الجاهزة (phonetics/grammar/vocabulary) **لا يُعاد بناؤها** — تُعدَّل في أضيق نطاق
11. عند الشك في قرار منتج: اختر ما يرفع الـ retention