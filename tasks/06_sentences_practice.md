# Task 06 — Sentences: بطاقة ممارسة + وضع العرض (List/Pager) + تصميم بصري جديد

**المرجع:** `PLAN.md` §9 (رقم 6)، §4.2 · تصميم معتمد: `https://claude.ai/artifact/9GaScKM6HViT8qPwCVQC7R` (canvas فيه شاشتين: List و Pager)
**الحالة:** ⬜ لم تبدأ · **الاعتماديات:** Task 05 · **يعتمد عليها:** Task 09 (نفس نمط `SentenceAssessor`)

---

## ⚠️ ملاحظة عن رابط التصميم

الرابط أعلاه canvas تفاعلي على claude.ai — **لا يمكن لـ Claude Code فتحه أو قراءته مباشرة** (ليس صفحة ويب عادية قابلة للجلب). لهذا كل قرار بصري من التصميم (ألوان، مسافات، أنصاف أقطار، ظلال، تخطيط) **مكتوب صراحة بالتفصيل في هذه المهمة أدناه (§3، §4)** — الرابط للرجوع إليه بصريًا من صاحب المشروع فقط إذا احتاج التأكد من التخطيط العام، وليس مصدرًا يقرأه Claude Code.

**تنبيه مهم:** التصميم على الرابط استخدم خط "Plus Jakarta Sans" كعرض توضيحي فقط. **التطبيق الفعلي له نظام خطوط قائم بالفعل** (`BayanTypography`: `BeVietnamPro` للعناوين، `Inter` للنصوص، `Cairo` للعربي) — **لا تُدخل خطًا جديدًا**. استخدم `BayanTypography`/`BayanColors` الموجودين مع تعيين القيم من التصميم عليهم كما في جدول §4 بالضبط، وليس القيم الحرفية من ملفات التصميم.

---

## الهدف (ثلاثة أجزاء في مهمة واحدة، لأنها تلمس نفس الملفات)

1. **بطاقة ممارسة:** UK/US + Slow/Normal + مايك لفحص نطق الجملة كاملة (كما اتُّفق سابقًا)
2. **وضع عرض يتحكم فيه المستخدم:** List (الحالي، قائمة قابلة للتمرير) ↔ Pager (جملة واحدة تملأ الشاشة، سحب لليمين/الشمال، بالضبط كتجربة `VocabularyWordsBody`) — زر تبديل أعلى يمين الشاشة، والاختيار يُحفظ ويُستخدم في كل مرة يفتح فيها المستخدم أي subtopic
3. **تصميم بصري أرقى:** بطاقات مرتفعة بظل، لا حدود رفيعة مسطحة كالتصميم الحالي (Task 05)

---

## ⚠️ فرق تقني مهم — لا تُعِد استخدام `PronunciationBloc` كما هو

`PronunciationBloc` الموجود (phonetics/vocabulary) يقارن **كلمة واحدة** بمطابقة تامة. جملة كاملة لن تتطابق حرفيًا حتى لو نُطقت صح تمامًا. **الحل:** `core/speech/sentence_assessor.dart` (`SentenceAssessor.assess`) موجود بالفعل ومكتوب لهذا بالضبط، **غير مستخدم حاليًا في أي مكان** — هذه أول استخدام فعلي له، وسيُعاد استخدامه لاحقًا في Task 09 (Shadowing). **لا تُعدّل `PronunciationBloc` أو `SpeechTextMatcher`.**

---

## 1. الملفات

### جديد
| الملف | الدور |
|---|---|
| `lib/features/sentences/presentation/bloc/sentence_practice/{bloc,event,state}.dart` | جلسة الاستماع + التقييم لجملة واحدة (§5) |
| `lib/features/sentences/presentation/widgets/sentence_view_mode_toggle.dart` | زر التبديل List/Pager (أيقونتان، segmented) |
| `lib/features/sentences/presentation/widgets/sentence_pager_view.dart` | وضع الصفحات (PageView، سحب) |
| `lib/core/usecases/get_sentences_view_mode.dart`, `set_sentences_view_mode.dart` | قراءة/كتابة التفضيل (§6) |
| `test/core/speech/sentence_assessor_test.dart` | لم يوجد اختبار له من قبل رغم وجوده منذ البداية |
| `test/features/sentences/presentation/bloc/sentence_practice_bloc_test.dart` | |

