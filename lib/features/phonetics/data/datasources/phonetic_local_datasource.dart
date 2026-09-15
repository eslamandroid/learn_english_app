import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../models/phonetic_category_model.dart';
import '../models/phonetic_example_model.dart';
import '../models/phonetic_section_model.dart';
import '../models/phonetic_table_item_model.dart';
import '../models/phonetic_topic_model.dart';

abstract class PhoneticLocalDataSource {
  Future<List<PhoneticCategoryModel>> getCategories();
  Future<List<PhoneticTopicModel>> getTopicsByCategory(int categoryId);
  Future<List<PhoneticTopicModel>> getTopicsForLevel(int levelId);
  Future<PhoneticTopicModel?> getTopicById(int id);
  Future<List<PhoneticSectionModel>> getSections(int topicId, String accent);
  Future<List<PhoneticTableItemModel>> getTableItems(int sectionId);
  Future<List<PhoneticExampleModel>> getExamples(int sectionId);

  /// Cheap aggregate query — returns `categoryId → ordered list of topic ids`
  /// for every category. Used to compute lock/unlock + progress %.
  Future<Map<int, List<int>>> getTopicIdsByCategory();
}

@LazySingleton(as: PhoneticLocalDataSource)
class PhoneticLocalDataSourceImpl implements PhoneticLocalDataSource {
  final Database _database;

  PhoneticLocalDataSourceImpl(this._database);

  @override
  Future<List<PhoneticCategoryModel>> getCategories() async {
    final result = await _database.query('phonetic', orderBy: 'id ASC');
    return result.map(PhoneticCategoryModel.fromMap).toList();
  }

  @override
  Future<List<PhoneticTopicModel>> getTopicsByCategory(int categoryId) async {
    // Pull each topic's phoneme clip (the first `sound` section) in one query
    // so the list can play it inline without an N+1 fetch.
    final result = await _database.rawQuery(
      '''
      SELECT pt.*, (
        SELECT ps.sound FROM phonetic_section ps
        WHERE ps.topic_id = pt.id
          AND ps.sound IS NOT NULL AND ps.sound != ''
        ORDER BY ps.sort_order ASC
        LIMIT 1
      ) AS sound
      FROM phoneticTopic pt
      WHERE pt.subId = ?
      ORDER BY pt.id ASC
      ''',
      [categoryId],
    );
    return result.map(PhoneticTopicModel.fromMap).toList();
  }

  @override
  Future<PhoneticTopicModel?> getTopicById(int id) async {
    final result = await _database.query(
      'phoneticTopic',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return PhoneticTopicModel.fromMap(result.first);
  }

  @override
  Future<List<PhoneticTopicModel>> getTopicsForLevel(int levelId) async {
    final result = await _database.rawQuery(
      '''
      SELECT pt.* FROM phoneticTopic pt
      INNER JOIN level_phonetic_topic lpt ON pt.id = lpt.phoneticId
      WHERE lpt.levelId = ?
      ORDER BY pt.id ASC
      ''',
      [levelId],
    );
    return result.map(PhoneticTopicModel.fromMap).toList();
  }

  @override
  Future<List<PhoneticSectionModel>> getSections(
    int topicId,
    String accent,
  ) async {
    final result = await _database.query(
      'phonetic_section',
      where: 'topic_id = ? AND accent = ?',
      whereArgs: [topicId, accent],
      orderBy: 'sort_order ASC',
    );
    return result.map(PhoneticSectionModel.fromMap).toList();
  }

  @override
  Future<List<PhoneticTableItemModel>> getTableItems(int sectionId) async {
    final result = await _database.query(
      'phonetic_table_item',
      where: 'section_id = ?',
      whereArgs: [sectionId],
      orderBy: 'sort_order ASC',
    );
    return result.map(PhoneticTableItemModel.fromMap).toList();
  }

  @override
  Future<List<PhoneticExampleModel>> getExamples(int sectionId) async {
    final result = await _database.query(
      'phonetic_example',
      where: 'section_id = ?',
      whereArgs: [sectionId],
      orderBy: 'sort_order ASC',
    );
    return result.map(PhoneticExampleModel.fromMap).toList();
  }

  @override
  Future<Map<int, List<int>>> getTopicIdsByCategory() async {
    final rows = await _database.query(
      'phoneticTopic',
      columns: ['id', 'subId'],
      orderBy: 'subId ASC, id ASC',
    );
    final out = <int, List<int>>{};
    for (final r in rows) {
      final cat = r['subId'] as int;
      (out[cat] ??= <int>[]).add(r['id'] as int);
    }
    return out;
  }
}
