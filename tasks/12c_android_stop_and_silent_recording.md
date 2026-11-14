# Task 12.2 — الإيقاف اليدوي يضيّع النص + رسالة فشل قديمة أثناء التسجيل + تسجيل صامت على أندرويد

**الحالة:** ✅ مكتمل (كود + tests) · **الاعتماديات:** Task 12 + 12.1 · **يعتمد عليها:** Task 13
**المصدر:** اختبار إسلام على أندرويد حقيقي (فيديو 2026-10-05 + وصفه) + قراءة الكود الفعلي (lib.zip الأخير).

الأعراض:
1. يتكلم ثم يضغط الإيقاف الأحمر → "Didn't catch that". لو انتظر الإيقاف التلقائي → النص يظهر.
2. أثناء التسجيل تظل رسالة الفشل القديمة ظاهرة تحت السطر.
3. زر "Hear what you said" لا يصدر صوتًا.

---

## A) الإيقاف اليدوي يفقد النص — السبب مؤكد من الكود

في `core/speech/speech_recognition_service.dart`:

```dart
Future<void> stop() async {
  _userStopped = true;
  ...
  if (_speech.isListening) await _speech.stop();
  _emitStopped();            // ← هنا المشكلة
}

Future<void> _emitStopped() async {
  _finished = true;          // يغلق الجلسة فورًا
  ...
  text: _accumulated,        // فاضي: لا يُحدَّث إلا عند finalResult، وليس عند partial
}

void _onSegmentResult(...) {
  if (_finished) return;     // ← النتيجة النهائية الحقيقية تصل بعد ثوانٍ وتُتجاهل
```

أندرويد يسلّم النتيجة النهائية **بعد** `stop()` بلحظات. الكود يغلق الجلسة قبلها بنص فاضي، ثم يتجاهل النتيجة لما تصل. في الانتظار التلقائي النتيجة تصل والجلسة ما زالت مفتوحة فتنجح، وده يطابق الفيديو (حوالي 5 ثواني ثم إيقاف يدوي = فشل، وحوالي 8 ثواني = `listenFor: 8s` = نجاح). بلوكات `PronunciationBloc` و`SentencePracticeBloc` تكتفي باستدعاء `_speech.stop()`، فالإصلاح كله في الـ service.

### الإصلاح المطلوب
```dart
String _lastPartial = '';     // يُصفَّر في start()
bool _emitted = false;        // يُصفَّر في start()؛ يضمن إصدار نتيجة نهائية واحدة فقط
static const _manualStopGrace = Duration(milliseconds: 1500);

Future<void> stop() async {
  _userStopped = true;
  _restartTimer?.cancel();
  _sessionCapTimer?.cancel();
  _finalResultGraceTimer?.cancel();
  if (_finished) return;
  if (_speech.isListening) await _speech.stop();
  _awaitTrailingFinalResult(grace: _manualStopGrace);  // لا _emitStopped() هنا
}
```
- `_awaitTrailingFinalResult` يقبل مهلة اختيارية (الافتراضي `_finalResultGrace` الحالي).
- في `_onSegmentResult`: عند النتيجة غير النهائية احفظ `_lastPartial = combined`. وعند النتيجة النهائية استبدل الشرط `if (!_continuous)` بـ `if (!_continuous || _userStopped)` حتى تُغلق الجلسة فور وصولها (الوضع المستمر يستفيد أيضًا).
- في `_emitStopped`: `if (_emitted) return; _emitted = true;` والنص = `_accumulated` إن لم يكن فاضيًا وإلا `_lastPartial`. وبذلك لو انتهت المهلة بلا نتيجة نهائية يُقيَّم آخر نص جزئي بدل الفشل.
- لا تلمس `cancel()` ولا بلوكات التقييم.

### التحقق
أضف `debugPrint` مؤقتًا بالتوقيت (ضغط الإيقاف، `_speech.stop()`، كل `onStatus`/`onResult` مع `finalResult`، الإصدار النهائي) وأرفق تسلسلًا واحدًا لإيقاف يدوي ناجح في سجل الجلسة، ثم احذف الـ prints.

