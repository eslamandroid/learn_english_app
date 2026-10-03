# Task 07 — Dictionary: `word_list` بفلتر CEFR + بحث + إضافة لـ My Words

**المرجع:** `PLAN.md` §9 (رقم 7) · **الحالة:** ⬜ لم تبدأ
**الاعتماديات:** Task 01 (`my_word_list` في user.db) · Task 03 (صوت متحقَّق) · Task 04 (`ContentLocalizer`)
**يعتمد عليها:** لا شيء مباشرة

---

## الهدف

بناء تاب "Words" الحالي (`_PlaceholderScreen`) كقاموس: قائمة 5,586 كلمة قابلة للفلترة حسب مستوى CEFR والبحث بالاسم، مع إمكانية حفظ أي كلمة في "My Words" (`my_word_list`، موجود فارغ من Task 01). **لا progress/تتبّع تعلّم لهذه الميزة في 1.0** — هي أداة مرجعية (قاموس)، وليست وحدة تعليمية متسلسلة كالباقي.

---

## 1. Schema المصدر (تحقق بنفسك قبل الكتابة)

```
word_list       (id, word, word_ar, pronunciation, example, level)   — 5,586 صف
                 level ∈ {'A1','A2','B1','B2','C1','C2'} كنص مباشر
word_list_topic (id, level, level_ar, lev)                           — 6 صفوف، معلومات عرض فقط لكل مستوى
```
- `pronunciation` = IPA (مثال: `/əˈbaʊt/`)
- `word_list.level` **نص** مطابق تمامًا لـ `CefrLevel.label` الموجود في `shared/enums/cefr_level.dart` (`'A1'`..`'C2'`) — **لا علاقة له بجدول `content_level`** (الذي يستخدم مستويات رقمية 1-6 لمحتوى آخر بالكامل). استخدم `CefrLevel.label` مباشرة في شرط `WHERE level = ?`، **لا تبني تعيينًا رقميًا جديدًا لهذا الجدول**.
- الصوت: `audio_files` حيث `source_table='word_list'`, `source_id = word_list.id` (مُتحقَّق 100% في Task 03) عبر `CdnConfig.wordListAudio(id, voice)`

---

## 2. الملفات

### Domain
```
lib/features/dictionary/domain/entities/dictionary_word.dart
lib/features/dictionary/domain/repositories/dictionary_repository.dart
lib/features/dictionary/domain/usecases/search_dictionary_words.dart
lib/features/dictionary/domain/usecases/save_word_to_my_words.dart
lib/features/dictionary/domain/usecases/remove_word_from_my_words.dart
lib/features/dictionary/domain/usecases/get_my_words.dart
```

### Data
```
lib/features/dictionary/data/models/dictionary_word_model.dart
lib/features/dictionary/data/datasources/dictionary_local_datasource.dart     (@Named('content') Database)
lib/features/dictionary/data/datasources/my_words_local_datasource.dart       (@Named('user') Database)
lib/features/dictionary/data/repositories/dictionary_repository_impl.dart
```

### Presentation
```
lib/features/dictionary/presentation/bloc/dictionary/{bloc,event,state}.dart
lib/features/dictionary/presentation/screens/dictionary_screen.dart
lib/features/dictionary/presentation/widgets/dictionary_level_filter.dart
lib/features/dictionary/presentation/widgets/dictionary_search_bar.dart
lib/features/dictionary/presentation/widgets/dictionary_word_card.dart
lib/features/dictionary/presentation/widgets/my_words_sheet.dart   (bottom sheet أو شاشة لعرض My Words المحفوظة)
```

### تعديل
| الملف | التعديل |
|---|---|
| `lib/core/router/app_router.dart` | استبدال `_PlaceholderScreen(label: 'Word list')` بـ `DictionaryScreen` على `AppRoutes.wordList` |

**لا تلمس:** أي ملف في `vocabulary/`, `sentences/`, `progress/`. هذا الـ feature مستقل تمامًا ولا يكتب في `user_progress`.

---

