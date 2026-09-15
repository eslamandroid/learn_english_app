// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'share_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get unAuthentication => 'Unauthenticated. Please sign in.';

  @override
  String get unAuthorization => 'Unauthorized action.';

  @override
  String get notFoundEntity => 'Entity not found.';

  @override
  String get invalidInput => 'Invalid input.';

  @override
  String get badCertificateException => 'Bad or untrusted certificate.';

  @override
  String get noInternetException => 'No Internet connection.';

  @override
  String get noInternetConnection =>
      'No internet connection. Please check your network and try again.';

  @override
  String get connectionLost => 'Connection Lost';

  @override
  String get canNotConnectToHost => 'Can\'t connect to host.';

  @override
  String get serverUnDefined => 'Unexpected server error.';

  @override
  String get timeoutException => 'Request timed out.';

  @override
  String get cancellationException => 'Operation was cancelled.';

  @override
  String get unknownException => 'Something went wrong. Please try again.';

  @override
  String get tokenExpired => 'Session expired. Please sign in again.';

  @override
  String get parseException => 'Data parse error.';

  @override
  String get retryLabel => 'Retry';

  @override
  String get refreshLabel => 'Refresh';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get yesLabel => 'Yes';

  @override
  String get searchLabel => 'Search';

  @override
  String get continueLabel => 'Continue';

  @override
  String get language => 'Language';

  @override
  String get environmentSwitched =>
      'Environment switched successfully! Restart the app to apply changes.';

  @override
  String get patchAvailableTitle => 'New Update Available';

  @override
  String get patchAvailableMessage =>
      'A new patch is available for the app. Would you like to install it now?';

  @override
  String get patchInstallNow => 'Install Now';

  @override
  String get patchLater => 'Later';

  @override
  String get patchDownloading => 'Downloading...';

  @override
  String get patchRestarting => 'Restarting...';

  @override
  String get patchDownloadedSuccess => 'Update downloaded successfully';

  @override
  String get patchCloseAndReopen =>
      'Close and reopen the app to apply changes.';

  @override
  String get showArabicTranslations => 'Show Arabic Translations';

  @override
  String get showArabicTranslationsHint =>
      'Display Arabic alongside English in lessons, examples, and word lists.';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية (Arabic)';

  @override
  String get grammar => 'Grammar';

  @override
  String get lesson => 'Lesson';

  @override
  String get practice => 'Practice';

  @override
  String get examplesInAction => 'Examples in Action';

  @override
  String get testYourKnowledge => 'Test Your Knowledge';

  @override
  String get chooseCorrectForm => 'Choose the correct form:';

  @override
  String get nextRule => 'Next Rule';

  @override
  String get finishLesson => 'Finish Lesson';

  @override
  String get mustEnglish => 'Must English';

  @override
  String get grammarCoreEssential => 'GRAMMAR CORE • ESSENTIAL';

  @override
  String get grammarTipTitle => 'Grammar Tip';

  @override
  String get grammarTipDefaultBody =>
      'Did you know? Regular past simple verbs always end in \'-ed\', but watch out for irregular verbs like \'go\' → \'went\'!';

  @override
  String get noModulesYet => 'No modules yet';

  @override
  String get noQuestionsYet => 'No questions for this lesson yet.';

  @override
  String ruleNumber(int id) {
    return 'Rule $id';
  }

  @override
  String questionLine(int index, String question) {
    return 'Q$index. $question';
  }

  @override
  String moduleNOfM(int n, int m) {
    return 'Module $n of $m';
  }

  @override
  String focusOnWhileReading(String tokens) {
    return 'Focus on $tokens while reading aloud.';
  }

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String rulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules',
      one: '1 rule',
      zero: 'No rules',
    );
    return '$_temp0';
  }

  @override
  String get homeTab => 'Home';

  @override
  String get learnTab => 'Learn';

  @override
  String get talkTab => 'Talk';

  @override
  String get wordsTab => 'Words';

  @override
  String get profileTab => 'Profile';

  @override
  String get appBrandName => 'Bayan';

  @override
  String goodMorning(String name) {
    return 'Good Morning, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good Afternoon, $name';
  }

  @override
  String goodEvening(String name) {
    return 'Good Evening, $name';
  }

  @override
  String streakMessage(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'You\'re on a $days-day learning streak!',
      one: 'You\'re on a 1-day learning streak!',
      zero: 'Start your streak today!',
    );
    return '$_temp0';
  }

  @override
  String get continueLesson => 'Continue Lesson';

  @override
  String get progress => 'Progress';

  @override
  String get learningModules => 'LEARNING MODULES';

  @override
  String get weeklyOverview => 'WEEKLY OVERVIEW';

  @override
  String weeklyChange(int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      percent,
      locale: localeName,
      other: '+$percent%',
      zero: '0%',
    );
    return '$_temp0';
  }

  @override
  String get vocabularyLabel => 'Vocabulary';

  @override
  String get grammarLabel => 'Grammar';

  @override
  String get sentencesLabel => 'Sentences';

  @override
  String get phoneticsLabel => 'Phonetics';

  @override
  String get conversationsLabel => 'Conversations';

  @override
  String get wordListLabel => 'Word List';

  @override
  String vocabularyTagline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Words',
      one: '1 Word',
      zero: 'No words yet',
    );
    return '$_temp0';
  }

  @override
  String get grammarTagline => 'Verb Tenses';

  @override
  String get sentencesTagline => 'Daily Phrasings';

  @override
  String get phoneticsTagline => 'Intonation';

  @override
  String get weeklyStatWords => 'Words';

  @override
  String get weeklyStatLessons => 'Lessons';

  @override
  String get weeklyStatHours => 'Hours';

  @override
  String get lessonStatusLocked => 'Locked';

  @override
  String get lessonStatusCompleted => 'Completed';

  @override
  String get lessonStatusStart => 'Start';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get allLessonsCompleteTitle => 'All lessons completed';

  @override
  String get allLessonsCompleteBody =>
      'Great work! You\'ve finished every grammar lesson available.';

  @override
  String phoneticsLevelPill(int id, String name) {
    return 'LEVEL $id: $name';
  }

  @override
  String phoneticsTopicsCompleted(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'topics',
      one: 'topic',
    );
    return '$completed of $total $_temp0 completed';
  }

  @override
  String get phoneticsCurrentMastery => 'CURRENT MASTERY';

  @override
  String phoneticsCurrentTopicCount(String title, int index, int total) {
    return '$title ($index/$total)';
  }

  @override
  String get settingsVoiceAccent => 'Voice Accent';

  @override
  String get settingsVoiceGender => 'Voice Gender';

  @override
  String get settingsLevel => 'Difficulty Level';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get settingsRestartTitle => 'Restart required';

  @override
  String get settingsRestartBody =>
      'Switching level reloads content from scratch. The app will restart now.';

  @override
  String get settingsRestartConfirm => 'Restart';

  @override
  String get voiceAccentUs => 'US English';

  @override
  String get voiceAccentUk => 'UK English';

  @override
  String get voiceGenderMale => 'Male';

  @override
  String get voiceGenderFemale => 'Female';

  @override
  String get cefrLevelDescriptionA1 => 'Beginner';

  @override
  String get cefrLevelDescriptionA2 => 'Elementary';

  @override
  String get cefrLevelDescriptionB1 => 'Intermediate';

  @override
  String get cefrLevelDescriptionB2 => 'Upper-Intermediate';

  @override
  String get cefrLevelDescriptionC1 => 'Advanced';

  @override
  String get cefrLevelDescriptionC2 => 'Proficient';

  @override
  String cefrLevelOptionLabel(String code, String description) {
    return '$code — $description';
  }
}
