import 'package:equatable/equatable.dart';

class VocabularyWord extends Equatable {
  final int id;
  final int subtopicId;

  /// English headword (`vocabulary.name`).
  final String word;

  /// Arabic translation of [word] (`vocabulary.ita`).
  final String wordAr;

  /// English gloss / short definition (`vocabulary.desc`).
  final String description;

  /// CDN key for the illustration — resolve with [CdnConfig.wordImage].
  final String imageResourceId;

  /// Legacy sibling of [imageResourceId] retained by the DB — same value in
  /// practice today. Kept for round-tripping only.
  final String sound;

  /// IPA transcription (`vocabulary.trans`), e.g. `/bɔɪ/`.
  final String phonetic;

  /// Example sentence using the word (`vocabulary.usage`).
  final String usage;

  const VocabularyWord({
    required this.id,
    required this.subtopicId,
    required this.word,
    required this.wordAr,
    required this.description,
    required this.imageResourceId,
    required this.sound,
    required this.phonetic,
    required this.usage,
  });

  @override
  List<Object?> get props => [
        id,
        subtopicId,
        word,
        wordAr,
        description,
        imageResourceId,
        sound,
        phonetic,
        usage,
      ];
}
