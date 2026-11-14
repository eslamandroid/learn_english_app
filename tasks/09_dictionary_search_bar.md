# Task 09 — Dictionary: تصميم شريط البحث + تأكيد زر Clear

**المرجع:** تصميم معتمد: `https://claude.ai/artifact/9GaScKM6HViT8qPwCVQC7R` (artboard `Dictionary.dc.html`، قسم البحث)
**الحالة:** ⬜ لم تبدأ · **الاعتماديات:** Task 07، Task 08 (إن نُفِّذت) · **يعتمد عليها:** لا شيء

---

## الخلفية

بعد Task 08، شريط البحث الفعلي في `DictionarySearchBar` لا يطابق شكل التصميم المعتمد (بطاقة بيضاء مرتفعة بظل خفيف وأيقونة بحث، تتحول لحدّ أزرق رفيع + زر مسح دائري عند الكتابة). سجل جلسة Task 07 ذكر أن زر الـ clear **موجود منطقيًا بالفعل** ("زر clear" في وصف `DictionarySearchBar`) — تحقق أولًا هل هو غير ظاهر بصريًا فقط أم غير موصول فعليًا بمسح نص الحقل وإعادة تحميل النتائج، وأصلح أيًا كانت المشكلة الفعلية بدل افتراضها.

---

## الملفات

### تعديل فقط
| الملف | التعديل |
|---|---|
| `lib/features/dictionary/presentation/widgets/dictionary_search_bar.dart` | إعادة تصميم كامل (§1) + التأكد من عمل Clear فعليًا (§2) |

**لا تلمس:** أي ملف آخر في `dictionary/`، ولا `DictionaryBloc` إلا إن كان سبب عطل الـ Clear فعليًا في منطق الحدث لا في الـ widget نفسه (وثّق أيهما في سجل الجلسة).

---

## 1. التصميم — حالتان

