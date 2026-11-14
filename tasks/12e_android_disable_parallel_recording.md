# Task 12.4 — أندرويد: إيقاف التسجيل الموازي + حاجز مدة التسجيل

**الحالة:** ✅ كود + tests (جدول §5 ينتظر لوجات إسلام) · **الاعتماديات:** Task 12.2 + 12.3 · **يعتمد عليها:** Task 13
**القرار (إسلام، 2026-10-06):** على أندرويد الـ STT يعمل لوحده بدون `record`، و"الاستماع لصوتك" يبقى على iOS.

**الأدلة:**
- لوجات أندرويد حقيقية، 3 جلسات من 3 (أطوال 4.5 و6.3 و7.2 ثانية): الملف دائمًا `6304B` و`encoded 4 frames` (حوالي 0.25 ثانية)، مهما طالت الجلسة.
- توثيق حزمة `speech_to_text` نفسه يذكر أن تسجيل الصوت أثناء التعرف على الكلام غير ممكن حاليًا على أندرويد.
- الـ recorder لا يعطي شيئًا على أندرويد، ويشارك الـ STT نفس المايك (وهو ما يشتكي منه إسلام: يحتاج محاولات كثيرة حتى يلتقط).

---

## 1) سياسة التسجيل حسب المنصة
- أنشئ دالة/ثابت واحد `SpeechRecordingPolicy` (في `core/speech/`) يجيب على سؤال واحد: هل التسجيل الموازي مسموح؟
  - iOS: نعم.
  - أندرويد: لا (في release دائمًا).
  - باقي المنصات: لا.
- `SpeechDebugFlags.parallelRecording` (من Task 12.3) يبقى للتجارب فقط: في debug يستطيع الزر في الإعدادات تفعيل التسجيل على أندرويد لأغراض المقارنة، وقيمته الافتراضية على أندرويد false.
- `_startRecording()` يعود فورًا (سطر لوج واحد بادئته 🎙️) عندما تمنع السياسة التسجيل. لا يُنشأ `AudioRecorder` ولا يُطلب `hasPermission()` ولا يُشترك في `onAmplitudeChanged`.
- لا تغيير في ترتيب بدء الـ STT على أندرويد عدا أنه لم يعد يمر بـ `await _startRecording()` (يقلل زمن الجاهزية).
- الاختبارات: السياسة قابلة للحقن (دالة `isSupported()` يمكن استبدالها)، ولا تعتمد الاختبارات على المنصة الفعلية.

## 2) حاجز مدة التسجيل (يعمل حيث التسجيل مسموح)
المشكلة التي ظهرت: ملف سليم الحجم لكنه يغطي جزءًا صغيرًا من الجلسة. حاجز الصمت لا يلتقطه لأنه يفحص أعلى سعة فقط.
- سجّل زمن بدء التسجيل ونهايته (wall-clock) لحساب طول الجلسة.
- بعد `stop()`، اقرأ مدة الملف الفعلية (نسخة مؤقتة من `AudioPlayer` من `audioplayers` + `DeviceFileSource` + `getDuration()` ثم `dispose()`؛ مرّر دالة القياس كمعامل قابل للحقن للاختبار).
- إن كانت الجلسة ≥ 1.5 ثانية ومدة الملف < 60% من طول الجلسة → اعتبر التسجيل غير صالح: `_recordingPath = null`، احذف الملف، سطر لوج بالقيمتين.
- أي فشل في قياس المدة (استثناء أو null) لا يُسقط الجلسة: اترك المسار كما هو بعد الفحوص الأخرى (حجم، صمت).
- النسبة (60%) والحد الأدنى (1.5 ثانية) ثوابت مسماة قابلة للتعديل.

