#!/usr/bin/env python3
"""
Verification script for content.db schema v2 migration.

Usage:
    python3 verify_v1.py --old <original.db> --new <migrated.db>

Prints [OK] / [FAIL] for every check. Exits with code 1 if any FAIL.
"""

import argparse
import sqlite3
import sys


LEVEL_SOURCES = [
    ("level_vocabulary_topic",    "vocaTopic",            "topicId"),
    ("level_vocabulary_subtopic", "vocaSubTopic",         "subTopicId"),
    ("level_sentence_topic",      "sentenceTopic",        "topicId"),
    ("level_sentence_subtopic",   "sentencesSubTopic",    "subTopicId"),
    ("level_phonetic_topic",      "phoneticTopic",        "phoneticId"),
    ("level_grammar_topic",       "grammar_topics",       "topicId"),
    ("level_grammar_subtopic",    "grammar_sub_topics",   "subTopicId"),
    ("level_conversation_lesson", "conversation_lesson",  "lessonId"),
    ("level_conversation_block",  "conversation_level",   "blockId"),
]

# Two tables have duplicate source_ids (one id in multiple CEFR levels).
# content_level collapses them to unique ids using MIN(levelId).
#   level_sentence_subtopic: subTopicId 49/50/51 each appear twice (3 extra rows)
#   level_conversation_block: blockId 7/8 each appear twice (2 extra rows)
DEDUP_TABLES = {"level_sentence_subtopic", "level_conversation_block"}


def count(cur, table, where=None, args=None):
    sql = f"SELECT COUNT(*) FROM {table}"
    if where:
        sql += f" WHERE {where}"
    cur.execute(sql, args or [])
    return cur.fetchone()[0]


def ok(msg):
    print(f"[OK]   {msg}")


def fail(msg):
    print(f"[FAIL] {msg}")
    return True  # indicates failure


