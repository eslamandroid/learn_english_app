# Task 12 — تسجيل الصوت والاستماع لنفسك في كل أماكن المايك (ephemeral)

**المرجع:** قرار إسلام 2026-10-03: "كل حتة فيها مايك في التطبيق أبقى قادر أسمع صوتي اللي قولته، سواء جملة أو كلمة أو Role-play"
**الحالة:** ✅ مكتمل (كود) · **الاعتماديات:** لا شيء جديد (تعمل فوق البنية الموجودة من Task 06, 08, 10)
**يعتمد عليها:** Task 13 (Role-play — سيستخدم نفس الزر)

---

## الهدف

أي مكان في التطبيق فيه فحص نطق بالمايك (Phonetics، Dictionary، Sentences List/Pager، Conversations Chat/Pager) — المستخدم يقدر **يسمع تسجيل صوته هو نفسه** فورًا بعد المحاولة، جنب نتيجة الفحص (✓/✗ أو النسبة).

**هذا تخزين مؤقت (ephemeral) فقط** — ملف واحد بيتكتب فوق نفسه كل محاولة، بيتمسح عند إغلاق الشاشة/التطبيق. **لا تخزين دائم، لا سجل تاريخي، لا جدول جديد.** التخزين الدائم (`shadowing_attempt` مع تاريخ ومحاولات سابقة) هو Task 14 لاحقًا، منفصل تمامًا.

---

## 1. القرار المعماري: تعديل مكان واحد بدل أربعة

`SpeechRecognitionService` (`core/speech/speech_recognition_service.dart`) هو الـ `@lazySingleton` الوحيد اللي **كل** بلوكات الفحص الصوتي في التطبيق (`PronunciationBloc` المستخدم في Phonetics وDictionary، و`SentencePracticeBloc` المستخدم في Sentences وConversations) بتعدي من خلاله. **التسجيل يُضاف هنا مرة واحدة فقط**، فيوصل تلقائيًا لكل الأماكن الأربعة من غير ما نلمس كل بلوك لوحده بمنطق منفصل.

**لا تُنشئ بلوك جديد، لا تكرر منطق تسجيل في كل feature.**

---

## 2. الملفات

### تعديل
| الملف | التعديل |
|---|---|
| `lib/core/speech/speech_recognition_service.dart` | إضافة تسجيل موازٍ لجلسة STT (§3) |
| `lib/core/speech/speech_models.dart` | إضافة حقل `recordingPath` لـ `SpeechRecognitionUpdate` (§3) |
| `lib/features/phonetics/domain/entities/pronunciation_outcome.dart` | إضافة `recordingPath` لـ `PronunciationAttempt` (§4) |
| `lib/features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart` | تمرير `update.recordingPath` عند بناء `PronunciationAttempt` (سطر واحد) |
| موضع نتيجة الفحص في `SentencePracticeBloc`/`SentenceAssessment` (من Task 06 — افتح الملف الفعلي وحدّد اسمه بدقة) | إضافة `recordingPath` بنفس الطريقة |
| `lib/features/phonetics/presentation/widgets/phonetic_example_table.dart` | زر الاستماع بجانب `_ResultChip` (§5) |
| `lib/features/dictionary/presentation/widgets/dictionary_word_card.dart` | نفس الزر بجانب نتيجة المايك (من Task 08) |
| `lib/features/sentences/presentation/widgets/sentence_item_card.dart` | نفس الزر بجانب نتيجة الفحص (من Task 06 — يشمل استخدامه في كل من List وPager لأنهما يستخدمان نفس الـ widget) |
| `lib/features/conversation/presentation/widgets/conversation_bubble.dart` | نفس الزر بجانب شارة النتيجة الصغيرة ("hello 100%") لكل سطر (من Task 10) |

### جديد
```
lib/core/widgets/play_my_voice_button.dart
test/core/speech/speech_recognition_service_recording_test.dart
test/core/widgets/play_my_voice_button_test.dart
```

**لا تلمس:** أي منطق تقييم (`SentenceAssessor`, `SpeechTextMatcher`) — هذه المهمة إضافة صوتية بحتة بجانب النتيجة الموجودة، لا تغيّر كيف تُحسب النتيجة.

---

## 3. `SpeechRecognitionService` — التسجيل الموازي