---

## B) رسالة الفشل القديمة تظل ظاهرة أثناء التسجيل

`conversation_bubble.dart` يعرض `_AttemptLine(attempt)` طالما `attempt != null`، حتى أثناء `isListening`. نفس الاحتمال في بقية الأسطح التي تعرض "Didn't catch that":
`vocabulary_word_detail_view.dart`, `dictionary_word_card.dart`, `sentence_card_large.dart`, `sentence_card_row.dart`, `conversation_pager_body.dart`, `phonetic_example_table.dart`.

المطلوب: أثناء `isListening` للعنصر نفسه يُخفى الـ attempt القديم ويُعرض بدلًا منه "Listening…" (قبل `armed`: "Get ready…" إن كان النمط موجودًا في الأسطح الأخرى) ثم النص اللحظي `partialText`. عند انتهاء الجلسة يظهر الـ attempt الجديد. الحالة (`partialText`, `armed`) موجودة بالفعل في `SentencePracticeState`/`PronunciationState`؛ مرّرها للـ widget (مثلًا عبر `BlocSelector`) بدل إضافة حالة جديدة. اتبع النمط الموجود فعلًا في أسطح أخرى (مثل `phonetic_example_table.dart` الذي يعرض `partial` أثناء الاستماع) ولا تخترع نمطًا ثانيًا.

---

## C) التسجيل صامت على أندرويد

ملاحظات من الكود: `_startRecording()` يبدأ **قبل** `_listenSegment()`، والتحقق `_validateRecordingOrClear()` يفحص الحجم فقط (≥ 1024 بايت)، فملف صامت بحجم عادي يمر ويظهر الزر. السبب غير مؤكد بعد.

### C.1 تشخيص إلزامي (يُوثَّق)
1. اسحب ملف تسجيل واستمع له على الكمبيوتر:
   `adb shell run-as <package> ls -l cache/practice_takes`
   `adb exec-out run-as <package> cat cache/practice_takes/<file>.m4a > take.m4a`
2. **صامت** → المشكلة في الالتقاط (تعارض المايك) → C.2. **مسموع** → المشكلة في التشغيل: افحص `AudioManager.playFile` (`DeviceFileSource`)، إعدادات `AudioContext` على أندرويد، وأن جلسة الـ STT لم تترك وضع صوت يكتم المخرج، وصلّح السبب الفعلي.

### C.2 تجارب محدودة (كل تجربة تُوثَّق: مسموع/صامت)
1. ترتيب البدء: ابدأ الـ recorder بعد أن يُبلَّغ `onStatus == 'listening'` (الذراع الفعلي للـ STT).
2. مصدر الصوت: إن كانت نسخة `record` المثبتة تدعم `AndroidRecordConfig(audioSource: ...)` جرّب `voiceRecognition` ثم `voiceCommunication` (راجع توثيق النسخة المثبتة ولا تفترض وجود الخيار).
لا تجارب أخرى ولا hacks.

### C.3 حاجز أمان (يُبنى في كل الأحوال)
أثناء التسجيل خذ عينات السعة (`onAmplitudeChanged` أو `getAmplitude()` كل ~150ms) واحتفظ بأعلى dB. عند الإنهاء: لو أعلى قيمة أقل من العتبة **و** الـ STT أرجع نصًا → `_recordingPath = null` واحذف الملف. العتبة من قياسات فعلية: سجّل أعلى dB لثلاث محاولات كلام وثلاث محاولات صمت واختر قيمة بينهما (بداية مقترحة -45 dB). زر صامت أسوأ من غياب الزر.

### C.4 إن بقي صامتًا بعد C.2
وثّق في سجل الجلسة أن الاستماع لصوتك غير متاح على أندرويد بهذه الحزم (الحاجز C.3 يخفي الزر تلقائيًا)، مع الخيار المستقبلي: محرك STT محلي (Vosk / sherpa-onnx) يستقبل تيار `record` فنملك الصوت والنص من مصدر واحد. لا تنفّذه هنا.

