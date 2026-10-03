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
  static const conversationLessons        = '/conversations/lessons';
  static const conversationPlayer         = '/conversations/player';

  static const achievements               = '/profile/achievements';
}
