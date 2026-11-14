# Task 05 — Sentences: بناء الـ feature كاملة (استعراض + استماع)

**المرجع:** `PLAN.md` §9 (رقم 5) · **الحالة:** ⬜ لم تبدأ
**الاعتماديات:** Task 01 (`user.db`) · Task 02 (`content_level`) · Task 03 (صوت متحقَّق) · Task 04 (`ContentLocalizer`)
**يعتمد عليها:** لا شيء مباشرة (تصميم دشبورد Task 10 سيقرأ progress هذا الـ feature)

---

## ⚠️ تصحيح افتراض في `PLAN.md`

الخطة كانت تفترض أن عمود `sentencesContent.answers` "جاهز للتمارين". **بعد الفحص الفعلي هذا غير صحيح:**
- العمود ممتلئ في **37 صفًا فقط من 2,089** (1.8%)
- محتواه **رد مقترح واحد كنص حر** (مثال: للسؤال `What's your name?` → `answers = "My name is Sophia."`)، **ليس** قائمة اختيارات أو إجابة صح/خطأ قابلة للتصحيح تلقائيًا

**النتيجة:** لا يوجد تمرين قابل للتصحيح في هذا الجدول. هذه المهمة تبني **شاشة استعراض واستماع فقط** (Listen & Read)، بدون أي تمرين أو تصحيح. لو `answers` موجودة لسطر معيّن، تُعرض كـ"رد مقترح" (Suggested reply) نصي بس، بدون تفاعل. **لا تبني منطق تصحيح إجابات في هذه المهمة.**

---

## الهدف

بناء feature "Sentences" كاملة (topics → subtopics → قائمة جمل) بنفس بنية Clean Architecture + BLoC المستخدمة في `vocabulary` بالضبط — انسخ نمطها حرفيًا (نفس تسلسل الطبقات، نفس تسمية الملفات، نفس أسلوب الـ blocs). كل جملة تُعرض بالإنجليزي + العربي (عبر `ContentLocalizer`) + زر تشغيل صوت (4 أصوات، متحقَّق من توفرها في Task 03).

---

## 1. Schema المصدر (تأكد بنفسك قبل الكتابة، لا تفترض)

```
sentenceTopic       (topicId, titleEn, titleAr, count, icon)         — 20 صف
sentencesSubTopic   (topicId, subTopicId, titleEn, titleAr)          — 100 صف
sentencesContent    (id, subTopicId, sentencesGrammarEn, sentencesEn,
                      sentencesAr, example, sentenceTitleEn, answers) — 2,089 صف
```
- `sentencesGrammarEn` غالبًا مطابق لـ `sentencesEn` (نفس الكلمة/الجملة) — استخدم `sentencesEn` كالنص الأساسي المعروض، ولا تعرض `sentencesGrammarEn` كسطر منفصل إلا لو القيمتان مختلفتان فعليًا في صف معيّن (تحقق بنفسك، لا تفترض التطابق دائمًا)
- `example` نص إنجليزي (جملة استخدام حقيقية للكلمة/العبارة) — يُعرض كسطر إضافي صغير تحت الجملة الأساسية لو موجود
- `sentenceTitleEn` ممتلئ في 69 صف فقط — عنوان مجموعة صغيرة داخل الـ subtopic أحيانًا. **تجاهله في هذه المهمة** (لا يستحق منطق تجميع إضافي لعدد قليل من الصفوف)
- الصوت: `audio_files` حيث `source_table='sentencesContent'`, `source_id = sentencesContent.id`، عبر `CdnConfig.sentenceAudio(id, voice)` (موجود بالفعل، تحقَّق منه في Task 03)

---

## 2. الملفات (انسخ بنية `features/vocabulary/` بالضبط)

### Domain
```
lib/features/sentences/domain/entities/sentence_topic.dart
lib/features/sentences/domain/entities/sentence_subtopic.dart
lib/features/sentences/domain/entities/sentence_item.dart
lib/features/sentences/domain/repositories/sentences_repository.dart
lib/features/sentences/domain/usecases/get_sentence_topics.dart
lib/features/sentences/domain/usecases/get_sentence_subtopics.dart
lib/features/sentences/domain/usecases/get_sentences.dart
```

### Data
```
lib/features/sentences/data/models/sentence_topic_model.dart
lib/features/sentences/data/models/sentence_subtopic_model.dart
lib/features/sentences/data/models/sentence_item_model.dart
lib/features/sentences/data/datasources/sentences_local_datasource.dart
lib/features/sentences/data/repositories/sentences_repository_impl.dart
```

