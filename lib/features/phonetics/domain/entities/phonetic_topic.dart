import 'package:equatable/equatable.dart';

class PhoneticTopic extends Equatable {
  final int id;
  final int categoryId;
  final String title;
  final String titleAr;
  final String? phoneTitle;
  final String? word;
  final String? icon;

  /// Bundled phoneme clip name (e.g. `consonants_b`), derived from the topic's
  /// `sound` section. Plays from `assets/sounds/{sound}.m4a`. Null for topics
  /// without a sound (alphabet, multigraphs).
  final String? sound;

  const PhoneticTopic({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.titleAr,
    this.phoneTitle,
    this.word,
    this.icon,
    this.sound,
  });

  @override
  List<Object?> get props =>
      [id, categoryId, title, titleAr, phoneTitle, word, icon, sound];
}