**حالة فارغة (لا نص):**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
  decoration: BoxDecoration(
    color: BayanColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(
      color: BayanColors.onSurface.withValues(alpha: .05),
      blurRadius: 8, offset: const Offset(0, 2),
    )],
  ),
  child: Row(children: [
    Icon(Icons.search, color: BayanColors.onSurfaceVariant, size: 18),
    const SizedBox(width: 10),
    Expanded(child: TextField(/* placeholder: "Search in English or Arabic" (أو المفتاح المترجم المستخدم بالفعل) */)),
  ]),
)
```

**حالة بها نص (بعد الكتابة):**
- حدّ رفيع إضافي بلون `BayanColors.primary.withValues(alpha: .25)` حول نفس الحاوية (`Border.all(width: 1.5, color: ...)`)
- أيقونة البحث تتحول للون `BayanColors.primary` بدل `onSurfaceVariant`
- زر دائري صغير (24×24) خلفية `BayanColors.outlineVariant.withValues(alpha:.3)` أو مكافئ فاتح، أيقونة `Icons.close` بحجم 12 ولون `BayanColors.onSurfaceVariant`، يظهر **فقط** عندما يكون نص الحقل غير فارغ (`controller.text.isNotEmpty`)

الانتقال بين الحالتين فوري حسب حالة الـ `TextEditingController` (`AnimatedContainer` اختياري لو أردت انتقالًا ناعمًا للحدّ، غير إجباري).

---

## 2. زر Clear — يجب أن يفعل الثلاثة معًا

1. يمسح نص `TextEditingController` فعليًا (`controller.clear()`)
2. يُعيد الحقل للـ focus أو يُغلق الكيبورد حسب ما هو متوقع تجريبيًا (افحص سلوك تطبيقات مشابهة إن لم يكن محددًا، القرار الافتراضي: يبقي الكيبورد مفتوحًا والـ focus في الحقل لإتاحة كتابة بحث جديد فورًا)
3. يُطلق نفس الحدث الذي يُطلقه مسح النص يدويًا (`QueryChanged('')` أو ما يعادله في `DictionaryBloc`) **لإعادة تحميل القائمة الكاملة غير المفلترة** — ليس فقط تفريغ الحقل بصريًا مع بقاء نتائج البحث القديمة ظاهرة

تحقق فعليًا من البند 3 تحديدًا: اكتب بحثًا، اضغط Clear، وتأكد أن القائمة ترجع لعرض كل الكلمات (أو الصفحة الأولى منها) لا أن تبقى فارغة أو عالقة على آخر نتائج بحث.

---

## 3. Tests

- Widget test: كتابة نص → زر Clear يظهر. حقل فارغ ابتدائيًا → زر Clear غائب
- Widget test: الضغط على Clear → `controller.text.isEmpty == true` **و** حدث إعادة التحميل الكامل أُطلق فعليًا (تحقق عبر mock للـ bloc/stream، لا تكتفِ بفحص الحقل بصريًا)
- `dictionary_bloc_test.dart` (إن احتاج تعديلًا): تأكيد أن `QueryChanged('')` يرجع لنفس نتائج الحالة الابتدائية بدون فلتر

---

## 4. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة، كل الـ tests تعدي
- [ ] فحص بصري: شريط البحث مطابق للتصميم في الحالتين (فارغ/به نص)
- [ ] فحص فعلي: اكتب "anim"، تأكد من ظهور زر Clear، اضغطه، تأكد أن النص اختفى **والقائمة رجعت لكل الكلمات** فعليًا على الشاشة وليس نظريًا فقط
- [ ] `git diff --stat`: التعديل محصور في `dictionary_search_bar.dart` فقط (أو + سطر واحد في `DictionaryBloc` لو كان هذا هو مصدر العطل الفعلي، مُوثَّق بوضوح في سجل الجلسة لماذا)

## 5. خارج النطاق
- أي تعديل على `dictionary_word_card.dart` أو `my_words_sheet.dart` (خارج نطاق هذه المهمة، انظر Task 08)
- إضافة اقتراحات بحث تلقائية (autocomplete) أو سجل بحث سابق

---

## سجل الجلسة

**الحالة:** ✅ مكتمل — 2026-10-03

### تشخيص سبب العطل (الإجابة على السؤال الصريح في المهمة)

**مزدوجة — تصميم بصري + عطل بنيوي حقيقي، ليس عطلًا في الـ Bloc.**

في النسخة التي خرجت من Task 07:
- منطق الـ Clear كان موجودًا وصحيحًا تمامًا في `_clear()`:
  - `_controller.clear()`
  - `widget.onChanged('')` (وهذا يستدعي `DictionaryQueryChanged('')` في البلوك،
    وبلوك تلك المهمة مختبر بالفعل أنه يعيد تحميل كل الكلمات على استعلام فارغ)
- **لكن** الزر نفسه كان لا يظهر أبدًا بصريًا. السبب:
  `suffixIcon: _controller.text.isEmpty ? null : IconButton(...)` يُحسب داخل
  `build()`، والـ state class لم يكن يستمع لأي تغيير في الـ controller ولا يستدعي
  `setState()` عند الكتابة. `TextField` نفسها تُعيد رسم محتواها فقط، لا تُعيد بناء
  parent StatefulWidget، فـ `build` لم يُستدعَ ثانية بعد الكتابة ⇒ `suffixIcon`
  يبقى `null` إلى الأبد.
- الحل في `DictionaryBloc` كان صحيحًا، فلا تعديل عليه. التصحيح كله في الـ widget.

### ما تم

- `dictionary_search_bar.dart` أُعيد بناؤه بالكامل:
  - **إصلاح البنيوي:** `initState` يضيف `_controller.addListener(_onControllerChanged)`
    و `_focusNode.addListener(_onControllerChanged)`؛ كلاهما يستدعي
    `setState({})` فيعاد تقييم ظهور الـ Clear وتبديل اللون الأنيميشني في الإطار التالي.
  - **التصميم:** `AnimatedContainer` بـ `surfaceContainerLowest` + ظل خفيف
    (`onSurface α:.05`, blur 8, offset (0,2))، radius 16، مع حدّ
    `primary α:.25` بسمك 1.5 يظهر عند وجود نص **أو** عند الـ focus (لنفس النمط البصري
    مطابق التصميم في الحالتين).
  - أيقونة البحث تتحول من `onSurfaceVariant` إلى `primary` عند
    `hasText || hasFocus`.
  - زر Clear منفصل كـ `_ClearButton` (24×24 دائرة بـ
    `outlineVariant α:.30`، أيقونة close 14px بـ `onSurfaceVariant`) + `Semantics(label: 'Clear search')`
    حتى اختبار الـ semantics يستهدفه بسهولة.
  - الضغط على Clear: `_timer?.cancel()` (لإلغاء debounce معلّق)، `_controller.clear()`،
    `_focusNode.requestFocus()` (لإبقاء الكيبورد)، ثم `widget.onChanged('')` **فورًا بدون
    debounce** حتى تعود القائمة الكاملة قبل أي تأخير.

### Tests (4 جديدة)

في `dictionary_search_bar_test.dart`:
1. حقل فارغ ابتدائيًا → `Clear search` semantics غير موجود
2. بعد كتابة "anim" → الـ Clear يظهر فورًا (يُثبت أن listener يعمل)
3. tap على Clear → النص فارغ + `onChanged('')` أُطلق مرة واحدة فورًا + الـ focus
   ما زال في الحقل
4. **Regression:** الكتابة ثم الضغط على Clear قبل انقضاء الـ 300ms debounce →
   لا يُطلق أي حدث متأخر بالنص المكتوب (الـ timer أُلغي كما ينبغي). الـ `events`
   يحتوي فقط `['']` بعد الـ sequence.

### الأرقام

- **analyze:** 28 issues — صفر جديد، نفس العدد قبل المهمة
- **tests:** 102 pass + 1 pre-existing fail (`widget_test.dart` Counter — موثق كـ broken
  منذ البداية). +4 من آخر عدّ (98) = عدد الاختبارات الجديدة بالضبط.
- **`git diff` scope:** محصور في:
  - `lib/features/dictionary/presentation/widgets/dictionary_search_bar.dart` (إعادة كتابة)
  - `test/features/dictionary/presentation/widgets/dictionary_search_bar_test.dart` (جديد)
- `DictionaryBloc` **لم يُلمس** — العطل كان في الـ widget نفسه كما وُصف أعلاه.

### قرارات صغيرة

- **`accentActive = hasText || hasFocus`** — الحدّ الأزرق يظهر أيضًا على مجرد الـ focus
  (قبل الكتابة) ليعطي إشارة بصرية فورية أن الحقل جاهز. لم يُطلب صراحة، لكنه يتناسق
  مع التصميم (المحدد يصبح primary وقت التفاعل، ليس وقت وجود نص فقط).
- **`_focusNode` يُدار كجزء من الـ state** (initState/dispose) حتى لا يتسرب resource
  ولا يسقط الـ listener عند التبديل بين الـ widgets.

### انحرافات
لا شيء. المهمة نُفّذت كما وُصفت، والسؤال الصريح في المقدمة (عطل بصري أم بنيوي؟)
مُجاب أعلاه: **كلاهما** — بصري (التصميم الجديد لم يكن مطبقًا) **و** بنيوي (الـ Clear
الموجود منطقيًا لم يكن يظهر بصريًا لأن الـ state لم يرصد تغير الـ controller).