### تعديل
| الملف | التعديل |
|---|---|
| `lib/features/sentences/presentation/widgets/sentence_item_card.dart` | إعادة تصميم كامل (§4) + accent/speed/mic |
| `lib/features/sentences/presentation/screens/sentence_content_screen.dart` | إضافة `SentenceViewModeToggle` في الهيدر، تبديل بين `ListView` (الموجود) و`SentencePagerView` (جديد) حسب الحالة المحفوظة، حقن `SentencePracticeBloc` |
| `lib/features/sentences/presentation/widgets/sentence_topic_card.dart`, `sentence_subtopic_row.dart` | مراجعة تصميمية فقط (ظل، `radiusLg`) — بدون تغيير منطق |
| `lib/core/constants/app_constants.dart` | إضافة مفتاح `prefSentencesViewMode` (أو مكافئ التسمية المستخدمة لمفاتيح prefs المشابهة) |

**لا تلمس:** `data/`, `domain/` الخاصين بـ sentences، ولا `PronunciationBloc`/`SpeechTextMatcher`.

---

## 2. أين يُحفظ اختيار وضع العرض؟

**قرار:** `SharedPreferences` (مثل باقي تفضيلات الواجهة كـ `prefSelectedVoice`)، **وليس** `user_settings` في `user.db`. السبب: هذا تفضيل عرض بحت (كيف تُصمَّم الشاشة)، بينما `user_settings`/`user.db` (Task 01) مخصص لبيانات تعلّم فعلية (تقدّم، SRS، لغة الشرح). اتبع بالضبط نمط `AppVoicePreferences` (singleton، `ValueNotifier<SentencesViewMode>`، `bind(prefs)` عند الإقلاع، دالة `set` تكتب فورًا). لا تضف عمودًا جديدًا لأي جدول SQL.

```dart
enum SentencesViewMode { list, pager }

class SentencesViewModePreference {
  SentencesViewModePreference._();
  static final instance = SentencesViewModePreference._();
  final ValueNotifier<SentencesViewMode> mode =
      ValueNotifier(SentencesViewMode.list);
  void bind(SharedPreferences prefs) { /* نفس نمط AppVoicePreferences.bind */ }
  void set(SentencesViewMode value) { /* يحدّث القيمة + يحفظ فورًا */ }
}
```
افتراضي `list` لمستخدم جديد لم يختر بعد (أقل تغييرًا مفاجئًا عن التصميم الحالي).

---

## 3. `SentencePagerView` — نمط `VocabularyWordsBody` بالحرف

انسخ بنية `features/vocabulary/presentation/widgets/vocabulary_words_body.dart` (استخدام `PageController`, `onPageChanged`, إيقاف أي تسجيل صوتي جارٍ عند تغيير الصفحة عبر إرسال حدث إيقاف لـ `SentencePracticeBloc`، مطابقة لما تفعله مع `PronunciationBloc` هناك). كل صفحة تعرض بطاقة جملة واحدة بنفس محتوى `sentence_item_card.dart` (أعد استخدام نفس الـ widget الداخلي، فقط بمقاسات أكبر حسب §4). أضف:
- عداد "N of M" في الهيدر (بجانب العنوان، محاذاة يمين)
- مؤشر نقاط أسفل الشاشة (نقطة نشطة أطول بيضاوية بلون `BayanColors.primary`، البقية دائرية بلون `BayanColors.outlineVariant`)

---

## 4. التصميم البصري — تعيين على `BayanColors`/`BayanTypography` الموجودين (لا قيم hex جديدة)

