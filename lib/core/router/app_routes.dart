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
  static const vocabularySubtopics        = '/vocabulary/subtopics';
  static const vocabularyList             = '/vocabulary/list';
  static const wordDetail                 = '/vocabulary/word';

  static const sentences                  = '/sentences';
  static const sentencesSubtopics         = '/sentences/subtopics';
  static const sentencePractice           = '/sentences/practice';

  static const conversations              = '/conversations';
  static const conversationLessons        = '/conversations/lessons';
  static const conversationPlayer         = '/conversations/player';

  static const achievements               = '/profile/achievements';
}
