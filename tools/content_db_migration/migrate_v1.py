#!/usr/bin/env python3
"""
content.db schema v2 migration — additive only, no DROP or DELETE.

Usage:
    python3 migrate_v1.py --in <source.db> --out <output.db>

Steps performed:
  1. Copy source → output (never writes to source)
  2. Create content_level from the 9 level_* tables
  3. Create meta with schema_version=2
  4. Create translation (empty)
  5. Add sub_topic_id to grammar_content
"""

import argparse
import shutil
import sqlite3
import sys


# ── Mapping: (level_table, source_table_value, source_id_column) ──────────────
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


def verify_source_schema(cur):
    """PRAGMA-check every source table against expected columns; abort on mismatch."""
    expected_cols = {
        "level_vocabulary_topic":    {"topicId", "levelId"},
        "level_vocabulary_subtopic": {"subTopicId", "levelId"},
        "level_sentence_topic":      {"topicId", "levelId"},
        "level_sentence_subtopic":   {"subTopicId", "levelId", "id"},
        "level_phonetic_topic":      {"phoneticId", "levelId", "id"},
        "level_grammar_topic":       {"topicId", "levelId"},
        "level_grammar_subtopic":    {"subTopicId", "levelId"},
        "level_conversation_lesson": {"lessonId", "levelId"},
        "level_conversation_block":  {"blockId", "levelId", "id"},
    }
    ok = True
    for table, expected in expected_cols.items():
        cur.execute(f"PRAGMA table_info({table})")
        actual = {row[1] for row in cur.fetchall()}
        if not expected.issubset(actual):
            missing = expected - actual
            extra = actual - expected
            print(f"[SCHEMA MISMATCH] {table}: expected cols {expected}, "
                  f"got {actual} | missing={missing} extra={extra}")
            ok = False
    return ok


def step_content_level(cur, read_cur):
    """Create and populate content_level from the 9 level_* tables."""
    cur.execute("""
        CREATE TABLE IF NOT EXISTS content_level (
            source_table TEXT    NOT NULL,
            source_id    INTEGER NOT NULL,
            level        INTEGER NOT NULL,
            PRIMARY KEY (source_table, source_id)
        )
    """)

    # Some level_* tables have duplicate source_id values (one id assigned to
    # multiple CEFR levels). content_level PK is (source_table, source_id) so
    # only one level per id can be stored. We resolve by keeping MIN(levelId)
    # per id and logging the collapsed rows.
    #   level_sentence_subtopic: subTopicId 49/50/51 appear twice each (3 extra rows)
    #   level_conversation_block: blockId 7/8 appear twice each (2 extra rows)
    DEDUPLICATE_TABLES = {"level_sentence_subtopic", "level_conversation_block"}

    for level_table, source_table, id_col in LEVEL_SOURCES:
        read_cur.execute(f"SELECT COUNT(*) FROM {level_table}")
        original_count = read_cur.fetchone()[0]

        cur.execute("BEGIN")
        try:
            if level_table in DEDUPLICATE_TABLES:
                # Deduplicate: pick the minimum levelId per source_id.
                read_cur.execute(
                    f"SELECT {id_col}, MIN(levelId) "
                    f"FROM {level_table} GROUP BY {id_col}"
                )
                rows = read_cur.fetchall()
                cur.executemany(
                    "INSERT INTO content_level (source_table, source_id, level) "
                    "VALUES (?, ?, ?)",
                    [(source_table, r[0], r[1]) for r in rows],
                )
                inserted = len(rows)
                skipped = original_count - inserted
                if skipped:
                    print(
                        f"  [NOTE] {level_table}: {original_count} rows → "
                        f"{inserted} inserted (skipped {skipped} duplicate "
                        f"{id_col} with different levelId — kept MIN(levelId) per id). "
                        f"See README for details."
                    )
            else:
                read_cur.execute(
                    f"SELECT {id_col}, levelId FROM {level_table}"
                )
                rows = read_cur.fetchall()
                cur.executemany(
                    "INSERT INTO content_level (source_table, source_id, level) "
                    "VALUES (?, ?, ?)",
                    [(source_table, r[0], r[1]) for r in rows],
                )
                inserted = len(rows)

            cur.execute("COMMIT")
        except Exception as exc:
            cur.execute("ROLLBACK")
            raise RuntimeError(
                f"Failed inserting from {level_table}: {exc}"
            ) from exc

        # Count check
        cur.execute(
            "SELECT COUNT(*) FROM content_level WHERE source_table = ?",
            (source_table,),
        )
        in_content_level = cur.fetchone()[0]
        expected_in_cl = original_count if level_table not in DEDUPLICATE_TABLES \
            else (original_count - (original_count - inserted))
        if in_content_level != inserted:
            print(
                f"  [WARN] {source_table}: expected {inserted} rows in "
                f"content_level, found {in_content_level}"
            )
        else:
            print(
                f"  [OK]  {level_table} → content_level[{source_table}]: "
                f"{in_content_level} rows"
            )


