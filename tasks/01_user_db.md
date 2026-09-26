# Task 01 — `user.db` + نقل الـ progress من SharedPreferences

**المرجع:** `PLAN.md` §3.1, §3.3, §11 · **الحالة:** ⬜ لم تبدأ
**الاعتماديات:** لا شيء · **يعتمد عليها:** كل المهام من 05 فصاعدًا

---

## الهدف

إنشاء قاعدة بيانات المستخدم `user.db` بـ **sqflite** منفصلة تمامًا عن `content.db`، وتحويل `ProgressLocalDataSource` ليكتب فيها بدل SharedPreferences، مع ترحيل البيانات الحالية مرة واحدة. **لا تغيير في الـ UI ولا في الـ domain layer** — الـ blocs والـ usecases والـ entities تفضل كما هي.

## لماذا الآن

كل الـ features القادمة (sentences, dictionary, shadowing, vocabulary practice, SRS) تكتب بيانات مستخدم. لو اتأخرت المهمة دي هنعمل migration تاني بعدين.

---

## 1. الملفات

### جديد
| الملف | الدور |
|---|---|
| `lib/core/database/user_database.dart` | فتح/إنشاء/ترقية `user.db` |
| `lib/core/database/user_db_schema.dart` | ثوابت أسماء الجداول والأعمدة + SQL الإنشاء (v1) |
| `lib/core/database/user_db_migrator.dart` | ترحيل prefs → user.db (مرة واحدة) |
| `test/core/database/user_database_test.dart` | |
| `test/core/database/user_db_migrator_test.dart` | |
| `test/features/progress/data/progress_local_datasource_test.dart` | |

### تعديل
| الملف | التعديل |
|---|---|
| `lib/core/database/database_helper.dart` | **rename** الكلاس إلى `ContentDatabase` (الملف `content_database.dart`)، بدون تغيير سلوك. حدّث كل الـ imports |
| `lib/core/constants/app_constants.dart` | إضافة `userDbFileName = 'user.db'` + `userDbVersion = 1` |
| `lib/di/modules.dart` | `DatabaseModule` يوفر **اثنين** بـ `@Named`: `@Named('content') Database` و `@Named('user') Database`. كل الـ datasources الحالية اللي بتاخد `Database` تتحول لـ `@Named('content')` |
| `lib/features/progress/data/datasources/progress_local_datasource.dart` | التنفيذ يتحول لـ `user.db`. **الـ interface `ProgressLocalDataSource` لا يتغير** |
| `lib/main.dart` → `_initializeServices` | استدعاء `UserDbMigrator.runIfNeeded()` بعد الـ DI |

---

## 2. Schema — `user.db` v1

```sql
CREATE TABLE user_settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE user_progress (
  source_table TEXT    NOT NULL,
  source_id    INTEGER NOT NULL,
  status       INTEGER NOT NULL DEFAULT 0,   -- 0 none, 1 in_progress, 2 completed
  score        INTEGER,
  attempts     INTEGER NOT NULL DEFAULT 0,
  started_at   INTEGER,                      -- epoch ms
  completed_at INTEGER,                      -- epoch ms
  PRIMARY KEY (source_table, source_id)
);
CREATE INDEX idx_progress_status ON user_progress(source_table, status);

CREATE TABLE srs_card (
  source_table  TEXT    NOT NULL,
  source_id     INTEGER NOT NULL,
  ease          REAL    NOT NULL DEFAULT 2.5,
  interval_days INTEGER NOT NULL DEFAULT 0,
  due_at        INTEGER NOT NULL,
  reps          INTEGER NOT NULL DEFAULT 0,
  lapses        INTEGER NOT NULL DEFAULT 0,
  last_review   INTEGER,
  PRIMARY KEY (source_table, source_id)
);
CREATE INDEX idx_srs_due ON srs_card(due_at);

CREATE TABLE daily_activity (
  date             TEXT PRIMARY KEY,          -- 'YYYY-MM-DD' local date
  minutes          INTEGER NOT NULL DEFAULT 0,
  items_done       INTEGER NOT NULL DEFAULT 0,
  lesson_completed INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE shadowing_attempt (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  sentence_id   INTEGER NOT NULL,
  recorded_path TEXT,
  similarity    REAL    NOT NULL,
  timing_score  REAL    NOT NULL,
  total         REAL    NOT NULL,
  is_favorite   INTEGER NOT NULL DEFAULT 0,
  created_at    INTEGER NOT NULL
);
CREATE INDEX idx_shadow_sentence ON shadowing_attempt(sentence_id);

CREATE TABLE my_word_list (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  word         TEXT NOT NULL,
  translation  TEXT,
  note         TEXT,
  source_table TEXT,
  source_id    INTEGER,
  created_at   INTEGER NOT NULL
);
CREATE UNIQUE INDEX idx_myword_word ON my_word_list(word COLLATE NOCASE);
```

