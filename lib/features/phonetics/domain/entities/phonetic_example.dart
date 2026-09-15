import 'package:equatable/equatable.dart';

class PhoneticExample extends Equatable {
  final int id;
  final int sectionId;
  final int sortOrder;
  final String word;
  final String? wordAr;
  final String? phonetic;

  const PhoneticExample({
    required this.id,
    required this.sectionId,
    required this.sortOrder,
    required this.word,
    this.wordAr,
    this.phonetic,
  });

  @override
  List<Object?> get props => [id, sectionId, sortOrder, word, wordAr, phonetic];
}
