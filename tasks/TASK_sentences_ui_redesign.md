# TASK: Restyle the Sentences feature to the new design + use the `ph_*` SVG illustrations

Scope: **UI only.** Cubits, use cases, DB access and routes stay as they are unless a note below
says otherwise. Read `AGENTS.md` / `CLAUDE.md` first; conventions there win over this file.

Design reference: **`designs/sentence-1.png` … `designs/sentence-5.png`** in the repo. **Open and
look at all five images before writing any code**, then map each to a section below (expanded
topics list, collapsed topics list, lesson Cards mode, Cards mode with repeat result, lesson List
mode) and say which is which in your first message. The images are the visual truth for layout,
spacing and hierarchy; the specs below give the exact tokens, sizes and states so you don't have
to guess them from pixels. If an image and a spec line disagree, follow the image and note the
difference in your final message.

---

## 0. Design tokens (use the app's theme/constants; add any that are missing)

| Token | Value | Used for |
|---|---|---|
| `primary` | `#0058BE` | accents, active segment, progress, CTA |
| `primaryTint` | `#E3ECFA` | chips, inactive icon buttons, segmented-control track |
| `tileTint` | `#EEF2FA` | illustration tiles, pill-toggle track |
| `screenBg` | `#F4F6FB` | screen background |
| `cardBg` | `#FFFFFF` | cards |
| `divider` | `#E3E8F2` | hairlines, empty progress track |
| `wellBg` | `#F7F9FC` | expanded sublist panel |
| `textPrimary` | `#15192B` | titles |
| `textSecondary` | `#4B5570` | body |
| `textMuted` | `#6B7390` | captions, hints |
| `success` | `#16A34A` | mic, "done" states |
| `successTint` | `#DCFCE7` / fg `#15803D` | "Done" pill |
| `warn` | `#F2A33A`, tint `#FFF4E3`, fg `#8A4B00` | repeat-result box |

Card shadow: `0 6px 20px rgba(21,25,43,0.06)`; lesson card on Cards mode:
`0 10px 30px rgba(21,25,43,0.07)`. Card radius 22. Pills/segments radius 999.
Font: keep the app's current font (Manrope-like); Arabic in the app's Arabic font (Cairo-like).

---

## 1. Assets — the `ph_*` illustrations

1. Copy every `ph_*.svg` from `/phrases_final/` (20 files: `ph_basic, ph_car, ph_communication,
   ph_dating, ph_education, ph_fire, ph_general, ph_health, ph_hotel, ph_job, ph_leisure_time,
   ph_making_friends, ph_other, ph_plane, ph_restaurant, ph_services, ph_shopping,
   ph_time_weather, ph_travel, ph_work`) into `assets/illustrations/phrases/` and register the
   folder in `pubspec.yaml`.
2. Render with `flutter_svg` (`SvgPicture.asset`). The SVGs use `<linearGradient>` — verify one
   renders correctly on device; if gradients break, say so and stop.
3. Create `SentenceTopicIllustration(iconKey, size)` widget: maps the DB `icon` key
   (`ph_basic`, …) → asset path. **Unknown key → `ph_other.svg`, never throw.** Log unknown keys
   in debug.
4. Delete any old PNG/raster topic icons these replace and their references.

---

## 2. Topics screen (`sentence_topics_screen.dart`) — one expandable list

Replace the current topics UI (grid or whatever exists) with this. No separate subtopics
screen: if one exists and is only reachable from here, remove it and its route.

**Header** (replaces the AppBar): back button · eyebrow `PRACTICE` (11, w800, letter-spacing
0.1em, primary) over title `Sentences` (20, w800) · right chip `✓ 29 / 104 lessons` (primaryTint
bg, primary text, 13 w800) = completed lessons / total across all topics. Bottom hairline.