**قيم `source_table` المعتمدة** (ثوابت في `user_db_schema.dart`، تطابق أسماء جداول content.db حرفيًا):
`grammar_sub_topics`, `phoneticTopic`, `vocaSubTopic`, `vocabulary`, `word_list`, `sentencesSubTopic`, `sentencesContent`, `conversation_lesson`, `conversation_sentence`

كل الجداول تُنشأ في v1 حتى اللي مش هتُستخدم في المهمة دي (srs_card, daily_activity, shadowing_attempt, my_word_list) — علشان المهام الجاية تكتب فيها بدون `onUpgrade`.

---

## 3. `UserDatabase`

```dart
class UserDatabase {
  static Future<Database> open();     // getApplicationDocumentsDirectory / user.db
  static Future<void> close();
}
```
- `openDatabase(path, version: AppConstants.userDbVersion, onCreate: ..., onUpgrade: ..., onConfigure: PRAGMA foreign_keys = ON)`
- `onCreate` ينفّذ كل SQL v1 داخل transaction
- `onUpgrade` فيه switch جاهز فاضي (`case 1:` → لا شيء) للمستقبل
- **لا** يُنسخ من asset. يُنشأ فارغًا.
- لا يمس `content.db` نهائيًا.

---

## 4. `ProgressLocalDataSourceImpl` الجديد

نفس الـ interface الحالي بالظبط:
```dart
Future<Set<int>> getCompletedGrammarSubtopics();
Future<int?>     getInProgressGrammarSubtopic();
Future<void>     setInProgressGrammarSubtopic(int? id);
Future<void>     markGrammarSubtopicCompleted(int id);
// + نفس الأربعة للـ phonetics
```

الترجمة لـ SQL (grammar مثالًا، `source_table = 'grammar_sub_topics'`):
- `getCompleted…` → `SELECT source_id WHERE source_table=? AND status=2`
- `getInProgress…` → `SELECT source_id WHERE source_table=? AND status=1 LIMIT 1`
- `setInProgress(id)` → داخل transaction: كل صفوف `status=1` للجدول ده تتحول لـ `status=0` (يحافظ على قاعدة "واحد فقط in_progress")، ثم لو `id != null`: `INSERT OR REPLACE` بـ `status=1`, `started_at = now` (لو الصف موجود بـ status=2 **لا تلمسه** — completed يفوز)
- `markCompleted(id)` → `INSERT ... ON CONFLICT DO UPDATE SET status=2, completed_at=now, attempts=attempts+1`

يحقن `@Named('user') Database`.

**السلوك الظاهري يجب أن يطابق التنفيذ القديم 100%** — الـ tests الموجودة على `GrammarProgress.statusFor` وغيرها لازم تعدي بدون تعديل.

---

## 5. `UserDbMigrator` — prefs → user.db

