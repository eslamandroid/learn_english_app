abstract class AppConstants {
  // ─── App ───
  static const appName = 'Bayan English';
  static const defaultLocale = 'en';
  static const supportedLocales = ['en', 'ar'];

  // ─── Database ───
  static const dbFileName = 'learn_db.db';
  static const dbAssetPath = 'assets/databases/learn_db.db';

  // ─── Audio voices ───
  static const voiceUsMale   = 'us_male';
  static const voiceUsFemale = 'us_female';
  static const voiceUkMale   = 'uk_male';
  static const voiceUkFemale = 'uk_female';
  static const defaultVoice  = voiceUsFemale;

  // ─── CEFR Levels ───
  static const levelA1 = 1;
  static const levelA2 = 2;
  static const levelB1 = 3;
  static const levelB2 = 4;
  static const levelC1 = 5;
  static const levelC2 = 6;

  // ─── SharedPreferences keys ───
  static const prefOnboardingComplete  = 'onboarding_complete';
  static const prefSelectedLevel       = 'selected_level';
  static const prefSelectedVoice       = 'selected_voice';
  static const prefLanguageCode        = 'language_code';
  static const prefStreakCount         = 'streak_count';
  static const prefLastOpenedDate      = 'last_opened_date';
  static const prefShowArabicContent   = 'show_arabic_content';
  static const prefContentEmphasisLang = 'content_emphasis_lang';

  // ─── Spacing (matches Tailwind spec in design doc) ───
  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 24.0;
  static const spacingXl = 32.0;
  static const containerPadding = 20.0;
  static const cardGap = 16.0;

  // ─── Radii ───
  static const radiusSm = 4.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
  static const radiusFull = 9999.0;
}