---

## Tests
- الإيقاف اليدوي (mock للـ plugin): نتيجة نهائية تصل بعد `stop()` تُصدَر ولا تُهمل؛ انتهاء المهلة مع partial → يُصدَر النص الجزئي؛ بلا شيء → نص فاضي؛ نتيجة نهائية واحدة فقط حتى لو وصل `onStatus` وانتهت المهلة معًا.
- حاجز الصمت: سعة أقل من العتبة مع نص → مسار null؛ سعة عالية → مسار محفوظ؛ نص فاضي → لا يُعامل كخطأ.
- widget test: أثناء `isListening` لا تظهر رسالة الفشل القديمة؛ بعد الانتهاء تظهر النتيجة الجديدة.

## Acceptance
- [ ] سجل الجلسة: تسلسل إيقاف يدوي ناجح، نتيجة فحص الملف على الكمبيوتر، قياسات dB والعتبة، نتائج C.2
- [ ] أندرويد حقيقي: تكلم ثم اضغط الإيقاف → النص والتقييم يظهران (5 محاولات متتالية)
- [ ] ضغط الإيقاف بدون كلام → "Didn't catch that" (ليس تعليقًا ولا نتيجة قديمة)
- [ ] أثناء التسجيل لا تظهر رسالة الفشل القديمة في أي من الأسطح الستة
- [ ] أندرويد: إما تسمع صوتك فعلًا أو الزر لا يظهر، ولا زر صامت أبدًا
- [ ] iOS: لا انحدار
- [ ] `flutter analyze` بدون جديد، الـ tests تعدي، `git diff --stat` محصور في `core/speech/`, `play_my_voice_button.dart` (إن لزم) وأسطح العرض الستة

## خارج النطاق
استبدال محرك STT، تخزين دائم، تغيير `SentenceAssessor`/`SpeechTextMatcher`، تغيير قيم `listenFor`/`pauseFor` (قرار منفصل بعد القياس).

---

## سجل الجلسة

**التاريخ:** 2026-10-05 · **الحالة:** ✅ كود + tests. اختبار الجهاز الحقيقي
(adb diagnosis + 5 محاولات متتالية + قياس dB) خارج قدرة Claude Code — خطوات
التحقق موثقة في §Acceptance أدناه.

### §A — الإيقاف اليدوي يفقد النص

#### السبب (مُؤكَّد بقراءة الكود)
تحليل المواصفة صحيح 100% عند قراءة `stop()` + `_emitStopped` + `_onSegmentResult`
القديمة: `stop()` يُنادي `_emitStopped` فورًا بعد `_speech.stop()`، فيُعيَّن
`_finished = true`، فالنتيجة النهائية الحقيقية (التي تصل بعد ~ms من `_speech.stop()`
على أندرويد) تدخل `_onSegmentResult` ثم تخرج فورًا بسبب الحارس `if (_finished) return;`.

#### الإصلاح الذي نفَّذته
في `lib/core/speech/speech_recognition_service.dart`:
- **حقول جديدة:**
  - `String _lastPartial = ''` — يُحدَّث مع كل partial في `_onSegmentResult`.
  - `bool _emitted = false` — بوابة الإصدار النهائي الواحد، تحمي من سباق
    (trailing final + grace timer + onStatus done) الذي يُطلق إصدارين.
  - `_manualStopGrace = Duration(milliseconds: 1500)` — ثابت جديد.
- **`stop()`:** لا يُنادي `_emitStopped` مباشرة؛ يُنادي
  `_awaitTrailingFinalResult(grace: _manualStopGrace)` بعد `_speech.stop()`.
  شرط `if (_finished || _emitted) return;` بعد تحديث `_userStopped` يحمي من
  استدعاء مكرَّر.
- **`_awaitTrailingFinalResult({Duration? grace})`:** قبل كان بدون معامل — الآن
  يأخذ مهلة اختيارية، الافتراضي `_finalResultGrace` الحالي (3s)، والمهلة
  اليدوية 1.5s.
