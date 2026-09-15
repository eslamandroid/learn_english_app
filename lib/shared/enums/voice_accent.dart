enum VoiceAccent {
  usMale('us_male', 'US Male'),
  usFemale('us_female', 'US Female'),
  ukMale('uk_male', 'UK Male'),
  ukFemale('uk_female', 'UK Female');

  final String key;
  final String label;
  const VoiceAccent(this.key, this.label);

  static VoiceAccent fromKey(String? key) =>
      VoiceAccent.values.firstWhere(
        (v) => v.key == key,
        orElse: () => VoiceAccent.usFemale,
      );
}
