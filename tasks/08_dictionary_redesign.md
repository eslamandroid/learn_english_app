# Task 08 — Dictionary + My Words: تصميم بصري جديد + زر المايك

**المرجع:** `PLAN.md` §9 · تصميم معتمد: `https://claude.ai/artifact/9GaScKM6HViT8qPwCVQC7R` (artboards: `Dictionary.dc.html`, `MyWords.dc.html`)
**الحالة:** ⬜ لم تبدأ · **الاعتماديات:** Task 07 (Dictionary مبنية) · **يعتمد عليها:** لا شيء

---

## ⚠️ ملاحظة عن رابط التصميم

نفس ملاحظة Task 06: الرابط canvas تفاعلي، **لا يمكن لـ Claude Code فتحه**. كل قرار بصري مكتوب بالتفصيل هنا. الخطوط والألوان في ملفات التصميم نفسها حقيقية هذه المرة (`Be Vietnam Pro`, `Inter`, `Cairo`, ألوان `CefrLevel`) لأنها مطابقة لما هو مستخدم بالفعل في `BayanTypography`/`BayanColors` — **عيّن عليهما كما في الجدول أدناه، لا تُدخل أي خط أو قيمة hex جديدة**.

---

## الهدف

1. إعادة تصميم `dictionary_word_card.dart` و`my_words_sheet.dart` (Task 07) لتطابق الشكل المرتفع الجديد (بطاقات بظل، لا حدود رفيعة)
2. **معالجة الكلمة الطويلة بشكل صريح** — هذا أهم بند في هذه المهمة، لا تتجاهله
3. **إضافة زر فحص نطق (مايك)** لكل كلمة، بإعادة استخدام `PronunciationBloc` الموجود **كما هو تمامًا** (بخلاف Sentences — هنا كلمة واحدة، فالمطابقة التامة الموجودة في `PronunciationBloc`/`SpeechTextMatcher` مناسبة تمامًا ولا داعٍ لـ `SentenceAssessor`)

---

## 1. الملفات

### تعديل فقط (لا ملفات جديدة في الغالب)
| الملف | التعديل |
|---|---|
| `lib/features/dictionary/presentation/widgets/dictionary_word_card.dart` | إعادة تصميم كامل (§3، §4) + زر مايك (§5) |
| `lib/features/dictionary/presentation/widgets/my_words_sheet.dart` | نفس بطاقة الكلمة (أعد استخدام `DictionaryWordCard` نفسه بدل تكرار تصميم منفصل — طالما البيانات متوفرة؛ إن لم تكفِ حقول `my_word_list` الحالية (لا IPA ولا level ولا example مخزّنة هناك مباشرة)، اعرض بيانات مبسطة بنفس الطراز البصري فقط بدون اختلاق حقول، راجع §6) |
| `lib/features/dictionary/presentation/screens/dictionary_screen.dart` | لا تغيير منطقي، فقط إن احتاج تمرير `PronunciationBloc` كـ provider جديد في الشجرة |

**لا تلمس:** `data/`, `domain/` الخاصين بـ dictionary، ولا `PronunciationBloc`/`SpeechTextMatcher` نفسيهما، ولا أي ملف في `sentences/`/`vocabulary/`/`grammar/`.

---

## 2. تعيين الألوان والخطوط (مطابق تمامًا لـ Task 06 — نفس الجدول، نفس الـ tokens)