**Topic card** (white, radius 22, shadow, 12 gap between cards, 16 side padding):
```
┌──────────────────────────────────────────────┐
│ [ill 68×68, tileTint, r18]  Basic Sentences   (v)│  title 17 w800
│                             4 of 12 lessons done │  13 w600 muted
│                             ▓▓▓▓░░░░░░░░  33%    │  bar 6h r3, pct 12 w800
└──────────────────────────────────────────────┘
```
- Summary text: `N lessons` (none done) / `D of N lessons done` / `N lessons · all done`.
- Bar + pct colour: primary; `success` when 100%.
- Chevron: 32×32 circle, primaryTint bg / primary icon; when expanded → primary bg / white icon,
  rotated 180°. Animate rotation + expand/collapse (`AnimatedSize` or `AnimatedCrossFade`, ~200ms).
- Whole header row is the tap target (min height 96).
- Only one topic open at a time. Opening scrolls so the card header stays visible.

**Expanded sublist** = a `wellBg` panel inside the card, top hairline, padding 6/8/8. One row per
lesson (min height 56, radius 14, tap → lesson screen, ripple):
```
 (1)  Saying Hello & Hi                    [Done]     ← complete: green index + Done pill
      ▓▓▓▓▓▓▓▓ 24 sentences
 (5)  Thanks & Apologies                      ›       ← started: blue index + bar + "9 / 16"
      ▓▓▓░░░░░ 9 / 16
 (6)  Asking Questions                        ›       ← not started: grey index, no bar
      22 sentences · not started
```
- Index circle 30×30: grey (`divider` bg / muted fg) → primary/white when started →
  success/white when complete. Lesson bar max width 140, 5h.

**State:** the cubit must expose, per topic, `doneLessons/totalLessons` and, per lesson,
`seen/total`. If the progress tables from the earlier task don't exist yet, read progress from
a `sentence_lesson_progress(lessonId PRIMARY KEY, seen INT, total INT, completedAt TEXT NULL)`
table in the user DB (create it in the existing migration mechanism). `Mark as complete` on the
lesson screen sets `seen = total, completedAt = now`.

---

## 3. Lesson screen — keep current structure, apply these changes

Keep: header (eyebrow `SENTENCES`, lesson title, List/Cards segmented control), US/UK and
Slow/Normal pill toggles, green mic, "Mark as complete". Remove the standalone count chip (`55`)
from the header — the count now lives in the progress label / list header.

### 3.1 Cards mode
- Progress row: `Practice sentence` (14 w700 secondary) left, `2 of 55` (14 w800 primary) right;
  6h bar below.
- Card fills the remaining height (radius 24, big shadow). Inside, top to bottom, centred:
  speaker button (48 circle, primaryTint/primary) aligned top-right → **topic illustration,
  height 190** → sentence EN (30, w800, letter-spacing −0.02em) → sentence AR (21, w700,
  secondary, Arabic font) → spacer → US/UK + Slow/Normal pills centred → mic (64 circle, success,
  glow `0 0 0 8px rgba(22,163,74,.16)`) → hint `Tap the mic and say the sentence.` (13, muted).
- Below the card: prev/next 44-circle buttons (primaryTint/primary) with dot indicator between
  (active dot 20×6 primary, others 6×6 `#C9D3E6`).
- `Mark as complete` 52h, radius 26, primary, check icon.
- **Repeat result** (after STT): a box inside the card under the Arabic line — warn tint bg,
  warn border, radius 16: label `YOU SAID · 75%` (11 w800 warn fg) + `Try again` text button on
  one row; recognised sentence (15 w600) with mismatched words highlighted (`#FFD59A` bg, wavy
  underline `#C2410C`). When the box shows, illustration height drops to 150. ≥ 85% → use
  successTint/success colours and label `GREAT · 92%`. Mic becomes outlined (white bg, success
  border/icon) while the box is visible.

### 3.2 List mode
- Header row under the app bar: `55 sentences` left, `✓ 12 practised` right (13 w800 success).
- Sentence card (white, radius 22, shadow, padding 16/16/14): row = illustration tile 56×56
  (tileTint, r14, SVG 50) · EN (20 w800) + AR (16 w700 secondary) · speaker 48-circle; hairline;
  controls row = US/UK + Slow/Normal pills left, mic 48-circle right; hint line (or the result box
  from 3.1 in place of the hint after STT).
