# Task 10 — Conversations: Listen mode (Chat + Pager)

**المرجع:** `PLAN.md` §4.1, §9 · تصميم معتمد: `https://claude.ai/artifact/9GaScKM6HViT8qPwCVQC7R`
(artboards: `ConversationLessons.dc.html`, `ConversationPlayer.dc.html` (Chat)، `ConversationPager.dc.html`)
**الحالة:** ⬜ لم تبدأ · **الاعتماديات:** Task 01, 02, 03, 04 · **يعتمد عليها:** Task 11 (Shadowing/Repeat mode)

---

## ⚠️ ملاحظة عن رابط التصميم

نفس ملاحظة Task 06/08: الرابط canvas تفاعلي، **لا يمكن لـ Claude Code فتحه**. كل قرار بصري مكتوب هنا بالتفصيل. الخطوط والألوان حقيقية (`Be Vietnam Pro`, `Inter`, `Cairo`, tokens من `BayanColors`) — عيّن عليها كما في Task 06/08، **لا تُدخل خطًا أو hex جديدًا**.

---

## الهدف

بناء تاب "Talk" الحالي (`_PlaceholderScreen`) كـ feature كاملة: تصنيفات (14) → دروس (138) → مشغّل حوار بوضعين يتحكم فيهما المستخدم:
1. **Chat** — تمرير تلقائي للحوار كفقاعات شات، مع تمييز السطر الحالي
2. **Pager** — سطر واحد يملأ الشاشة، سحب يدوي بين الأسطر (بدون تشغيل تلقائي متسلسل)

**نطاق هذه المهمة = الاستماع + فحص نطق خفيف لكل سطر (بدون تخزين).** التسجيل الكامل وحفظ المحاولات (`shadowing_attempt`) هو Task 11 (Repeat mode) تحديدًا — **لا تبنِ أي تخزين لمحاولات هنا**.

---

## 1. ⚠️ فخّان في الـ schema — تحقق بنفسك، لا تخمّن

### أ) أعمدة متشابهة الاسم بمعانٍ مختلفة تمامًا
```
conversation_level  (id, title, titleAr, itemCount, level)   — 14 صف (تصنيفات: "General Questions"...)
conversation_lesson (id, level, duration, title, titleAr, level_id) — 138 صف
conversation_sentence (id, lesson, character, start, end, sentence, phonetic, sentenceAr) — 2,932 صف
```
- `conversation_lesson.level_id` → **مفتاح أجنبي فعلي** لـ `conversation_level.id` (التصنيف/الفئة). **هذا هو أساس التسلسل الهرمي.**
- `conversation_level.level` (قيم 1-3) و`conversation_lesson.level` (قيم 1-4) **عمودان منفصلان تمامًا بمعنى غير محدد في الواجهة حاليًا — لا علاقة بينهما ولا بنظام CEFR العام للتطبيق (content_level من Task 02)**. **لا تستخدمهما لأي فلترة أو عرض في هذه المهمة.** إن احتجت فلترة CEFR لاحقًا (1.1)، المصدر الصحيح هو `content_level` حيث `source_table='conversation_lesson'` (مرحَّل من `level_conversation_lesson` القديم في Task 02)، وليس هذين العمودين.
- `conversation_sentence.lesson` (وليس `lessonId`) → مفتاح أجنبي لـ `conversation_lesson.id`

### ب) `start`/`end` غير مستخدمين هنا
موثّق في `PLAN.md` §3.3 و§4.2: هذان العمودان offsets بالعُشر من الثانية داخل ملف صوتي واحد متصل قديم (غير متحقَّق من وجوده على CDN). **الصوت الفعلي المتحقَّق (Task 03) هو ملف منفصل لكل جملة** عبر `CdnConfig.conversationAudio(id, voice)`. **لا تستخدم `start`/`end` إطلاقًا في هذه المهمة.**

