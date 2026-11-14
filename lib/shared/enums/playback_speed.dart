/// Two-way playback speed toggle used across features that offer a
/// "listen slowly to hear each phoneme" affordance.
///
/// [rate] is the audioplayers scale — 1.0 is natural, values < 1 slow the
/// clip down without changing pitch. Passed to [SoundPlayer.play] and
/// [SoundPlayer.speak] to control both pre-recorded audio and device TTS.
enum PlaybackSpeed {
  slow(0.65, 'Slow'),
  normal(1.0, 'Normal');

  final double rate;
  final String label;
  const PlaybackSpeed(this.rate, this.label);
}
