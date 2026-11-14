/// Payload carried as `GoRouterState.extra` from the topics screen into the
/// lesson screen. Lets us render the hero illustration and the lesson title
/// without a second DB round trip when the user taps a lesson row.
///
/// On deep links / back-forward where no [extra] is set, both fields are
/// null and the UI falls back to generic defaults (ph_other illustration,
/// generic title) without throwing.
class SentenceLessonArgs {
  final String subtopicTitle;
  final String? topicIconKey;
  const SentenceLessonArgs({
    required this.subtopicTitle,
    this.topicIconKey,
  });
}
