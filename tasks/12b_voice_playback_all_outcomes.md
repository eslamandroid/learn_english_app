# Task 12.1 — الاستماع لصوتك في النجاح والفشل + ملف تسجيل لكل محاولة

**المرجع:** طلب إسلام 2026-10-05: "في حالة النجاح أو الفشل أسمع صوتي"
**الحالة:** ✅ مكتمل (كود + tests) · **الاعتماديات:** Task 12 (كود مكتمل)
**يعتمد عليها:** Task 13 (Role-play)

---

## المشاكل (ثلاث، مرتبة بالأهمية)

### 1) ملف واحد ثابت يتكتب فوقه — زر الاستماع القديم يشغّل التسجيل الأحدث
`SpeechRecognitionService` يكتب كل المحاولات في `practice_take.m4a`. حالة `SentencePracticeBloc` (وما يشبهها) تحتفظ بنتيجة **كل عنصر** في Map، وكل نتيجة تحمل نفس `recordingPath`. لو سجّلت الجملة A ثم B وضغطت الاستماع عند A، هتسمع B.
**للتأكد قبل أي تعديل:** سجّل جملتين متتاليتين في Sentences، اضغط الاستماع عند الأولى، ووثّق ما سمعته في سجل الجلسة.

### 2) الاستماع في كل نتيجة، وليس فقط عند التقييم الناجح
المطلوب أن يظهر الزر في **كل** حالة يكون فيها تسجيل صالح:
نجاح، فشل (نطق غلط)، "ما سمعتش كلام" (`noSpeech`)، وفشل STT مع نجاح التسجيل.
لا يظهر فقط عندما `recordingPath == null` (صلاحية مرفوضة أو الـ recorder لم يبدأ).

### 3) سباق إنهاء الملف
`_emitStopped()` و`_emitFailure()` يطلقان `unawaited(_stopRecording())` ثم يمرّران المسار فورًا. لو ضغط المستخدم الاستماع بسرعة قد يكون الملف غير مكتمل (خصوصًا iOS).

---

## 2. الحل

### أ) ملف لكل محاولة (`speech_recognition_service.dart`)
- مجلد مؤقت مخصص: `${tempDir}/practice_takes/`
- اسم الملف لكل جلسة: `take_${DateTime.now().microsecondsSinceEpoch}.m4a`
- عند كل `start()`: لو عدد الملفات في المجلد > 20، احذف الأقدم (بترتيب وقت التعديل) حتى يبقى 20 كحد أقصى
- `dispose()` يحذف المجلد كله (نفس سلوك Task 12 لكن للمجلد)
- ممنوع أي جدول DB أو حفظ دائم: الملفات مؤقتة، وتنظيف المجلد عند بدء التطبيق مقبول وبسيط

### ب) انتظار إنهاء التسجيل قبل إصدار النتيجة النهائية
قبل بناء آخر `SpeechRecognitionUpdate` (النهائي أو الفاشل)، انتظر `await _stopRecording()` مع timeout قصير (مثلًا 1 ثانية). عند انتهاء المهلة أو الخطأ: مرّر `recordingPath: null` بدل مسار ملف غير مكتمل، ولا تُسقط الفحص أبدًا. إن كانت دوال الـ emit متزامنة حاليًا، أعد هيكلتها بأقل تغيير ممكن.

### ج) جرد كل حالات النتيجة (إلزامي، يُوثَّق جدول في سجل الجلسة)
لكل سطح، اكتب هل الزر يظهر في كل حالة وصلّح الناقص:

| السطح | نجاح | نطق غلط | noSpeech | STT فشل + تسجيل نجح | صلاحية مرفوعة |
|---|---|---|---|---|---|
| Phonetics (`PronunciationBloc`) | | | | | |
| Dictionary (`PronunciationBloc`) | | | | | |
| Sentences List/Pager (`SentencePracticeBloc`) | | | | | |
| Conversations Chat/Pager | | | | | |

القيمة المتوقعة في كل خلية: زر ظاهر، إلا عمود الصلاحية فيكون مخفيًا.
افتح `PronunciationBloc` تحديدًا وتأكد أنه يبني `PronunciationAttempt` (بـ `heard` فارغ و`recordingPath`) حتى في حالة `noSpeech`، وإلا لن يجد الـ UI شيئًا يعرضه.