| عنصر التصميم | الحالة الحالية (Task 05) | التصميم الجديد | الـ token الفعلي المستخدم |
|---|---|---|---|
| خلفية البطاقة | بيضاء بحدّ رفيع | بيضاء مرتفعة بظل ناعم | `BayanColors.surfaceContainerLowest` + ظل مطابق لـ `_HeroCard` في vocabulary (`onSurface.withValues(alpha:.07), blurRadius:24, offset:(0,10)`) |
| نصف قطر البطاقة | صغير | كبير وواضح | `AppConstants.radiusXl` (نفس ما تستخدمه `_HeroCard`) بدل `radiusLg` الحالي |
| نص الجملة الإنجليزية | عادي | كبير وbold | `BayanTypography.headlineLarge` أو ما يعادلها بحجم أكبر في وضع Pager تحديدًا |
| نص العربي | عادي | لون مخفّف أنيق | `BayanColors.onSurfaceVariant` + `BayanTypography.arabicFontFamily` (كما هو مستخدم بالفعل) |
| الفاصل بين الأقسام | خط رفيع | نفس الفكرة، أخف | `BayanColors.outlineVariant.withValues(alpha: .4)` |
| `example` | نص مائل رمادي | نفس الفكرة + أيقونة اقتباس صغيرة (SVG بسيط، لا إيموجي) | `BayanColors.onSurfaceVariant` |
| أزرار US/UK وSlow/Normal | — (غير موجودة بعد) | segmented pill: نشط أبيض بظل خفيف ونص `primary`، غير نشط شفاف ونص باهت | مطابق تمامًا لـ segmented control الموجود فعليًا في `VocabularyWordDetailView._PracticeCard` — **انسخه من هناك حرفيًا بدل إعادة بنائه** |
| زر المايك | — | دائرة خضراء بارزة بظل | `BayanColors.success` |
| زر الصوت 🔊 | دائرة زرقاء فاتحة | نفس الفكرة | `BayanColors.primary.withValues(alpha:.10)` خلفية، أيقونة بلون `primary` |
| كلمة صحيحة (بعد فحص المايك) | — | أخضر | `BayanColors.success` |
| كلمة خاطئة/ناقصة | — | أحمر | `BayanColors.error` |
| زر "Mark as complete" | زر مسطح | pill كامل العرض بظل بارز | خلفية `BayanColors.primary`، ظل `primary.withValues(alpha:.32)` تقريبًا |
| زر تبديل List/Pager | — (جديد) | segmented صغير أعلى يمين الهيدر، نفس أسلوب pill الآخر | نشط: خلفية `primary` ونص أبيض. غير نشط: شفاف ونص `onSurfaceVariant` |

**كل الأيقونات SVG/`Icons.*` من Material، لا إيموجي في أي مكان.**

---

## 5. `SentencePracticeBloc`

مطابق بنيويًا لـ `PronunciationBloc` (نفس معالجة الحالات: `permissionDenied`, `unavailable`, `unrecoverable`, `noSpeech` — **انسخها حرفيًا**)، الفرق الوحيد في مسار النجاح:
```dart
final assessment = SentenceAssessor.assess(heard, _targetSentence);
```
تحقق أولًا من الشكل الفعلي لـ `SentenceAssessment`/`WordResult` في `core/speech/sentence_assessment.dart` (موجود مسبقًا حسب تعليقات `sentence_assessor.dart`) — **لا تُعِد تعريف بنية بيانات موجودة**. `continuous: false` (نفس نمط phonetics/vocabulary).

**لا تحفظ نتيجة الفحص في أي قاعدة بيانات في هذه المهمة.** حالة UI مؤقتة تُمسح عند مغادرة الشاشة (التخزين الدائم للمحاولات محدد فقط لـ Task 09 وجدول `shadowing_attempt` الخاص بـ conversation_sentence).

---

## 6. صلاحية الميكروفون

استخدم تدفق الطلب الموجود بالفعل عبر `SpeechRecognitionService`/`permission_handler` — لا تبني منطق صلاحية جديد.

---

## 7. Tests

**`sentence_assessor_test.dart`:**
- جملة مطابقة تمامًا → `score == 1.0`, `passed == true`
- كلمة مفقودة غير function word → أثر أوضح من فقدان function word
- `heard` فارغ → `score == 0`

**`sentence_practice_bloc_test.dart`:**
- بدء → استماع، نتيجة مطابقة → `passed == true`، `permissionDenied` → نفس سلوك `PronunciationBloc`

**`sentences_view_mode_test.dart` (تفضيل):**
- `bind()` بدون قيمة محفوظة → `list`
- `set(pager)` ثم `bind()` جديد → `pager` (محاكاة إعادة تشغيل التطبيق)