## 3) إبقاء ما سبق
- حاجز الصمت `dropPathIfSilent` يبقى كما هو.
- شرط "ومعنا نص من الـ STT" في `dropPathIfSilent`: **احذفه** (قرار إسلام: الصمت يخفي الزر في كل الحالات، بما فيها "Didn't catch that"، لأن زر يشغّل صمتًا لا قيمة له).
- كل سجلات `[stt +…ms]` تبقى (debug فقط).
- لا تغيير في واجهات الأسطح الستة: `PlayMyVoiceButton` يختفي تلقائيًا عند `recordingPath == null`.

## 4) Tests
- السياسة: iOS true، أندرويد false، أخرى false؛ وفي debug مع تفعيل الزر على أندرويد true.
- `_startRecording` مع سياسة false: لا يُنشأ recorder ولا يُطلب الإذن (mock).
- حاجز المدة: جلسة 5 ثوانٍ وملف 0.25 ثانية → null؛ ملف 4.8 ثانية → المسار محفوظ؛ جلسة 1 ثانية (أقل من الحد) → لا فحص؛ فشل القياس → المسار محفوظ.
- `dropPathIfSilent` بدون شرط النص: صمت + نص فاضي → null.

## 5) Acceptance (يُنفَّذ على أندرويد حقيقي، وتُسجَّل النتائج)
- [ ] 5 محاولات متتالية بنفس الجملة: كم منها التقط من أول مرة؟ وكم ظهر فيها نص لحظي أثناء الكلام؟
- [ ] 5 محاولات إيقاف يدوي بعد الكلام: كم منها رجّع النص؟
- [ ] لا يظهر زر الاستماع على أندرويد (متوقع)، ولا أخطاء جديدة في اللوج
- [ ] iOS: الاستماع لصوتك يعمل كما كان (محاولتان على الأقل)
- [ ] `flutter analyze` بدون جديد، الـ tests تعدي
- [ ] `git diff --stat` محصور في `core/speech/` والإعدادات (زر debug إن لزم)

## خارج النطاق
محرك STT محلي، `EXTRA_AUDIO_SOURCE` الأصلي (Kotlin)، تغيير `listenFor`/`pauseFor`/`ListenMode` (يُقرَّر بعد قياس الدقة بدون الـ recorder)، ميزة الاستماع على أندرويد.

---

## سجل الجلسة

**التاريخ:** 2026-10-06 · **الحالة:** ✅ كود + tests. جدول §Acceptance ينتظر
نتائج إسلام على جهاز حقيقي (خارج قدرة Claude Code).

### §1 — سياسة التسجيل حسب المنصة

- **ملف جديد:** `lib/core/speech/speech_recording_policy.dart`.
  - دالة ثابتة `isSupported() → bool`: `Platform.isIOS` فقط. الكل غير ذلك
    (أندرويد، ويب، desktop) = `false`.
  - `_override: bool Function()?` قابل للحقن عبر
    `setTestOverride(fn)` → **لا تعتمد الاختبارات على المنصة الفعلية** حسب §1.
  - الـ try/catch حول قراءة `Platform.*` منع crash على web (حيث dart:io قد
    يرمي).
- **تعديل `SpeechDebugFlags.parallelRecording`:** قيمته الابتدائية الآن
  `SpeechRecordingPolicy.isSupported()` بدل `true` ثابت.
  - iOS: `true` (كان).
  - Android: `false` (جديد).
  - test host: `false` (ليس iOS).
- **تعديل `_startRecording()`:** الفحص الآن طبقتان:
  ```
  if (!policyAllows && !flagAllows) → skip (release Android steady state)
  if (!flagAllows) → skip (iOS debug toggle OFF)
  ```
  وبخلاف ذلك ينشأ الـ recorder. المنطق يسمح للـ debug toggle على أندرويد
  بتفعيل التسجيل (`flagAllows=true` ولو `policyAllows=false`) لأغراض
  المقارنة فقط.
- في release Android: الـ Settings toggle مخفي خلف `kDebugMode` → الـ flag
  يبقى `false` → لا `AudioRecorder()`، لا `hasPermission()`، لا
  `onAmplitudeChanged`. السطر الوحيد: `[stt +Xms] 🎙️ recording blocked
  (policy=false, flag=false) → skipping`.