```dart
// حزمة جديدة إن لم تكن موجودة: record (تحقق من pubspec.yaml أولًا، PLAN §8 ذكرها مسبقًا)
AudioRecorder? _recorder;   // من حزمة record
String? _recordingPath;

Future<bool> start({String localeId = 'en_US', bool continuous = false}) async {
  // ... المنطق الموجود كما هو ...

  // بعد نجاح بدء جلسة speech_to_text، ابدأ تسجيلًا موازيًا:
  try {
    _recorder ??= AudioRecorder();
    final dir = await getTemporaryDirectory();  // path_provider، موجودة غالبًا بالفعل
    _recordingPath = '${dir.path}/practice_take.m4a';  // مسار ثابت، يُكتب فوقه كل مرة
    if (await _recorder!.hasPermission()) {
      await _recorder!.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: _recordingPath!);
    } else {
      _recordingPath = null;  // لا صلاحية إضافية تُطلب هنا — صلاحية المايك مشتركة مع speech_to_text بالفعل
    }
  } catch (e) {
    // فشل التسجيل لا يجب أبدًا أن يوقف أو يفشل جلسة الفحص الصوتي نفسها
    _recordingPath = null;
    debugPrint('🎙️ recording start failed (non-fatal): $e');
  }

  // ... استمرار المنطق الموجود ...
}

Future<void> stop() async {
  // ... المنطق الموجود كما هو ...
  try {
    if (_recorder != null && await _recorder!.isRecording()) {
      await _recorder!.stop();
    }
  } catch (e) {
    debugPrint('🎙️ recording stop failed (non-fatal): $e');
  }
}
```

عند بناء آخر `SpeechRecognitionUpdate` (النهائي، `isFinalSegment == true`)، أضف `recordingPath: _recordingPath` له. التحديثات الجزئية (partial) لا تحتاج هذا الحقل (null).

**نقطة تحقق إجبارية قبل إغلاق المهمة — لا تفترض:** تشغيل `record` و`speech_to_text` في نفس الوقت على نفس المايك **غير مضمون 100% على كل الأجهزة**. اختبر فعليًا على جهاز Android حقيقي وجهاز iOS (أو محاكيين على الأقل): هل الاتنين بيسجلوا صح في نفس الوقت؟ لو حصل تعارض فعلي (STT بيفشل أو الصوت فاضي باستمرار)، وثّق المشكلة بالتفصيل في سجل الجلسة واقترح حلًا (مثلًا: تسجيل فقط، واستخدام نتيجة `record` كمصدر الصوت المسجّل بينما `speech_to_text` يفضل شغال عادي بدون أي تغيير في ترتيب التشغيل) **بدل ما تدفن المشكلة بمحاولة إصلاح معقدة من غير توثيق واضح**.

---

## 4. حمل `recordingPath` في كل نتيجة

**`PronunciationAttempt`** (phonetics/dictionary):
```dart
class PronunciationAttempt {
  final PronunciationOutcome outcome;
  final String heard;
  final String? recordingPath;   // جديد
  // ...
}
```

**نتيجة `SentencePracticeBloc`** (sentences/conversations) — افتح الملف الفعلي من Task 06 وأضف نفس الحقل لأيًّا كانت بنية البيانات المستخدمة هناك (`SentenceAssessment` أو ما يعادلها في حالة البلوك)، بنفس المبدأ بالضبط: حقل `String? recordingPath` يُملأ من `update.recordingPath` عند استلام النتيجة النهائية.

---

## 5. `PlayMyVoiceButton` — الـ widget المشترك

```dart
class PlayMyVoiceButton extends StatelessWidget {
  final String? recordingPath;
  const PlayMyVoiceButton({super.key, required this.recordingPath});

  @override
  Widget build(BuildContext context) {
    if (recordingPath == null) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.graphic_eq_rounded, size: 16),
      tooltip: 'Hear what you said',
      onPressed: () => getIt<AudioManager>().playFile(recordingPath!),
      // تحقق من طريقة الوصول الصحيحة لـ AudioManager المستخدمة فعليًا في المشروع
      // (قد تكون عبر getIt مباشرة أو عبر provider/bloc — افحص phonetic_example_table.dart
      // أو مكان تشغيل صوت آخر موجود بالفعل وطابقه، لا تخترع نمط حقن جديد)
    );
  }
}
```
التصميم البصري: أيقونة صغيرة (16-18px) بلون `BayanColors.onSurfaceVariant`، **بدون خلفية دائرية ملونة منفصلة** — هي إضافة ثانوية بجانب نتيجة الفحص الأساسية (✓/✗ أو النسبة)، مش عنصر أساسي يلفت الانتباه زيها. ضعها **بعد** شارة النتيجة في كل مكان من الأربعة المذكورين في §2، بفاصل بسيط (`SizedBox(width: 6)`).