### ج) تنسيق `phonetic` خام — يحتاج استخراج
القيمة الفعلية في العمود شكلها: `{How | haʊ} {are | ɑː} {you | juː}?` — كل كلمة مع نطقها بين قوسين معقوفين، والعلامات (نقطة/علامة استفهام) خارج الأقواس. **يجب استخراج جزء النطق فقط** قبل العرض:
```
"{How | haʊ} {are | ɑː} {you | juː}?"  →  "haʊ ɑː juː?"
"{Hello | həˈloʊ}."                      →  "həˈloʊ."
```
اكتب دالة `extractPhonetic(String raw)` في `core/utils/` (أو داخل الـ feature لو أنسب — راجع بنية المشروع الحالية لمكان أدوات نصية مشابهة): بـ Regex يلتقط `\{[^|]+\|\s*([^}]+)\}` ويستبدل كل تطابق بمجموعته الملتقطة، تاركًا أي نص خارج الأقواس (علامات الترقيم) كما هو. **اختبرها بالأمثلة الأربعة أعلاه بالضبط قبل إغلاق المهمة.**

---

## 2. الملفات

### Domain
```
lib/features/conversation/domain/entities/conversation_category.dart
lib/features/conversation/domain/entities/conversation_lesson.dart
lib/features/conversation/domain/entities/conversation_line.dart
lib/features/conversation/domain/repositories/conversation_repository.dart
lib/features/conversation/domain/usecases/get_conversation_categories.dart
lib/features/conversation/domain/usecases/get_conversation_lessons.dart
lib/features/conversation/domain/usecases/get_conversation_lines.dart
```

### Data
```
lib/features/conversation/data/models/conversation_category_model.dart
lib/features/conversation/data/models/conversation_lesson_model.dart
lib/features/conversation/data/models/conversation_line_model.dart
lib/features/conversation/data/datasources/conversation_local_datasource.dart   (@Named('content'))
lib/features/conversation/data/repositories/conversation_repository_impl.dart
lib/core/utils/phonetic_parser.dart   (أو مكان مكافئ — انظر §1ج)
```

### Presentation
```
lib/features/conversation/presentation/bloc/conversation_categories/{bloc,event,state}.dart
lib/features/conversation/presentation/bloc/conversation_lessons/{bloc,event,state}.dart
lib/features/conversation/presentation/bloc/conversation_player/{bloc,event,state}.dart   (§5)
lib/features/conversation/presentation/bloc/conversation_line_practice/{bloc,event,state}.dart   (§6 — تحقق أولًا من إمكانية إعادة استخدام ما بُني في Task 06)
lib/features/conversation/presentation/screens/conversation_categories_screen.dart
lib/features/conversation/presentation/screens/conversation_lessons_screen.dart
lib/features/conversation/presentation/screens/conversation_chat_screen.dart
lib/features/conversation/presentation/screens/conversation_pager_screen.dart
lib/features/conversation/presentation/widgets/conversation_lesson_row.dart
lib/features/conversation/presentation/widgets/conversation_bubble.dart
lib/features/conversation/presentation/widgets/conversation_view_mode_toggle.dart
lib/core/preferences/conversation_view_mode_preference.dart   (نفس نمط `SentencesViewModePreference` من Task 06 حرفيًا)
```

### تعديل
| الملف | التعديل |
|---|---|
| `lib/core/router/app_router.dart` | استبدال `_PlaceholderScreen(label: 'Conversations')` بمسارات حقيقية (categories → lessons → chat/pager) |
| `lib/features/progress/domain/repositories/progress_repository.dart` | قسم Conversations جديد (مطابق تمامًا لقسم Sentences من Task 05 — بدون قفل تدريجي، `source_table='conversation_lesson'`) |
| `lib/features/progress/data/datasources/progress_local_datasource.dart` | 4 methods جديدة (`getCompletedConversationLessons`, إلخ) — نفس نمط Sentences بالحرف |

**لا تلمس:** `sentences/`, `vocabulary/`, `grammar/`, `phonetics/`, `dictionary/`. **لا `shadowing_attempt`** (Task 11).

---

## 3. التحقق أولًا من إعادة الاستخدام — لا تُعِد بناء ما هو موجود