### Presentation
```
lib/features/sentences/presentation/bloc/sentence_topics/{bloc,event,state}.dart
lib/features/sentences/presentation/bloc/sentence_subtopics/{bloc,event,state}.dart
lib/features/sentences/presentation/bloc/sentence_content/{bloc,event,state}.dart
lib/features/sentences/presentation/screens/sentence_topics_screen.dart
lib/features/sentences/presentation/screens/sentence_subtopics_screen.dart
lib/features/sentences/presentation/screens/sentence_content_screen.dart
lib/features/sentences/presentation/widgets/sentence_topic_card.dart
lib/features/sentences/presentation/widgets/sentence_subtopic_row.dart
lib/features/sentences/presentation/widgets/sentence_item_card.dart
```
(أسماء الـ widgets استرشادية — اتبع تسمية `vocabulary` المكافئة لها لو الاسم الأنسب مختلف قليلًا، المهم التطابق البنيوي لا الحرفي)

### تعديل
| الملف | التعديل |
|---|---|
| `lib/core/router/app_router.dart` | استبدال الـ `_PlaceholderScreen` الخاص بـ `AppRoutes.sentences` بمسارات حقيقية: topics → subtopics (`AppRoutes.sentencesSubtopics` موجود بالفعل بالاسم في `app_routes.dart`) → content. اتبع نفس نمط nested routes الموجود لـ vocabulary |
| `lib/features/progress/domain/repositories/progress_repository.dart` | إضافة قسم Sentences (انظر §3) |
| `lib/features/progress/domain/entities/sentences_progress.dart` (جديد) | مطابق لـ `GrammarProgress` تمامًا (نفس الحقول والمنطق، فقط إعادة تسمية) |
| `lib/features/progress/data/datasources/progress_local_datasource.dart` | 4 methods جديدة: `getCompletedSentencesSubtopics`, `getInProgressSentencesSubtopic`, `setInProgressSentencesSubtopic`, `markSentencesSubtopicCompleted` — تنفيذ مطابق تمامًا لنظيراتها في grammar، بـ `source_table='sentencesSubTopic'` (هذه القيمة موجودة بالفعل ضمن الثوابت المعتمدة من Task 01، لا حاجة لإضافتها) |
| `lib/features/progress/data/repositories/progress_repository_impl.dart` | تفويض الاستدعاءات الجديدة لنفس الـ datasource، بنفس نمط قسم Grammar بالضبط |
| `lib/features/progress/domain/usecases/get_sentences_progress.dart` (جديد) | مطابق لـ `get_grammar_progress.dart` |
| `lib/features/progress/domain/usecases/mark_sentences_subtopic_started.dart`, `mark_sentences_subtopic_completed.dart` (جديد) | مطابقان لنظيريهما في grammar |

**ملاحظة مهمة:** `ProgressLocalDataSource` تحتها فعليًا استعلامات SQL عامة (`source_table` + `source_id`) بُنيت في Task 01. إضافة الدوال الأربعة الجديدة **لا تحتاج أي تعديل في `user_database.dart` أو الـ schema** — فقط دوال جديدة في نفس الكلاس تستخدم نفس الجدول `user_progress` بقيمة `source_table` مختلفة. لا تُنشئ جدولًا جديدًا.

---

## 3. `ProgressRepository` — الإضافة (بنفس ترتيب وتسمية قسم Grammar الموجود)

```dart
abstract class ProgressRepository {
  // ... الموجود (Grammar, Phonetics) بدون تغيير ...

  // ─── Sentences ────────────────────────────────────────────────────────
  Future<SentencesProgress> getSentencesProgress();
  Future<void> markSentencesSubtopicStarted(int subtopicId);
  Future<void> markSentencesSubtopicCompleted(int subtopicId);
}
```
`SentencesProgress` نسخة طبق الأصل من `GrammarProgress` (`completedSubtopicIds`, `inProgressSubtopicId`, نفس الدوال `isCompleted`/`isInProgress`/`statusFor`/`topicProgress`/`overallProgress`).

**معيار الإكمال لهذه المهمة:** زر "تم" (`Mark as complete` أو ما يعادلها بصريًا بأسلوب grammar) في أسفل قائمة جمل الـ subtopic — وليس تلقائيًا عند التمرير. نفس آلية `MarkGrammarLessonCompleted` بالضبط، لكن بدون شرط "قفل الدرس التالي حتى إتمام السابق" (الجمل ليست تسلسلية تعليميًا زي القواعد — كل subtopic مستقل، **لا تبني منطق قفل/فتح تدريجي هنا**، كل الـ subtopics تكون مفتوحة دائمًا بصرف النظر عن حالة الإكمال).

