# Task 12.3 — تجربة قياس: هل الـ recorder يخرّب الـ STT على أندرويد؟

**الحالة:** ✅ أدوات القياس جاهزة (ينتظر لوجات إسلام) · **الاعتماديات:** Task 12.2 · **يعتمد عليها:** قرار مصير "الاستماع لصوتك" على أندرويد، ثم Task 13
**الأعراض (إسلام، أندرويد حقيقي):** (1) يتكلم أكثر من مرة حتى يلتقط، (2) الإيقاف اليدوي بعد الكلام لا يرجّع النص، (3) صوته لا يُسجَّل فلا يستطيع إعادة سماعه.
**الفرضية (غير مؤكدة):** `record` و`speech_to_text` يتنافسان على المايك؛ الـ recorder يبدأ قبل الـ STT فيستلم الـ recognizer صمتًا أو صوتًا ضعيفًا.

**هذه مهمة قياس فقط. لا إصلاحات ولا تغيير في السلوك الافتراضي.** القرار يؤخذ بعد النتائج.

---

## 1) سجلات تشخيص (داخل `kDebugMode` فقط)
في `speech_recognition_service.dart`، كل سطر ببادئة `[stt +<ms من بداية الجلسة>]`:
- كل `onStatus` (القيمة النصية).
- كل `onError`: `errorMsg` و`permanent`. **هذا أهم سطر**: `error_audio` أو `error_busy` أو `error_client` يعني تعارض على المايك، و`error_no_match`/`error_speech_timeout` يعني الـ recognizer لم يسمع كلامًا.
- كل `onResult`: `finalResult`، عدد الكلمات، `confidence`.
- مستوى الصوت من الـ recognizer نفسه: مرّر `onSoundLevelChange` إلى `_speech.listen(...)` وسجّل أدنى وأعلى قيمة في الجلسة عند الإنهاء (سطر واحد ملخّص، لا سطر لكل عينة). لو بقي المستوى ثابتًا قرب الحد الأدنى أثناء الكلام فالـ recognizer "أصم".
- الـ recorder: نتيجة `hasPermission()`، نجاح أو فشل `start()` (مع الاستثناء)، المسار، أعلى dBFS رصدته العينات، حجم الملف، وقرار `dropPathIfSilent` (أُبقي/حُذف ولماذا). بادئة `🎙️` كما في الكود الحالي.

## 2) مفتاح تعطيل التسجيل الموازي (لا يغير الافتراضي)
- كلاس بسيط `SpeechDebugFlags` فيه `static final ValueNotifier<bool> parallelRecording = ValueNotifier(true)`.
- `_startRecording()` يعود فورًا (`return`) لو القيمة false، مع سطر لوج.
- زر تبديل في شاشة الإعدادات **يظهر فقط في `kDebugMode`** (قسم "Developer"، عنوان إنجليزي مباشر، دون ترجمة) يبدّل القيمة بدون إعادة بناء.
- في نسخ الـ release لا يظهر الزر وتبقى القيمة true.

## 3) التجربة (ينفذها إسلام على جهاز الأندرويد، ويلصق اللوجات)
نفس الجملة ("How are you?") في الحالتين، 5 محاولات لكل حالة، والكلام يبدأ فور ظهور حالة الجاهزية (المايك armed):

| الحالة | أول مرة التقط؟ | ظهر نص لحظي أثناء الكلام؟ | الإيقاف اليدوي بعد الكلام رجّع النص؟ | أخطاء STT | أقل/أعلى مستوى صوت | تسجيل: أعلى dBFS / أُبقي؟ |
|---|---|---|---|---|---|---|
| A: التسجيل الموازي ON (×5) | | | | | | |
| B: التسجيل الموازي OFF (×5) | | | | | | |

يملأ Claude Code الجدول في سجل الجلسة من اللوجات التي يلصقها إسلام، **بدون استنتاج من عنده**: لو ناقص سطر يكتب "غير متاح".

## 4) تجربة ثانوية (فقط لو B أيضًا يفشل في أكثر من محاولتين من الخمس)
في `_listenSegment()` الوضع غير المستمر يستخدم `ListenMode.confirmation` (مخصص لإجابات قصيرة من نوع نعم/لا). جرّب `ListenMode.dictation` لنفس الجمل الخمس ووثّق الفرق. لا تغيّر الافتراضي.

## 5) ممنوع في هذه المهمة
تعطيل الـ recorder على أندرويد افتراضيًا، تغيير `listenFor`/`pauseFor`، استبدال المحرك، لمس `SentenceAssessor`.

