# Task 04 — `ContentLocalizer`: تعميم لغة الشرح في Grammar / Phonetics / Vocabulary

**المرجع:** `PLAN.md` §3.4, §7 · **الحالة:** ⬜ لم تبدأ
**الاعتماديات:** Task 01 (`user.db` جاهزة) · Task 02 (جدول `translation` موجود فارغ)
**يعتمد عليها:** أي feature جديدة تعرض شرح مترجم (05 Sentences, 06 Dictionary لاحقًا)

---

## الهدف

بناء نقطة قراءة واحدة (`ContentLocalizer`) لكل نص "شرح" في المحتوى (العربي حاليًا)، بحيث لما نضيف لغة جديدة (تركي مثلًا) في 1.2، **الكود الحالي لثلاث features الجاهزة (Grammar, Phonetics, Vocabulary) يعمل تلقائيًا بدون أي تعديل إضافي** — فقط نملأ جدول `translation`.

**لا تغيير في العمود العربي نفسه ولا في أسماء حقول الـ entities** (`titleAr`, `descriptionAr`, `wordAr`, `bodyAr` تبقى بنفس الاسم). التغيير فقط في **من أين تُملأ هذه الحقول** داخل الـ models.

---

## 0. مفهومان منفصلان — لا تخلط بينهما

1. **`explanation_locale`** (جديد، هذه المهمة): "بأي لغة يُعرض شرح المحتوى؟" — القيمة الوحيدة المدعومة فعليًا في 1.0 هي `'ar'`. القيمة تُخزَّن في `user_settings.explanation_locale` (الجدول والعمود من Task 01 موجودان بالفعل).
2. **`AppContentLanguage` / `ContentLang`** (موجود، `core/utils/content_language.dart`): يتحكم في **ترتيب العرض والإظهار/الإخفاء** للعربي في الواجهة (`emphasis`, `showArabic`). **لا تلمسه في هذه المهمة.** هذا عن العرض، ContentLocalizer عن المصدر.

---

## 1. الملفات

### جديد
| الملف | الدور |
|---|---|
| `lib/core/localization/content_localizer.dart` | الواجهة + الـ singleton |
| `lib/core/localization/content_localizer_impl.dart` | التنفيذ |
| `test/core/localization/content_localizer_test.dart` | |
| `test/features/grammar/data/models/grammar_topic_model_test.dart` | regression |
| `test/features/phonetics/data/models/phonetic_topic_model_test.dart` | regression |
| `test/features/vocabulary/data/models/vocabulary_word_model_test.dart` | regression |

### تعديل (data layer فقط — لا لمس لـ domain/presentation)
| الملف | التعديل |
|---|---|
| `lib/features/grammar/data/models/grammar_topic_model.dart` | `titleAr`/`descriptionAr` عبر `ContentLocalizer` |
| `lib/features/grammar/data/models/grammar_subtopic_model.dart` | نفس الشيء |
| `lib/features/phonetics/data/models/phonetic_category_model.dart` | `titleAr` عبر `ContentLocalizer` |
| `lib/features/phonetics/data/models/phonetic_topic_model.dart` | `titleAr` |
| `lib/features/phonetics/data/models/phonetic_section_model.dart` | `titleAr`, `bodyAr` |
| `lib/features/phonetics/data/models/phonetic_example_model.dart` | `wordAr` |
| `lib/features/vocabulary/data/models/vocabulary_topic_model.dart` | `titleAr` |
| `lib/features/vocabulary/data/models/vocabulary_subtopic_model.dart` | `titleAr` |
| `lib/features/vocabulary/data/models/vocabulary_word_model.dart` | `wordAr` |
| `lib/di/modules.dart` | `@preResolve @singleton` لتهيئة `ContentLocalizer` عند الإقلاع |
| `lib/main.dart` | استدعاء `ContentLocalizer.instance.bind(...)` بعد الـ DI (نفس نمط `AppVoicePreferences.instance.bind`) |