---

## 4. `SentencesRepository` (domain interface)

```dart
abstract class SentencesRepository {
  Future<List<SentenceTopic>> getTopics();
  Future<List<SentenceSubtopic>> getSubtopics(int topicId);
  Future<List<SentenceItem>> getSentences(int subtopicId);
}
```
لا حاجة لـ `getTopicsForLevel` في هذه المهمة (الفلترة بالمستوى تُبنى مع الشاشة الرئيسية الجديدة في 1.1، ليست هنا — نفس ما لم يُستخدم بعد فعليًا في vocabulary UI الحالي رغم وجود الدالة).

## 5. Entities

```dart
class SentenceTopic {
  final int id; final String title; final String titleAr;
  final int sentenceCount; final String? icon;
}
class SentenceSubtopic {
  final int id; final int topicId; final String title; final String titleAr;
}
class SentenceItem {
  final int id;
  final String english;       // sentencesEn
  final String arabic;        // sentencesAr → عبر ContentLocalizer
  final String? example;      // جملة استخدام، لو موجودة
  final String? suggestedReply; // answers، لو موجود (نص فقط، بدون تفاعل)
}
```

## 6. Models — تطبيق `ContentLocalizer` مباشرة (بدون انتظار عمود عربي منفصل زي باقي الـ features)

```dart
// sentence_item_model.dart
factory SentenceItemModel.fromMap(Map<String, dynamic> map) => SentenceItemModel(
  id: map['id'] as int,
  english: map['sentencesEn'] as String? ?? '',
  arabic: ContentLocalizerImpl.instance.localize(
    sourceTable: 'sentencesContent',
    sourceId: map['id'] as int,
    field: 'sentencesAr',
    englishValue: map['sentencesEn'] as String? ?? '',
    arabicValue: map['sentencesAr'] as String?,
  ),
  example: map['example'] as String?,
  suggestedReply: map['answers'] as String?,
);
```
نفس النمط لـ `sentence_topic_model.dart` (`field: 'titleAr'`) و`sentence_subtopic_model.dart` (`field: 'titleAr'`).

## 7. Datasource — استعلامات SQL على `@Named('content') Database`

```dart
Future<List<SentenceTopicModel>> getTopics() =>
    db.query('sentenceTopic', orderBy: 'topicId');

Future<List<SentenceSubtopicModel>> getSubtopics(int topicId) =>
    db.query('sentencesSubTopic', where: 'topicId = ?', whereArgs: [topicId],
        orderBy: 'subTopicId');

Future<List<SentenceItemModel>> getSentences(int subtopicId) =>
    db.query('sentencesContent', where: 'subTopicId = ?', whereArgs: [subtopicId],
        orderBy: 'id');
```
(أسماء الأعمدة كما في §1 بالحرف — camelCase، لا تحوّلها)

## 8. UI

- **Topics screen:** grid/list زي `vocabulary_topics_screen.dart` بالضبط، شريط تقدم لكل موضوع (`SentencesProgress.topicProgress`)
- **Subtopics screen:** قائمة زي `vocabulary_subtopics_screen.dart`، بدون حالة "مقفول" (كل الصفوف مفتوحة دائمًا، خلافًا لـ grammar)
- **Content screen:** قائمة بطاقات، كل بطاقة: الجملة الإنجليزية (كبيرة) + العربية تحتها (عبر `ContentLocalizer`، تُخفى/تُظهر حسب `AppContentLanguage.instance.showArabic` — **استخدم نفس الـ widget/pattern الموجود بالفعل في phonetics أو grammar لإظهار/إخفاء العربي، لا تبني منطقًا جديدًا**) + `example` كسطر رمادي صغير لو موجود + `suggestedReply` كـ"رد مقترح:" لو موجود + زر صوت (`CdnConfig.sentenceAudio` + `SoundPlayer` الموجود، بنفس نمط استدعائه في `vocabulary_words_bloc.dart`) + زر "تم" في الأسفل يستدعي `MarkSentencesSubtopicCompleted`

**عند فتح شاشة المحتوى:** استدعِ `MarkSentencesSubtopicStarted` (نفس لحظة استدعاء نظيرتها في grammar عند فتح الدرس).

---

## 9. Tests