## 3. Entity

```dart
class DictionaryWord {
  final int id;
  final String word;          // الإنجليزي
  final String arabic;        // word_ar → عبر ContentLocalizer
  final String pronunciation; // IPA
  final String example;
  final CefrLevel level;
  final bool isSaved;         // موجود في my_word_list؟ (يُحسب عند الجلب، ليس عمودًا في word_list)
}
```

## 4. Model

```dart
factory DictionaryWordModel.fromMap(Map<String, dynamic> map, {required bool isSaved}) =>
  DictionaryWordModel(
    id: map['id'] as int,
    word: map['word'] as String,
    arabic: ContentLocalizerImpl.instance.localize(
      sourceTable: 'word_list',
      sourceId: map['id'] as int,
      field: 'word_ar',
      englishValue: map['word'] as String,
      arabicValue: map['word_ar'] as String?,
    ),
    pronunciation: map['pronunciation'] as String? ?? '',
    example: map['example'] as String? ?? '',
    level: CefrLevel.fromKey((map['level'] as String).toLowerCase()),
    isSaved: isSaved,
  );
```
(`CefrLevel.fromKey` يتوقع مفتاحًا lowercase حسب تعريف الـ enum — حوّل `level` من `word_list` لـ lowercase عند الاستدعاء، لا تُعدّل الـ enum نفسه)

## 5. Datasources

**`dictionary_local_datasource.dart`** (`@Named('content') Database`):
```dart
Future<List<Map<String, dynamic>>> search({
  String? query,       // LIKE على word أو word_ar
  CefrLevel? level,    // WHERE level = ?
  int limit = 50,
  int offset = 0,
});
```
- بدون `query` ولا `level`: أول صفحة من كل الكلمات مرتبة أبجديًا (`ORDER BY word`)
- `query` غير فارغ: `WHERE word LIKE '%?%' OR word_ar LIKE '%?%'` (استخدم parameter binding، لا string interpolation مباشر لتفادي SQL injection حتى لو كان المصدر محليًا)
- **Pagination إجبارية**: 5,586 صف لا تُحمَّل دفعة واحدة في القائمة الافتراضية (بدون بحث) — استخدم `limit`/`offset` مع "تحميل المزيد" عند الوصول لنهاية القائمة (أو infinite scroll بسيط). نتائج البحث المفلترة (غالبًا عدد قليل) يمكن تحميلها كاملة دفعة واحدة إن كان عددها أقل من حد معقول (مثلًا < 200)

**`my_words_local_datasource.dart`** (`@Named('user') Database`، جدول `my_word_list` من Task 01):
```dart
Future<Set<String>> getSavedWords();   // SELECT word — لمعرفة isSaved بسرعة لكل صفحة نتائج
Future<void> save({required String word, String? translation, required int sourceId});
  // INSERT OR IGNORE (الجدول عنده UNIQUE على word COLLATE NOCASE من Task 01)
  // source_table ثابت = 'word_list' دائمًا من هذا الـ feature
Future<void> remove(String word);
Future<List<Map<String, dynamic>>> getAll();  // لعرض My Words
```

---

## 6. UI

**`DictionaryScreen`:**
- شريط بحث أعلى (`dictionary_search_bar.dart`) — debounce ~300ms قبل إطلاق البحث، لا طلب DB مع كل حرف
- فلتر مستوى أفقي قابل للتمرير (`dictionary_level_filter.dart`) — 7 خيارات: "الكل" + 6 مستويات، بألوان `CefrLevel.color` الموجودة بالفعل (نفس الشرائح المستخدمة في grammar/vocabulary)
- زر "My Words" في الهيدر (عدد الكلمات المحفوظة بجانبه) يفتح `my_words_sheet.dart`
- قائمة `dictionary_word_card.dart`: الكلمة الإنجليزية + IPA صغير بجانبها + العربي تحتها (`ArabicVisibility` الموجود) + `example` كسطر رمادي + زر صوت (`CdnConfig.wordListAudio` + `SoundPlayer`) + زر قلب/نجمة للحفظ في My Words (تبديل فوري، تفاؤلي UI ثم تأكيد من DB)
- حالة فارغة واضحة عند بحث بلا نتائج