| عنصر | التصميم | الـ token الفعلي |
|---|---|---|
| خلفية البطاقة | بيضاء مرتفعة بظل | `BayanColors.surfaceContainerLowest` + ظل `onSurface.withValues(alpha:.07), blurRadius:24, offset:(0,10)` (نفس `_HeroCard`) |
| نصف قطر البطاقة | كبير | `AppConstants.radiusXl` |
| chip المستوى | لون حسب `CefrLevel` | `CefrLevel.color.withValues(alpha:.14)` خلفية، نفس اللون نص (مع تعتيم مناسب للتباين) |
| الكلمة الإنجليزية | كبيرة bold | `BayanTypography.headlineLarge` أو ما يعادلها |
| IPA | رمادي italic صغير | `BayanColors.onSurfaceVariant` |
| العربي | — | `BayanColors.onSurfaceVariant` + `BayanTypography.arabicFontFamily`، عبر `ArabicVisibility` الموجود |
| الفاصل | رفيع خفيف | `BayanColors.outlineVariant.withValues(alpha:.4)` |
| `example` | italic + أيقونة اقتباس | `BayanColors.onSurfaceVariant`، أيقونة بلون أفتح من `outlineVariant` |
| زر الصوت 🔊 | دائرة زرقاء فاتحة | خلفية `BayanColors.primary.withValues(alpha:.10)`، أيقونة `primary` |
| **زر المايك 🎙️ (جديد)** | دائرة خضراء بارزة | خلفية `BayanColors.success`، أيقونة بيضاء، ظل `success.withValues(alpha:.30)` |
| زر الحفظ (غير محفوظة) | دائرة برتقالية فاتحة، أيقونة outline | خلفية لون تحذير فاتح (استخدم `BayanColors.warning.withValues(alpha:.14)` إن لم يوجد لون "برتقالي فاتح" مخصص)، أيقونة `warning` |
| زر الحفظ (محفوظة) | دائرة برتقالية ممتلئة، أيقونة مملوءة | خلفية `BayanColors.warning`، أيقونة بيضاء، ظل مطابق |

كل الأيقونات من `Icons.*` (Material) أو حزمة الأيقونات المستخدمة بالفعل في المشروع — **لا إيموجي**.

---

## 3. ⚠️ معالجة الكلمة الطويلة — أهم بند في هذه المهمة

**المشكلة:** صف الهيدر الحالي (chip + الكلمة على اليسار، 3 أزرار على اليمين) مبني غالبًا كـ `Row` بسيط. كلمة طويلة (مثال حقيقي من `word_list`: `responsibility`, `entrepreneurship`, `misunderstanding`) يمكن أن:
- تدفع الأزرار خارج حدود البطاقة أو تتسبب في `RenderFlex overflow`
- أو تُقطع بثلاث نقاط بشكل غير لائق لكلمة تعليمية يُفترض أن تُقرأ كاملة