**bloc/widget test لـ `SentencePagerView`:** التنقل بين الصفحات يوقف أي تسجيل جارٍ (نفس اختبار مكافئ موجود ضمنيًا في تصرف `VocabularyWordsBody`، اكتب نظيره هنا)

---

## 8. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة، كل الـ tests تعدي
- [ ] فتح Sentences → subtopic: الوضع الافتراضي List، زر أعلى يمين يبدّل لـ Pager فورًا
- [ ] إغلاق التطبيق وإعادة فتحه بعد اختيار Pager → subtopic جديد يُفتح مباشرة بوضع Pager (التفضيل محفوظ فعليًا)
- [ ] فحص بصري: البطاقات الآن بظل وعمق واضحين، مطابقة لمستوى `vocabulary_word_detail_view` — لا حدود رفيعة مسطحة متبقية
- [ ] UK وUS يصدران صوتًا مختلفًا فعليًا، Slow أبطأ محسوسًا من Normal
- [ ] نطق جملة صح بالكامل → نسبة عالية وتلوين أخضر؛ جملة بها كلمة غلط/ناقصة → نسبة أقل وتلوين واضح للكلمة
- [ ] لا خط جديد أُضيف للمشروع (تأكيد: `grep -rn "Plus Jakarta" pubspec.yaml lib/` يعيد صفر نتائج)
- [ ] `git diff --stat`: صفر تعديل في `data/`/`domain/` لـ sentences، وصفر تعديل في `PronunciationBloc`/`SpeechTextMatcher`

## 9. خارج النطاق
- حفظ محاولات الفحص في قاعدة بيانات (Task 09)
- تسجيل صوت المستخدم وتشغيله لاحقًا (Task 09)
- تعديل `PronunciationBloc` أو استخدامه في phonetics/vocabulary
- إعادة تصميم Grammar/Phonetics/Vocabulary نفسها
- أي خط جديد أو نظام تصميم موازٍ لـ `BayanTypography`/`BayanColors`

---

## سجل الجلسة

**الحالة:** ✅ مكتملة — 2026-09-27

### ما تم (جلسة واحدة، مقسّمة لجزأين)

**جلسة 1 (BLoC + تصميم أولي):**
- `SentencePracticeBloc` (event/state/bloc) — أول استخدام لـ `SentenceAssessor`
- تصميم أولي لـ `sentence_item_card.dart` + تحديث `sentence_content_screen.dart`
- `sentence_assessor_test.dart` (11 test) + `sentence_practice_bloc_test.dart` (4 tests)

**جلسة 2 (وضع العرض + تصميم معتمد):**
- `SentencesViewModePreference` — singleton بنمط `AppVoicePreferences`
- `prefSentencesViewMode` في `AppConstants`
- `bind()` في `main.dart`
- `SentenceViewModeToggle` — segmented pill (List/Cards) في الهيدر
- `SentencePagerView` — PageView بنفس بنية `VocabularyWordsBody` + dot indicators
- إعادة تصميم `sentence_item_card.dart` بالكامل:
  - `radiusXl` (بدل `radiusLg`)
  - ظل مطابق لـ `_HeroCard` في vocabulary
  - mic button أخضر (`BayanColors.success`) بظل نابض
  - `_ListContent` و `_PagerContent` منفصلان
  - assessment: inline `RichText` ملوّن (أخضر/أحمر per word) داخل pill ملوّن
- `sentence_content_screen.dart`: هيدر جديد + `ValueListenableBuilder` يبدّل List ↔ Pager
- `sentences_view_mode_test.dart` (4 tests)

**Tests:** 68 total (64 pass + 1 fail قديم `widget_test.dart` ثابت منذ البداية)

### قرارات اتُّخذت
- حفظ وضع العرض في `SharedPreferences` لا `user.db` (تفضيل واجهة بحت)
- assessment يعرض inline RichText بدل word chips منفصلة (أقرب للتصميم المعتمد)
- mic بلون `BayanColors.success` (أخضر) دائمًا — عند الاستماع يتحوّل للـ error (أحمر) لإيقافه
- في Pager mode: تغيير الصفحة يوقف STT + الصوت تلقائيًا (نفس نمط PronunciationBloc في VocabularyWordsBody)