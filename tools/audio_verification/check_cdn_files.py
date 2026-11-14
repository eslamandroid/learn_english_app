#!/usr/bin/env python3
"""
CDN audio verification tool.

Samples audio files from audio_files table and checks each URL via HTTP HEAD
(falling back to GET with Range: bytes=0-0) against CloudFront.

Usage:
    python3 check_cdn_files.py --db /path/to/learn_db.db [--sample-size 20]
                               [--out report.json] [--workers 20]
"""

import argparse
import json
import random
import sqlite3
import sys
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

CDN_BASE = "https://dwgyo0auw588p.cloudfront.net"
SOURCE_TABLES = [
    "vocabulary",
    "word_list",
    "sentencesContent",
    "phonetic_example",
    "conversation_sentence",
]
VOICE_KEYS = ["us_male", "us_female", "uk_male", "uk_female"]


def build_url(file_path: str) -> str:
    return f"{CDN_BASE}/audio/{file_path}"


def check_url(url: str, timeout: int = 5) -> dict:
    """Return dict with url, status, method, ok."""
    # Try HEAD first.
    for method, extra_headers in [
        ("HEAD", {}),
        ("GET", {"Range": "bytes=0-0"}),
    ]:
        req = urllib.request.Request(url, method=method, headers=extra_headers)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                code = resp.status
                ok = code in (200, 206)
                return {"url": url, "status": code, "method": method, "ok": ok}
        except urllib.error.HTTPError as e:
            if method == "HEAD" and e.code in (405, 400):
                continue  # CDN doesn't support HEAD — retry with GET
            return {"url": url, "status": e.code, "method": method, "ok": False,
                    "error": str(e)}
        except Exception as e:
            return {"url": url, "status": None, "method": method, "ok": False,
                    "error": str(e)}

    return {"url": url, "status": None, "method": "GET", "ok": False,
            "error": "Both HEAD and GET failed"}


def sample_urls(db_path: str, sample_size: int) -> list[dict]:
    """Sample `sample_size` file_paths per (source_table, voice_key) combination."""
    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    cur = conn.cursor()

    samples = []
    for source_table in SOURCE_TABLES:
        for voice_key in VOICE_KEYS:
            cur.execute(
                "SELECT file_path FROM audio_files "
                "WHERE source_table = ? AND voice_key = ? "
                "ORDER BY RANDOM() LIMIT ?",
                (source_table, voice_key, sample_size),
            )
            rows = cur.fetchall()
            for (file_path,) in rows:
                samples.append({
                    "source_table": source_table,
                    "voice_key": voice_key,
                    "file_path": file_path,
                    "url": build_url(file_path),
                })

    conn.close()
    return samples


def run(db_path: str, sample_size: int, out_path: str, workers: int):
    print(f"== Audio CDN Verification ==")
    print(f"DB: {db_path}")
    print(f"CDN base: {CDN_BASE}")
    print(f"Sample size: {sample_size} per (source_table × voice)")
    print(f"Workers: {workers}")
    print()

    samples = sample_urls(db_path, sample_size)
    total = len(samples)
    print(f"Total URLs to check: {total}  "
          f"({len(SOURCE_TABLES)} tables × {len(VOICE_KEYS)} voices × ~{sample_size})\n")

    results = []
    with ThreadPoolExecutor(max_workers=workers) as pool:
        future_to_sample = {
            pool.submit(check_url, s["url"]): s for s in samples
        }
        done = 0
        for future in as_completed(future_to_sample):
            s = future_to_sample[future]
            result = future.result()
            combined = {**s, **result}
            results.append(combined)
            done += 1
            if done % 50 == 0 or done == total:
                ok_so_far = sum(1 for r in results if r["ok"])
                print(f"  Progress: {done}/{total} checked, {ok_so_far} OK so far...",
                      end="\r", flush=True)

    print()  # clear progress line

    # ── Per-table summary ─────────────────────────────────────────────────────
    print("\n" + "=" * 50)
    grand_ok = 0
    grand_total = 0
    failures = []

    for source_table in SOURCE_TABLES:
        table_results = [r for r in results if r["source_table"] == source_table]
        ok_count = sum(1 for r in table_results if r["ok"])
        t = len(table_results)
        grand_ok += ok_count
        grand_total += t
        fail_tag = f"  [{t - ok_count} FAIL]" if ok_count < t else ""
        print(f"  {source_table:<25}: {ok_count}/{t} OK{fail_tag}")
        for r in table_results:
            if not r["ok"]:
                failures.append(r)

    print("-" * 50)
    pct = 100 * grand_ok / grand_total if grand_total else 0
    print(f"  TOTAL: {grand_ok}/{grand_total} ({pct:.1f}%)")

    if failures:
        print(f"\nFAILURES ({len(failures)}):")
        for f in failures:
            err = f.get("error", "")
            status = f.get("status", "?")
            print(f"  [{status}] {f['file_path']}  ({err})")
    else:
        print("\nAll sampled files returned OK.")

    # ── Write JSON report ─────────────────────────────────────────────────────
    report = {
        "cdn_base": CDN_BASE,
        "db": db_path,
        "sample_size_per_combination": sample_size,
        "total_checked": grand_total,
        "total_ok": grand_ok,
        "total_fail": grand_total - grand_ok,
        "pass_rate_pct": round(pct, 2),
        "results": results,
    }
    out_file = Path(out_path)
    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(json.dumps(report, indent=2, ensure_ascii=False))
    print(f"\nFull report saved to: {out_file.resolve()}")

    sys.exit(0 if grand_ok == grand_total else 1)


def main():
    parser = argparse.ArgumentParser(
        description="Verify audio files are accessible on CloudFront CDN"
    )
    parser.add_argument("--db", required=True,
                        help="Path to learn_db.db")
    parser.add_argument("--sample-size", type=int, default=20,
                        help="Number of files to sample per (source_table, voice) "
                             "combination (default: 20)")
    parser.add_argument("--out", default="tools/audio_verification/report.json",
                        help="Output JSON report path")
    parser.add_argument("--workers", type=int, default=20,
                        help="Concurrent HTTP workers (default: 20)")
    args = parser.parse_args()
    run(args.db, args.sample_size, args.out, args.workers)


if __name__ == "__main__":
    main()
