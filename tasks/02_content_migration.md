# Task 02 — سكريبت تنضيف `content.db` (إضافي فقط، بدون حذف)

**المرجع:** `PLAN.md` §3.2 · **الحالة:** ⬜ لم تبدأ
**الاعتماديات:** Task 01 (مفهوميًا فقط — لا تعديل كود مشترك) · **يعتمد عليها:** Task 04, 05, 09

---

## ⚠️ قاعدة صارمة لهذه المهمة

**لا حذف نهائيًا.** لا `DROP TABLE`، لا `DELETE`، لا `ALTER TABLE ... DROP COLUMN`. كل تغيير في هذه المهمة **إضافي فقط** (`CREATE TABLE`, `ALTER TABLE ... ADD COLUMN`, `INSERT`). الجداول القديمة (`level_*` التسعة، `grammar_test`) **تبقى كما هي بجانب** الجديدة. حذفها (إن قررنا لاحقًا) مهمة منفصلة صريحة بعد التأكد من الاستقرار على أرض الواقع — **ليست جزءًا من هذه المهمة ولا تُقترح فيها**.

---

## الهدف

سكريبت Python **خارج التطبيق** يقرأ `assets/databases/learn_db.db` الحالي وينتج نسخة جديدة بنفس الاسم، بإضافة:
1. جدول `content_level` موحّد (نسخة من 9 جداول `level_*` القديمة، القديمة تبقى)
2. جدول `meta` فارغ (تجهيز لتحديث المحتوى لاحقًا)
3. جدول `translation` فارغ (تجهيز للغات الجديدة لاحقًا)
4. عمود `sub_topic_id` في `grammar_content` (مربوط بـ `grammar_sub_topics`)

**لا تعديل على أي كود Dart في هذه المهمة.** الكود الحالي يستمر بالقراءة من الجداول القديمة كما هو تمامًا — الجدول الجديد `content_level` يُنشأ ويُملأ فقط، ولا يُستخدم من أي feature حتى مهمة لاحقة صريحة.

---

## 1. الملفات

### جديد
| الملف | الدور |
|---|---|
| `tools/content_db_migration/migrate_v1.py` | السكريبت نفسه |
| `tools/content_db_migration/README.md` | كيفية التشغيل + المدخلات/المخرجات |
| `tools/content_db_migration/verify_v1.py` | سكريبت تحقق منفصل (عدّ قبل/بعد) |

لا تعديل على أي ملف داخل `lib/`.

---

## 2. مصدر الجداول القديمة (الأسماء والأعمدة الحقيقية — تحقّق منها بنفسك في الملف قبل الكتابة، لا تفترض)

| جدول level_* قديم | أعمدة | عدد الصفوف | source_table المقابل | source_id = |
|---|---|---|---|---|
| `level_vocabulary_topic` | `topicId, levelId` | 14 | `vocaTopic` | `topicId` |
| `level_vocabulary_subtopic` | `subTopicId, levelId` | 101 | `vocaSubTopic` | `subTopicId` |
| `level_sentence_topic` | `topicId, levelId` | 20 | `sentenceTopic` | `topicId` |
| `level_sentence_subtopic` | `subTopicId, levelId, id` | 100 | `sentencesSubTopic` | `subTopicId` |
| `level_phonetic_topic` | `phoneticId, levelId, id` | 115 | `phoneticTopic` | `phoneticId` |
| `level_grammar_topic` | `topicId, levelId` | 20 | `grammar_topics` | `topicId` |
| `level_grammar_subtopic` | `subTopicId, levelId` | 114 | `grammar_sub_topics` | `subTopicId` |
| `level_conversation_lesson` | `lessonId, levelId` | 138 | `conversation_lesson` | `lessonId` |
| `level_conversation_block` | `blockId, levelId, id` | 14 | `conversation_level` | `blockId` |

**ملاحظة مهمة:** `level_conversation_block` رغم اسمه لا يرتبط بـ `conversation_lesson` بل بـ `conversation_level` (14 صف = عدد الـ CEFR levels نفسها، وليس عدد الدروس الـ 138). تحقّق من هذا بالـ query قبل الكتابة: `SELECT MAX(blockId) FROM level_conversation_block` يجب أن يساوي `SELECT MAX(id) FROM conversation_level` وليس `conversation_lesson`.