قبل كتابة أي كود جديد للفحص الصوتي، افحص الملفات التالية من Task 06 وحدّد **بوضوح في سجل الجلسة** ما إذا كانت قابلة لإعادة الاستخدام مباشرة أو تحتاج تعميمًا بسيطًا:
- `core/speech/sentence_assessor.dart` (`SentenceAssessor.assess`) — **استخدمه كما هو**، جمل المحادثة (`"How are you?"`, `"I'm from California."`) بها أكثر من كلمة بالضبط كما جمل Sentences، فنفس منطق المطابقة الوزنية ينطبق. **لا تستخدم `PronunciationBloc`/`SpeechTextMatcher` هنا** (ذاك لكلمة واحدة فقط — راجع Task 08 §5 للفرق الموثّق سابقًا).
- بلوك الممارسة من Task 06 (`SentencePracticeBloc` أو ما يعادله) — إن كان عامًا بما يكفي (يأخذ نص الهدف كمعامل، لا يعتمد على كيانات Sentences تحديدًا)، **أعد استخدامه مباشرة** بدل إنشاء `ConversationLinePracticeBloc` منفصل. إن كان مرتبطًا ببنية Sentences بشكل وثيق، أنشئ نسخة مكافئة بأقل تكرار ممكن (استخرج منطقًا مشتركًا إلى مكان عام لو كان ذلك بسيطًا وواضحًا، وإلا انسخ النمط كما فعلت Task 08 مع `PronunciationBloc`).

---

## 4. Schema والاستعلامات

```dart
// categories
db.query('conversation_level', orderBy: 'id');

// lessons لفئة معينة
db.query('conversation_lesson', where: 'level_id = ?', whereArgs: [categoryId], orderBy: 'id');

// سطور درس معين
db.query('conversation_sentence', where: 'lesson = ?', whereArgs: [lessonId], orderBy: 'id');
```
الصوت: `CdnConfig.conversationAudio(line.id, voice)` (تحقَّق في Task 03، 100%).

## 5. Entities

```dart
class ConversationCategory { final int id; final String title, titleAr; final int lessonCount; }
class ConversationLesson {
  final int id; final int categoryId;
  final String title, titleAr;
  final int durationSeconds;   // عمود duration كما هو، بالثواني
  final int lineCount;         // يُحسب (COUNT) وليس عمودًا مباشرًا — تحقق من مصدره في الاستعلام
}
class ConversationLine {
  final int id;
  final String character;           // اسم المتكلم كما هو من العمود
  final String english;             // sentence
  final String phonetic;            // بعد extractPhonetic()
  final String arabic;              // sentenceAr → عبر ContentLocalizer
}
```
`ContentLocalizer` لـ `arabic`: `sourceTable: 'conversation_sentence'`, `field: 'sentenceAr'`, `englishValue: sentence`.

## 6. Chat view (`conversation_chat_screen.dart` + `conversation_bubble.dart`)

- فقاعات: محاذاة يسار/يمين تتناوب حسب **ترتيب ظهور كل `character` فريد لأول مرة** (أول متكلم جديد يظهر = يسار، الثاني = يمين، وهكذا لو كان فيه أكثر من متكلمين — أغلب الدروس متكلمان فقط حسب العينة، لكن لا تفترض الاثنين فقط، اكتب منطقًا يدعم أي عدد)
- أفاتار دائري بحرف أول الاسم، لون يُشتق من hash اسم الشخصية (ثابت لكل اسم عبر كل التطبيق) بدل ألوان عشوائية لكل تحميل
- كل فقاعة: الإنجليزي (bold) → النطق (`italic`, رمادي فاتح) → العربي (`ArabicVisibility`)، ثم صف صغير تحتها بزرّين: 🔊 (يشغّل هذا السطر وحده) و🎙️ (فحص نطق هذا السطر، §3)
- **حالات بصرية ثلاث للفقاعة:** عادية (بيضاء) / **الحالية أثناء auto-play** (خلفية `BayanColors.primary`، نص أبيض، ظل أبرز، زرّان أكبر (34px) + تسمية "Now playing") / **قادمة** (نفس الشكل العادي بـ `opacity: .5`)
- **تشغيل تلقائي متسلسل:** عند فتح الشاشة يبدأ التشغيل من أول سطر لم يُستمع له بعد (أو من البداية)، كل سطر بصوته الخاص بالتتابع، مع تحديث حالة "الحالي/القادم" تزامنًا. الضغط على 🔊 الخاص بسطر معيّن يشغّله وحده **ولا يستأنف** التسلسل التلقائي تلقائيًا بعدها (يحتاج المستخدم يضغط ▶ تاني من الشريط)
- **شريط تحكم عائم أسفل الشاشة:** Slow/Normal فقط (**لا UK/US هنا** — قرار صريح، اللهجة من الإعدادات العامة فقط) + ▶/⏸ مركزي كبير + سابق/تالي
- **لا تشغيل تلقائي بين الدروس** (ينتهي عند آخر سطر، لا ينتقل للدرس التالي من نفسه)
- زر تبديل اللغة العربية (`ع`) في الهيدر يتحكم في إظهار/إخفاء كل ترجمات العربي دفعة واحدة (`AppContentLanguage`/`ArabicVisibility` الموجودين — **لا تبنِ حالة جديدة لهذا**)