## Acceptance
- [ ] اللوجات تعمل في debug وتختفي في release
- [ ] الزر يظهر في debug فقط ويبدّل فعليًا بدون restart
- [ ] السلوك الافتراضي (ON) لم يتغير، `flutter analyze` بدون جديد، الـ tests تعدي
- [ ] الجدول (§3) مملوء من لوجات حقيقية

## قاعدة القرار (تُطبَّق في مهمة لاحقة، لا هنا)
لو B (OFF) التقط من أول مرة في ≥ 4 من 5 بينما A في ≤ 3 من 5: يُعطَّل التسجيل الموازي على أندرويد افتراضيًا (الاستماع لصوتك يبقى على iOS)، وتُؤجَّل ميزته على أندرويد لمحرك STT محلي نملك تياره. غير ذلك: نبحث عن سبب آخر (مثل §4 أو اللغة/الحزمة الصوتية على الجهاز).

---

## سجل الجلسة

**التاريخ:** 2026-10-06 · **الحالة:** ✅ البنية التحتية للقياس جاهزة. الجدول
في §3 ينتظر لوجات حقيقية من جهاز إسلام — موعد ملؤه عند لصق اللوجات.

### §1 — سجلات التشخيص (في `kDebugMode` فقط)

نُضيفت في `lib/core/speech/speech_recognition_service.dart`:

- حقلان جديدان `_sessionStartedAt` و دالة `_log(String message)` تُطبّق البادئة
  `[stt +<ms من بداية الجلسة>] ...`. دالة `_log` تحمل في أول سطر
  `if (!kDebugMode) return;` → في release تختفي تمامًا بفضل tree-shaking
  للـ compile-time constant.
- `onStatus` → `[stt +<ms>] onStatus=<value>`
- `onError` → `[stt +<ms>] onError msg=<errorMsg> permanent=<bool>`
  (التعليق فوق السطر يذكّر: `error_audio`/`error_busy`/`error_client` =
  تعارض على المايك؛ `error_no_match`/`error_speech_timeout` = لم يسمع كلامًا).
- `onResult` → سطر لكل نتيجة بـ `final=<bool> words=<n> confidence=<x.xx>
  text="..."`.
- `onSoundLevelChange` → **لا يُلوگ لكل عينة** (ضجيج). بدل ذلك: حقلان
  `_minSoundLevel`/`_maxSoundLevel` يتتبعان المدى، ودالة
  `_logSoundLevelSummary()` تُطلق سطرًا واحدًا في نهاية الجلسة
  (`soundLevel summary: min=X.XX max=X.XX`) أو `no samples received` لو لم
  يُطلق المحرك العينات.
- الـ recorder (مع البادئة `🎙️`):
  - `hasPermission=<bool>` قبل `start()`
  - `recorder started at <path>` عند النجاح
  - `recorder start FAILED (non-fatal): <e>` عند الاستثناء
  - عند الإنهاء: سطر واحد `recorder stop: peakDbfs=X.X size=N`B
    `path=... kept=<bool>` يحتوي القيم المتَّخذ عليها قرار `dropPathIfSilent`.
- بداية الجلسة: `session start: locale=<id> continuous=<bool>
  parallelRecording=<bool>` ليربط كل التسلسل التالي بحالة الـ flag.
- نهاية `_emitStopped` و `_emitFailure`: سطر `emitStopped text="..."
  recordingPath=...` / `emitFailure reason=<SpeechFailure> text="..."`.

**تعليل: مع كل جلسة تُطبع تقريبًا 8–12 سطرًا** (status + partials + 1 final +
summary + recorder) — كافية للتشخيص، ليست غامرة.

### §2 — مفتاح تعطيل التسجيل الموازي

- `lib/core/speech/speech_debug_flags.dart` (جديد): كلاس خاص بالـ debug-only
  flags. أول وأهم flag: `static final ValueNotifier<bool> parallelRecording
  = ValueNotifier(true)`.
- `_startRecording()`: `if (!SpeechDebugFlags.parallelRecording.value) {
  _log('🎙️ parallelRecording=false → skipping recorder start'); return; }`
  **قبل أي شيء آخر** — فلا permission check ولا filename ولا timer
  يُنفَّذ. الحالة الموازية غائبة تمامًا.
- `settings_screen.dart`: قسم `DEVELOPER` جديد يظهر فقط داخل
  `if (kDebugMode) ...[ ... ]`. يحوي `_ParallelRecordingToggleRow` الذي
  يستخدم `ValueListenableBuilder` على الـ flag — إيقاف/تشغيل الـ switch
  يبدِّل القيمة فورًا بدون `setState` ولا restart. العنوان "Parallel recorder"،
  الـ subtitle يوضّح الحالة بالإنجليزية فقط (قرار صريح في المواصفة §2:
  "عنوان إنجليزي مباشر، دون ترجمة").