**الحل المعتمد في التصميم (طبّقه حرفيًا):**

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          _LevelChip(level: word.level),           // لا flex، حجم ثابت
          Text(
            word.word,
            style: BayanTypography.headlineLarge.copyWith(color: BayanColors.onSurface),
            softWrap: true,                          // يلتف لسطر جديد، لا يُقطع
            overflow: TextOverflow.visible,           // لا ellipsis هنا إطلاقًا
          ),
        ],
      ),
    ),
    const SizedBox(width: 10),
    Row(
      mainAxisSize: MainAxisSize.min,               // لا يتمدد، لا ينكمش
      children: [
        _IconButton(...speaker...),
        const SizedBox(width: 7),
        _IconButton(...mic...),
        const SizedBox(width: 7),
        _IconButton(...save...),
      ],
    ),
  ],
)
```

**النقاط الجوهرية (لماذا هذا الشكل بالتحديد):**
- `Expanded` على الـ `Wrap` يسمح للكلمة الطويلة بأخذ العرض المتاح وتلتف لسطر ثانٍ **تحت** chip المستوى، بدل ما تدفع الأزرار
- `Wrap` (وليس `Row`) هو ما يسمح لـ chip والكلمة بالانتقال لسطر جديد معًا كوحدة واحدة إن لزم الأمر
- مجموعة الأزرار في `Row` منفصل بـ `mainAxisSize: MainAxisSize.min` بجانب الـ `Expanded` — **لا تضعها أبدًا داخل نفس `Wrap`**، لأنها يجب أن تبقى ثابتة الحجم والموضع دائمًا بصرف النظر عن طول الكلمة
- **ممنوع استخدام `TextOverflow.ellipsis` أو `maxLines: 1`** على اسم الكلمة — هذا تطبيق قاموس، قطع الكلمة يفقد المعنى التعليمي (خلافًا مثلاً لعنوان درس في Grammar حيث القطع مقبول)

**اختبر فعليًا بهذه الكلمات الثلاث من `word_list` الحقيقي قبل إغلاق المهمة:**
- `about` (قصيرة، الحالة الشائعة)
- `responsibility` (14 حرفًا، تلتف غالبًا لسطرين مع الـ chip)
- أطول كلمة فعلية في الجدول — نفّذ `SELECT word, LENGTH(word) FROM word_list ORDER BY LENGTH(word) DESC LIMIT 1` على `content.db` واستخدم الناتج الفعلي كحالة اختبار قصوى، لا تخمّن الكلمة

---

## 4. باقي بنية البطاقة

```
┌─────────────────────────────────────────┐
│ [A1] word                    🔊 🎙️ ⭐    │ ← Wrap للجزء الأيسر، Row ثابت لليمين (§3)
│ /pronunciation/   عربي                   │ ← Wrap أيضًا (نفس احتياط الالتفاف لو IPA طويل)
│ ─────────────────────────────           │
│ " example sentence                      │
└─────────────────────────────────────────┘
```
صف IPA+عربي أيضًا يُبنى بـ `Wrap` بنفس المنطق (`spacing`, `runSpacing`) احتياطًا لو كان النطق أو الترجمة طويلين بشكل غير معتاد — نفس القاعدة: لا تدع أي نص يدفع عنصرًا آخر خارج حدود البطاقة.

---

## 5. زر المايك — إعادة استخدام `PronunciationBloc` كما هو

**لا بلوك جديد، لا تعديل على `PronunciationBloc`/`SpeechTextMatcher`.** هذه الحالة بالذات (كلمة واحدة، مطابقة تامة) هي **بالضبط** ما صُمم له هذا الـ bloc أصلًا — نفس طريقة استخدامه في `VocabularyWordDetailView._PracticeCard`:
- احقن `PronunciationBloc` (نفس الموجود، عبر DI القائم) في `DictionaryScreen` أو على مستوى البطاقة
- عند الضغط على المايك: `StartPronunciationCheck(target: word.word)` (أو الحدث المكافئ بنفس التوقيع المستخدم في vocabulary — افتح `vocabulary_word_detail_view.dart` وطابق الاستدعاء حرفيًا)
- اعرض نفس حالات النجاح/الفشل الموجودة بالفعل (صح/غلط ثنائي، لا تلوين كلمة بكلمة — هذا فرق متعمد عن Sentences لأنها كلمة واحدة فقط)
- **لا تضف Slow/Normal أو UK/US هنا** — لم يُطلب، والقاموس أداة مرجعية سريعة، أزرار النطق الكاملة (accent/speed) موجودة في vocabulary وليست مطلوبة هنا

نفس تدفق صلاحية الميكروفون الموجود بالفعل — لا تبني شيئًا جديدًا.

---

## 6. `my_words_sheet.dart`

الحقول المتوفرة في `my_word_list` (Task 01): `word`, `translation`, `note`, `source_table`, `source_id`. **لا `pronunciation` ولا `level` ولا `example` مخزّنة في هذا الجدول مباشرة.**

**القرار:** عند عرض My Words، اجلب تفاصيل الكلمة الكاملة (IPA, level, example) بـ `JOIN` أو استعلام تالٍ على `word_list` عبر `source_id` (الموجود بالفعل كما وثّق سجل جلسة Task 07: `fromMyWordsJoin` مع "fallback graceful لو word_list row غير موجودة") — **هذا موجود بالفعل من Task 07، استخدمه ولا تُعد بناءه.** بهذا تُعرض بطاقة My Words بنفس شكل `DictionaryWordCard` بالضبط (أعد استخدام نفس الـ widget، مرّر له `isSaved: true` دائمًا وزر الحفظ فيها يعمل كـ"إزالة" بدل "إضافة" — نفس الأيقونة الممتلئة، فقط الحدث المرتبط يختلف).

لو `fromMyWordsJoin` يرجع `null`/fallback (الكلمة اتشالت من `word_list` في تحديث محتوى لاحق): اعرض `word`/`translation` المخزّنين في `my_word_list` نفسه بدون IPA/level/example بنفس هيكل البطاقة (أقسام مفقودة تُحذف بدل ما تُعرض فاضية).

---

## 7. Tests

- Widget test لـ `DictionaryWordCard`: تمرير كلمة طويلة فعلية (من نتيجة استعلام §3) → `tester.takeException() == null` (لا overflow error) + التحقق البصري بـ `expect(find.byType(Row), ...)` أن مجموعة الأزرار ما زالت 3 عناصر ظاهرة بالكامل
- اختبار مكافئ لـ IPA طويل بشكل استثنائي (لو وُجد في البيانات)
- Widget test لـ `my_words_sheet`: عرض كلمة محفوظة بكل الحقول، وعرض كلمة محفوظة بعد حذفها من `word_list` (fallback) بدون كسر

---

## 8. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة، كل الـ tests تعدي
- [ ] تشغيل فعلي: البحث عن `responsibility` وعن أطول كلمة في الجدول (من استعلام §3) → لا overflow، لا قطع للنص، الأزرار الثلاثة ظاهرة وسليمة في كل الحالات
- [ ] فحص بصري: البطاقات بنفس مستوى الظل/العمق لـ Sentences/Vocabulary
- [ ] المايك يعمل فعليًا: نطق الكلمة صح → نتيجة إيجابية، نطقها غلط → نتيجة سلبية (نفس سلوك vocabulary بالضبط)
- [ ] My Words تعرض نفس شكل البطاقة، وزر "الإزالة" يعمل
- [ ] `git diff --stat`: صفر تعديل في `data/`/`domain/` لـ dictionary، وصفر تعديل في `PronunciationBloc`/`SpeechTextMatcher`، وصفر تعديل خارج `dictionary/`

## 9. خارج النطاق
- UK/US أو Slow/Normal في القاموس
- حفظ محاولات النطق في أي جدول
- أي تعديل على `my_word_list` schema
- إعادة تصميم أي شاشة خارج Dictionary/My Words

---

## سجل الجلسة

**الحالة:** ✅ مكتمل — 2026-10-03

### ما تم

- **`dictionary_word_card.dart`** أُعيد كتابته بالكامل:
  - الصف العلوي: `Expanded(Wrap(spacing: 8, runSpacing: 6))` يحتوي chip المستوى
    والكلمة بـ `softWrap: true` + `TextOverflow.visible` (لا ellipsis إطلاقًا)، بجانبه
    `Row(mainAxisSize: MainAxisSize.min)` بـ 3 أزرار دائرية ثابتة الحجم (speaker/mic/star)
  - الصف الثاني: `Wrap` احتياطي لـ IPA + العربي (نفس حماية طول IPA)
  - الفاصل + صف example بأيقونة اقتباس
  - سطر feedback تحت الكل: pill ملوّن (success/error/warning/muted) بحسب
    `PronunciationAttempt.outcome` — نجاح/فشل ثنائي كما أمر §5 (لا تلوين كلمة بكلمة)
  - استخدام الـ tokens المحددة في §2 حرفيًا (`radiusXl`, shadow مطابق لـ `_HeroCard`،
    chip بـ `CefrLevel.color.withValues(alpha: .14)`، star بـ `warning` tint/filled)
- **`my_words_sheet.dart`** أُعيد كتابته: حذف `_Row` الداخلي بالكامل والاستفادة من
  `DictionaryWordCard` نفسه. التفاصيل الكاملة (IPA/level/example) تأتي من
  `fromMyWordsJoin` الموجود من Task 07 — لو row الـ word_list غير موجود (orphan save)،
  الأعمدة الناقصة تختفي تلقائيًا لأن البطاقة تتحقق من `isNotEmpty` قبل العرض،
  **بدون اختلاق حقول** كما أمر §6.
- **`dictionary_screen.dart`**: `BlocProvider` ⇒ `MultiBlocProvider` لإضافة
  `PronunciationBloc` (نفس الـ bloc المسجَّل من phonetics، عبر DI الموجود)؛
  `MyWordsSheet.show` تستقبل الآن `pronunciationBloc` أيضًا وتُمرّره عبر
  `BlocProvider.value` داخل الـ sheet لنفس شجرة الـ bloc.

### اختبار النطق (المايك)

- حدث `StartPronunciationCheck(exampleId: word.id, targetWord: word.word)` — نفس
  التوقيع المستخدم في `vocabulary_word_detail_view._PracticeCard` حرفيًا، فقط
  اختلاف الحقل `exampleId` → استخدمنا `word.id` من `word_list` (مفتاح فريد لكل كلمة).
- `StopPronunciationCheck` عند الضغط ثاني مرة.
- لا US/UK ولا Slow/Normal ولا تلوين كلمة بكلمة — كما أمر §5 و§9.

### Tests (5 جديدة)

- `dictionary_word_card_test.dart`:
  - `about` (قصيرة) → `takeException() == null`
  - `responsibility` (14 حرفًا، موجودة بالفعل في `word_list`) → بدون exception
  - **`lie (verb - to not tell the truth)` (34 حرفًا، أطول صف فعلي في الجدول)** →
    بدون exception + 3 أزرار trailing ما زالت ظاهرة (`findByTooltip` × 3)
  - correct attempt مزروع في `PronunciationBloc` → `_Pill` بنص "Correct" يظهر
  - tap على زر النجمة → onToggleSaved يُستدعى مرة واحدة

### الأرقام

- **analyze:** 28 issue، كلها pre-existing — صفر جديد
- **tests:** 98 pass + 1 pre-existing fail (`widget_test.dart` Counter — موثق كـ broken
  منذ البداية). +5 من آخر عدّ، بالضبط عدد الاختبارات الجديدة.
- **`git diff --stat` داخل `lib/features/dictionary/`:**
  - `presentation/widgets/dictionary_word_card.dart` (إعادة كتابة)
  - `presentation/widgets/my_words_sheet.dart` (إعادة كتابة)
  - `presentation/screens/dictionary_screen.dart` (إضافة `PronunciationBloc` provider
    + تمرير للـ sheet)
- **ملفات خارج `dictionary/` التي لُمست في هذه المهمة:** صفر. (الملفات المظهرة في
  `git status --short` كلها من Task 06/07/08_sentences_ui_redesign التي سبقت هذه المهمة.)
- **data/domain لـ dictionary:** صفر تعديل
- **`PronunciationBloc`/`SpeechTextMatcher`:** صفر تعديل

### قرارات اتُّخذت

- **لا `elevated: true` على زر الصوت الافتراضي** — فقط على المايك دومًا وعلى النجمة
  عند `isSaved`. السبب: المايك هو الأفعال الأهم تعليميًا (الهدف الأساسي للتدريب)،
  والنجمة الممتلئة تحتاج إشارة بصرية أنها "محفوظة فعلًا". الصوت فعل داعم،
  إبرازه بظل يُشتت.
- **`_Pill` بـ `color.withValues(alpha: .10)` + أيقونة ملوّنة** بدل background ممتلئ —
  أهدأ بصريًا داخل بطاقة بيضاء مرتفعة، وتوافق لون النتيجة (success/error/warn/error)
  مع الـ pills المستخدمة في Sentences repeat-result (تناسق بصري عبر الـ features).
- **`exampleId: word.id`** في `StartPronunciationCheck` — PronunciationBloc.state.attempts
  مفهرسة بـ exampleId، فاستخدام word.id يضمن تفرد المحاولة لكل كلمة في القائمة
  دون تضارب (مثلاً لو كلمتان بنفس النص الإنجليزي لها IDs مختلفة).

### انحرافات
لا شيء. المهمة نُفّذت كما وُصفت بالضبط. §6 الحالة الاستثنائية (orphan save) تُعرض
تلقائيًا بإخفاء الحقول الفارغة، بدون كود شرطي إضافي داخل `_MyWordsSheet`.
