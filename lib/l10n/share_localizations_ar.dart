// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'share_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get unAuthentication => 'غير مصادق — يرجى تسجيل الدخول.';

  @override
  String get unAuthorization => 'ليست لديك صلاحية لتنفيذ هذا الإجراء.';

  @override
  String get notFoundEntity => 'العنصر غير موجود.';

  @override
  String get invalidInput => 'بيانات إدخال غير صحيحة.';

  @override
  String get badCertificateException => 'شهادة غير صالحة أو غير موثوقة.';

  @override
  String get noInternetException => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get noInternetConnection =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من شبكتك والمحاولة مرة أخرى.';

  @override
  String get connectionLost => 'انقطع الاتصال';

  @override
  String get canNotConnectToHost => 'تعذّر الاتصال بالمضيف.';

  @override
  String get serverUnDefined => 'خطأ غير متوقع في الخادم.';

  @override
  String get timeoutException => 'انتهت مهلة الطلب.';

  @override
  String get cancellationException => 'تم إلغاء العملية.';

  @override
  String get unknownException => 'حدث خطأ غير متوقع، برجاء المحاولة مرة أخرى';

  @override
  String get tokenExpired => 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجددًا.';

  @override
  String get parseException => 'خطأ في تحليل البيانات.';

  @override
  String get retryLabel => 'إعادة المحاولة';

  @override
  String get refreshLabel => 'إعادة التحميل';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yesLabel => 'نعم';

  @override
  String get searchLabel => 'بحث';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get language => 'اللغة';

  @override
  String get environmentSwitched =>
      'Environment switched successfully! Restart the app to apply changes.';

  @override
  String get patchAvailableTitle => 'New Update Available';

  @override
  String get patchAvailableMessage =>
      'يوجد تحديث جديد للتطبيق. هل تريد تثبيته الآن؟';

  @override
  String get patchInstallNow => 'تثبيت الآن';

  @override
  String get patchLater => 'لاحقاً';

  @override
  String get patchDownloading => 'جاري التنزيل...';

  @override
  String get patchRestarting => 'جاري إعادة التشغيل...';

  @override
  String get patchDownloadedSuccess => 'تم تنزيل التحديث بنجاح';

  @override
  String get patchCloseAndReopen =>
      'Close and reopen the app to apply changes.';

  @override
  String get showArabicTranslations => 'إظهار الترجمات العربية';

  @override
  String get showArabicTranslationsHint =>
      'إظهار العربية بجانب الإنجليزية في الدروس والأمثلة وقوائم الكلمات.';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية (Arabic)';

  @override
  String get grammar => 'القواعد';

  @override
  String get lesson => 'الدرس';

  @override
  String get practice => 'تدريب';

  @override
  String get examplesInAction => 'أمثلة عملية';

  @override
  String get testYourKnowledge => 'اختبر معلوماتك';

  @override
  String get chooseCorrectForm => 'اختر الصيغة الصحيحة:';

  @override
  String get nextRule => 'القاعدة التالية';

  @override
  String get finishLesson => 'إنهاء الدرس';

  @override
  String get mustEnglish => 'Must English';

  @override
  String get grammarCoreEssential => 'قواعد أساسية • أساسي';

  @override
  String get grammarTipTitle => 'نصيحة قواعد';

  @override
  String get grammarTipDefaultBody =>
      'هل تعلم؟ الأفعال الماضية البسيطة المنتظمة دائمًا تنتهي بـ \'-ed\'، لكن انتبه للأفعال الشاذة مثل \'go\' → \'went\'!';

  @override
  String get noModulesYet => 'لا توجد وحدات بعد';

  @override
  String get noQuestionsYet => 'لا توجد أسئلة لهذا الدرس بعد.';

  @override
  String ruleNumber(int id) {
    return 'القاعدة $id';
  }

  @override
  String questionLine(int index, String question) {
    return 'س$index. $question';
  }

  @override
  String moduleNOfM(int n, int m) {
    return 'الوحدة $n من $m';
  }

  @override
  String focusOnWhileReading(String tokens) {
    return 'ركز على $tokens عند القراءة بصوت عالٍ.';
  }

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس',
      many: '$count درسًا',
      few: '$count دروس',
      two: 'درسان',
      one: 'درس واحد',
      zero: 'لا دروس',
    );
    return '$_temp0';
  }

  @override
  String rulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قاعدة',
      many: '$count قاعدة',
      few: '$count قواعد',
      two: 'قاعدتان',
      one: 'قاعدة واحدة',
      zero: 'لا قواعد',
    );
    return '$_temp0';
  }

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get learnTab => 'تعلّم';

  @override
  String get talkTab => 'تحدّث';

  @override
  String get wordsTab => 'كلمات';

  @override
  String get profileTab => 'الملف';

  @override
  String get appBrandName => 'بيان';

  @override
  String goodMorning(String name) {
    return 'صباح الخير يا $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'نهارك سعيد يا $name';
  }

  @override
  String goodEvening(String name) {
    return 'مساء الخير يا $name';
  }

  @override
  String streakMessage(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'أنت في سلسلة تعلّم لمدة $days يوم!',
      many: 'أنت في سلسلة تعلّم لمدة $days يومًا!',
      few: 'أنت في سلسلة تعلّم لمدة $days أيام!',
      two: 'أنت في سلسلة تعلّم لمدة يومين!',
      one: 'أنت في سلسلة تعلّم لمدة يوم واحد!',
      zero: 'ابدأ سلسلتك اليوم!',
    );
    return '$_temp0';
  }

  @override
  String get continueLesson => 'تابع الدرس';

  @override
  String get progress => 'التقدّم';

  @override
  String get learningModules => 'وحدات التعلّم';

  @override
  String get weeklyOverview => 'نظرة أسبوعية';

  @override
  String weeklyChange(int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      percent,
      locale: localeName,
      other: '+$percent٪',
      zero: '0٪',
    );
    return '$_temp0';
  }

  @override
  String get vocabularyLabel => 'المفردات';

  @override
  String get grammarLabel => 'القواعد';

  @override
  String get sentencesLabel => 'الجمل';

  @override
  String get phoneticsLabel => 'علم الصوتيات';

  @override
  String get conversationsLabel => 'المحادثات';

  @override
  String get wordListLabel => 'قائمة الكلمات';

  @override
  String vocabularyTagline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كلمة',
      many: '$count كلمة',
      few: '$count كلمات',
      two: 'كلمتان',
      one: 'كلمة واحدة',
      zero: 'لا كلمات بعد',
    );
    return '$_temp0';
  }

  @override
  String get grammarTagline => 'أزمنة الأفعال';

  @override
  String get sentencesTagline => 'عبارات يومية';

  @override
  String get phoneticsTagline => 'التنغيم';

  @override
  String get weeklyStatWords => 'كلمات';

  @override
  String get weeklyStatLessons => 'دروس';

  @override
  String get weeklyStatHours => 'ساعات';

  @override
  String get lessonStatusLocked => 'مقفل';

  @override
  String get lessonStatusCompleted => 'مكتمل';

  @override
  String get lessonStatusStart => 'ابدأ';

  @override
  String get markAsCompleted => 'تعليم كمكتمل';

  @override
  String get allLessonsCompleteTitle => 'اكتملت كل الدروس';

  @override
  String get allLessonsCompleteBody =>
      'أحسنت! لقد أنهيت كل دروس القواعد المتاحة.';

  @override
  String phoneticsLevelPill(int id, String name) {
    return 'المستوى $id: $name';
  }

  @override
  String phoneticsTopicsCompleted(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'موضوع',
      many: 'موضوعًا',
      few: 'مواضيع',
      two: 'موضوعان',
      one: 'موضوع واحد',
      zero: 'موضوع',
    );
    return '$completed من $total $_temp0 مكتمل';
  }

  @override
  String get phoneticsCurrentMastery => 'الإتقان الحالي';

  @override
  String phoneticsCurrentTopicCount(String title, int index, int total) {
    return '$title ($index/$total)';
  }

  @override
  String get settingsVoiceAccent => 'اللهجة الصوتية';

  @override
  String get settingsVoiceGender => 'نوع الصوت';

  @override
  String get settingsLevel => 'المستوى';

  @override
  String get settingsAppLanguage => 'لغة التطبيق';

  @override
  String get settingsRestartTitle => 'إعادة التشغيل مطلوبة';

  @override
  String get settingsRestartBody =>
      'تغيير المستوى يعيد تحميل المحتوى من جديد. سيُعاد تشغيل التطبيق الآن.';

  @override
  String get settingsRestartConfirm => 'إعادة التشغيل';

  @override
  String get voiceAccentUs => 'إنجليزية أمريكية';

  @override
  String get voiceAccentUk => 'إنجليزية بريطانية';

  @override
  String get voiceGenderMale => 'ذكر';

  @override
  String get voiceGenderFemale => 'أنثى';

  @override
  String get cefrLevelDescriptionA1 => 'مبتدئ';

  @override
  String get cefrLevelDescriptionA2 => 'ابتدائي';

  @override
  String get cefrLevelDescriptionB1 => 'متوسط';

  @override
  String get cefrLevelDescriptionB2 => 'فوق المتوسط';

  @override
  String get cefrLevelDescriptionC1 => 'متقدّم';

  @override
  String get cefrLevelDescriptionC2 => 'متمكّن';

  @override
  String cefrLevelOptionLabel(String code, String description) {
    return '$code — $description';
  }
}