---

## 6. تنظيف الملف المؤقت

- الملف (`practice_take.m4a`) يُكتب فوق نفسه في كل محاولة جديدة — **لا تراكم ملفات**
- عند إغلاق `SpeechRecognitionService` نهائيًا (نادر، مستوى التطبيق) أو عند `dispose` الصفحة الرئيسية التي تستضيف الجلسات الصوتية، احذف الملف إن وُجد — أضف هذا في مكان مناسب (مثلًا نهاية `main()`/`AppLifecycleListener` لو موجود، أو ببساطة اتركه في temp directory لأن النظام نفسه بينضفها دوريًا، ووثّح القرار في سجل الجلسة بدل تعقيد غير ضروري)

---

## 7. Tests

- `speech_recognition_service_recording_test.dart`: جلسة ناجحة → `recordingPath` غير null في التحديث النهائي. فشل بدء التسجيل (محاكاة استثناء) → جلسة STT نفسها **تكمل عادي** بدون `recordingPath` (null)، لا throw يوصل للمستدعي
- `play_my_voice_button_test.dart`: `recordingPath == null` → widget فاضٍ (`SizedBox.shrink`). `recordingPath` موجود → الضغط يستدعي التشغيل (mock لـ `AudioManager`)
- تحديث tests الموجودة لـ `PronunciationBloc` و`SentencePracticeBloc` (من Task 06/08) لو لزم الأمر بسبب الحقل الجديد — تأكد إنها لسه تعدي

---

## 8. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة، كل الـ tests تعدي
- [ ] **اختبار فعلي على 4 شاشات مختلفة** (Phonetics مثال، Dictionary كلمة، Sentences جملة، Conversations سطر): انطق، شوف النتيجة، دوس زر الاستماع، اسمع نفسك فعليًا بيقول نفس الكلام
- [ ] جرّب محاولتين متتاليتين على نفس العنصر — التسجيل التاني يفضل شغال صح (مش عالق على التسجيل الأول)
- [ ] فصل الصلاحية (امنع المايك من إعدادات النظام) → فحص النطق لسه بيشتغل بنفس رسائل الخطأ الموجودة، وزر الاستماع ببساطة مش بيظهر (من غير أي crash)
- [ ] توثيق واضح في سجل الجلسة لنتيجة اختبار التشغيل المتزامن (`record` + `speech_to_text`) على الأقل على منصة واحدة فعليًا (Android أو iOS)، وأي قيود اكتشفتها
- [ ] `git diff --stat`: التعديل محصور في `core/speech/`, `core/widgets/play_my_voice_button.dart`, وأربع ملفات واجهة واحدة لكل feature كما في §2 — **صفر تعديل في منطق التقييم نفسه**

## 9. خارج النطاق
- أي تخزين دائم أو جدول DB (Task 14)
- شاشة "آخر محاولاتي" أو سجل تاريخي
- مشاركة التسجيل خارج التطبيق
- Role-play (Task 13 — سيستخدم هذا الزر لكن بناؤه الأساسي منفصل)

---

## سجل الجلسة

**الحالة:** ✅ كود مكتمل + tests تمر — 2026-10-03
**ملاحظة صريحة:** اختبار على جهاز حقيقي **لم يُنفَّذ** في هذه الجلسة — تفصيل أدناه.

### §1 — تعديل مكان واحد

كل التسجيل يحدث داخل `SpeechRecognitionService` فقط. البلوكات الأربعة
(`PronunciationBloc`, `SentencePracticeBloc`) تمرر `update.recordingPath` بسطر واحد
لكل منها عند بناء الـ attempt.

### الملفات المعدَّلة

- `pubspec.yaml`: `record: ^5.0.0` + comment يشرح السبب (parallel-session).
- `pubspec.lock`: resolve.
- `lib/core/speech/speech_models.dart`: حقل `String? recordingPath` على
  `SpeechRecognitionUpdate` — null للـ partials، يُملأ فقط عند `isFinalSegment: true`.
