# Task 11 — Conversations: إصلاح محاذاة الفقاعات يمين/شمال

**المرجع:** تصميم معتمد `https://claude.ai/artifact/9GaScKM6HViT8qPwCVQC7R` (`ConversationPlayer.dc.html`)
**الحالة:** ⬜ لم تبدأ · **الاعتماديات:** Task 10 · **يعتمد عليها:** لا شيء

---

## المشكلة

بعد تنفيذ Task 10، الفقاعات بتاخد عرض الشاشة تقريبًا بالكامل وبتتكدّس فوق بعض عموديًا، والأفاتار بس هو اللي بيتبدل مكانه يمين/شمال — بينما التصميم المعتمد بيحدد فقاعات بعرض محدود (`max-width: 84%`) مع محاذاة حقيقية: فقاعات المتكلم الأول تبدأ من أقصى اليسار، وفقاعات المتكلم الثاني تبدأ من أقصى اليمين (`align-self: flex-end` + `flex-direction: row-reverse` للمجموعة)، بالضبط زي أي تطبيق محادثة عادي.

---

## الملف

### تعديل فقط
| الملف | التعديل |
|---|---|
| `lib/features/conversation/presentation/widgets/conversation_bubble.dart` | تصحيح المحاذاة والعرض الأقصى (§1) |
| `lib/features/conversation/presentation/widgets/conversation_chat_body.dart` | التأكد أن كل `ConversationBubble` داخل `ListView` ملفوفة بما يسمح لها تاخد عرضها الطبيعي بدل `double.infinity` (عادة `Align` أو `Row` بدل `SizedBox(width: double.infinity)`) |

**لا تلمس:** أي منطق (auto-play, progress, practice bloc) — هذه مهمة تخطيط بصري فقط.

---

## 1. البنية الصحيحة (مطابقة لـ HTML التصميم)

لكل فقاعة، بدل أي `width: double.infinity` أو container ياخد عرض الشاشة كامل:

```dart
Align(
  alignment: isLeftSpeaker ? Alignment.centerLeft : Alignment.centerRight,
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: screenWidth * 0.84),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isLeftSpeaker ? TextDirection.ltr : TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Avatar(...),
        const SizedBox(width: 8),
        Flexible(child: _BubbleContent(...)),  // اسم المتكلم + الكارت + الأزرار تحته
      ],
    ),
  ),
)
```

النقاط الجوهرية:
- **`Align` هو المسؤول عن الالتصاق بأقصى اليسار/اليمين**، وليس `Row` بـ `MainAxisAlignment` (الطريقة الحالية الخاطئة على الأرجح)
- **`ConstrainedBox` بـ `maxWidth`** يمنع الفقاعة من أخذ عرض الشاشة كاملًا — بدونه أي نص قصير زي "Hello." هيطلع كارت بعرض الشاشة بالكامل زي الصورة المرفقة في المحادثة
- استخدام `textDirection: TextDirection.rtl` لعكس ترتيب (أفاتار، فراغ، محتوى) للمتكلم التاني بدل تكرار الكود بنسختين منفصلتين
- `isLeftSpeaker` يُحسب بنفس منطق `_buildAlignmentMap` الموجود بالفعل من Task 10 — **لا تُعِد بناءه**، فقط تأكد إنه بيوصل لـ `ConversationBubble` ويُستخدم هنا

---

## 2. Acceptance criteria

- [ ] `flutter analyze` بدون warnings جديدة
- [ ] فحص بصري فعلي: فقاعة James تبدأ من أقصى يسار الشاشة بعرض محدود (مش كامل الشاشة)، فقاعة Lisa تبدأ من أقصى يمين الشاشة، وفيه فراغ واضح بينهم لجملة قصيرة ("Hello." / "Hi.")
- [ ] جملة طويلة (زي "How have you been since the last time we met?" لو وُجدت في البيانات) لسه بتاخد `maxWidth` محدود ومحتواها بيلتف داخلها بدل ما تتمدد لعرض الشاشة
- [ ] الفقاعة الحالية (المظلّلة أثناء auto-play) والفقاعات الباهتة لسه شغالين بنفس المنطق، فقط العرض والمحاذاة اتصلحوا
- [ ] وضع Pager غير متأثر (هو أصلًا كارت واحد بعرض الشاشة بتصميم مختلف تمامًا، لا علاقة له بهذه المهمة)
- [ ] `git diff --stat`: التعديل محصور في الملفين المذكورين فقط

## 3. خارج النطاق
- أي تعديل على منطق auto-play أو الفحص الصوتي
- وضع Pager
- Role-play (Task 13، منفصلة تمامًا)

---

## سجل الجلسة

**الحالة:** ✅ مكتمل — 2026-10-03