**`my_words_sheet.dart`:** قائمة بسيطة بما حُفظ، زر إزالة لكل عنصر، حالة فارغة ("لم تحفظ أي كلمة بعد")

**لا صوت تلقائي عند فتح الشاشة.** لا mic/pronunciation check في هذه المهمة (القاموس للمراجعة السريعة، ليس تدريبًا).

---

## 7. Tests

- `dictionary_word_model_test.dart` — تحويل `level` نصًا لـ `CefrLevel` صحيح لكل القيم الستة
- `dictionary_local_datasource_test.dart` — بحث بالإنجليزي، بحث بالعربي، فلتر مستوى، pagination (offset/limit صحيحين)
- `my_words_local_datasource_test.dart` — حفظ، حفظ مكرر لا يفشل (`INSERT OR IGNORE`)، إزالة، معزول تمامًا عن أي جدول آخر في `user.db`
- `dictionary_bloc_test.dart` — بحث → تحميل → نتائج، تبديل فلتر يعيد البحث، تبديل حفظ كلمة يحدّث `isSaved` في القائمة المعروضة فورًا

---

## 8. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة، كل الـ tests تعدي
- [ ] فتح تاب Words: قائمة كلمات تظهر فورًا (بدون تجميد الواجهة رغم 5,586 صف — بفضل الـ pagination)
- [ ] البحث عن كلمة إنجليزية وكلمة بالعربي يرجع نتائج صحيحة
- [ ] فلتر مستوى واحد يقلّل النتائج فعليًا لذلك المستوى فقط
- [ ] حفظ كلمة → تظهر في My Words فورًا → إزالتها من My Words تُحدّث القلب في القائمة الرئيسية لو ظهرت فيها مرة أخرى
- [ ] إغلاق التطبيق وإعادة فتحه: الكلمات المحفوظة سابقًا لا تزال في My Words (تأكيد ثبات `user.db`)
- [ ] تشغيل صوت كلمة من القاموس يعمل (4 أصوات)
- [ ] `_PlaceholderScreen` الخاص بـ Word list أُزيل بالكامل
- [ ] `git diff --stat`: لا تعديل في `vocabulary/`, `sentences/`, `progress/`

## 9. خارج النطاق
- أي progress/تتبّع تعلّم لهذا الـ feature
- ربط `content_level` (غير ذي صلة بـ `word_list` كما وُضِّح في §1)
- فحص نطق/مايك
- عرض My Words ضمن إحصائيات الداشبورد (Task 11)
- فرز أبجدي بالعربي أو أي ترتيب غير `ORDER BY word` الإنجليزي

---

## سجل الجلسة

**الحالة:** ✅ مكتمل — 2026-10-03

### ما تم

**Domain:**
- `DictionaryWord` entity (مع `copyWith(isSaved)`)
- `DictionaryRepository` interface + 4 use cases: `SearchDictionaryWords`,
  `GetMyWords` (مع `.watch()` stream)، `SaveWordToMyWords`, `RemoveWordFromMyWords`

**Data:**
- `DictionaryWordModel` مع `fromMap({required bool isSaved})` و `fromMyWordsJoin`
  (fallback graceful لو word_list row غير موجودة بعد تحديث محتوى)
- `DictionaryLocalDataSourceImpl` (`@Named('content')`): `search` بـ parameter binding
  وضمان escape لـ `%`/`_` قبل الـ LIKE، `ORDER BY word COLLATE NOCASE`،
  `limit`/`offset` إجباريان
- `MyWordsLocalDataSourceImpl` (`@Named('user')`): `save` بـ
  `ConflictAlgorithm.ignore` (آمن مع UNIQUE من Task 01)، `remove` بـ `COLLATE NOCASE`
- `DictionaryRepositoryImpl` يدمج الـ datasource الاثنين ويفتح
  `savedChanges` broadcast stream للتحديثات الفورية بين الصفحة الرئيسية و My Words

