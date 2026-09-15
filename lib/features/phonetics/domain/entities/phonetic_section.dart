import 'package:equatable/equatable.dart';

import 'phonetic_example.dart';
import 'phonetic_table_item.dart';

/// One ordered rendering block inside a phonetic topic.
///
/// `type` is one of: `title`, `subTitle`, `table`, `content`, `tip`.
/// `superType` enriches the rendering (e.g. `accent`, `tip`, `warning`,
/// `sectionWithImage`, `sound`).
class PhoneticSection extends Equatable {
  final int id;
  final int topicId;
  final String accent;
  final int sortOrder;
  final String type;
  final String? superType;
  final String? title;
  final String? titleAr;
  final String? body;
  final String? bodyAr;

  /// CDN image name(s) for `sectionWithImage` blocks (e.g. `consonants_b`).
  /// Resolve with `CdnConfig.phoneticSoundImage`.
  final String? image;
  final String? image2;

  /// Bundled sound asset name(s) for `sound` blocks (e.g. `consonants_b`).
  /// Plays from `assets/sounds/{sound}.m4a`.
  final String? sound;
  final String? sound2;

  /// Spelling patterns that produce this sound (e.g. `['b', 'bb']`).
  final List<String> highlight;

  final List<PhoneticTableItem> tableItems;
  final List<PhoneticExample> examples;

  const PhoneticSection({
    required this.id,
    required this.topicId,
    required this.accent,
    required this.sortOrder,
    required this.type,
    this.superType,
    this.title,
    this.titleAr,
    this.body,
    this.bodyAr,
    this.image,
    this.image2,
    this.sound,
    this.sound2,
    this.highlight = const [],
    this.tableItems = const [],
    this.examples = const [],
  });

  @override
  List<Object?> get props => [
        id,
        topicId,
        accent,
        sortOrder,
        type,
        superType,
        title,
        titleAr,
        body,
        bodyAr,
        image,
        image2,
        sound,
        sound2,
        highlight,
        tableItems,
        examples,
      ];
}
