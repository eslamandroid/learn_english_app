import 'package:equatable/equatable.dart';

class SentenceSubtopic extends Equatable {
  final int id;
  final int topicId;
  final String title;
  final String titleAr;

  const SentenceSubtopic({
    required this.id,
    required this.topicId,
    required this.title,
    required this.titleAr,
  });

  @override
  List<Object?> get props => [id, topicId, title, titleAr];
}