**ممنوع لمس:** أي ملف تحت `domain/` أو `presentation/` في الثلاث features. أسماء حقول الـ entities (`titleAr`, `descriptionAr`, `wordAr`, `bodyAr`) **لا تتغير اسمًا ولا نوعًا** — فقط تحديث الـ doc comment فوق كل حقل ليوضّح أنه الآن "نص مترجَم حسب `explanation_locale`، وليس عربيًا بالضرورة دائمًا (حاليًا = عربي فقط)".

---

## 2. `ContentLocalizer`

### الواجهة
```dart
abstract class ContentLocalizer {
  /// اللغة الحالية لشرح المحتوى، مثل 'ar'. القيمة الافتراضية والوحيدة
  /// المدعومة فعليًا في 1.0 هي 'ar'. أي قيمة غير مدعومة تُعامل كـ 'ar'.
  String get currentLocale;

  /// يُستدعى مرة عند إقلاع التطبيق بعد توفر `@Named('user') Database`.
  Future<void> bind();

  /// يُرجع النص المناسب حسب [currentLocale]:
  /// - locale == 'ar' → [arabicValue] إن لم يكن فارغًا، وإلا [englishValue]
  /// - غير ذلك → يبحث في جدول translation عن
  ///   (sourceTable, sourceId, field, currentLocale)؛ إن لم يوجد يرجع
  ///   [englishValue] ويسجّل الحدث كـ "ترجمة ناقصة" (انظر §2.3)
  String localize({
    required String sourceTable,
    required int sourceId,
    required String field,
    required String englishValue,
    String? arabicValue,
  });
}
```

### 2.1 الـ Singleton (لتطابق نمط الكود الحالي: `AppVoicePreferences.instance`, `AppContentLanguage.instance`)
```dart
class ContentLocalizerImpl implements ContentLocalizer {
  ContentLocalizerImpl._();
  static final ContentLocalizerImpl instance = ContentLocalizerImpl._();
  // ...
}
```
يُسجَّل أيضًا في DI كـ `@singleton` (لمن يحتاج حقنه في اختبارات أو usecases لاحقًا)، لكن الاستخدام من داخل الـ models الثابتة (`fromMap` static) يكون عبر `ContentLocalizerImpl.instance` مباشرة — بنفس أسلوب `CdnConfig.currentVoice` و`AppVoicePreferences.instance` الموجودين بالفعل في الكود.

### 2.2 `bind()`
```dart
Future<void> bind(Database userDb) async {
  final row = await userDb.query('user_settings',
      where: 'key = ?', whereArgs: ['explanation_locale'], limit: 1);
  final stored = row.isNotEmpty ? row.first['value'] as String? : null;
  _locale = (stored == 'ar') ? 'ar' : 'ar'; // فقط 'ar' مدعومة فعليًا في 1.0
  // بنية جاهزة لإضافة لغات: عند دعم لغة جديدة تُضاف لقائمة مسموحة
  // ويُقرأ منها القيمة الفعلية بدل الرجوع الدائم لـ 'ar'.
}
```
**سبب "فقط 'ar' مدعومة فعليًا الآن":** جدول `translation` فارغ (Task 02) ولا يوجد أي منتقٍ للغة في الواجهة بعد (يُبنى في 1.2 مع التركي). لا فائدة من قراءة قيمة قد تكون `'en'` من `language_code` القديم (migrated في Task 01) واعتمادها كلغة شرح — ده كان لغة واجهة، مش لغة شرح محتوى. **وثّق هذا الفرق بوضوح في تعليق الكود.**

### 2.3 التسجيل عند نقص الترجمة
عند `currentLocale != 'ar'` وعدم وجود صف في `translation`: استخدم آلية التسجيل الموجودة بالفعل في المشروع (Firebase Analytics/Crashlytics — تحقق من `core/` كيف تُستدعى حاليًا في أماكن أخرى واتبع نفس النمط) بحدث `translation_missing` مع `source_table`, `source_id`, `field`, `locale`. **لا تُسقط التطبيق ولا تطبع فقط `debugPrint`** — هذا الحدث سيُستخدم فعليًا لقياس جاهزية الترجمة قبل إطلاق كل لغة جديدة.