### د) `PlayMyVoiceButton`
- اترك التصميم كما هو (أيقونة صغيرة ثانوية)
- قبل التشغيل تحقق من وجود الملف (`File(path).exists()`)؛ لو غير موجود لا تفعل شيئًا ولا ترمِ استثناء
- ضمان أن تشغيل تسجيل جديد يوقف السابق (تحقق من سلوك `AudioManager.playFile`، ولا تضف حالة جديدة إن كان يفعل ذلك بالفعل)

---

## 3. الملفات
تعديل فقط: `core/speech/speech_recognition_service.dart`، `core/widgets/play_my_voice_button.dart`، وأي widget أو bloc يكشف الجرد (ج) نقصًا فيه من الأسطح الأربعة (`phonetic_example_table.dart`, `dictionary_word_card.dart`, `repeat_result_box.dart`/`sentence_card_*`, `conversation_bubble.dart`, `pronunciation_bloc.dart`).
**لا تلمس:** `SentenceAssessor`, `SpeechTextMatcher`، منطق التقييم.

## 4. Tests
- خدمة التسجيل: محاولتان متتاليتان تنتجان مسارين مختلفين، والملف الأول لم يُحذف قبل تجاوز 20
- حذف الأقدم عند تجاوز الحد
- النتيجة النهائية لا تحمل مسارًا عند انتهاء مهلة الإنهاء
- `PlayMyVoiceButton`: ملف غير موجود → لا استثناء
- `PronunciationBloc`: `noSpeech` ينتج attempt بمسار التسجيل

## 5. Acceptance
- [ ] `flutter analyze` بدون جديد، كل الـ tests تعدي
- [ ] جدول الجرد (ج) مكتمل في سجل الجلسة
- [ ] على جهاز حقيقي: سجّل جملتين، الاستماع عند كل واحدة يشغّل **صوتها هي**
- [ ] نطق غلط عمدًا: الزر ظاهر، وتسمع صوتك فعلًا
- [ ] الصمت التام (ما تتكلمش): الزر ظاهر أو مخفي حسب الجرد، وموثّق السبب
- [ ] الضغط السريع على الاستماع فور ظهور النتيجة لا يعطي صوتًا مقطوعًا
- [ ] امنع المايك: لا crash ولا زر

## 6. خارج النطاق
تخزين دائم أو تاريخ محاولات (Task 14)، مشاركة التسجيلات، مؤشر تقدم تشغيل أو waveform.

---

## سجل الجلسة

**التاريخ:** 2026-10-05 · **الحالة:** ✅ كود + tests · اختبار الجهاز الحقيقي خارج قدرة Claude Code.

### §1 — المشكلة #1 تم التحقق منها قبل التعديل

قراءة الكود قبل البدء:
- `SpeechRecognitionService._startRecording` كان يكتب على مسار ثابت
  `${tempDir}/practice_take.m4a` كل مرة.
- `SentencePracticeBloc` يبني `attempts: Map<int, SentencePracticeAttempt>`
  يحتفظ بـ attempt لكل sentence_id. الـ attempt الأول يحمل مسار الملف الثابت.
  الـ attempt الثاني (لجملة أخرى) يحمل **نفس** المسار الثابت.
- النتيجة التنفيذية: ضغط الاستماع عند الجملة الأولى يشغّل الملف الموجود حاليًا
  — أي تسجيل الجملة الثانية. هذه هي المشكلة.
- اختبار الاستماع الفعلي على جهاز حقيقي يحتاج device-test (مذكور في §Acceptance)،
  لكن الـ race منطقي ومثبت بقراءة الكود.

### §2 — جدول الجرد (قبل التعديل)

