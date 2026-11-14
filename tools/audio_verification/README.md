# Audio CDN Verification

Samples audio files from `audio_files` table and checks each URL against
CloudFront via HTTP HEAD (fallback: GET with `Range: bytes=0-0`).

## How to run

```bash
python3 tools/audio_verification/check_cdn_files.py \
    --db assets/databases/learn_db.db
```

Default: 20 files sampled per `(source_table × voice_key)` = 400 URLs total
(5 tables × 4 voices × 20).

### Options

| Flag | Default | Description |
|---|---|---|
| `--db` | *(required)* | Path to `learn_db.db` |
| `--sample-size` | `20` | Files per `(source_table, voice)` pair |
| `--out` | `tools/audio_verification/report.json` | JSON output path |
| `--workers` | `20` | Concurrent HTTP connections |

### Example — larger sample

```bash
python3 tools/audio_verification/check_cdn_files.py \
    --db assets/databases/learn_db.db \
    --sample-size 100 \
    --workers 40
```

## Reading the report

```
== Audio CDN Verification ==
vocabulary          : 80/80 OK
word_list           : 80/80 OK
sentencesContent    : 78/80 OK  [2 FAIL]
phonetic_example    : 80/80 OK
conversation_sentence: 80/80 OK
--------------------------------------------------
TOTAL: 398/400 (99.5%)

FAILURES (2):
  [404] us_male/sentences/1847.mp3
  [404] uk_female/sentences/1847.mp3
```

- Exit code **0** = 100% pass.
- Exit code **1** = at least one failure. The full failure list is printed to stdout and saved in `report.json`.

## What a failure means

Any status other than 200/206 (including timeout or connection error) is a
failure. A failure means the file is genuinely missing or inaccessible on
S3/CloudFront.

**A failure rate > 0% must be resolved before shipping any feature that uses
those files.** Upload the missing files to S3 (`s3://…/audio/<file_path>`) and
re-run this script to confirm.

## This tool is NOT part of CI/CD

Run manually before releasing a build that depends on CDN audio. It is
safe to re-run at any time (read-only against the DB, read-only against CDN).