### 2.4 التخزين المؤقت لجدول `translation`
بما إن الجدول فارغ حاليًا وسيبقى فارغًا حتى 1.2، **لا داعٍ لتحسين أداء استعلام معقّد الآن**. نفّذ استعلام `SELECT` مباشر بسيط لكل `localize()` عند `currentLocale != 'ar'` (المسار الشائع `'ar'` لا يلمس القاعدة إطلاقًا). أضف تعليق `// TODO(1.2): cache translation rows per locale at bind() time once the table has data` بدل بناء تخزين مؤقت غير مُختبَر لبيانات غير موجودة.

---

## 3. تعديل الـ Models — مثال كامل (البقية بنفس النمط)

**قبل** (`vocabulary_word_model.dart`):
```dart
wordAr: (map['ita'] as String?) ?? '',
```

**بعد:**
```dart
wordAr: ContentLocalizerImpl.instance.localize(
  sourceTable: 'vocabulary',
  sourceId: map['id'] as int,
  field: 'ita',
  englishValue: map['name'] as String? ?? '',
  arabicValue: map['ita'] as String?,
),
```

طبّق نفس النمط على كل الحقول المذكورة في جدول §1، بـ:
- `sourceTable` = اسم جدول content.db الحرفي (`grammar_topics`, `grammar_sub_topics`, `phonetic`, `phoneticTopic`, `phonetic_section`, `phonetic_example`, `vocaTopic`, `vocaSubTopic`, `vocabulary`)
- `field` = اسم العمود العربي نفسه كما هو في الجدول (`titleAr`, `descriptionAr`, `title_ar`, `body_ar`, `word_ar`, `ita`) — هذا هو المفتاح الذي سيُطابق عمود `translation.field` لاحقًا، فيجب أن يبقى ثابتًا ومطابقًا لاسم العمود الأصلي بالحرف
- `englishValue` = العمود الإنجليزي المقابل في نفس الجدول (`title`, `name`, `word`, `body`) — تحقق من كل model على حدة، لا تفترض

---

## 4. Tests

**`content_localizer_test.dart`** (بـ in-memory `user.db` عبر `sqflite_common_ffi`، وجدول `translation` من `content.db` محاكى بقاعدة منفصلة أو mock):
- `bind()` بدون قيمة مخزّنة → `currentLocale == 'ar'`
- `bind()` بقيمة `'en'` مخزّنة (محاكاة الترحيل القديم) → `currentLocale == 'ar'` (**ليست `'en'`** — هذا اختبار حرج يمنع رجوع خطأ خلط اللغتين)
- `localize()` بـ `currentLocale='ar'` و`arabicValue` غير فارغ → يرجع العربي
- `localize()` بـ `currentLocale='ar'` و`arabicValue` فارغ/null → يرجع `englishValue`
- (تحضيرًا لـ 1.2، اختبار تركيبي فقط) لو أُجبر `currentLocale` داخليًا على `'tr'` لغرض الاختبار ووُجد صف `translation` مطابق → يرجعه؛ لو غير موجود → يرجع `englishValue`

**Regression tests للـ 3 models المذكورة في §1** — أهم جزء: تأكيد أن **مخرجات `fromMap` بعد التعديل مطابقة تمامًا لما قبل التعديل** عند `currentLocale='ar'` (القيمة الوحيدة الممكنة فعليًا في 1.0)، بإعطاء نفس الـ map القديم والتحقق من نفس القيم بالحرف.

---