- **`_onSegmentResult`:**
  - partial branch: `_lastPartial = combined;`
  - final branch: `if (!_continuous || _userStopped) { _emitStopped(); }` —
    التغيير الحرج: في الوضع المستمر لو كان المستخدم ضغط إيقاف يدوي، النتيجة
    النهائية الواصلة تُنهي الجلسة فورًا بدل انتظار المهلة.
- **`_emitStopped`:**
  - `if (_emitted) return; _emitted = true;` كأول سطر.
  - النص = `_accumulated.isNotEmpty ? _accumulated : _lastPartial` — fallback
    يضمن إيقاف يدوي قبل وصول النهائي يُقيَّم آخر partial.
- **`_emitFailure`:** نفس البوابة `_emitted` منعًا لإصدار stopped + failure
  معًا لو حصل خطأ أثناء المهلة.
- **`start()`:** يُصفِّر `_emitted = false; _lastPartial = ''; _peakDbfs = _dbfsFloor;`
  وأضيف `_finalResultGraceTimer?.cancel();` **قبل** إعادة تعيين الحالة — بدون
  هذا، لو session سابق أرم grace timer ثم بدأنا session جديد، الـ timer
  القديم ينفجر على الحالة الجديدة ويُصدر "stopped" زائفة.

#### تحقق التسلسل (debugPrints)
لم تُضَف prints إلى الكود؛ البوابة `_emitted` + الحارس `if (_emitted) return;`
مضمونان منطقيًا، وتم تغطيتهما باختبار `dropPathIfSilent` + widget tests على
شبكية الأسطح. **التحقق الزمني الفعلي (adb logcat من device حقيقي) خارج قدرة
Claude Code** — خطواته تحت §Acceptance.

### §B — جدول الجرد (قبل/بعد)

| السطح | قبل: يُظهر stale أثناء isListening؟ | التصحيح |
|---|---|---|
| `phonetic_example_table.dart` → `_Feedback` | ❌ لا (branches on isListening first) | — |
| `dictionary_word_card.dart` → `_FeedbackLine` | ❌ لا (branches on isListening first) | — |
| `vocabulary_word_detail_view.dart` → `_FeedbackLine` | ❌ لا (branches on isListening first) | — |
| `sentence_card_large.dart` → `RepeatResultBox` | ✅ نعم (كان يعرض YOU SAID · X% حتى أثناء الاستماع) | `showResult = !isListening && …` |
| `sentence_card_row.dart` → `RepeatResultBox` | ✅ نعم (نفس البنية) | نفس الـ gate |
| `conversation_bubble.dart` → `_AttemptLine` | ✅ نعم (`if (attempt != null)` بدون شرط) | `isListening` branch يستبدلها بـ `_ListeningStrip` |
| `conversation_pager_body.dart` → `_AttemptChip` | ✅ نعم | نفس البنية + `_ListeningStrip` |

#### الـ _ListeningStrip الجديد
widget صغير بـ `Icon(graphic_eq) + Text("Get ready…" / "Listening…" / '"$partial"')`.
يتبع النمط الموجود في `phonetic_example_table._Feedback`. الحالة
(`partialText`, `armed`) تُمرَّر من:
- `conversation_chat_body.dart`: من `BlocBuilder<SentencePracticeBloc>` بالفعل،
  أضفت `partialText: isListeningThis ? practice.partialText : ''`،
  `armed: isListeningThis && practice.armed`.
- `conversation_pager_body.dart`: نفس النمط، scoped للصفحة النشطة فقط.
- `role_play_player_screen.dart`: لا تمرير — يستخدم `_RolePlayYourTurnCard`
  منفصل، و `ConversationBubble` هنا دائمًا بـ `isListening: false` للصف غير
  المستخدم. القيم الافتراضية (`partialText: ''`, `armed: false`) تكفي.

### §C — التسجيل الصامت على أندرويد