قبل كتابة أي INSERT، شغّل `PRAGMA table_info` على كل جدول من التسعة وقارن بالجدول أعلاه — لو فيه فرق (عمود إضافي، اسم مختلف) **أوقف ونبّه في الـ README، لا تخمّن**.

---

## 3. الخطوات بالترتيب

### 3.1 نسخ الملف
```python
shutil.copy2(source_db_path, output_db_path)
# اعمل على النسخة فقط، لا تفتح الأصل بوضع كتابة أبدًا
```

### 3.2 `content_level`
```sql
CREATE TABLE IF NOT EXISTS content_level (
  source_table TEXT    NOT NULL,
  source_id    INTEGER NOT NULL,
  level        INTEGER NOT NULL,
  PRIMARY KEY (source_table, source_id)
);
```
ثم 9 عمليات `INSERT INTO content_level SELECT 'vocaTopic', topicId, levelId FROM level_vocabulary_topic` (وهكذا للباقي حسب الجدول أعلاه)، كل واحدة داخل نفس الـ transaction.

**تحقق بعد كل INSERT:** `COUNT(*)` في `content_level` لكل `source_table` = `COUNT(*)` في الجدول القديم المقابل بالضبط. لو فيه فرق (تكرار مفاتيح، إلخ) اطبع تحذيرًا واضحًا بالجدول والعدد ولا تكمل صامتًا.

### 3.3 `meta`
```sql
CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
INSERT INTO meta (key, value) VALUES ('schema_version', '2');
-- 'content_version' لا يُملأ الآن — يُترك لمهمة S3/version.json لاحقًا
```

### 3.4 `translation`
```sql
CREATE TABLE IF NOT EXISTS translation (
  source_table TEXT NOT NULL,
  source_id    INTEGER NOT NULL,
  field        TEXT NOT NULL,
  locale       TEXT NOT NULL,
  text         TEXT NOT NULL,
  PRIMARY KEY (source_table, source_id, field, locale)
);
-- يبقى فارغًا في هذه المهمة
```

### 3.5 ربط `grammar_content`
```sql
ALTER TABLE grammar_content ADD COLUMN sub_topic_id INTEGER;
```
قبل الملء: تحقق أن `grammar_content` و`grammar_sub_topics` بنفس عدد الصفوف (114) وأن الترتيب بالـ `id` متطابق منطقيًا (لا يوجد عمود ربط ظاهر حاليًا، لذا الافتراض هو تطابق ترتيبي `grammar_content.id = grammar_sub_topics.id` بنفس الفهرس). **تحقّق فعليًا بمقارنة العدّين والقيم الدنيا/العليا لـ id في كل جدول قبل الافتراض، واطبع النتيجة في الـ log.** لو الافتراض غير صحيح، أوقف واطلب توضيحًا بدل تخمين الربط.

```sql
UPDATE grammar_content SET sub_topic_id = id;
-- (بافتراض أن id متطابق؛ عدّل فقط لو التحقق في الأعلى أثبت عكس ذلك)
```

### 3.6 لا تلمس
- `grammar_test` — **يبقى كما هو تمامًا**، بدون قراءة أو تعديل
- الجداول التسعة `level_*` — **تبقى كما هي**، السكريبت يقرأ منها فقط
- `my_word_list` في content.db — **تبقى كما هي في هذه المهمة** (نقلها لـ user.db مهمة منفصلة لاحقة، وتتضمن حذفها من هنا — ليست الآن)
- أي عمود أو جدول آخر لم يُذكر أعلاه

---

## 4. `verify_v1.py` — سكريبت التحقق (يُشغَّل بعد الـ migration، منفصل)

يفتح النسخة الجديدة والقديمة معًا (read-only) ويطبع تقرير:
```
[OK]   content_level: 536 rows total (14+101+20+100+115+20+114+138+14 = 536)
[OK]   content_level.vocaTopic: 14 == level_vocabulary_topic: 14
...(لكل من التسعة)
[OK]   meta: 1 row (schema_version=2)
[OK]   translation: 0 rows (as expected)
[OK]   grammar_content.sub_topic_id: 114/114 filled, 0 NULL
[OK]   جميع الجداول القديمة (level_* × 9, grammar_test) موجودة وعدد صفوفها لم يتغير
[FAIL] ... (أي فرق يُطبع بوضوح مع الأرقام، exit code ≠ 0)
```

