# Task 03 — التحقق من الصوت على CloudFront (بدون تعديل السلسلة الحالية)

**المرجع:** `PLAN.md` §3.5 · **الحالة:** ⬜ لم تبدأ
**الاعتماديات:** لا شيء تقنيًا · **يعتمد عليها:** كل feature بيستخدم صوت (05, 07, 08, 09)

---

## ⚠️ تحديث على القرار

**قرار إسلام:** سلسلة الصوت في `sound_player.dart` **تبقى كما هي بالكامل** — لا حذف لـ Google TTS ولا أي تعديل على السلسلة الرباعية الحالية (cache → CDN → device TTS → Google TTS كملاذ أخير نادر). **لا تلمس `sound_player.dart` في هذه المهمة نهائيًا.**

## ملاحظة من الفحص

عند فحص الكود اتضح إن البنية التحتية للصوت جاهزة وصحيحة فعليًا:
- `core/network/cdn_config.dart` (`CdnConfig`) فيه `baseUrl = 'https://dwgyo0auw588p.cloudfront.net'` — **مطابق تمامًا** لرابط CloudFront الحقيقي
- كل الـ helper methods (`vocabularyAudio`, `sentenceAudio`, `conversationAudio`, `phoneticExampleAudio`, `wordListAudio`) بأنماط المسار **مطابقة تمامًا** لعمود `audio_files.file_path` الفعلي في content.db (تم التحقق يدويًا: `us_male/vocabulary/1.mp3`, `us_male/sentences/1.mp3`, `us_male/conversation/1.mp3`, `us_male/phonetic_example/1.mp3`, `us_male/word_list/2.mp3`)
- `AppVoicePreferences` وشاشة الإعدادات (`voice_accent_row.dart`, `voice_gender_row.dart`) جاهزة وتدعم الأصوات الأربعة

**يعني: لا `EnvironmentConfig` جديد، لا تعديل `CdnConfig`، لا تعديل `sound_player.dart`.** الشكل صحيح — الباقي هو **التأكد إن الملفات فعلاً موجودة على الإنترنت**، لأن الرابط الصحيح شكليًا لا يضمن أن كل الـ 59,744 ملف رُفعت فعلًا وبنفس المسار بالضبط.

هذه المهمة الآن **مهمة تحقّق فقط، بدون أي تعديل على `lib/`**.

---

## 1. الملفات

### جديد فقط (لا تعديل على أي ملف Dart)
| الملف | الدور |
|---|---|
| `tools/audio_verification/check_cdn_files.py` | يتحقق فعليًا من عيّنة من الروابط على CloudFront |
| `tools/audio_verification/README.md` | طريقة التشغيل وقراءة التقرير |

---

## 2. `check_cdn_files.py`

```
المدخل:  --db <path to learn_db.db> --sample-size 20 (افتراضي، لكل source_table)
المخرج:  تقرير في الـ stdout + ملف JSON بالتفاصيل الكاملة (tools/audio_verification/report.json)
```

الخطوات:
1. افتح `content.db` (read-only)، لكل `source_table` مختلف في `audio_files` (القيم الخمسة: `vocabulary`, `word_list`, `sentencesContent`, `phonetic_example`, `conversation_sentence`) اسحب عيّنة عشوائية بحجم `--sample-size` **من كل صوت من الأربعة** (يعني 5 جداول × 4 أصوات × 20 = 400 رابط افتراضيًا؛ عدّل الرقم لو كبير جدًا لوقت التشغيل، لكن لازم تغطية لكل تركيبة (source_table, voice))
2. لكل صف: ابنِ الرابط بنفس منطق `CdnConfig` تمامًا:
   `https://dwgyo0auw588p.cloudfront.net/audio/{file_path}` — **استخدم عمود `audio_files.file_path` مباشرة** (`f"{baseUrl}/audio/{file_path}"`), لا تعيد بناء المسار يدويًا، لتفادي أي فرق تسمية بين الجداول (لاحظ: `sentencesContent` في DB لكن `sentences` في المسار، و`conversation_sentence` في DB لكن `conversation` في المسار — استخدام `file_path` مباشرة يتجنب هذا الفخ تمامًا)