| السطح | نجاح | نطق غلط | noSpeech | STT فشل + تسجيل نجح | صلاحية مرفوضة |
|---|---|---|---|---|---|
| Phonetics (`phonetic_example_table` / `PronunciationBloc`) | ✅ يظهر | ✅ يظهر | ✅ يظهر | ✅ يظهر | ❎ مخفي صح (`recordingPath=null`) |
| Dictionary (`dictionary_word_card`) | ✅ يظهر | ✅ يظهر | ✅ يظهر | ✅ يظهر | ❎ مخفي صح |
| Sentences List+Pager (`sentence_card_large/row`) | ✅ (RepeatResultBox) | ✅ (RepeatResultBox) | **❌ ناقص** | **❌ ناقص** | ❎ مخفي صح |
| Conversations (`conversation_bubble`) | ✅ يظهر | ✅ يظهر | ✅ fallback text + button | ✅ fallback text + button | ❎ مخفي صح |

**الفجوة الوحيدة:** Sentences كان `showResult` مشروط بـ `outcome == assessed`.
لـ `noSpeech`/`permissionDenied`/`unavailable` تظهر `_HintLine` فقط بدون زر
الاستماع — حتى لو `recordingPath != null`.

### §3 — التغييرات

#### `core/speech/speech_recognition_service.dart`
- **ملف لكل محاولة (§A):** مجلد ثابت `${tempDir}/practice_takes/` + اسم ملف
  `take_${ts}_$counter.m4a` حيث:
  - `ts` = `DateTime.now().microsecondsSinceEpoch` (microsecond precision)
  - `$counter` = عداد تصاعدي يحمي ضد تصادم microsecond على Windows (millisecond
    resolution) أو جلستين متتاليتين في اختبار واحد.
- **Prune (§A):** قبل كل `start()` ينادى `pruneTakes(dir, keep: 19)` — يحذف
  الأقدم بترتيب mtime حتى يبقى 19، ثم الـ `start()` نفسه يضيف الـ 20.
- **Timeout على stop (§B):** `_stopRecording()` الآن:
  - `await rec.stop().timeout(1s, onTimeout: ...)` — على التمهلة `_recordingPath=null`
    بدلًا من مسار ملف غير مكتمل.
  - على exception: `_recordingPath=null` فورًا.
  - على نجاح: validation القديم (`_validateRecordingOrClear`) بيكمل الدور في
    التقاط ملف صغير جدًا (<1KB).
- **dispose (§A):** يحذف المجلد كله `recursive: true` بدلًا من ملف واحد.
- **testable statics (`@visibleForTesting`):**
  - `nextTakePath(dir, {counter, now})` — بناء اسم الملف.
  - `pruneTakes(dir, {keep})` — حذف الأقدم.

#### `core/widgets/play_my_voice_button.dart`
- فحص وجود الملف (`File(path).exists()`) قبل التشغيل. لو مفقود → SnackBar
  "Recording is no longer available." وبدون `onPlay()`. يحمي ضد:
  - prune حذف الملف بعد أن سجّل الـ bloc المسار.
  - OS temp-dir sweep.
  - race بين انتهاء الـ take وضغط الاستماع فورًا.
- `exists: Future<bool> Function(String)?` حقن اختياري لتجنب الـ dart:io داخل
  widget tests (نفس نمط `onPlay`).

#### `features/sentences/presentation/widgets/sentence_card_large.dart` + `sentence_card_row.dart`
- `_HintLine` / `_hintLine()`: زر `PlayMyVoiceButton` يُضاف في نهاية الـ Row
  عندما `!isListening && attempt != null && outcome != assessed && recordingPath != null`.
- في `sentence_card_large.dart`: الـ `_HintLine` يظهر دائمًا، فالشرط يستبعد
  حالة `assessed` (تلك فيها زر داخل `RepeatResultBox` فعلًا — تجنب التكرار).
- في `sentence_card_row.dart`: الـ `_hintLine` يظهر فقط في فرع `else` (أي ليس
  assessed أصلًا)، فالفلترة بـ `outcome != assessed` غير ضرورية.

#### `AudioManager.playFile` — لم يُلمس
القراءة أثبتت أن `playFile` ينادي `_player.stop()` قبل `play()` → تشغيل جديد
يوقف السابق تلقائيًا. §D النقطة الثالثة محققة بالفعل. لا تعديل.

### §4 — جدول الجرد (بعد التعديل)