## 7. Pager view (`conversation_pager_screen.dart`)

- **لا تشغيل تلقائي متسلسل هنا إطلاقًا** — بالضبط مثل `SentencePagerView` من Task 06: سحب يدوي بين الصفحات، كل صفحة سطر واحد كامل الشاشة
- كل صفحة: اسم المتكلم + أفاتار أعلى الكارت (بنفس لون الأفاتار المشتق في §6) → الإنجليزي كبير → النطق → العربي → Slow/Normal → زرّا 🔊/🎙️ كبيرين (44px/58px كما في Task 06 Pager) في المنتصف
- نقاط تقدم أسفل الشاشة بعدد كل أسطر الدرس (ليس بعدد صفحات متعددة الأسطر — نقطة واحدة لكل `ConversationLine`)
- زر "Mark as complete" ثابت في الأسفل (نفس نمط Sentences Pager بالضبط)

## 8. زر التبديل Chat/Pager

نفس نمط Task 06 بالحرف:
```dart
enum ConversationViewMode { chat, pager }
class ConversationViewModePreference {
  static final instance = ConversationViewModePreference._();
  final ValueNotifier<ConversationViewMode> mode = ValueNotifier(ConversationViewMode.chat);
  void bind(SharedPreferences prefs) { ... }
  void set(ConversationViewMode value) { ... }
}
```
مفتاح `SharedPreferences` منفصل عن مفتاح Sentences (`prefConversationViewMode` مثلًا). الافتراضي `chat`. يظهر الزر في هيدر الشاشتين (كما في التصميم)، والانتقال بينهما فوري (نفس المحتوى، تمثيل مختلف).

## 9. شاشة الدروس (`conversation_lessons_screen.dart` + `conversation_lesson_row.dart`)

- صف لكل درس: أفاتار أول متكلمين متراكبين (overlap، كما في التصميم) + العنوان + العربي + مدة (أيقونة ساعة + ثواني) + عدد أسطر + حالة (✓ مكتمل / "Continue" بحد أزرق / سهم بسيط لم يبدأ بعد) — **كل الدروس مفتوحة دائمًا، لا قفل تدريجي** (نفس قرار Sentences)
- هيدر الفئة: عنوان الفئة + "N of M completed" + progress bar

## 10. Progress

مطابق تمامًا لقسم Sentences (Task 05 §3، §4): `ConversationProgress` entity، `getConversationProgress`, `markConversationLessonStarted`, `markConversationLessonCompleted` — `source_table='conversation_lesson'`. يُستدعى `markStarted` عند فتح شاشة اللعب (Chat أو Pager)، و`markCompleted` عند الضغط على "Mark as complete".

---

## 11. Tests

- `phonetic_parser_test.dart` — الأمثلة الأربعة في §1ج بالضبط + حالة بدون أقواس إطلاقًا (ترجع كما هي) + حالة فارغة
- `conversation_repository_impl_test.dart`, model tests (خاصة `arabic` عبر `ContentLocalizer`، و`phonetic` عبر `extractPhonetic`)
- `conversation_view_mode_test.dart` (مطابق لنظيره في Task 06)
- Progress: عزل كامل عن grammar/phonetics/sentences (نفس اختبار Task 05)
- Bloc test لتسلسل auto-play: تشغيل → انتقال تلقائي للسطر التالي عند انتهاء الصوت → توقف عند آخر سطر