def step_meta(cur):
    """Create meta table and insert schema_version=2."""
    cur.execute(
        "CREATE TABLE IF NOT EXISTS meta "
        "(key TEXT PRIMARY KEY, value TEXT NOT NULL)"
    )
    cur.execute(
        "INSERT OR REPLACE INTO meta (key, value) VALUES ('schema_version', '2')"
    )
    print("  [OK]  meta: schema_version=2")


def step_translation(cur):
    """Create translation table (empty)."""
    cur.execute("""
        CREATE TABLE IF NOT EXISTS translation (
            source_table TEXT    NOT NULL,
            source_id    INTEGER NOT NULL,
            field        TEXT    NOT NULL,
            locale       TEXT    NOT NULL,
            text         TEXT    NOT NULL,
            PRIMARY KEY (source_table, source_id, field, locale)
        )
    """)
    print("  [OK]  translation: created (empty)")


def step_grammar_content(cur, read_cur):
    """Add sub_topic_id to grammar_content and populate with id value."""
    # Verify id ranges match before touching anything.
    read_cur.execute("SELECT MIN(id), MAX(id), COUNT(*) FROM grammar_content")
    gc_min, gc_max, gc_count = read_cur.fetchone()
    read_cur.execute("SELECT MIN(id), MAX(id), COUNT(*) FROM grammar_sub_topics")
    gs_min, gs_max, gs_count = read_cur.fetchone()

    print(
        f"  [INFO] grammar_content:   id {gc_min}–{gc_max}, {gc_count} rows"
    )
    print(
        f"  [INFO] grammar_sub_topics: id {gs_min}–{gs_max}, {gs_count} rows"
    )

    if gc_count != gs_count or gc_min != gs_min or gc_max != gs_max:
        raise RuntimeError(
            f"grammar_content id range ({gc_min}–{gc_max}, {gc_count}) does not "
            f"match grammar_sub_topics ({gs_min}–{gs_max}, {gs_count}). "
            "Aborting — manual inspection required."
        )

    # Check if column already exists (idempotent).
    cur.execute("PRAGMA table_info(grammar_content)")
    existing_cols = {row[1] for row in cur.fetchall()}
    if "sub_topic_id" not in existing_cols:
        cur.execute(
            "ALTER TABLE grammar_content ADD COLUMN sub_topic_id INTEGER"
        )

    cur.execute("UPDATE grammar_content SET sub_topic_id = id")
    cur.execute(
        "SELECT COUNT(*) FROM grammar_content WHERE sub_topic_id IS NOT NULL"
    )
    filled = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM grammar_content WHERE sub_topic_id IS NULL")
    nulls = cur.fetchone()[0]
    print(
        f"  [OK]  grammar_content.sub_topic_id: {filled}/{gc_count} filled, "
        f"{nulls} NULL"
    )


def run(source_path: str, output_path: str):
    print(f"Source: {source_path}")
    print(f"Output: {output_path}\n")

    # ── Step 1: copy ──────────────────────────────────────────────────────────
    shutil.copy2(source_path, output_path)
    print(f"[1] Copied {source_path} → {output_path}")

    # Open source read-only, output for writing.
    src_conn = sqlite3.connect(f"file:{source_path}?mode=ro", uri=True)
    src_conn.row_factory = sqlite3.Row
    read_cur = src_conn.cursor()

    out_conn = sqlite3.connect(output_path)
    out_conn.execute("PRAGMA journal_mode=WAL")
    cur = out_conn.cursor()

    # ── Schema sanity check ───────────────────────────────────────────────────
    print("\n[Schema check]")
    if not verify_source_schema(read_cur):
        print("\n[ABORT] Schema mismatch detected. Fix the mapping before re-running.")
        sys.exit(1)
    print("  All source table schemas verified.\n")

    # ── Step 2: content_level ─────────────────────────────────────────────────
    print("[2] Building content_level ...")
    step_content_level(cur, read_cur)
    cur.execute("SELECT COUNT(*) FROM content_level")
    total = cur.fetchone()[0]
    print(f"  → content_level total: {total} rows\n")

    # ── Step 3: meta ──────────────────────────────────────────────────────────
    print("[3] Creating meta ...")
    step_meta(cur)
    print()

    # ── Step 4: translation ───────────────────────────────────────────────────
    print("[4] Creating translation ...")
    step_translation(cur)
    print()

    # ── Step 5: grammar_content.sub_topic_id ─────────────────────────────────
    print("[5] Adding grammar_content.sub_topic_id ...")
    step_grammar_content(cur, read_cur)
    print()

    out_conn.commit()
    out_conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    out_conn.close()
    src_conn.close()

    print("Migration complete. Run verify_v1.py to confirm.")


def main():
    parser = argparse.ArgumentParser(
        description="Additive migration of content.db to schema v2"
    )
    parser.add_argument("--in", dest="source", required=True,
                        help="Path to source learn_db.db (read-only)")
    parser.add_argument("--out", dest="output", required=True,
                        help="Path for migrated output file")
    args = parser.parse_args()
    run(args.source, args.output)


if __name__ == "__main__":
    main()