3. لكل رابط: HTTP `HEAD` (fallback إلى `GET` بـ `Range: bytes=0-0` لو الـ CDN لا يدعم HEAD) بـ timeout 5 ثواني
4. اجمع النتائج: 200/206 = OK، أي حاجة تانية (403/404/timeout/connection error) = FAIL مع كود الحالة والسبب

تقرير الـ stdout:
```
== Audio CDN Verification ==
vocabulary          : 80/80 OK
word_list           : 80/80 OK
sentencesContent    : 78/80 OK  [2 FAIL]
phonetic_example    : 80/80 OK
conversation_sentence: 80/80 OK
-----------------------------------
TOTAL: 398/400 (99.5%)

FAILURES:
  [404] us_male/sentences/1847.mp3
  [404] uk_female/sentences/1847.mp3
```
exit code: 0 لو 100%، غير كده 1 (لكن يكمل الفحص كامل، لا يتوقف عند أول فشل).

`report.json` يحتوي كل رابط ونتيجته (لتشخيص لاحق لو فيه فشل).

---

## 3. `README.md`

يوثّق:
- طريقة التشغيل: `python3 check_cdn_files.py --db /path/to/learn_db.db`
- إن هذه أداة تشغيل يدوي، وليست جزءًا من CI/CD أو بناء التطبيق
- إن نسبة فشل > 0% تعني ملفات ناقصة فعليًا على S3/CloudFront ويجب رفعها قبل الاعتماد على أي feature يستخدمها

---

## 4. Acceptance criteria

- [ ] السكريبت يعمل بدون تعديل أي ملف تحت `lib/`
- [ ] التقرير الكامل (stdout + عدد الفشل إن وجد) **مرفق في سجل الجلسة بالكامل**، حتى لو 100% نجاح
- [ ] لو فيه أي فشل: القائمة الكاملة للروابط الفاشلة مذكورة بوضوح (لا تُلخَّص أو تُهمَل)
- [ ] `git diff --stat` يظهر فقط ملفات جديدة تحت `tools/audio_verification/`، **صفر تعديل على أي ملف موجود**

## 5. خارج النطاق (لا تفعله هنا)
- أي تعديل على `sound_player.dart` أو `cdn_config.dart` أو `voice_preferences.dart`
- حذف أو تعديل Google TTS بأي شكل
- ربط الصوت بـ features لسه مبنياش (sentences, conversation, dictionary)
- رفع أي ملفات ناقصة على CDN (ده شغل إسلام يدويًا لو ظهر نقص)
- تجميع صوت داخل الـ APK

---

## سجل الجلسة

**الحالة:** ✅ مكتملة — 2026-09-26

### ما تم
- أُنشئ `tools/audio_verification/check_cdn_files.py`
- أُنشئ `tools/audio_verification/README.md`
- السكريبت شُغّل على `assets/databases/learn_db.db` — 400 رابط (5 جداول × 4 أصوات × 20 عيّنة)
- لا أي ملف `lib/` تغيّر ✅

### نتيجة check_cdn_files.py (كاملة)

```
== Audio CDN Verification ==
DB: assets/databases/learn_db.db
CDN base: https://dwgyo0auw588p.cloudfront.net
Sample size: 20 per (source_table × voice)
Workers: 20

Total URLs to check: 400  (5 tables × 4 voices × ~20)

==================================================
  vocabulary               : 80/80 OK
  word_list                : 80/80 OK
  sentencesContent         : 80/80 OK
  phonetic_example         : 80/80 OK
  conversation_sentence    : 80/80 OK
--------------------------------------------------
  TOTAL: 400/400 (100.0%)

All sampled files returned OK.
```

**Exit code: 0 (100% pass)**

### قرار
كل الملفات المُعيَّنة موجودة وقابلة للوصول على CloudFront. البنية التحتية للصوت جاهزة للـ features القادمة (05, 07, 08, 09).