## 12. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة، كل الـ tests تعدي
- [ ] `extractPhonetic` يعطي بالضبط `"haʊ ɑː juː?"` لمدخل `"{How | haʊ} {are | ɑː} {you | juː}?"` (اختبار حرفي، لا تقريبي)
- [ ] فتح Talk tab → فئة → درس → Chat: التشغيل التلقائي يبدأ، الفقاعة الحالية مميزة، الباقي باهت تدريجيًا مع التقدم
- [ ] الضغط على 🔊 سطر منفرد يشغّله وحده بدون كسر تزامن الفقاعة الحالية الفعلية
- [ ] الضغط على 🎙️ ونطق السطر صح → نتيجة إيجابية واضحة (نفس مستوى Sentences، تلوين كلمة بكلمة)
- [ ] تبديل Chat↔Pager فوري، نفس المحتوى، لا UK/US ظاهر في أي مكان بهذه الشاشة
- [ ] Pager: السحب بين الأسطر يدوي فقط، لا صوت يبدأ من نفسه عند الوصول لصفحة جديدة
- [ ] "Mark as complete" يحدّث progress فعليًا ويظهر في شاشة الدروس عند الرجوع
- [ ] `_PlaceholderScreen` الخاص بـ Conversations أُزيل بالكامل
- [ ] `git diff --stat`: صفر تعديل خارج `conversation/`, `core/utils/phonetic_parser.dart` (أو مكانه البديل), `core/preferences/`, `core/router/app_router.dart`, وملفي `progress/` المذكورين

## 13. خارج النطاق
- تسجيل صوت المستخدم وحفظ المحاولات (`shadowing_attempt`) — Task 11
- Role-play (اختيار شخصية والتطبيق يقرأ البقية) — 1.1
- فلترة حسب CEFR عبر `content_level` — غير مُستخدمة في هذه المهمة (انظر §1أ)
- أي استخدام لـ `start`/`end` (§1ب)
- UK/US في أي مكان بهذا الـ feature

---

## سجل الجلسة

**الحالة:** ✅ مكتمل — 2026-10-03

### إعادة الاستخدام من Task 06 — إجابة صريحة للسؤال في المهمة

- **`SentenceAssessor` من `core/speech/sentence_assessor.dart`:** أُعيد استخدامه كما
  هو، بلا تعديل. يُستدعى داخليًا من `SentencePracticeBloc`؛ جملة محادثة من كلمتين
  إلى عشر كلمات تدخل نفس مسار المطابقة الوزنية بالضبط.
- **`SentencePracticeBloc` نفسه:** أُعيد استخدامه مباشرة بلا تعديل. حدث
  `StartSentenceCheck(sentenceId: line.id, targetSentence: line.english)` يتعامل مع
  أي قيمتين — لا تربطه ببنية Sentences-specific. حقن instance واحد عبر
  `BlocProvider(create: (_) => getIt<SentencePracticeBloc>())` داخل
  `ConversationPlayerScreen` بحيث كل الفقاعات في الدرس تشترك في نفس حالة الـ attempts.
- **لا تعميم جديد**، لا نقل كود مشترك إلى عام، لا نسخ نمط. البلوك كان مُعمَّمًا
  بالفعل من Task 06 بالصدفة (قيد التصميم كان: "لا يعتمد على كيانات Sentences").

### نتيجة اختبار `extractPhonetic`

- 8 اختبارات تمر، بينها الحالتان الحرفيتان من §1ج:
  - `"{How | haʊ} {are | ɑː} {you | juː}?"` → `"haʊ ɑː juː?"` ✓
  - `"{Hello | həˈloʊ}."` → `"həˈloʊ."` ✓
- حالة فعلية من `conversation_sentence` (`id=5` في الـ DB) بها نقطة شاذة
  داخل القوس الأول: `"{Good | gʊd.}. ..."` → `"gʊd.. dʊ ju spiːk ˈɪŋglɪʃ?"`
  (المحتوى يُحفظ كما هو، لا نُصحّح نصوص الـ DB).

