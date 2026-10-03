import 'package:equatable/equatable.dart';

class SentenceTopic extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final int sentenceCount;
  final String? icon;

  const SentenceTopic({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.sentenceCount,
    this.icon,
  });

  @override
  List<Object?> get props => [id, title, titleAr, sentenceCount, icon];
}
