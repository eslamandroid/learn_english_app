sealed class LanguageEvent {
  const LanguageEvent();
}

class LoadCurrentLanguageEvent extends LanguageEvent {
  const LoadCurrentLanguageEvent();
}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;
  final String screenId;

  const ChangeLanguageEvent({
    required this.languageCode,
    required this.screenId,
  });
}

class ObserveLanguageChangesEvent extends LanguageEvent {
  const ObserveLanguageChangesEvent();
}

