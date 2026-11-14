# content.db Schema v2 Migration

One-time additive migration — no DROP, no DELETE, no ALTER … DROP COLUMN.

## What it does

| # | Change | Why |
|---|---|---|
| 1 | Creates `content_level(source_table, source_id, level)` | Consolidates 9 `level_*` tables into one unified lookup |
| 2 | Creates `meta(key, value)` with `schema_version=2` | Enables future content-version checks |
| 3 | Creates `translation(source_table, source_id, field, locale, text)` (empty) | Ready for multilingual content (Task 04+) |
| 4 | Adds `grammar_content.sub_topic_id INTEGER` | Links grammar content to its sub-topic (Task 05+) |

All original tables (`level_*` × 9, `grammar_test`, everything else) are **untouched**.

---

## How to run

```bash
python3 migrate_v1.py --in assets/databases/learn_db.db --out /tmp/learn_db_v2.db
```

Then verify:

```bash
python3 verify_v1.py --old assets/databases/learn_db.db --new /tmp/learn_db_v2.db
```

All lines must show `[OK]`. Exit code 0 = success, 1 = failure.

---

## After successful verification (manual step)

1. Replace the asset:
   ```bash
   cp /tmp/learn_db_v2.db assets/databases/learn_db.db
   ```
2. Force Flutter to pick up the new asset:
   ```bash
   flutter clean && flutter pub get
   ```
3. Reinstall the app on a test device (existing installs won't pick up the new
   asset automatically — that is handled by the content-version mechanism in
   Task 03/S3, not here).

> **Do not commit the migrated DB without running verify first.**

---

## Known data anomalies (logged by migrate_v1.py)

### Duplicate source_ids in level_sentence_subtopic
`subTopicId` values 49, 50, and 51 each appear in two different CEFR levels
(total 100 rows, only 97 unique `subTopicId` values). Since `content_level`
has a PK of `(source_table, source_id)`, only one row per `subTopicId` can be
stored. The migration keeps `MIN(levelId)` per `subTopicId` and discards the
3 duplicate rows. The 3 extra rows remain in `level_sentence_subtopic` unchanged.

### Duplicate blockIds in level_conversation_block
`blockId` 7 and 8 each appear twice with different `levelId` values (total 16
rows, 14 unique `blockId` values). Same resolution: `MIN(levelId)` per
`blockId`. `level_conversation_block` keeps its original 16 rows.

Both anomalies are present in the **original** database and are not introduced
by this script.

---

## content_level total rows

| source_table | rows | from |
|---|---|---|
| vocaTopic | 14 | level_vocabulary_topic |
| vocaSubTopic | 101 | level_vocabulary_subtopic |
| sentenceTopic | 20 | level_sentence_topic |
| sentencesSubTopic | 97 | level_sentence_subtopic (97 unique, 3 collapsed) |
| phoneticTopic | 115 | level_phonetic_topic |
| grammar_topics | 20 | level_grammar_topic |
| grammar_sub_topics | 114 | level_grammar_subtopic |
| conversation_lesson | 138 | level_conversation_lesson |
| conversation_level | 14 | level_conversation_block (14 unique, 2 collapsed) |
| **Total** | **633** | |

> Note: the PLAN.md verify example showed 536 — that is a typo; the correct
> total is 633 (= 636 expected from unique counts, minus the 3 collapsed
> sentence_subtopic rows).

---

## This tool is NOT part of CI/CD

Run it manually once before publishing a new APK/IPA. It is safe to re-run
(all `CREATE TABLE IF NOT EXISTS`, `ALTER TABLE … ADD COLUMN` if not exists,
`INSERT OR REPLACE` for meta) — idempotent for all steps except `content_level`
rows which would raise a UNIQUE error on re-run (use a fresh output path).
