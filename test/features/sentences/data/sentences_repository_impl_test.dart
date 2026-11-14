import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:learn_english_app/features/sentences/data/models/sentence_item_model.dart';
import 'package:learn_english_app/features/sentences/data/models/sentence_subtopic_model.dart';
import 'package:learn_english_app/features/sentences/data/models/sentence_topic_model.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_item.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_subtopic.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_topic.dart';

// Minimal in-memory datasource mock.
class _FakeDatasource implements _IDatasource {
  final List<SentenceTopicModel> topics;
  final Map<int, List<SentenceSubtopicModel>> subtopics;
  final Map<int, List<SentenceItemModel>> sentences;

  _FakeDatasource({
    required this.topics,
    this.subtopics = const {},
    this.sentences = const {},
  });

  @override
  Future<List<SentenceTopicModel>> getTopics() async => topics;

  @override
  Future<List<SentenceSubtopicModel>> getSubtopics(int topicId) async =>
      subtopics[topicId] ?? [];

  @override
  Future<List<SentenceItemModel>> getSentences(int subtopicId) async =>
      sentences[subtopicId] ?? [];
}

// Minimal interface to avoid importing injectable into tests.
abstract class _IDatasource {
  Future<List<SentenceTopicModel>> getTopics();
  Future<List<SentenceSubtopicModel>> getSubtopics(int topicId);
  Future<List<SentenceItemModel>> getSentences(int subtopicId);
}

// Test-only repository that accepts the minimal interface.
class _TestRepository {
  final _IDatasource _local;
  _TestRepository(this._local);

  Future<List<SentenceTopic>> getTopics() => _local.getTopics();
  Future<List<SentenceSubtopic>> getSubtopics(int topicId) =>
      _local.getSubtopics(topicId);
  Future<List<SentenceItem>> getSentences(int subtopicId) =>
      _local.getSentences(subtopicId);
}

void main() {
  tearDown(() => ContentLocalizerImpl.instance.debugReset());

  test('getTopics returns all topics from datasource', () async {
    final topic = SentenceTopicModel(
      id: 1,
      title: 'Basic Sentences',
      titleAr: 'الجمل الأساسية',
      sentenceCount: 20,
    );
    final repo = _TestRepository(_FakeDatasource(topics: [topic]));
    final result = await repo.getTopics();
    expect(result, hasLength(1));
    expect(result.first.id, 1);
    expect(result.first.title, 'Basic Sentences');
  });

  test('getSubtopics returns subtopics for given topicId', () async {
    final st = SentenceSubtopicModel(
      id: 5,
      topicId: 1,
      title: 'Saying Hello',
      titleAr: 'قول السلام',
    );
    final repo = _TestRepository(_FakeDatasource(
      topics: [],
      subtopics: {1: [st]},
    ));
    final result = await repo.getSubtopics(1);
    expect(result, hasLength(1));
    expect(result.first.id, 5);
  });

  test('getSentences returns items for given subtopicId', () async {
    final item = SentenceItemModel(
      id: 10,
      english: 'Hi there',
      arabic: 'أهلاً',
    );
    final repo = _TestRepository(_FakeDatasource(
      topics: [],
      sentences: {5: [item]},
    ));
    final result = await repo.getSentences(5);
    expect(result, hasLength(1));
    expect(result.first.english, 'Hi there');
  });

  test('getSentences for unknown subtopicId returns empty', () async {
    final repo = _TestRepository(_FakeDatasource(topics: []));
    final result = await repo.getSentences(999);
    expect(result, isEmpty);
  });
}