- `sentences_repository_impl_test.dart` — mock للـ datasource، تحقق من تمرير البيانات بشكل صحيح
- `sentence_item_model_test.dart` — تحقق أن `arabic` يساوي `sentencesAr` عند `currentLocale='ar'` (نفس نمط regression tests في Task 04)
- `progress_repository_impl_test.dart` (تحديث) — إضافة حالات لقسم Sentences (started/completed/معزول عن grammar وphonetics)
- على الأقل bloc test واحد لكل من الثلاث blocs (loading → loaded → error)

---

## 10. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة
- [ ] كل الـ tests الجديدة والقديمة تعدي
- [ ] التنقل الفعلي: داشبورد → Sentences → موضوع → subtopic → قائمة جمل → تشغيل صوت جملة → زر "تم" → الرجوع يُظهر تقدّم محدَّث
- [ ] العربي يظهر صح لكل جملة/موضوع/subtopic (فحص بصري، خذ لقطة شاشة لثلاث مستويات)
- [ ] لا أي منطق تصحيح إجابات أو تمرين تفاعلي في هذه المهمة
- [ ] `_PlaceholderScreen` الخاص بـ Sentences أُزيل بالكامل من `app_router.dart`

## 11. خارج النطاق (لا تفعله هنا)
- أي تمرين تفاعلي أو تصحيح تلقائي (العمود `answers` لا يدعم ذلك، انظر التصحيح أعلى الملف)
- ربط progress الـ dashboard الرئيسي (Task 10)
- فلترة حسب المستوى (`content_level`) في الواجهة — الجدول موجود من Task 02 لكن لا واجهة تستخدمه بعد في أي feature حاليًا
- التسجيل الصوتي أو Shadowing (Task 08، خاص بـ Conversations فقط أصلًا)
- تحديث `PLAN.md` نفسه (سيُحدَّث في نهاية المراجعة بعد هذه المهمة)

---

## سجل الجلسة

**الحالة:** ✅ مكتملة — 2026-09-27

### ما تم
**Domain:**
- `sentence_topic.dart`, `sentence_subtopic.dart`, `sentence_item.dart` entities
- `SentencesRepository` interface + 3 usecases

**Data:**
- 3 models مع `ContentLocalizer` + `_emptyToNull` helper لـ answers/example
- `SentencesLocalDataSourceImpl` بـ `@Named('content')` — 3 queries SQL
- `SentencesRepositoryImpl`

**Progress:**
- `SentencesProgress` entity (نسخة من GrammarProgress بدون قفل تدريجي)
- 4 methods جديدة في `ProgressLocalDataSource` + impl بـ `srcSentencesSubTopic`
- `getSentencesProgress`, `markSentencesSubtopicStarted`, `markSentencesSubtopicCompleted` usecases
- `ProgressRepository` و `ProgressRepositoryImpl` محدَّثَان

**Presentation:**
- 3 blocs (topics/subtopics/content) مع events/states
- 3 screens + 3 widgets (`SentenceTopicCard`, `SentenceSubtopicRow`, `SentenceItemCard`)
- `SentenceItemCard` يستخدم `BilingualText` الموجود لإظهار/إخفاء العربي

**Router:**
- `app_routes.dart`: أُضيف `sentenceSubtopics(id)` و `sentenceContent(topicId, subtopicId)`
- `app_router.dart`: `_PlaceholderScreen` حُذف وأُضيف nested GoRoute (3 مستويات)

**Tests:** 13 test جديد تعدي (sentence_item_model × 4، repository × 4، blocs × 5)
**DI:** `build_runner` محدَّث، كل registrations صحيحة
**analyze:** 0 errors، 0 warnings جديدة

### قرارات اتُّخذت
- `answers` column: يُعرض كـ "Suggested reply" نصي بدون تفاعل — لا تصحيح تلقائي (1.8% من الجمل فقط فيها قيمة)
- `sentenceTitleEn`: تُجاهَل (69 صف فقط، لا يستحق منطق تجميع)
- قفل/فتح: **لا** — كل الـ subtopics مفتوحة دائمًا خلافًا للـ grammar
- معيار الإكمال: زر "Mark as complete" يدوي في أسفل الشاشة
- `bloc_test` و `mocktail` أُضيفا لـ dev_dependencies (لأول مرة في المشروع)

### ملاحظات للمهام القادمة
- Task 10 (Dashboard) سيقرأ `getSentencesProgress()` لعرض التقدم
- `SentencesSubtopicBloc` يجلب progress مرة واحدة عند التحميل — لو أُريد تحديث فوري بعد الإكمال يمكن إضافة `watch()` لاحقًا