### السبب الجذري

في Task 10، `ConversationBubble.build` كان:
```dart
Row(
  crossAxisAlignment: start,
  children: alignRight
    ? [Flexible(bubble), SizedBox(8), avatar]
    : [avatar, SizedBox(8), Flexible(bubble)],
)
```

مشكلتان:
1. **الـ Row ياخد عرض الـ ListView tile كاملًا** (`double.infinity` الفعلي داخل
   `ListView.builder`)، و`Flexible(bubble)` بياخد كل العرض الفاضي ⇒ "Hello." يظهر
   بكارت بعرض الشاشة بالكامل.
2. **`MainAxisAlignment.start`** الافتراضي يُلصق المحتوى بأقصى اليسار حتى في حالة
   `alignRight: true` — تبديل ترتيب الـ children فقط يحرك الـ avatar من يسار لـ
   يمين الـ bubble، لكن الـ bubble نفسه لسه بيبدأ من يسار الشاشة.

### التصحيح

في `conversation_bubble.dart` **فقط** (و`chat_body.dart` *لم يُعدَّل* — تم فحصه،
`KeyedSubtree(child: ConversationBubble)` لا يفرض عرضًا):

```dart
Align(
  alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
    child: Row(
      mainAxisSize: MainAxisSize.min,   // ← ياخد عرض محتواه بس
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alignRight
        ? [Flexible(bubble), SizedBox(8), avatar]
        : [avatar, SizedBox(8), Flexible(bubble)],
    ),
  ),
)
```

ثلاث قطع تعمل معًا:
- **`Align`** يُلصق المجموعة كلها بأقصى اليسار أو اليمين — هو المسؤول عن المحاذاة
  الحقيقية، ليس `MainAxisAlignment`.
- **`ConstrainedBox(maxWidth: 0.84 * screenWidth)`** يسقف العرض عند 84% حسب التصميم،
  فجملة طويلة تلتف داخل الكارت بدل أن تمتد لعرض الشاشة.
- **`Row(mainAxisSize: MainAxisSize.min)`** يسمح للـ bubble أن يأخذ عرضه الطبيعي —
  "Hi." يصبح كارت صغير فعليًا، لا كارت 84% فاضي.

### لماذا `textDirection: TextDirection.rtl` *لم* يُستخدم (خلافًا لمقترح §1)

مقترح المهمة باستخدام `textDirection: rtl` على الـ Row لعكس ترتيب (avatar, bubble)
يُقدم عيبًا بصريًا: الـ `textDirection` على Row يُصبح الـ ambient Directionality
لكل subtree Text widgets داخل الـ Flexible — فنص إنجليزي زي "Hello." يُحاذى يمين
بدل يسار داخل الكارت نفسه، لأن `Text` يرث الـ Directionality من أقرب parent.

البديل الواضح والصريح: الترتيب الشرطي للأطفال في الـ Row — نفس النتيجة بلا آثار
جانبية. موثقة بتعليق صريح في الكود.

### Tests (5 جديدة، كلها تمر)

في `conversation_bubble_test.dart`:
1. `alignRight: false` → `Align.alignment == Alignment.centerLeft`.
2. `alignRight: true` → `Align.alignment == Alignment.centerRight`.
3. **قياس فعلي:** `ConstrainedBox.constraints.maxWidth ≈ 0.84 × 390 = 327.6px`،
   و`Row` المُقاس بعد layout أقل من 327.6 لجملة "Hi." (يُثبت أن `MainAxisSize.min`
   يعمل والـ Row لا يصل للـ cap).
4. ترتيب الـ children لـ `alignRight: false`: الأفاتار على اليسار من الكارت.
5. ترتيب الـ children لـ `alignRight: true`: الأفاتار على يمين الكارت.

### الأرقام

- **analyze:** 28 issues — صفر جديد.
- **tests:** 131 pass + 1 pre-existing fail (`widget_test.dart` Counter smoke، موثق كـ
  broken من البداية). +5 من آخر عدّ = عدد الاختبارات الجديدة بالضبط.
- **`git diff --stat`:** محصور في `lib/features/conversation/presentation/widgets/conversation_bubble.dart`
  + `test/features/conversation/presentation/widgets/conversation_bubble_test.dart`.
  **لم يُعدَّل** `conversation_chat_body.dart` — فحصنا وتأكدنا أنه نظيف.

### انحرافات
- واحد صغير مبرر: `textDirection: rtl` **لم** يُستخدم كما اقترحت المهمة §1، لأنه
  يُغير محاذاة النص داخل الكارت. البديل (ترتيب شرطي للأطفال) يحقق نفس التأثير
  البصري بالضبط بلا آثار جانبية — موثق في الكود وفي السجل أعلاه.