## 5. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة
- [ ] كل الـ tests الجديدة تعدي، وكل tests المشروع القديمة (خصوصًا grammar/phonetics/vocabulary الموجودة) تعدي بدون تعديل فيها
- [ ] تشغيل التطبيق فعليًا: شاشات Grammar وPhonetics وVocabulary تعرض نفس النص العربي بالضبط كما قبل التعديل (فحص بصري على 3-4 شاشات من كل feature)
- [ ] `git diff --stat` يُظهر فقط ملفات `data/models/` في الثلاث features + `core/localization/` + `di/modules.dart` + `main.dart`. **صفر تعديل في أي `domain/` أو `presentation/`**
- [ ] `user_settings.explanation_locale` غير الموجودة أو المخزَّنة بقيمة غير `'ar'` لا تُسقط `bind()` ولا تُغيّر السلوك الظاهري

## 6. خارج النطاق (لا تفعله هنا)
- أي منتقٍ لغة في الواجهة (يُبنى في 1.2 مع التركي)
- ملء جدول `translation` بأي بيانات فعلية
- تعديل `AppContentLanguage` / `ContentLang` / `AppLocaleRow` / شاشة الإعدادات
- تطبيق `ContentLocalizer` على sentences/conversation/dictionary (لسه مبنيّة، ستستخدمه مباشرة عند بنائها في مهامها الخاصة)
- أي تحسين أداء/تخزين مؤقت لجدول translation (غير مفيد وهو فارغ)
- تغيير القيمة المرحَّلة فعليًا في `user_settings.explanation_locale` من Task 01 (تبقى كما رُحِّلت، `bind()` فقط يتجاهلها إن لم تكن `'ar'`)

---

## سجل الجلسة

**الحالة:** ✅ مكتملة — 2026-09-26

### ما تم
- أُنشئ `lib/core/localization/content_localizer.dart` — الواجهة المجردة
- أُنشئ `lib/core/localization/content_localizer_impl.dart` — singleton بنمط `AppVoicePreferences`
- أُضيف `LocalizationModule` لـ `modules.dart` يسجّل `ContentLocalizer` كـ `@singleton`
- أُضيف `await ContentLocalizerImpl.instance.bind(userDb)` لـ `main._initializeServices()`
- تم تعديل 9 models (grammar × 2، phonetics × 4، vocabulary × 3) — data layer فقط
- شُغّل `build_runner` — DI config محدَّث صح
- كُتبت 17 test (4 ملفات) — كلها تعدي ✅
- `flutter analyze` — 0 warnings جديدة في الملفات المعدّلة ✅
- `git diff --stat` — صفر تعديل في `domain/` أو `presentation/` ✅

### قرارات اتُّخذت
- **`@Singleton` على الـ impl**: حُذف لأن injectable لا يدعم private constructor. التسجيل في DI عبر `LocalizationModule` فقط، مطابق لنمط `AppVoicePreferences` (بدون injectable annotation على الكلاس).
- **الحقول الـ nullable** (`PhoneticSection.titleAr/bodyAr`, `PhoneticExample.wordAr`, `GrammarTopic/Subtopic.descriptionAr`): استخدام `map['field'] == null ? null : localize(...)` للحفاظ على `null` عند غياب القيمة في الـ DB — يضمن عدم تغيير السلوك الظاهري.
- **`bind()` لا تستخدم القيمة المقروءة**: في v1.0، أي قيمة مخزّنة تُتجاهل ويُعيَّن `_locale = 'ar'` دائمًا. الاستعلام يبقى ليكون الكود الـ 1.2 واضحًا عند التعديل.
- **`contentLocalizer` في DI**: `@singleton` بدون `@preResolve` — التهيئة تحدث في main.dart بعد DI، مطابق لنمط `AppVoicePreferences`.

### ملاحظات للمهام القادمة
- Sentences وConversation وDictionary ستستخدم `ContentLocalizerImpl.instance.localize()` مباشرة في الـ models عند بنائها (لا تعديل مطلوب هنا)
- لإضافة التركي في 1.2: فقط تعديل `bind()` لقراءة القيمة الفعلية وملء `_translationCache`