- زمن الجاهزية على أندرويد: `await _startRecording()` ما زال موجودًا لكنه
  يرجع فورًا بعد log سطر واحد (microseconds) — عمليًا nil overhead.

### §2 — حاجز مدة التسجيل

- **ثابتان جديدان:** `_minSessionForDurationCheck = 1500ms`،
  `_minDurationRatio = 0.6`.
- **`static dropPathIfTooShort({path, sessionDuration, measure, …})`** —
  `@visibleForTesting` static مثل `dropPathIfSilent`. يقرأ مدة الملف
  الفعلية عبر دالة `measure` قابلة للحقن:
  - `path == null` → `null`.
  - `sessionDuration < 1.5s` → يحتفظ (نقرة قصيرة طبيعية).
  - `measure` يرمي أو يرجع `null` → يحتفظ (لا نُسقِط على فشل قياس).
  - `fileDuration.ms / sessionDuration.ms >= 0.6` → يحتفظ.
  - غير ذلك → `null` + حذف الملف.
- **`_measureAudioDuration(path)`** — `AudioPlayer` مؤقَّت من
  `audioplayers`، `DeviceFileSource(path).setSource` ثم `getDuration()`،
  وفي `finally` دائمًا `dispose()`. الاستثناءات تُبلَع وترجع `null`.
- **`setDurationMeasurerForTest(fn?)`** — حقن اختياري على instance حتى
  لا نحتاج تمرير plugin mock.
- **ربط في `_stopRecording()`:** بعد `dropPathIfSilent` مباشرة:
  ```
  if (_recordingPath != null && sessionStart != null) {
    _recordingPath = await dropPathIfTooShort(
      sessionDuration: now - sessionStart,
      measure: _durationMeasurer ?? _measureAudioDuration,
      ...
    );
  }
  ```

### §3 — إبقاء ما سبق + تعديل `dropPathIfSilent`

- **حذفت شرط `recognizedText`** من `dropPathIfSilent` (قرار إسلام 2026-10-06):
  صمت = حذف دائمًا، حتى في "Didn't catch that". التوقيع الجديد:
  `dropPathIfSilent({path, peakDbfs, threshold})`.
- جميع الاستدعاءات داخل الـ service حُدِّثت.
- سجلات `[stt +Xms]` (Task 12.3) تبقى كما هي، كلها خلف `kDebugMode` guard.
- `PlayMyVoiceButton`: صفر تغيير — المسار `null` → `SizedBox.shrink` تلقائيًا.

### §Tests

- `test/core/speech/speech_recording_policy_test.dart` × **3 جديد**:
  - override `true` → iOS semantics.
  - override `false` → Android semantics.
  - clearing override على test host → `false` (نفس أندرويد release).
- `test/core/speech/speech_debug_flags_test.dart`: استبدلت test "default = true"
  (لم يعد صحيحًا) بـ comment موثِّق الاعتمادية على policy. تبقى test
  الـ notifier بعد seed صريح.
- `test/core/speech/speech_recognition_service_recording_test.dart`:
  - `dropPathIfSilent` × 5 (بدل 6): حذفت "text empty keeps path" (أصبحت
    "silent → null بغض النظر عن النص").
  - **`dropPathIfTooShort` × 7 جديد:**
    - `path null` → null.
    - session < 1.5s → تجاوز الفحص.
    - 5s session + 0.25s file (الـ fingerprint الفعلي من لوجات إسلام) →
      null + حذف.
    - 5s + 4.8s → kept.
    - `measure` يرجع null → kept.
    - `measure` يرمي → kept.
    - ratio = 0.6 بالضبط → kept (الحد غير صارم: `>=`).