### ما تم

**Core:**
- `PhoneticParser.extractPhonetic` بـ Regex `\{\s*[^|]+\|\s*([^}]+)\}` ودالة
  `replaceAllMapped` تحتفظ بما خارج الأقواس حرفيًا.
- `ConversationViewModePreference` (chat/pager) + `prefConversationViewMode` constant
  + `bind()` في `main.dart`.

**Progress (user.db نفسها، بدون bump — فقط إضافة methods على `source_table='conversation_lesson'` القائم أصلًا):**
- `ConversationProgress` entity (مطابق لـ `SentencesProgress`).
- 4 methods جديدة في `ProgressLocalDataSource` + implementations في الـ repo.
- 3 use cases: `GetConversationProgress` (مع `.watch()`),
  `MarkConversationLessonStarted`, `MarkConversationLessonCompleted`.

**Conversation Feature (clean architecture):**
- Domain: `ConversationCategory`, `ConversationLesson`, `ConversationLine` entities
  (مع ملاحظة صريحة أن `start/end` و`level` *غير* معروضة في entity level per §1a/b)؛
  `ConversationRepository` + 3 use cases.
- Data: 3 models (مع `ContentLocalizer` لـ `arabic` و`PhoneticParser` لـ `phonetic`)،
  `ConversationLocalDataSourceImpl` بثلاث استعلامات، أهمها `getLessons` بـ
  COUNT subquery لتجنب N+1 عند حساب lineCount.
- Presentation: 3 blocs — `ConversationCategoriesBloc` (basic), `ConversationLessonsBloc`
  (مع listener على `ProgressRepository.changes` ليحدث progress تلقائيًا بعد Mark
  as complete), و`ConversationPlayerBloc` (المحور — يدير auto-play sequencing +
  single-play مستقل + current line + mark-complete).

**UI:**
- `conversation_categories_screen.dart`: قائمة كارتات بأفاتار دائرية.
- `conversation_lessons_screen.dart`: `ConversationLessonRow` (أفاتار متراكبة لأول
  متكلمين + مدة + lineCount + حالة Done/Continue/arrow). هيدر الفئة بـ progress bar.
- `conversation_player_screen.dart`: يختار بين Chat body و Pager body حسب الـ pref؛
  يحتوي `_ArabicToggleButton` (`ع` chip) و`ConversationViewModeToggle` في الـ app bar.
- `conversation_chat_body.dart`: ListView من `ConversationBubble` ذاتية التمحور
  يسار/يمين حسب ترتيب ظهور كل character فريد (`_buildAlignmentMap`). الفقاعة الحالية
  تلتقط `isCurrent` (primary bg + Now playing tag + أزرار 34px)، القادمات بـ
  opacity 0.5. شريط عائم بـ Slow/Normal + prev/play/next + "N / M" counter.
  Auto-scroll للفقاعة الحالية عبر `GlobalKey` + `Scrollable.ensureVisible`.
- `conversation_pager_body.dart`: `PageView` بـ `onPageChanged` يُوقف STT + auto-play
  (لا يبدأ تلقائيًا — §7). كارت كل صفحة: أفاتار 44px + character + English 26pt +
  phonetic + arabic + Slow/Normal + أزرار 44/58px. `_DotIndicator` بسقف 11 نقطة.
  `Mark as complete` ثابت في الأسفل.
- `ConversationBubble`: 3 حالات بصرية، إعادة استخدام `CharacterAvatar` الحتمي
  (hash-based للون — نفس اللون للشخصية عبر كل التطبيق).

**Router:**
- `_PlaceholderScreen('Conversations')` + كلاس `_PlaceholderScreen` نفسه حُذفا
  (لا يُستخدم في أي مكان آخر الآن — `_PlaceholderScreen('Word list')` كان قد حُذف في
  Task 07).
- 3 nested routes تحت `AppRoutes.conversations`: `/conversations` → categories،
  `/conversations/:catId` → lessons، `/conversations/:catId/:lessonId` → player.