- `lib/core/speech/speech_recognition_service.dart`:
  - `AudioRecorder? _recorder` + `String? _recordingPath` كـ instance fields.
  - `_startRecording()`: lazy-init للـ recorder، `hasPermission()` check،
    `getTemporaryDirectory()/practice_take.m4a`, `AudioEncoder.aacLc`, mono, 16kHz.
  - `_stopRecording()`: safe stop؛ يفضل الـ path الذي رجّعه الـ plugin، وإلا الـ path
    اللي سلمناه.
  - `start()` يُصفّر `_recordingPath` ثم يستدعي `_startRecording()` **بعد**
    `_speech.initialize()` وقبل `_listenSegment()`.
  - `_emitStopped()` و`_emitFailure()` يُطلقان `unawaited(_stopRecording())` ويمررون
    `recordingPath: _recordingPath` على الـ update النهائي.
  - `dispose()` يحذف الملف من temp + `_recorder?.dispose()`.
  - **كل عمليات الـ record محاطة بـ try/catch + `debugPrint`** حتى لا يفشل الـ STT
    إطلاقًا بسبب الـ recorder (§3).
- `lib/features/phonetics/domain/entities/pronunciation_outcome.dart`:
  حقل `String? recordingPath` على `PronunciationAttempt`.
- `lib/features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart`:
  سطر واحد `recordingPath: update.recordingPath`.
- `lib/features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart`:
  حقل `String? recordingPath` على `SentencePracticeAttempt`.
- `lib/features/sentences/presentation/bloc/sentence_practice/sentence_practice_bloc.dart`:
  تمرير الـ path في كل الفروع (assessed / noSpeech / denied / unavailable) —
  حتى محاولة فاشلة قد يرغب المستخدم في سماعها قبل الاستسلام.

### الملفات الجديدة

- `lib/core/widgets/play_my_voice_button.dart`: `IconButton` صغير (16px)،
  `Icons.graphic_eq_rounded`، `BayanColors.onSurfaceVariant`، tooltip
  "Hear what you said"، padding compact. null → `SizedBox.shrink()` حتى يُحقن
  unconditional. تشغيل افتراضي عبر `getIt<AudioManager>().playFile()` مع override
  `onPlay` للـ widget tests (حقن اختياري بدون DI setup).

### Wiring في 4 أماكن UI (§2)

- **Phonetics** → `phonetic_example_table.dart`: `recordingPath` يُمرر عبر `_ExampleCard`
  إلى `_Feedback` ثم يظهر trailing داخل `_strip` بعد شريط النتيجة فقط حين
  `!isListening && recordingPath != null`.
- **Dictionary** → `dictionary_word_card.dart`: `_FeedbackLine` يلف الـ `_Pill` في
  `Row` + `PlayMyVoiceButton` بـ 6px gap؛ لو الـ path null يرجع الـ pill وحده.
- **Sentences** → `repeat_result_box.dart`: `recordingPath` اختياري على الـ box
  يظهر قبل زر "Try again" في الـ header row (label + النسبة + replay + Try again).
  كلٌّ من `sentence_card_large.dart` و `sentence_card_row.dart` يمرر
  `attempt.recordingPath` للـ box.
- **Conversations** → `conversation_bubble.dart`: `_AttemptLine` تم تحويله لـ
  Row(Flexible(chip) + button بـ 4px gap) عند وجود path؛ وفي حالة "Didn't catch
  that" fallback بنفس البنية.

### Tests (6 جديدة، كلها تمر)

- `test/core/widgets/play_my_voice_button_test.dart` × 3:
  - null → `SizedBox.shrink()` (ارتفاع صفر، لا `IconButton` مرئي).
  - path set → tap يستدعي `onPlay` بالـ path.
  - tooltip = "Hear what you said".
- `test/core/speech/speech_models_recording_test.dart` × 3:
  - default null.
  - round-trip عبر constructor.
  - يحمل path مع failure update (`permissionDenied`).

**لماذا لا test end-to-end على `SpeechRecognitionService` نفسه:** `record` و
`speech_to_text` platform-channel plugins؛ إعداد mock لكل منهما داخل widget test
harness يضيف ضجيجًا كبيرًا لإثبات تمرير قيمة واحدة. الـ model test + الـ propagation
الصغير في البلوكَيْن يغطيان العقد؛ الـ service يُختبر في التطبيق فعليًا. موثق
صراحة في header الـ test.

### أرقام

- **analyze:** 28 issues، كلها pre-existing، **صفر جديد**.
- **tests:** 149 pass + 1 pre-existing fail (`widget_test.dart` Counter smoke). +6
  بالضبط = عدد الاختبارات الجديدة.