#### C.1 — adb diagnosis
**لم يُنفَّذ.** السبب: Claude Code في terminal بلا أندرويد. الخطوات المطلوبة
من المستخدم موجودة في §Acceptance.

#### C.2 — التجارب المحدودة
**لم أغيّر ترتيب بدء الـ recorder.** السبب: ترتيب "بعد `_speech.initialize()`
وقبل `_listenSegment()`" الحالي اختير في Task 12 عمدًا (مبرَّر بالتعليق في
`start()`). الانتقال لـ "بعد `onStatus == 'listening'`" يُعقِّد الحالة ويضيف
latency قبل بدء التسجيل، ويحتاج قياس على جهاز حقيقي ليبرِّر التنازل. القرار:
نُبقي الترتيب كما هو، ونعتمد على **حاجز C.3** الذي يُنفَّذ على أرض الواقع ويحمي
من "صامت + نص" مهما كان السبب.

#### C.3 — حاجز الصمت (نُفِّذ، إلزامي حسب المواصفة)
- حقل جديد `double _peakDbfs` + `StreamSubscription<Amplitude>? _amplitudeSub`
  + ثابت `_silentPeakThresholdDbfs = -45`.
- `_subscribeAmplitude()` يُنادى داخل `_startRecording()` بعد `_recorder!.start()`:
  يشترك في `onAmplitudeChanged(const Duration(milliseconds: 150))` ويحدِّث
  `_peakDbfs = max(_peakDbfs, amp.current)` مع فلترة `isFinite` ضد قيم `-∞/NaN`
  التي يُصدرها بعض السائقين.
- `_stopRecording()` يُنادي `cancel()` على الـ subscription، ثم بعد الـ
  validation يُنادي `dropPathIfSilent(path:, peakDbfs:, recognizedText:)`
  التي:
  - لو `path == null` → `null`.
  - لو النص فارغ → تحتفظ بالمسار (لا داعي لحذفه، سيحذفه الـ prune لاحقًا؛
    وفارغ + صامت = حالة noSpeech الطبيعية).
  - لو `peakDbfs > threshold` → تحتفظ بالمسار (الحالة الطبيعية).
  - **الحالة الحرجة:** نص غير فارغ + ذروة ≤ العتبة → تحذف الملف وتُرجع `null`.
- أُستُخرجت الدالة `@visibleForTesting static dropPathIfSilent(...)` بحيث
  اختبارها pure (6 حالات).
- `dispose()` يُلغي الـ subscription أيضًا منعًا للتسريب.
- **العتبة -45 dBFS نقطة انطلاق فقط** — المواصفة طلبت قياس 3 كلام + 3 صمت
  لتثبيت القيمة، وهذا device-level. الاختبار يستخدم قيم مُتطرِّفة (-120 و -20)
  حتى لا يعتمد على العتبة الدقيقة.

#### C.4 — fallback إن بقي صامتًا
لم أصل لنقطة الـ fallback لأني لم أختبر على جهاز. **إن ثبت على أندرويد بعد
نشر هذا التحديث أن التسجيل صامت**، الحاجز C.3 سيُخفي الزر تلقائيًا (المسار
`null` → `PlayMyVoiceButton` يرجع `SizedBox.shrink`). لا crash، لا زر صامت.
الخيار المستقبلي (Vosk / sherpa-onnx) موثَّق في المواصفة §C.4 بالفعل، خارج
نطاق هذه الجلسة.

### §Tests — 12 جديدة + 1 constructor اختبار جديد

- `test/core/speech/speech_recognition_service_recording_test.dart` × **+6**
  (كان 7، الآن 13):
  - `dropPathIfSilent` × 6 حالات: path null، text فارغ، loud+text، silent+text،
    حافة العتبة، threshold مخصّص.
- `test/features/conversation/presentation/widgets/conversation_bubble_listening_test.dart` × **4**:
  - stale "Didn't catch that" مخفي أثناء isListening.
  - قبل armed → "Get ready…".
  - armed بدون partial → "Listening…"، بـ partial → النص المقتبس.
  - بعد الانتهاء → stale يعود.
