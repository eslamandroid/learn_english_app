abstract class UserDbSchema {
  // ─── Table names ─────────────────────────────────────────────────────────
  static const tUserSettings = 'user_settings';
  static const tUserProgress = 'user_progress';
  static const tSrsCard = 'srs_card';
  static const tDailyActivity = 'daily_activity';
  static const tShadowingAttempt = 'shadowing_attempt';
  static const tMyWordList = 'my_word_list';
  static const tSentenceLessonProgress = 'sentence_lesson_progress';

  // ─── source_table values (must match content.db table names exactly) ─────
  static const srcGrammarSubTopics = 'grammar_sub_topics';
  static const srcPhoneticTopic = 'phoneticTopic';
  static const srcVocaSubTopic = 'vocaSubTopic';
  static const srcVocabulary = 'vocabulary';
  static const srcWordList = 'word_list';
  static const srcSentencesSubTopic = 'sentencesSubTopic';
  static const srcSentencesContent = 'sentencesContent';
  static const srcConversationLesson = 'conversation_lesson';
  static const srcConversationSentence = 'conversation_sentence';

  // ─── Progress status values ───────────────────────────────────────────────
  static const statusNone = 0;
  static const statusInProgress = 1;
  static const statusCompleted = 2;

  // ─── user_settings keys ──────────────────────────────────────────────────
  static const keyMigrationDone = 'migration_done';
  static const keyLevel = 'level';
  static const keyVoiceKey = 'voice_key';
  static const keyExplanationLocale = 'explanation_locale';

  // ─── v1 CREATE statements ─────────────────────────────────────────────────
  static const createUserSettings = '''
    CREATE TABLE $tUserSettings (
      key   TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const createUserProgress = '''
    CREATE TABLE $tUserProgress (
      source_table TEXT    NOT NULL,
      source_id    INTEGER NOT NULL,
      status       INTEGER NOT NULL DEFAULT 0,
      score        INTEGER,
      attempts     INTEGER NOT NULL DEFAULT 0,
      started_at   INTEGER,
      completed_at INTEGER,
      PRIMARY KEY (source_table, source_id)
    )
  ''';

  static const createUserProgressIndex = '''
    CREATE INDEX idx_progress_status ON $tUserProgress(source_table, status)
  ''';

  static const createSrsCard = '''
    CREATE TABLE $tSrsCard (
      source_table  TEXT    NOT NULL,
      source_id     INTEGER NOT NULL,
      ease          REAL    NOT NULL DEFAULT 2.5,
      interval_days INTEGER NOT NULL DEFAULT 0,
      due_at        INTEGER NOT NULL,
      reps          INTEGER NOT NULL DEFAULT 0,
      lapses        INTEGER NOT NULL DEFAULT 0,
      last_review   INTEGER,
      PRIMARY KEY (source_table, source_id)
    )
  ''';

  static const createSrsCardIndex = '''
    CREATE INDEX idx_srs_due ON $tSrsCard(due_at)
  ''';

  static const createDailyActivity = '''
    CREATE TABLE $tDailyActivity (
      date             TEXT PRIMARY KEY,
      minutes          INTEGER NOT NULL DEFAULT 0,
      items_done       INTEGER NOT NULL DEFAULT 0,
      lesson_completed INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const createShadowingAttempt = '''
    CREATE TABLE $tShadowingAttempt (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      sentence_id   INTEGER NOT NULL,
      recorded_path TEXT,
      similarity    REAL    NOT NULL,
      timing_score  REAL    NOT NULL,
      total         REAL    NOT NULL,
      is_favorite   INTEGER NOT NULL DEFAULT 0,
      created_at    INTEGER NOT NULL
    )
  ''';

  static const createShadowingAttemptIndex = '''
    CREATE INDEX idx_shadow_sentence ON $tShadowingAttempt(sentence_id)
  ''';

  static const createMyWordList = '''
    CREATE TABLE $tMyWordList (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      word         TEXT NOT NULL,
      translation  TEXT,
      note         TEXT,
      source_table TEXT,
      source_id    INTEGER,
      created_at   INTEGER NOT NULL
    )
  ''';

  static const createMyWordListIndex = '''
    CREATE UNIQUE INDEX idx_myword_word ON $tMyWordList(word COLLATE NOCASE)
  ''';

  // ─── v2: per-lesson sentence progress ───────────────────────────────────
  // Drives the lesson sublist "9 / 16" / "Done" visualisation in the topics
  // screen. [lessonId] == subTopicId from content.db. [seen] is the max page
  // index visited; [completedAt] is set when "Mark as complete" is tapped.
  static const createSentenceLessonProgress = '''
    CREATE TABLE $tSentenceLessonProgress (
      lessonId     INTEGER PRIMARY KEY,
      seen         INTEGER NOT NULL DEFAULT 0,
      total        INTEGER NOT NULL DEFAULT 0,
      completedAt  TEXT
    )
  ''';

  static const List<String> v1Statements = [
    createUserSettings,
    createUserProgress,
    createUserProgressIndex,
    createSrsCard,
    createSrsCardIndex,
    createDailyActivity,
    createShadowingAttempt,
    createShadowingAttemptIndex,
    createMyWordList,
    createMyWordListIndex,
  ];

  static const List<String> v2Statements = [
    createSentenceLessonProgress,
  ];
}