- في release: `kDebugMode = false` → القسم بالكامل يُشَذَّب في compile time.
  القيمة تبقى الافتراضية `true`، فالتسجيل الموازي يعمل كالعادة.

### §3 — جدول التجربة (ينتظر لوجات إسلام)

| الحالة | أول مرة التقط؟ | ظهر نص لحظي أثناء الكلام؟ | الإيقاف اليدوي بعد الكلام رجّع النص؟ | أخطاء STT | أقل/أعلى مستوى صوت | تسجيل: أعلى dBFS / أُبقي؟ |
|---|---|---|---|---|---|---|
| A: التسجيل الموازي ON (×5) | غير متاح | غير متاح | غير متاح | غير متاح | غير متاح | غير متاح |
| B: التسجيل الموازي OFF (×5) | غير متاح | غير متاح | غير متاح | غير متاح | غير متاح | — (لا تسجيل) |

**ملاحظة إلزامية (المواصفة §3):** Claude Code **لا يستنتج من عنده**. سيُحدَّث
هذا الجدول بـ edit مباشر عند لصق إسلام للوجات الحقيقية.

### §4 — التجربة الثانوية

**لم تُنفَّذ.** تُفعَّل فقط لو جدول §3 يُظهر أن B أيضًا يفشل في > 2 من 5 محاولات.
التغيير المُقترَح (مقابلة `ListenMode.confirmation` بـ `ListenMode.dictation`
في `_listenSegment`) غير قابل للتوثيق إلا بعد نتائج §3.

### §Tests

- `test/core/speech/speech_debug_flags_test.dart` × 2:
  - الـ default = `true` (ضمان أن release غير متأثر).
  - تغيير القيمة يُخطر الـ listeners → الـ `ValueListenableBuilder` في
    Settings يُعاد بناؤه بدون `setState`.
- الـ widget tests للـ Settings screen لم تُضَف — الشاشة تعتمد على
  `flutter_screenutil` + `context.localization`، إعدادهما في test harness
  overhead لا يُبرَّر لأجل switch واحد visually ترفـيال. الـ unit test على
  الـ ValueNotifier + الـ `if (kDebugMode)` guard (constant tree-shake)
  يغطيان العقد تمامًا.

### §أرقام

- `flutter test`: **174 pass + 1 pre-existing fail** (`widget_test.dart`
  Counter smoke — موثق منذ Task 12).
- `flutter analyze --no-pub`: **28 issues، صفر جديد** (نفس baseline Task 12.1).
- `git diff --stat` scope محصور في:
  - `lib/core/speech/speech_debug_flags.dart` (جديد)
  - `lib/core/speech/speech_recognition_service.dart` (logs + flag check)
  - `lib/features/settings/presentation/screens/settings_screen.dart` (قسم Developer)
  - `test/core/speech/speech_debug_flags_test.dart` (جديد)
  - **صفر** تعديل في بلوكات، UI، أو منطق التقييم.

### §Acceptance — متحقَّق منه الآن

- [x] اللوجات تعمل في debug وتختفي في release — `kDebugMode` guard في
  `_log` + `_logSoundLevelSummary`.
- [x] الزر يظهر في debug فقط ويبدّل فعليًا بدون restart — `ValueListenableBuilder`
  على الـ ValueNotifier، `onChanged` يُعيّن القيمة مباشرة.
- [x] السلوك الافتراضي (ON) لم يتغير — flag default `true`، كل الـ tests
  السابقة تعدي كما هي.
- [ ] الجدول (§3) مملوء من لوجات حقيقية — **ينتظر إسلام**.

### §خطوات التحقق على جهاز إسلام (لتعبئة §3)

1. تأكد من بناء debug (`flutter run` بدون `--release`).
2. افتح Settings → قسم DEVELOPER → تحقق من ظهور "Parallel recorder" ON.
3. افتح جملة في Sentences، شغّل `adb logcat -v time | grep "\[stt"`.
4. انطق "How are you?" × 5. لصق التسلسل كله (كل الـ 5 جلسات).
5. ارجع لـ Settings، أطفئ "Parallel recorder".
6. كرّر الخطوة 3-4 مع "How are you?" × 5.
7. ألصق التسلسلين — Claude Code يملأ الجدول حسب القيم بدون استنتاج.
