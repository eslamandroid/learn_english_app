import '../utils/voice_preferences.dart';

abstract class CdnConfig {
  static const baseUrl = 'https://dwgyo0auw588p.cloudfront.net';

  // ══════════════════════════════════════════════
  //  AUDIO URLs (59,744 files)
  //  Pattern: {baseUrl}/audio/{voice}/{source}/{id}.mp3
  //  Voices: us_male, us_female, uk_male, uk_female
  //
  //  Pass [currentVoice] (reads the user's settings selection) instead of a
  //  hard-coded string so accent + gender stay in sync with Settings.
  // ══════════════════════════════════════════════

  /// Reads the user's settings selection (`us_male`, `us_female`, `uk_male`,
  /// `uk_female`). Use this when calling the per-source helpers below.
  static String get currentVoice => AppVoicePreferences.instance.voiceKey;

  // Vocabulary audio (2,514 words × 4 voices = 10,056)
  // DB: audio_files WHERE source_table = 'vocabulary'
  // Example: https://YOUR_DOMAIN.cloudfront.net/audio/us_male/vocabulary/1.mp3
  static String vocabularyAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/vocabulary/$id.mp3';

  // Word List audio (5,586 words × 4 voices = 22,344)
  // DB: audio_files WHERE source_table = 'word_list'
  // Example: https://YOUR_DOMAIN.cloudfront.net/audio/us_female/word_list/2.mp3
  static String wordListAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/word_list/$id.mp3';

  // Sentences audio (2,089 sentences × 4 voices = 8,356)
  // DB: audio_files WHERE source_table = 'sentencesContent'
  // Example: https://YOUR_DOMAIN.cloudfront.net/audio/uk_male/sentences/1.mp3
  static String sentenceAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/sentences/$id.mp3';

  // Phonetic Example audio (1,815 examples × 4 voices = 7,260)
  // DB: audio_files WHERE source_table = 'phonetic_example'
  // Example: https://YOUR_DOMAIN.cloudfront.net/audio/us_male/phonetic_example/752.mp3
  static String phoneticExampleAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/phonetic_example/$id.mp3';

  // Conversation audio (2,932 sentences × 4 voices = 11,728)
  // DB: audio_files WHERE source_table = 'conversation_sentence'
  // Example: https://YOUR_DOMAIN.cloudfront.net/audio/uk_female/conversation/1.mp3
  static String conversationAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/conversation/$id.mp3';

  // ══════════════════════════════════════════════
  //  IMAGE URLs
  // ══════════════════════════════════════════════

  // Vocabulary word images (~2,635 files, .webp)
  // DB: vocabulary.imageResourceId → e.g. "boy"
  // Example: https://YOUR_DOMAIN.cloudfront.net/word_img/boy.webp
  static String wordImage(String imageResourceId) =>
      '$baseUrl/word_img/$imageResourceId.webp';

  // Grammar diagram images (~231 files, .webp)
  // DB: grammar_rule.image → e.g. "a01_01_01"
  // Example: https://YOUR_DOMAIN.cloudfront.net/grammarImg/a01_01_01.webp
  static String grammarImage(String imageName) =>
      '$baseUrl/grammarImg/$imageName.webp';

  // Phonetic Alphabet images (26 files, .png)
  // DB: phoneticTopic.icon → e.g. "the_letter_a"
  // Example: https://YOUR_DOMAIN.cloudfront.net/phonetic/alphabet/the_letter_a.png
  static String phoneticAlphabetImage(String icon) =>
      '$baseUrl/phonetic/alphabet/$icon.png';

  // Phonetic Consonants/Vowels images (78 files, .png)
  // e.g. "consonants_b", "consonants_ch"
  // Example: https://YOUR_DOMAIN.cloudfront.net/phonetic/img/consonants_b.png
  static String phoneticSoundImage(String name) =>
      '$baseUrl/phonetic/img/$name.png';

  // Phonetic Multigraph images (62 files, .png)
  // e.g. "multigraphs_ch-min"
  // Example: https://YOUR_DOMAIN.cloudfront.net/phonetic/multigraphs/multigraphs_ch-min.png
  static String phoneticMultigraphImage(String name) =>
      '$baseUrl/phonetic/multigraphs/$name.png';

  // ══════════════════════════════════════════════
  //  GENERIC HELPER (from audio_files.file_path)
  // ══════════════════════════════════════════════

  // Use directly with audio_files.file_path column
  // DB value: "us_male/vocabulary/1.mp3"
  // Result: https://YOUR_DOMAIN.cloudfront.net/audio/us_male/vocabulary/1.mp3
  static String audioFromPath(String filePath) =>
      '$baseUrl/audio/$filePath';
}