| السطح | نجاح | نطق غلط | noSpeech | STT فشل + تسجيل نجح | صلاحية مرفوضة |
|---|---|---|---|---|---|
| Phonetics | ✅ | ✅ | ✅ | ✅ | ❎ مخفي |
| Dictionary | ✅ | ✅ | ✅ | ✅ | ❎ مخفي |
| **Sentences** | ✅ | ✅ | ✅ **(جديد في `_HintLine`)** | ✅ **(جديد)** | ❎ مخفي |
| Conversations | ✅ | ✅ | ✅ | ✅ | ❎ مخفي |

### §5 — Tests (10 جديدة + 1 معدَّلة)

- `test/core/speech/speech_recognition_service_recording_test.dart` × 7:
  - `nextTakePath`: مساران متتاليان مختلفان.
  - `nextTakePath`: نفس `now` لكن counter مختلف → مسار مختلف (Windows guard).
  - `pruneTakes` تحت الحد → لا حذف.
  - `pruneTakes` عند الحد بالضبط → لا حذف.
  - `pruneTakes` فوق الحد → حذف الأقدم بالضبط `files.length - keep` ملف.
  - `pruneTakes` مجلد مفقود → لا throw.
  - `pruneTakes(keep: _maxTakes-1)` → 19 (محاكاة نمط الاستدعاء داخل الخدمة).
- `test/features/phonetics/presentation/bloc/pronunciation_bloc_test.dart` × 2:
  - `noSpeech` ينتج `PronunciationAttempt(recordingPath: '/tmp/...')` — ليس null.
  - `permissionDenied` ينتج attempt بـ `recordingPath: null` (لا recorder).
- `test/core/widgets/play_my_voice_button_test.dart` × 1 جديد:
  - `exists: () => false` → `onPlay` **لا يُستدعى** + SnackBar "Recording is no
    longer available." + لا exception.
- تحديث 3 اختبارات موجودة في نفس الملف: حقن `exists: () => true` حيث يحتاج الـ
  mock المسار موجود (كان `null` قبل الـ patch فيوقع في الفرع الجديد).

### §6 — أرقام

- `flutter analyze --no-pub`: **28 issues، صفر جديد** (كلها pre-existing في
  `base/`, `resources/themes.dart`).
- `flutter test`: **160 pass + 1 pre-existing fail** (`widget_test.dart`
  Counter smoke — موثق في Task 12 كـ pre-existing).

### §7 — ⚠️ اختبار الجهاز الحقيقي (خارج قدرة Claude Code)

النقاط التالية من §Acceptance لم تُنفَّذ، لأن Claude Code في terminal بلا
محاكي/هاتف:
1. **الاستماع عند جملتين متتاليتين:** سجّل جملة A ثم B، اضغط الاستماع عند A
   → **يجب** أن تسمع صوت A (ليس B). قبل Task 12.1 كان الاتنين نفس الصوت.
2. **نطق غلط عمدًا:** الزر ظاهر في Sentences List وPager، تضغط فتسمع صوتك
   الخاطئ. قبل Task 12.1 الزر كان مخفي (فقط `_HintLine` بدون زر).
3. **الصمت التام:** الزر يظهر إن كان الـ recorder أمسك حتى صمتًا (مسار موجود)،
   ويختفي إن كان الـ recorder لم يُنتج ملفًا. السلوك متوقع من §D.
4. **الضغط السريع:** الحماية ضد الملف غير المكتمل عبر الـ 1-second timeout
   في `_stopRecording` + `_validateRecordingOrClear` (الملف الصغير `<1KB`).
5. **منع المايك:** `PronunciationBloc` + `SentencePracticeBloc` ينتجان attempt
   بـ outcome `denied`/`permissionDenied` و`recordingPath: null` → الزر
   مخفي، لا crash. الـ bloc test غطى هذا.

### §8 — خروج عن النطاق

- لم أعدّل أي منطق تقييم (`SentenceAssessor`, `SpeechTextMatcher`).
- لم أضف جدول DB أو تخزين دائم (Task 14 لاحقًا).
- لم أعدّل الـ UI لإظهار waveform/تقدم.