- `AppRoutes.conversationLessons(id)` و `conversationPlayer(catId, lessonId)` helpers
  (استبدلت الـ constants الفارغة القديمة).

**Tests (24 جديدة، كلها تمر):**
- `phonetic_parser_test` × 8
- `conversation_view_mode_test` × 4
- `conversation_line_model_test` × 2
- `conversation_repository_impl_test` × 3
- `conversation_progress_isolation_test` × 3 (معزولة تمامًا عن grammar/phonetics/sentences،
  وفحص `setInProgress` ضد lesson مكتمل)
- `conversation_player_bloc_test` × 4 (load، auto-advance على completion ثم stop عند
  آخر سطر "no auto-play between lessons"، PlaySingle لا يتقدم في الـ sequence،
  MarkConversationComplete يُحدّث `isCompleted`)

### أرقام

- **analyze:** 28 issues — صفر جديد، كلها pre-existing في ملفات غير مَمسوسة.
  `_PlaceholderScreen` warning اختفى بعد حذف الكلاس.
- **tests:** 126 pass + 1 pre-existing fail (`widget_test.dart` Counter smoke — موثق
  كـ broken منذ اليوم الأول). +24 بالضبط = عدد الاختبارات الجديدة.
- **DI:** `build_runner` تم تشغيله، 15+ تسجيلًا جديدًا
  (`ConversationLocalDataSource`, `ConversationRepository`, 3 use cases، 3 blocs،
  3 progress use cases).

### قرارات اتُّخذت

- **موقع `phonetic_parser.dart`:** في `lib/core/utils/` بدل `lib/core/preferences/`
  الذي اقترحته المهمة — لأن `core/preferences/` غير موجود وأدوات نصية مماثلة
  (`content_language.dart`, `voice_preferences.dart`) تعيش في `core/utils/` بالفعل.
- **موقع `conversation_view_mode_preference.dart`:** في `lib/core/utils/`
  أيضًا بدل المسار المقترح — لنفس السبب، ولمطابقة `sentences_view_mode_preference.dart`.
- **UK/US لم يُعرض في أي مكان** — القاعدة الصريحة في §6/§13. الصوت يستخدم
  `CdnConfig.currentVoice` (الذي يقرأ من إعدادات التطبيق العامة).
- **`CharacterAvatar.colorFor(name)` بـ `name.hashCode.abs() % _palette.length`:**
  حتمي، نفس اللون للشخصية عبر كل الشاشات ومرات التشغيل (§6).
- **Chat auto-scroll:** `_lastScrolledIndex` يمنع إعادة الـ scroll المتكررة لنفس
  الفقاعة، ويُستدعى `Scrollable.ensureVisible` فقط حين يتغير `currentIndex`.
- **Pager `onPageChanged` يُوقف الـ sequence (`PauseConversationSequence`)** بدل تجاهل
  حالة الـ player — ضمان أن السحب يدوي تمامًا كما يطلب §7، ولو كان المستخدم جاء من
  Chat بـ auto-play وبدّل لـ Pager أثناء التشغيل.

### انحرافات
- **لم يُنشأ `ConversationLinePracticeBloc` منفصل** كما ذكرت المهمة §6 شرطيًا — بعد
  التحقق كما طلبت §3، `SentencePracticeBloc` كان قابلًا للاستخدام المباشر 100%
  دون تعميم. المهمة سمحت صراحة بهذا المسار ("إن كان عامًا بما يكفي... أعد استخدامه
  مباشرة بدل إنشاء ... منفصل").

### ملاحظات للمهام القادمة
- **Task 11 (Shadowing/Repeat mode):** `ConversationPlayerBloc.PlayConversationSingle`
  هو نقطة التكامل الطبيعية — يمكن إضافة `shadowing_attempt` persistence في بلوك
  Shadowing منفصل يستمع لـ `SentencePracticeBloc` ويكتب لـ `user.db`.
- **CEFR filter مستقبلًا (1.1):** إذا احتجنا فلترة بالمستوى، المصدر الصحيح
  `content_level` حيث `source_table='conversation_lesson'`، *ليس*
  `conversation_level.level` أو `conversation_lesson.level` (أعمدة غامضة الدلالة، §1a).