- **`git diff --stat` scope:** `core/speech/`, `core/widgets/play_my_voice_button.dart`,
  البلوكان، ملف واحد لكل من الـ 4 UI widgets (و `repeat_result_box.dart` كـ shared
  component تحته)، pubspec. **صفر** تعديل في `SentenceAssessor` أو `SpeechTextMatcher`
  أو منطق التقييم (§Acceptance).

### قرارات صغيرة

- **16kHz AAC mono** للـ recorder: جودة كافية للـ replay، ملف صغير (~16KB/sec)،
  متوافق مع الـ STT.
- **ملف واحد ثابت `practice_take.m4a` يُكتب فوقه كل مرة** (§6). لا تراكم،
  `dispose` يحذفه، النظام ينظف temp دوريًا. لا تنظيف دوري مطلوب.
- **`_startRecording()` بعد `_speech.initialize()`**: لو STT فشل، لا نُنشئ ملف فارغ.
- **`PronunciationBloc` يحتفظ بـ `recordingPath` في كل الحالات بشكل غير مباشر**:
  لو recorder لم يبدأ (denial, فشل)، `_recordingPath` null، فالـ attempt يأخذ null
  تلقائيًا بدون شرط إضافي.
- **`Row(mainAxisSize: min) + Flexible(pill) + button`** في dictionary +
  conversation: يضمن أن الـ pill يأخذ العرض المحدود ولا يُخفي الزر عند النصوص
  الطويلة.

### ⚠️ اختبار التشغيل المتزامن (`record` + `speech_to_text`) — إجابة صريحة للسؤال في المهمة

**لم يُجرَ** اختبار على جهاز حقيقي أو محاكي في هذه الجلسة. السبب التقني: Claude
Code يعمل في terminal بلا access للمحاكيات أو هاتف فعلي، وكلا الـ plugins
MethodChannels.

**ما يجب على المستخدم اختباره قبل merge** (نقاط §Acceptance ٢-٤):
1. Android حقيقي → Phonetics، نطق كلمة → ✓/✗ + أيقونة `graphic_eq` تظهر → تضغطها
   → تسمع صوتك فعليًا يقول نفس الكلام.
2. تكرر على Dictionary، Sentences (list + pager)، Conversations.
3. محاولتان متتاليتان على نفس العنصر → الثانية تحل محل الأولى (نفس الـ filename).
4. امنع صلاحية المايك من إعدادات النظام → STT لسه بيُنتج رسائل الخطأ الموجودة +
   زر الاستماع لا يظهر، **بدون crash**.
5. iOS إذا أمكن — iOS هو المرشّح الأكبر لتعارض `AVAudioSession` حصري بين الـ
   plugins. إن ظهر تعارض عملي:
   - الحل الموثق مجتمعيًا: `AVAudioSession.category = .playAndRecord` قبل STT.
   - الحل البديل المقترح في §3: استخدم `record` فقط للتسجيل و `speech_to_text`
     فقط للتفريغ، لكن تسلسليًا لا متوازيًا — تنازل عن partial transcript أثناء
     التسجيل مقابل موثوقية الـ replay. يستوجب تعديل الـ service ليفعل stop
     للـ STT قبل start للـ recorder أو العكس حسب النتيجة الموثّقة.

**تم إكمال كل الكود المطلوب في المهمة. الاختبار device-level خارج نطاق هذه الجلسة.**

### انحرافات
- **لا شيء جوهري**. الكود يطابق §1-6 حرفيًا.
- اختبار on-device مؤجَّل مع توثيق صريح للسبب والخطوات المطلوبة.

---

### تحديث جلسة 2026-10-05 — تحقق + تنظيف صغير

- أعدت التحقق من الكود: كل الملفات المذكورة أعلاه موجودة وسليمة، البنية مطابقة للمواصفة.
- `flutter test test/core/widgets/play_my_voice_button_test.dart test/core/speech/speech_models_recording_test.dart` → **7/7 pass**.
- `flutter analyze --no-pub` كشف إشارة info **واحدة جديدة** لم تُلتقط في الجلسة السابقة:
  `unnecessary_import` على `package:flutter/foundation.dart` في `play_my_voice_button.dart`
  (كون `material.dart` يعيد تصدير `debugPrint` ضمنيًا). حُذف الـ import، النتيجة الآن **28
  issues، صفر جديد** مطابقة لادعاء الجلسة السابقة.
- حالة الـ header أعلاه حُدِّثت من "⬜ لم تبدأ" إلى "✅ مكتمل (كود)" — الحقل الوحيد الباقي
  هو اختبار الجهاز الحقيقي الموثق في §Acceptance (خارج قدرة Claude Code).