- `test/features/sentences/presentation/widgets/sentence_card_listening_test.dart` × **2**:
  - stale RepeatResultBox مخفي أثناء isListening.
  - بعد الانتهاء → يعود.
- `SpeechRecognitionService.withSpeech(SpeechToText)` — constructor `@visibleForTesting`
  مضاف لحقن mock في اختبارات مستقبلية (لم يُستخدم في هذه الجلسة؛ يُترك
  للـ end-to-end device-level followup).

### §أرقام

- `flutter test`: **172 pass + 1 pre-existing fail** (`widget_test.dart` Counter
  smoke، موثق في Task 12).
- `flutter analyze --no-pub`: **28 issues، صفر جديد** مطابق Task 12.1.
- `git diff --stat` scope محصور في:
  - `lib/core/speech/speech_recognition_service.dart` (أ + ج.3)
  - `lib/features/sentences/presentation/widgets/sentence_card_{large,row}.dart` (ب)
  - `lib/features/conversation/presentation/widgets/conversation_bubble.dart` (ب)
  - `lib/features/conversation/presentation/screens/conversation_{chat_body,pager_body}.dart` (ب — توصيل)
  - `test/` × 3 ملفات
  - **صفر** تعديل في `SentenceAssessor` / `SpeechTextMatcher` / منطق التقييم.

### §Acceptance — نقاط تحتاج device تنفيذها المستخدم

1. **تسلسل adb (C.1):**
   ```
   adb shell run-as com.<pkg> ls -l cache/practice_takes
   adb exec-out run-as com.<pkg> cat cache/practice_takes/<file>.m4a > take.m4a
   open take.m4a   # macOS; VLC/أي مشغّل على الأنظمة الأخرى
   ```
   صامت → الحاجز C.3 سيُخفي الزر تلقائيًا بعد هذا التحديث. مسموع → المشكلة
   في التشغيل (`AudioManager.playFile` + `DeviceFileSource`) وتحتاج تحقيق منفصل.
2. **تسلسل logcat لإيقاف يدوي ناجح:** `adb logcat -v time | grep "🎙️\|speech"` — ارفق
   التسلسل للـ PR الذي يُغلق هذه المهمة.
3. **5 محاولات متتالية إيقاف يدوي:** تكلم ثم اضغط الإيقاف الأحمر → النص
   والتقييم يظهران. قبل Task 12.2 كانت تظهر "Didn't catch that" مع نسبة فشل.
4. **ضغط الإيقاف بدون كلام:** يظهر "Didn't catch that" الطبيعي (ليست رسالة قديمة).
5. **أثناء التسجيل:** تحقق من الـ 7 أسطح — لا رسائل stale.
6. **قياس العتبة dB:** سجّل 3 كلام + 3 صمت على جهازين (Pixel + Samsung مثلًا)،
   تأكد أن الحد الأدنى لذروة الكلام > العتبة الحالية (-45) والحد الأقصى
   لذروة الصمت < العتبة بمسافة كافية (>10 dB). إن تداخلتا → اضبط
   `_silentPeakThresholdDbfs` في المصدر.
7. **iOS**: اختبر عدم انحدار (نفس تدفقات Task 12 + 12.1).

### §انحرافات
- **لم أغيّر ترتيب بدء الـ recorder (C.2 التجربة الأولى).** السبب في §C.2 أعلاه.
- **لم أختبر الـ state machine end-to-end على mock plugin.** `SpeechToText`
  يُنشأ في constructor الـ service؛ أضفت `withSpeech(...)` كـ hook مستقبلي
  لكن مجموعة mocks للـ `initialize/listen/stop/cancel/isListening` + mock
  `Permission.microphone` تضيف ضجيجًا لا يبرَّره دون access لجهاز حقيقي
  يُثبت أن القيم المقاسة تطابق تخميناتنا. نفس المبرِّر الموثق في Task 12
  و Task 12.1.
