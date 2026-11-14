import 'package:equatable/equatable.dart';

/// One `conversation_sentence` row — a single utterance in a lesson's dialog.
///
/// `start`/`end` from the DB are intentionally NOT exposed: they're offsets
/// into a legacy single-file layout that isn't verified on CDN. We play each
/// line via its own clip (`CdnConfig.conversationAudio(id, voice)`), so these
/// offsets have no role in the Listen flow.
class ConversationLine extends Equatable {
  final int id;
  final int lessonId;
  final String character;
  final String english;
  final String phonetic;
  final String arabic;

  const ConversationLine({
    required this.id,
    required this.lessonId,
    required this.character,
    required this.english,
    required this.phonetic,
    required this.arabic,
  });

  @override
  List<Object?> get props =>
      [id, lessonId, character, english, phonetic, arabic];
}