def run(old_path: str, new_path: str):
    old = sqlite3.connect(f"file:{old_path}?mode=ro", uri=True)
    new = sqlite3.connect(f"file:{new_path}?mode=ro", uri=True)
    old_cur = old.cursor()
    new_cur = new.cursor()

    failures = False

    # ── 1. content_level exists and per-source counts match ──────────────────
    new_cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='content_level'"
    )
    if not new_cur.fetchone():
        failures |= fail("content_level table is missing")
    else:
        cl_total = 0
        for level_table, source_table, id_col in LEVEL_SOURCES:
            old_cur.execute(f"SELECT COUNT(*) FROM {level_table}")
            old_count = old_cur.fetchone()[0]

            new_cur.execute(
                "SELECT COUNT(*) FROM content_level WHERE source_table = ?",
                (source_table,),
            )
            cl_count = new_cur.fetchone()[0]
            cl_total += cl_count

            if level_table in DEDUP_TABLES:
                # Expected = number of unique source_ids in the old table.
                old_cur.execute(
                    f"SELECT COUNT(DISTINCT {id_col}) FROM {level_table}"
                )
                expected = old_cur.fetchone()[0]
                skipped = old_count - expected
                if cl_count == expected:
                    ok(
                        f"content_level[{source_table}]: {cl_count} rows "
                        f"(from {old_count} in {level_table}, {skipped} duplicate "
                        f"{id_col} collapsed by MIN(levelId) — expected)"
                    )
                else:
                    failures |= fail(
                        f"content_level[{source_table}]: expected {expected}, "
                        f"got {cl_count}"
                    )
            else:
                if cl_count == old_count:
                    ok(
                        f"content_level[{source_table}]: "
                        f"{cl_count} == {level_table}: {old_count}"
                    )
                else:
                    failures |= fail(
                        f"content_level[{source_table}]: expected {old_count} "
                        f"from {level_table}, got {cl_count}"
                    )

        # Total
        new_cur.execute("SELECT COUNT(*) FROM content_level")
        total_in_db = new_cur.fetchone()[0]
        if total_in_db == cl_total:
            ok(f"content_level total: {total_in_db} rows")
        else:
            failures |= fail(
                f"content_level total mismatch: expected {cl_total}, "
                f"got {total_in_db}"
            )

        # No duplicate PKs (sqlite enforces this, but double-check)
        new_cur.execute(
            "SELECT source_table, source_id, COUNT(*) AS n FROM content_level "
            "GROUP BY source_table, source_id HAVING n > 1"
        )
        dupes = new_cur.fetchall()
        if dupes:
            failures |= fail(
                f"content_level has {len(dupes)} duplicate PKs: {dupes[:5]}"
            )
        else:
            ok("content_level: no duplicate PKs")

    # ── 2. meta ───────────────────────────────────────────────────────────────
    new_cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='meta'"
    )
    if not new_cur.fetchone():
        failures |= fail("meta table is missing")
    else:
        new_cur.execute("SELECT value FROM meta WHERE key = 'schema_version'")
        row = new_cur.fetchone()
        if row and row[0] == "2":
            ok("meta: 1 row (schema_version=2)")
        else:
            failures |= fail(
                f"meta.schema_version: expected '2', got {row[0] if row else None}"
            )

    # ── 3. translation ────────────────────────────────────────────────────────
    new_cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='translation'"
    )
    if not new_cur.fetchone():
        failures |= fail("translation table is missing")
    else:
        n = count(new_cur, "translation")
        if n == 0:
            ok("translation: 0 rows (as expected)")
        else:
            failures |= fail(f"translation: expected 0 rows, got {n}")

    # ── 4. grammar_content.sub_topic_id ──────────────────────────────────────
    new_cur.execute("PRAGMA table_info(grammar_content)")
    cols = {row[1] for row in new_cur.fetchall()}
    if "sub_topic_id" not in cols:
        failures |= fail("grammar_content.sub_topic_id column is missing")
    else:
        total_gc = count(new_cur, "grammar_content")
        filled = count(
            new_cur, "grammar_content", "sub_topic_id IS NOT NULL"
        )
        nulls = count(new_cur, "grammar_content", "sub_topic_id IS NULL")
        if filled == total_gc and nulls == 0:
            ok(
                f"grammar_content.sub_topic_id: {filled}/{total_gc} filled, "
                f"0 NULL"
            )
        else:
            failures |= fail(
                f"grammar_content.sub_topic_id: {filled}/{total_gc} filled, "
                f"{nulls} NULL"
            )

    # ── 5. Old tables untouched ───────────────────────────────────────────────
    must_survive = [t for t, _, _ in LEVEL_SOURCES] + ["grammar_test"]
    for table in must_survive:
        old_cur.execute(f"SELECT COUNT(*) FROM {table}")
        old_n = old_cur.fetchone()[0]
        new_cur.execute(
            f"SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            (table,),
        )
        if not new_cur.fetchone():
            failures |= fail(f"old table {table} is missing from migrated DB")
            continue
        new_cur.execute(f"SELECT COUNT(*) FROM {table}")
        new_n = new_cur.fetchone()[0]
        if old_n == new_n:
            ok(f"preserved {table}: {new_n} rows unchanged")
        else:
            failures |= fail(
                f"preserved {table}: row count changed {old_n} → {new_n}"
            )

    old.close()
    new.close()

    print()
    if failures:
        print("Result: FAIL — see [FAIL] entries above")
        sys.exit(1)
    else:
        print("Result: ALL CHECKS PASSED")


def main():
    parser = argparse.ArgumentParser(
        description="Verify content.db v2 migration"
    )
    parser.add_argument("--old", required=True,
                        help="Path to original (pre-migration) learn_db.db")
    parser.add_argument("--new", required=True,
                        help="Path to migrated output file")
    args = parser.parse_args()
    run(args.old, args.new)


if __name__ == "__main__":
    main()
