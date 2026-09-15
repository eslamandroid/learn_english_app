import '../entities/phonetic_category.dart';
import '../entities/phonetic_section.dart';
import '../entities/phonetic_topic.dart';

abstract class PhoneticRepository {
  Future<List<PhoneticCategory>> getCategories();

  Future<List<PhoneticTopic>> getTopicsByCategory(int categoryId);

  Future<List<PhoneticTopic>> getTopicsForLevel(int levelId);

  Future<PhoneticTopic?> getTopicById(int id);

  Future<List<PhoneticSection>> getSections({
    required int topicId,
    required String accent,
  });

  /// `categoryId → ordered list of topic ids in that category`. Single cheap
  /// SQL aggregate — used to compute lock/unlock + per-category progress %.
  Future<Map<int, List<int>>> getTopicIdsByCategory();
}