- تحديثات اعتمادات (استدعاءات `dropPathIfSilent` بدون `recognizedText`
  في الـ widget tests): لا شيء — الـ widget tests كانت تختبر الـ UI
  وليست الـ static مباشرة.

### §أرقام

- `flutter test`: **182 pass + 1 pre-existing fail** (Counter smoke).
  Baseline Task 12.3 كان 174، فأضفت 8 صافي (10 جديد – 2 محذوف بسبب تغيير
  السلوك).
- `flutter analyze --no-pub`: **28 issues، صفر جديد**.
- `git diff --stat` scope:
  - `lib/core/speech/speech_recording_policy.dart` (جديد)
  - `lib/core/speech/speech_debug_flags.dart` (default = policy)
  - `lib/core/speech/speech_recognition_service.dart` (طبقتان في
    `_startRecording`, `dropPathIfSilent` بدون نص، `dropPathIfTooShort`،
    `_measureAudioDuration`، `_durationMeasurer`)
  - 3 ملفات test
  - **صفر** تعديل في: Settings UI (الزر من 12.3 يُستفاد منه مباشرة)،
    بلوكات، UI الأسطح الستة، `SentenceAssessor`/`SpeechTextMatcher`.

### §Acceptance (§5) — ينتظر جهاز إسلام

| البند | الحالة | ملاحظة |
|---|---|---|
| 5 محاولات ON (بنفس الجملة) — كم التقط من أول مرة؟ ونص لحظي؟ | ⏳ غير متاح | ينتظر لوجات |
| 5 محاولات إيقاف يدوي — كم رجّع النص؟ | ⏳ غير متاح | ينتظر لوجات |
| أندرويد: لا زر استماع، لا أخطاء | ⏳ غير متاح | متوقع بناءً على policy |
| iOS: الاستماع لصوتك يعمل كما كان | ⏳ غير متاح | يحتاج iOS build |
| `flutter analyze` بدون جديد | ✅ | 28/28، صفر جديد |
| tests تعدي | ✅ | 182 pass + 1 pre-existing fail |
| `git diff --stat` محصور في `core/speech/` + settings (debug) | ✅ | §أرقام أعلاه |

**خطوات التحقق المتبقية (على جهاز إسلام):**
1. أندرويد release-equivalent: `flutter run --profile` → Settings لا يظهر
   فيها "DEVELOPER" (الـ toggle مخفي). افتح جملة في Sentences، تكلم 5 مرات،
   تحقق:
   - زر "Hear what you said" لا يظهر مطلقًا.
   - اللوج: `recording blocked (policy=false, flag=false)` مرة واحدة لكل
     جلسة.
   - لا تحسُّن مطلوب في الـ STT (نفس الدقة) — إن كان قبل أندرويد "محاولات
     كثيرة قبل الالتقاط"، يجب الآن ≤ 2 لكل جملة.
2. أندرويد debug + toggle ON: نفس الاختبار، نتوقع عودة السلوك القديم (تسجيل
   صامت، الزر يظهر ثم يختفي بـ `dropPathIfSilent` أو `dropPathIfTooShort`).
   وجود `dropPathIfTooShort` يحمي حتى لو مرَّ `dropPathIfSilent`.
3. iOS: 2+ محاولات أي سطح به مايك → الاستماع يعمل كما قبل Task 12.4.

### §انحرافات
- **لم أزل الـ `AudioRecorder` + `onAmplitudeChanged` من الـ service.**
  السبب: هم ضروريين على iOS، والـ policy يعزلهم عن أندرويد عبر الـ
  `return` المبكر في `_startRecording()`. حذفهم كان سيكسر iOS.
- `AudioPlayer` من `audioplayers` يُنشأ ويُدمَّر لقياس المدة. تكلفة
  التهيئة ~10-50ms. مقبولة لأنها تقع بعد الـ emit النهائي للـ bloc (في
  `_stopRecording` بعد `_speech.stop`)، فالمستخدم يرى النتيجة فورًا بغض
  النظر.
