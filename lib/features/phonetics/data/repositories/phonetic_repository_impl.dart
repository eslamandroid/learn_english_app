import 'package:injectable/injectable.dart';

import '../../domain/entities/phonetic_category.dart';
import '../../domain/entities/phonetic_section.dart';
import '../../domain/entities/phonetic_topic.dart';
import '../../domain/repositories/phonetic_repository.dart';
import '../datasources/phonetic_local_datasource.dart';
import '../models/phonetic_section_model.dart';

@LazySingleton(as: PhoneticRepository)
class PhoneticRepositoryImpl implements PhoneticRepository {
  final PhoneticLocalDataSource _localDataSource;

  PhoneticRepositoryImpl(this._localDataSource);

  @override
  Future<List<PhoneticCategory>> getCategories() =>
      _localDataSource.getCategories();

  @override
  Future<List<PhoneticTopic>> getTopicsByCategory(int categoryId) =>
      _localDataSource.getTopicsByCategory(categoryId);

  @override
  Future<List<PhoneticTopic>> getTopicsForLevel(int levelId) =>
      _localDataSource.getTopicsForLevel(levelId);

  @override
  Future<PhoneticTopic?> getTopicById(int id) =>
      _localDataSource.getTopicById(id);

  @override
  Future<List<PhoneticSection>> getSections({
    required int topicId,
    required String accent,
  }) async {
    final sections = await _localDataSource.getSections(topicId, accent);
    return Future.wait(sections.map(_hydrateChildren));
  }

  Future<PhoneticSectionModel> _hydrateChildren(
    PhoneticSectionModel section,
  ) async {
    switch (section.type) {
      case 'table':
        final items = await _localDataSource.getTableItems(section.id);
        return section.copyWithChildren(tableItems: items);
      case 'content':
        final examples = await _localDataSource.getExamples(section.id);
        return section.copyWithChildren(examples: examples);
      default:
        return section;
    }
  }

  @override
  Future<Map<int, List<int>>> getTopicIdsByCategory() =>
      _localDataSource.getTopicIdsByCategory();
}
