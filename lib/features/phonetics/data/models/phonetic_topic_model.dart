import '../../domain/entities/phonetic_topic.dart';

class PhoneticTopicModel extends PhoneticTopic {
  const PhoneticTopicModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.titleAr,
    super.phoneTitle,
    super.word,
    super.icon,
    super.sound,
  });

  factory PhoneticTopicModel.fromMap(Map<String, Object?> map) {
    final sound = map['sound'] as String?;
    return PhoneticTopicModel(
      id: map['id'] as int,
      categoryId: map['subId'] as int,
      title: map['title'] as String,
      titleAr: map['title_ar'] as String,
      phoneTitle: map['phoneTitle'] as String?,
      word: map['word'] as String?,
      icon: map['icon'] as String?,
      sound: (sound == null || sound.isEmpty) ? null : sound,
    );
  }
}
