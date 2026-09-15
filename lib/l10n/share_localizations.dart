import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'share_localizations_ar.dart';
import 'share_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/share_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @unAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Unauthenticated. Please sign in.'**
  String get unAuthentication;

  /// No description provided for @unAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized action.'**
  String get unAuthorization;

  /// No description provided for @notFoundEntity.
  ///
  /// In en, this message translates to:
  /// **'Entity not found.'**
  String get notFoundEntity;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input.'**
  String get invalidInput;

  /// No description provided for @badCertificateException.
  ///
  /// In en, this message translates to:
  /// **'Bad or untrusted certificate.'**
  String get badCertificateException;

  /// No description provided for @noInternetException.
  ///
  /// In en, this message translates to:
  /// **'No Internet connection.'**
  String get noInternetException;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get noInternetConnection;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get connectionLost;

  /// No description provided for @canNotConnectToHost.
  ///
  /// In en, this message translates to:
  /// **'Can\'t connect to host.'**
  String get canNotConnectToHost;

  /// No description provided for @serverUnDefined.
  ///
  /// In en, this message translates to:
  /// **'Unexpected server error.'**
  String get serverUnDefined;

  /// No description provided for @timeoutException.
  ///
  /// In en, this message translates to:
  /// **'Request timed out.'**
  String get timeoutException;

  /// No description provided for @cancellationException.
  ///
  /// In en, this message translates to:
  /// **'Operation was cancelled.'**
  String get cancellationException;

  /// No description provided for @unknownException.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownException;

  /// No description provided for @tokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get tokenExpired;

  /// No description provided for @parseException.
  ///
  /// In en, this message translates to:
  /// **'Data parse error.'**
  String get parseException;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @refreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshLabel;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @environmentSwitched.
  ///
  /// In en, this message translates to:
  /// **'Environment switched successfully! Restart the app to apply changes.'**
  String get environmentSwitched;

  /// No description provided for @patchAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New Update Available'**
  String get patchAvailableTitle;

  /// No description provided for @patchAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new patch is available for the app. Would you like to install it now?'**
  String get patchAvailableMessage;

  /// No description provided for @patchInstallNow.
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get patchInstallNow;

  /// No description provided for @patchLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get patchLater;

  /// No description provided for @patchDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get patchDownloading;

  /// No description provided for @patchRestarting.
  ///
  /// In en, this message translates to:
  /// **'Restarting...'**
  String get patchRestarting;

  /// No description provided for @patchDownloadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update downloaded successfully'**
  String get patchDownloadedSuccess;

  /// No description provided for @patchCloseAndReopen.
  ///
  /// In en, this message translates to:
  /// **'Close and reopen the app to apply changes.'**
  String get patchCloseAndReopen;

  /// No description provided for @showArabicTranslations.
  ///
  /// In en, this message translates to:
  /// **'Show Arabic Translations'**
  String get showArabicTranslations;

  /// No description provided for @showArabicTranslationsHint.
  ///
  /// In en, this message translates to:
  /// **'Display Arabic alongside English in lessons, examples, and word lists.'**
  String get showArabicTranslationsHint;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic)'**
  String get arabic;

  /// No description provided for @grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammar;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @examplesInAction.
  ///
  /// In en, this message translates to:
  /// **'Examples in Action'**
  String get examplesInAction;

  /// No description provided for @testYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test Your Knowledge'**
  String get testYourKnowledge;

  /// No description provided for @chooseCorrectForm.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct form:'**
  String get chooseCorrectForm;

  /// No description provided for @nextRule.
  ///
  /// In en, this message translates to:
  /// **'Next Rule'**
  String get nextRule;

  /// No description provided for @finishLesson.
  ///
  /// In en, this message translates to:
  /// **'Finish Lesson'**
  String get finishLesson;

  /// No description provided for @mustEnglish.
  ///
  /// In en, this message translates to:
  /// **'Must English'**
  String get mustEnglish;

  /// No description provided for @grammarCoreEssential.
  ///
  /// In en, this message translates to:
  /// **'GRAMMAR CORE • ESSENTIAL'**
  String get grammarCoreEssential;

  /// No description provided for @grammarTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Tip'**
  String get grammarTipTitle;

  /// No description provided for @grammarTipDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Did you know? Regular past simple verbs always end in \'-ed\', but watch out for irregular verbs like \'go\' → \'went\'!'**
  String get grammarTipDefaultBody;

  /// No description provided for @noModulesYet.
  ///
  /// In en, this message translates to:
  /// **'No modules yet'**
  String get noModulesYet;

  /// No description provided for @noQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions for this lesson yet.'**
  String get noQuestionsYet;

  /// No description provided for @ruleNumber.
  ///
  /// In en, this message translates to:
  /// **'Rule {id}'**
  String ruleNumber(int id);

  /// No description provided for @questionLine.
  ///
  /// In en, this message translates to:
  /// **'Q{index}. {question}'**
  String questionLine(int index, String question);

  /// No description provided for @moduleNOfM.
  ///
  /// In en, this message translates to:
  /// **'Module {n} of {m}'**
  String moduleNOfM(int n, int m);

  /// No description provided for @focusOnWhileReading.
  ///
  /// In en, this message translates to:
  /// **'Focus on {tokens} while reading aloud.'**
  String focusOnWhileReading(String tokens);

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lessons} =1{1 lesson} other{{count} lessons}}'**
  String lessonsCount(int count);

  /// No description provided for @rulesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rules} =1{1 rule} other{{count} rules}}'**
  String rulesCount(int count);

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @learnTab.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTab;

  /// No description provided for @talkTab.
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get talkTab;

  /// No description provided for @wordsTab.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @appBrandName.
  ///
  /// In en, this message translates to:
  /// **'Bayan'**
  String get appBrandName;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning, {name}'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon, {name}'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening, {name}'**
  String goodEvening(String name);

  /// No description provided for @streakMessage.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Start your streak today!} =1{You\'re on a 1-day learning streak!} other{You\'re on a {days}-day learning streak!}}'**
  String streakMessage(int days);

  /// No description provided for @continueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue Lesson'**
  String get continueLesson;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @learningModules.
  ///
  /// In en, this message translates to:
  /// **'LEARNING MODULES'**
  String get learningModules;

  /// No description provided for @weeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY OVERVIEW'**
  String get weeklyOverview;

  /// No description provided for @weeklyChange.
  ///
  /// In en, this message translates to:
  /// **'{percent, plural, =0{0%} other{+{percent}%}}'**
  String weeklyChange(int percent);

  /// No description provided for @vocabularyLabel.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabularyLabel;

  /// No description provided for @grammarLabel.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammarLabel;

  /// No description provided for @sentencesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sentences'**
  String get sentencesLabel;

  /// No description provided for @phoneticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Phonetics'**
  String get phoneticsLabel;

  /// No description provided for @conversationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationsLabel;

  /// No description provided for @wordListLabel.
  ///
  /// In en, this message translates to:
  /// **'Word List'**
  String get wordListLabel;

  /// No description provided for @vocabularyTagline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words yet} =1{1 Word} other{{count} Words}}'**
  String vocabularyTagline(int count);

  /// No description provided for @grammarTagline.
  ///
  /// In en, this message translates to:
  /// **'Verb Tenses'**
  String get grammarTagline;

  /// No description provided for @sentencesTagline.
  ///
  /// In en, this message translates to:
  /// **'Daily Phrasings'**
  String get sentencesTagline;

  /// No description provided for @phoneticsTagline.
  ///
  /// In en, this message translates to:
  /// **'Intonation'**
  String get phoneticsTagline;

  /// No description provided for @weeklyStatWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get weeklyStatWords;

  /// No description provided for @weeklyStatLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get weeklyStatLessons;

  /// No description provided for @weeklyStatHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get weeklyStatHours;

  /// No description provided for @lessonStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lessonStatusLocked;

  /// No description provided for @lessonStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lessonStatusCompleted;

  /// No description provided for @lessonStatusStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get lessonStatusStart;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markAsCompleted;

  /// No description provided for @allLessonsCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'All lessons completed'**
  String get allLessonsCompleteTitle;

  /// No description provided for @allLessonsCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Great work! You\'ve finished every grammar lesson available.'**
  String get allLessonsCompleteBody;

  /// No description provided for @phoneticsLevelPill.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {id}: {name}'**
  String phoneticsLevelPill(int id, String name);

  /// No description provided for @phoneticsTopicsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} {total, plural, =1{topic} other{topics}} completed'**
  String phoneticsTopicsCompleted(int completed, int total);

  /// No description provided for @phoneticsCurrentMastery.
  ///
  /// In en, this message translates to:
  /// **'CURRENT MASTERY'**
  String get phoneticsCurrentMastery;

  /// No description provided for @phoneticsCurrentTopicCount.
  ///
  /// In en, this message translates to:
  /// **'{title} ({index}/{total})'**
  String phoneticsCurrentTopicCount(String title, int index, int total);

  /// No description provided for @settingsVoiceAccent.
  ///
  /// In en, this message translates to:
  /// **'Voice Accent'**
  String get settingsVoiceAccent;

  /// No description provided for @settingsVoiceGender.
  ///
  /// In en, this message translates to:
  /// **'Voice Gender'**
  String get settingsVoiceGender;

  /// No description provided for @settingsLevel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get settingsLevel;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsAppLanguage;

  /// No description provided for @settingsRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart required'**
  String get settingsRestartTitle;

  /// No description provided for @settingsRestartBody.
  ///
  /// In en, this message translates to:
  /// **'Switching level reloads content from scratch. The app will restart now.'**
  String get settingsRestartBody;

  /// No description provided for @settingsRestartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get settingsRestartConfirm;

  /// No description provided for @voiceAccentUs.
  ///
  /// In en, this message translates to:
  /// **'US English'**
  String get voiceAccentUs;

  /// No description provided for @voiceAccentUk.
  ///
  /// In en, this message translates to:
  /// **'UK English'**
  String get voiceAccentUk;

  /// No description provided for @voiceGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get voiceGenderMale;

  /// No description provided for @voiceGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get voiceGenderFemale;

  /// No description provided for @cefrLevelDescriptionA1.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get cefrLevelDescriptionA1;

  /// No description provided for @cefrLevelDescriptionA2.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get cefrLevelDescriptionA2;

  /// No description provided for @cefrLevelDescriptionB1.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get cefrLevelDescriptionB1;

  /// No description provided for @cefrLevelDescriptionB2.
  ///
  /// In en, this message translates to:
  /// **'Upper-Intermediate'**
  String get cefrLevelDescriptionB2;

  /// No description provided for @cefrLevelDescriptionC1.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get cefrLevelDescriptionC1;

  /// No description provided for @cefrLevelDescriptionC2.
  ///
  /// In en, this message translates to:
  /// **'Proficient'**
  String get cefrLevelDescriptionC2;

  /// No description provided for @cefrLevelOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'{code} — {description}'**
  String cefrLevelOptionLabel(String code, String description);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