يُستدعى مرة عند بدء التشغيل:
```dart
static Future<void> runIfNeeded(SharedPreferences prefs, Database userDb);
```
1. لو `user_settings.migration_done == '1'` → return
2. اقرأ من prefs (المفاتيح الحالية بالحرف):
    - `grammar.completed_subtopics` (JSON list) → صفوف `status=2`, `completed_at = now`
    - `grammar.in_progress_subtopic` (int) → صف `status=1`, `started_at = now`
    - `phonetics.completed_topics`, `phonetics.in_progress_topic` → نفس الشيء بـ `source_table='phoneticTopic'`
    - `selected_level` → `user_settings.level`
    - `selected_voice` → `user_settings.voice_key`
    - `language_code` → `user_settings.explanation_locale`
3. كل الكتابة داخل transaction واحد
4. اكتب `migration_done = '1'`
5. **لا تحذف** مفاتيح prefs القديمة في هذه المهمة (احتياط للـ rollback). تُحذف في task لاحق بعد إصدار مستقر.
6. أي خطأ → log + Crashlytics non-fatal، ولا يُسقط التطبيق، ولا يكتب `migration_done` (يعيد المحاولة الفتحة الجاية)

الإعدادات (`level`, `voice_key`, `explanation_locale`) **تُنسخ فقط** — الكود الحالي يكمل قراءتها من prefs في هذه المهمة. التبديل لـ `user_settings` يحصل في Task 04.

---

## 6. DI

```dart
@module
abstract class DatabaseModule {
  @preResolve @singleton @Named('content')
  Future<Database> get contentDatabase => ContentDatabase.initDatabase();

  @preResolve @singleton @Named('user')
  Future<Database> get userDatabase => UserDatabase.open();
}
```
شغّل `build_runner` وتأكد إن كل الـ datasources الحالية (phonetics, grammar, vocabulary, dashboard) بتاخد `@Named('content')`.

---

## 7. Tests (إجبارية قبل إغلاق المهمة)

استخدم `sqflite_common_ffi` للـ in-memory DB في الـ tests.

**`user_database_test.dart`**
- إنشاء v1 ينتج الجداول الستة + الـ indexes (تحقق من `sqlite_master`)
- فتح مرتين لا يعيد الإنشاء

**`progress_local_datasource_test.dart`**
- `markCompleted` ثم `getCompleted` يرجع الـ id
- `setInProgress(a)` ثم `setInProgress(b)` → `getInProgress == b` فقط
- `setInProgress(x)` على id مكتمل **لا** يغير حالته (يبقى completed)
- `markCompleted` على in_progress يمسح الـ in_progress
- grammar وphonetics معزولان تمامًا (كتابة في واحد لا تظهر في الآخر)
- `attempts` يزيد مع كل `markCompleted`

**`user_db_migrator_test.dart`**
- prefs فيها بيانات → user.db تحتوي نفس الأرقام + `migration_done='1'`
- تشغيل ثاني لا يضاعف الصفوف
- prefs فارغة → `migration_done='1'` بدون صفوف
- JSON تالف في prefs → لا استثناء، migration تكمل للباقي

---

## 8. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة
- [ ] كل الـ tests الجديدة + القديمة تعدي
- [ ] فتح التطبيق بمستخدم عنده progress في prefs → يظهر نفس الـ progress في grammar وphonetics بعد التحديث
- [ ] ملف `user.db` موجود في documents dir، وملف `learn_db.db` **لم يتغير حجمه ولا محتواه**
- [ ] لا تغيير في أي ملف تحت `presentation/` أو `domain/`
- [ ] الـ `ProgressRepository.changes` stream يشتغل زي الأول

## 9. خارج النطاق (لا تفعله هنا)
- أي كتابة في `srs_card` / `daily_activity` / `shadowing_attempt` / `my_word_list`
- حذف مفاتيح prefs القديمة
- قراءة الإعدادات من `user_settings` (Task 04)
- أي تعديل على schema الـ content.db (Task 02)
- ترحيل بيانات التطبيق الـ native القديم (Task 11)

---

## سجل الجلسة
_(يملؤه Claude Code في نهاية الجلسة: ما تم، ما لم يتم، قرارات اتُّخذت، أسئلة مفتوحة)_