**Presentation:**
- `DictionaryBloc` + events (`LoadInitial`, `QueryChanged`, `LevelChanged`,
  `LoadMore`, `ToggleSaved` بتدفق optimistic، `PlayAudio`/`StopAudio`,
  internal `SavedSetRefreshed`) + state مع pagination (`hasMore`), status enum،
  playingWordId, myWordsCount
- `DictionaryScreen` مع `AppBar + body` (بدون كومة header/footer في Column — تطبيق فعلي
  لـ feedback memory رقم 2)
- Widgets: `DictionarySearchBar` (debounce 300ms داخلي، `Timer`-based، زر clear)،
  `DictionaryLevelFilter` (7 chips أفقية بلون `CefrLevel.color`)،
  `DictionaryWordCard` (level pip + IPA + Arabic عبر `ArabicVisibility` + example +
  speaker + star)، `MyWordsSheet` (bottom sheet مع `getMyWords.watch()`)

**Router:**
- `_PlaceholderScreen(label: 'Word list')` → `DictionaryScreen` على `AppRoutes.wordList`

**DI:** `build_runner` أُعيد تشغيله، 7 تسجيلات جديدة
(`DictionaryLocalDataSource`, `MyWordsLocalDataSource`, `DictionaryRepository`،
 4 use cases + bloc)

**Tests:** 22 اختبار جديد
- `dictionary_word_model_test.dart` (7 cases: level mapping × 6 + null-tolerant + orphan)
- `dictionary_local_datasource_test.dart` (7 cases: ordering, English/Arabic search,
  level filter, pagination, LIKE wildcard safety, getById)
- `my_words_local_datasource_test.dart` (5 cases: save/get/dedupe/remove/isolation)
- `dictionary_bloc_test.dart` (5 cases: initial, level change, toggle on/off,
  loadMore pagination)

**Analyze:** 0 errors، 0 warnings جديدة. المجموع 28 issue — كلها pre-existing في ملفات
غير متأثرة بهذه المهمة.

**Test run:** 93 pass + 1 fail قديم (`widget_test.dart` Counter smoke — موثق كـ broken
من البداية في سجلات Task 05/06). +22 تمامًا من آخر عدّ.

### قرارات اتُّخذت
- **لا `bloc_concurrency` dep:** الاستخدام الوحيد كان `restartable`/`droppable` transformers،
  لكن الـ debounce في الـ search bar (300ms داخلي) يكفي لمنع race conditions المرئية.
  التسلسل الافتراضي لـ bloc آمن هنا والمهمة لا تستحق إضافة dep جديد.
- **Pagination:** 50 صف/صفحة، infinite-scroll بـ `ScrollController.addListener` يحمّل
  عند اقتراب 400px من النهاية. hasMore مبني على
  `returned_count == pageSize` — بسيط وموثوق.
- **Optimistic UI للـ toggle star:** حالة الـ UI تنقلب فورًا قبل الكتابة لـ DB
  لتجنب latency مرئي. الـ `savedChanges` stream يعيد الـ sync لو حصل خطأ.
- **`ArabicVisibility` حول الكلمة العربية فقط** (ليس حول الـ pronunciation أو
  example لأنهما إنجليزي).

### انحرافات
لا شيء. المهمة نُفّذت كما وُصفت، بما في ذلك الحدود (لا progress tracking، لا mic/pronunciation،
لا تعديل في `vocabulary/`, `sentences/`, `progress/`).

### ملاحظات للمهام القادمة
- Task 10 (Dashboard) ممكن يقرأ `myWordsCount` من `GetMyWords.execute()` لعرض
  stat صغير "N words saved"
- Task 11 (ترحيل بيانات Android القديمة) هيحتاج يملأ `my_word_list`
  من الـ Android DB القديمة — نفس الـ datasource الجديد (`MyWordsLocalDataSourceImpl.save`)
  هو نقطة الكتابة الوحيدة الصحيحة له
