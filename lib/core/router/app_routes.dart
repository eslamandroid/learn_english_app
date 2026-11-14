abstract class AppRoutes {
  // ─── Bootstrap ───
  static const splash      = '/';
  static const onboarding  = '/onboarding';

  // ─── Main shell ───
  static const dashboard   = '/dashboard';
  static const wordList    = '/word-list';
  static const profile     = '/profile';
  static const settings    = '/settings';

  // ─── Modules ───
  static const phonetics                  = '/phonetics';
  // Parametric — built with .toPath():
  // /phonetics/:catId               → topics
  // /phonetics/:catId/:topicId      → detail
  static String phoneticsTopics(int catId) => '/phonetics/$catId';
  static String phoneticsDetail(int catId, int topicId) =>
      '/phonetics/$catId/$topicId';

  static const grammar = '/grammar';
  // Parametric:
  // /grammar/:topicId/:subtopicId        → lesson
  // /grammar/:topicId/:subtopicId/test   → quiz
  static String grammarLesson(int topicId, int subtopicId) =>
      '/grammar/$topicId/$subtopicId';
  static String grammarTest(int topicId, int subtopicId) =>
      '/grammar/$topicId/$subtopicId/test';

  static const vocabulary                 = '/vocabulary';
  // Parametric:
  // /vocabulary/:topicId               → subtopics
  // /vocabulary/:topicId/:subtopicId   → word list
  static String vocabularySubtopics(int topicId) => '/vocabulary/$topicId';
  static String vocabularyWords(int topicId, int subtopicId) =>
      '/vocabulary/$topicId/$subtopicId';

  static const sentences = '/sentences';
  // Parametric:
  // /sentences/:topicId/:subtopicId   → lesson (topics screen jumps here
  // directly from the expanded topic sublist — no separate subtopics screen).
  static String sentenceContent(int topicId, int subtopicId) =>
      '/sentences/$topicId/$subtopicId';

  static const conversations              = '/conversations';
  // Parametric:
  // /conversations/:catId                   → lessons
  // /conversations/:catId/:lessonId         → player (Chat or Pager, chosen
  // by ConversationViewModePreference).
  static String conversationLessons(int catId) => '/conversations/$catId';
  static String conversationPlayer(int catId, int lessonId) =>
      '/conversations/$catId/$lessonId';
  // Role-play layered on top of the same lesson route tree. The result
  // screen is a transient full-screen push, not a GoRoute (TASK 13 §1).
  static String rolePlaySelect(int catId, int lessonId) =>
      '/conversations/$catId/$lessonId/roleplay';
  static String rolePlayPlayer(int catId, int lessonId, String character) =>
      '/conversations/$catId/$lessonId/roleplay/${Uri.encodeComponent(character)}';

  static const achievements               = '/profile/achievements';
}