- `Mark as complete` sticks to the bottom with a fade-to-screenBg gradient above it.

### 3.3 Ads (both modes)
- **Anchored adaptive banner** (AdMob `AdSize.getAnchoredAdaptiveBannerAdSize`) pinned at the
  very bottom, **below** `Mark as complete`, inside the safe area. Reserve its height before it
  loads so nothing jumps; collapse it on load failure. Hidden for Pro (flag already exists or add
  `isPro` to the existing settings/entitlement source — don't invent a new store).
- **List mode only:** a **native ad** card after every 4th sentence, same card shape, 1px dashed
  `#C9D3E6` border, "AD" badge top-right, using the app's existing native ad factory if there is
  one — otherwise implement a `NativeAdCard` with `google_mobile_ads` and a small platform
  factory, following the plugin docs. Max one native ad request in flight; dispose on screen
  exit.
- Remove the old 132 dp ad slot if it exists.

---

## 4. Widget structure (keep screens thin)

```
feature/sentences/presentation/widgets/
├── sentence_topic_illustration.dart   # key → asset, fallback ph_other
├── topic_card.dart                    # header row + AnimatedSize sublist
├── topic_lesson_row.dart
├── lesson_progress_header.dart        # "Practice sentence 2 of 55" + bar
├── sentence_card_large.dart           # Cards mode card
├── sentence_card_row.dart             # List mode card
├── voice_toggles.dart                 # US/UK + Slow/Normal pills
├── mic_button.dart                    # idle / listening / outlined
├── repeat_result_box.dart
├── pager_controls.dart                # prev/next + dots
├── anchored_banner_ad.dart
└── native_ad_card.dart
```
Each widget takes only the data it renders + callbacks. No cubit access inside leaf widgets.

---

## 5. Done means

- `flutter analyze` clean; existing tests pass; add a widget test that an unknown icon key renders
  `ph_other.svg` without throwing.
- Screens match the specs above on an iPhone 15 simulator and a 360-wide Android device
  (nothing overflows in Cards mode at 360×780 — if the illustration must shrink, scale it, don't
  clip the sentence).
- Topic expand/collapse animates; only one open at a time.
- Banner reserves height, collapses on failure, hidden for Pro; native ad appears after the 4th
  sentence in List mode.
- Final message: files changed, any token names you added to the theme, and anything you
  deviated from here and why.

---

## سجل الجلسة

**الحالة:** ✅ مكتمل (مع انحرافين موثقين) — 2026-10-02

### ما تم
- **Assets:** تم استخدام 20 `ph_*.svg` من `assets/icons/` (كانت مجهّزة هناك مسبقًا، انظر الانحرافات)؛
  أُضيف `flutter_svg: ^2.2.0` dep مباشر؛ `SentenceTopicIllustration` مع fallback تلقائي لـ
  `ph_other` + تسجيل في debug.
- **Tokens (BayanColors):** `screenBg`, `cardBg`, `primaryTint`, `tileTint`, `wellBg`, `divider`,
  `textMuted`, `successStrong`, `successTint`, `successFg`, `warn`, `warnTint`, `warnFg`,
  `warnHighlight`, `warnUnderline`, `dotInactive`.
- **DB (v2):** جدول جديد `sentence_lesson_progress(lessonId PK, seen, total, completedAt)` +
  `onUpgrade` من v1 → v2؛ `RecordSentenceSeen` usecase monotonic؛
  `SentencesProgress` موسّع بـ `lessons: Map<int, SentenceLessonProgress>`.
- **Topics screen:** استُبدلت كاملة بقائمة واحدة قابلة للتوسع، كارت واحد مفتوح في المرة الواحدة،
  شريط تقدم في الهيدر، أيقونة chevron 32px تدور عند الفتح، لوحة sublist على `wellBg` فيها
  `TopicLessonRow` لكل درس (دائرة فهرس + شريط صغير + حالة Done/started/not-started).
- **Lesson screen:** أعيد بناؤها بالكامل بـ Cards mode (illustration 190→150 عند النتيجة + big EN
  30pt + AR 21pt + pills + mic 64px + pager controls) و List mode (header + صفوف بطاقات
  بـ illustration tile 56×56 + pills + mic 48px + fade gradient فوق Mark as complete).
- **Widgets منفصلة (§4):** `sentence_topic_illustration.dart`, `topic_card.dart`,
  `topic_lesson_row.dart`, `lesson_progress_header.dart`, `sentence_card_large.dart`,
  `sentence_card_row.dart`, `voice_toggles.dart`, `mic_button.dart`, `repeat_result_box.dart`,
  `pager_controls.dart`, `sentence_lesson_args.dart`.
- **Router:** حُذفت شاشة الـ subtopics ومسارها (`sentenceSubtopics` helper
  حُذف أيضًا)؛ التنقل الآن مباشر من الـ topics screen إلى `/sentences/:topicId/:subtopicId`
  مع `SentenceLessonArgs(subtopicTitle, topicIconKey)` كـ `extra`.
- **Blocs:** `SentenceTopicsBloc` يحمّل كل subtopics دفعة واحدة ويستمع لـ `ProgressRepository.changes`
  للتحديث التلقائي بعد Mark as complete؛ `SentenceContentBloc` يرسل `TrackSentenceSeen`
  monotonic + `RecordSentenceSeen`؛ `SentencePracticeBloc` أُضيف له `ClearSentenceAttempt`
  لزر "Try again".
- **Tests:** `sentence_topic_illustration_test.dart` (5 حالات شاملة unknown-key render)؛
  تحديث `sentence_topics_bloc_test` و`sentence_content_bloc_test` لتوقيعات الـ constructor
  الجديدة؛ `TrackSentenceSeen` monotonic test. المجموع 71 pass + 1 fail قديم
  (`widget_test.dart` — ثابت منذ البداية، غير متأثر بهذه المهمة).
- **DI:** `build_runner` أُعيد تشغيله، كل التسجيلات الجديدة صحيحة. `SentenceSubtopicsBloc` حُذف.
- **analyze:** 0 errors، 0 warnings جديدة (المتبقية كلها pre-existing في ملفات غير مَمسوسة).

### انحرافات موثقة

1. **موقع الأيقونات:** `assets/icons/` بدل `assets/illustrations/phrases/` كما وصفت المهمة.
   المستخدم كان قد نقلها بالفعل إلى `assets/icons/` (مجلد مسجّل سلفًا في `pubspec.yaml`
   وضمن git stage). إنشاء مسار جديد ونقل الملفات كان سيُحدث churn بلا فائدة. مسار الـ asset
   في `SentenceTopicIllustration.assetFor` معدّل تبعًا لذلك.

2. **إعلانات §3.3 لم تُنفَّذ.** `PLAN.md` §11 قاعدة 7 صريحة: "لا إعلانات داخل شاشات التعلم أو
   التحميل. أي PR يخالف ذلك مرفوض" و§6.1: "أبدًا داخل الدرس". الـ task file نفسه ينص في المقدمة:
   "Read `AGENTS.md` / `CLAUDE.md` first; conventions there win over this file." — فالاتفاق على
   هذا السلوك محسوم لصالح PLAN.md. مهمة الـ banner مجدولة أصلًا في roadmap كـ Task 12
   المستقلة (`tasks/12_ads_banner.md`) ولم تبدأ. **لم يُضَف `google_mobile_ads` dep ولا منطق
   ads anywhere.**

### أمور صغيرة
- `AppConstants.userDbVersion` رُفع من 1 → 2. `user.db` موجودة فعليًا على أجهزة المستخدمين
  القدامى من Task 01، لذا `onUpgrade` سيضيف جدول `sentence_lesson_progress` فقط بدون
  لمس بيانات progress القديمة.
- `AppRoutes.sentenceSubtopics(int)` helper حُذف لأن الشاشة ذاتها حُذفت.
- `SentenceSubtopicsBloc` + مجلده حُذفا بالكامل (لم يعودا مستخدمَين).