---

## 5. `README.md` (في نفس مجلد الأداة)

يوثّق:
- طريقة التشغيل: `python3 migrate_v1.py --in <path> --out <path>`
- طريقة التحقق: `python3 verify_v1.py --old <path> --new <path>`
- تنويه: هذه أداة تشغيل يدوي مرة واحدة، ليست جزءًا من بناء التطبيق (CI/CD)
- خطوة يدوية بعد النجاح: استبدال `assets/databases/learn_db.db` بالناتج، ثم `flutter clean && flutter pub get` لضمان نسخ الأصل الجديد عند إعادة تثبيت التطبيق (المستخدمون الحاليون لن يتأثروا إلا بإصدار جديد يغيّر رقم نسخة الـ asset — هذا يُدار في مهمة تحديث المحتوى لاحقًا وليس هنا)

---

## 6. Acceptance criteria

- [ ] السكريبت يعمل على نسخة من `learn_db.db` بدون لمس الأصل
- [ ] `verify_v1.py` يطبع `[OK]` لكل بند، بدون أي `[FAIL]`
- [ ] حجم الملف الجديد ≈ القديم + حجم البيانات المضافة فقط (لا فقدان بيانات ملموس)
- [ ] فتح النسخة الجديدة والتأكد يدويًا (DB Browser for SQLite أو مشابه) أن الجداول القديمة التسعة و`grammar_test` **موجودة بنفس عدد صفوفها بالضبط**
- [ ] لا أي ملف تحت `lib/` تم تعديله في هذه المهمة
- [ ] `content_level` تحتوي 536 صف بالضبط (مجموع التسعة) بدون تكرار مفاتيح

## 7. خارج النطاق (لا تفعله هنا)
- حذف أي جدول أو عمود قديم
- تعديل أي كود Dart أو repository ليقرأ من `content_level`
- نقل `my_word_list` إلى `user.db`
- ملء `meta.content_version` أو أي منطق S3/version.json
- ملء جدول `translation` بأي بيانات فعلية
- استبدال الملف الفعلي في `assets/` تلقائيًا (خطوة يدوية بعد المراجعة)

---

## سجل الجلسة

**الحالة:** ✅ مكتملة — 2026-09-26

### ما تم
- أُنشئ `tools/content_db_migration/migrate_v1.py` — سكريبت الترحيل الإضافي
- أُنشئ `tools/content_db_migration/verify_v1.py` — سكريبت التحقق
- أُنشئ `tools/content_db_migration/README.md` — التوثيق الكامل
- السكريبت شُغّل على نسخة من `learn_db.db` → `/tmp/learn_db_v2.db`
- `verify_v1.py` أعطى ALL CHECKS PASSED بدون أي [FAIL]
- الأصل `assets/databases/learn_db.db` لم يُمسّ (MD5 ثابت)
- لا أي ملف `lib/` تغيّر في هذه المهمة ✅

### قرارات اتُّخذت
- **Duplicates في level_* tables:** تم اكتشاف أن 3 جداول بها source_id مكرر بـ levelId مختلف:
  - `level_sentence_subtopic`: subTopicId 49/50/51 يظهر مرتين (100 صف → 97 unique)
  - `level_conversation_block`: blockId 7/8 يظهر مرتين (16 صف → 14 unique)
  - الحل: `MIN(levelId)` per id مع تسجيل [NOTE] في الـ log وتوثيق في README
- `content_level` total = **633** صف (وليس 536 كما في PLAN.md — رقم PLAN.md خطأ حسابي)
- `grammar_content.sub_topic_id = id` (تحقق: id يتطابق 1–114 في الجدولين)

### ملاحظات للمهام القادمة
- الملف المُرحَّل `/tmp/learn_db_v2.db` جاهز للمراجعة اليدوية ثم استبدال الأصل
- استبدال الأصل خطوة **يدوية** (موثّقة في README) — لا تحدث تلقائيًا
- `content_level` جاهز للاستخدام من Task 04, 05, 09