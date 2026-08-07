#!/usr/bin/env python3
"""Generate resumable Edge TTS audio for every bundled Bible verse."""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

import edge_tts


LBV_VOICE = "en-US-AriaNeural"
KJV_VOICE = "en-GB-RyanNeural"
EXPECTED_CHAPTERS = 1_189


@dataclass(frozen=True)
class VerseJob:
    slug: str
    chapter: int
    verse: int
    little_bible: Optional[str]
    kjv: str

    @property
    def label(self) -> str:
        return f"{self.slug}/{self.chapter:03d}/{self.verse:03d}"


def to_slug(book_name: str) -> str:
    """Convert a canonical display name such as '1 Samuel' to its URL slug."""
    normalized = book_name.strip().lower()
    if normalized == "song of solomon":
        return "song-of-solomon"
    return re.sub(r"\s+", "-", normalized)


def clean_text(value: object) -> Optional[str]:
    if not isinstance(value, str):
        return None
    value = value.strip()
    return value or None


def load_jobs(asset_root: Path, only_book: Optional[str] = None) -> list[VerseJob]:
    chapter_files = sorted(asset_root.glob("*/*chapter*.json"))
    if len(chapter_files) != EXPECTED_CHAPTERS:
        raise RuntimeError(
            f"Expected {EXPECTED_CHAPTERS} chapter files under {asset_root}, "
            f"found {len(chapter_files)}"
        )

    jobs: list[VerseJob] = []
    seen: set[tuple[str, int, int]] = set()
    for chapter_file in chapter_files:
        with chapter_file.open(encoding="utf-8") as handle:
            chapter = json.load(handle)

        slug = to_slug(str(chapter["book"]))
        if slug != chapter_file.parent.name:
            raise ValueError(
                f"Book slug mismatch in {chapter_file}: expected directory {slug!r}"
            )
        if only_book and slug != only_book:
            continue

        chapter_number = int(chapter["chapter"])
        for raw_verse in chapter["verses"]:
            verse_number = int(raw_verse["verse"])
            key = (slug, chapter_number, verse_number)
            if key in seen:
                raise ValueError(f"Duplicate verse: {slug} {chapter_number}:{verse_number}")
            seen.add(key)

            kjv = clean_text(raw_verse.get("kjv"))
            if kjv is None:
                raise ValueError(f"Missing KJV text: {slug} {chapter_number}:{verse_number}")
            jobs.append(
                VerseJob(
                    slug=slug,
                    chapter=chapter_number,
                    verse=verse_number,
                    little_bible=clean_text(raw_verse.get("little_bible")),
                    kjv=kjv,
                )
            )

    return jobs


async def synthesize(text: str, voice: str, destination: Path, retries: int) -> str:
    if destination.is_file() and destination.stat().st_size > 0:
        return "skipped"

    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_suffix(f".{os.getpid()}.{id(asyncio.current_task())}.tmp")
    for attempt in range(1, retries + 1):
        try:
            temporary.unlink(missing_ok=True)
            await edge_tts.Communicate(text=text, voice=voice).save(str(temporary))
            if not temporary.is_file() or temporary.stat().st_size == 0:
                raise RuntimeError("Edge TTS returned an empty audio file")
            temporary.replace(destination)
            return "generated"
        except Exception:
            temporary.unlink(missing_ok=True)
            if attempt == retries:
                raise
            await asyncio.sleep(min(2 ** attempt, 10))
    raise AssertionError("unreachable")


async def process_job(job: VerseJob, output_root: Path, retries: int) -> tuple[int, int]:
    directory = Path(job.slug) / f"{job.chapter:03d}"
    filename = f"{job.verse:03d}.mp3"

    if job.little_bible is None:
        lbv_status = "skip"
        lbv_generated = 0
    else:
        lbv_result = await synthesize(
            job.little_bible,
            LBV_VOICE,
            output_root / "lbv" / directory / filename,
            retries,
        )
        lbv_status = "✓" if lbv_result == "generated" else "exists"
        lbv_generated = int(lbv_result == "generated")

    kjv_result = await synthesize(
        job.kjv,
        KJV_VOICE,
        output_root / "kjv" / directory / filename,
        retries,
    )
    kjv_status = "✓" if kjv_result == "generated" else "exists"
    print(f"[{job.label}] lbv {lbv_status} | kjv {kjv_status}", flush=True)
    return lbv_generated, int(kjv_result == "generated")


async def generate(jobs: list[VerseJob], output_root: Path, concurrency: int, retries: int) -> None:
    queue: asyncio.Queue[Optional[VerseJob]] = asyncio.Queue()
    for job in jobs:
        queue.put_nowait(job)
    for _ in range(concurrency):
        queue.put_nowait(None)

    totals = {"lbv": 0, "kjv": 0}

    async def worker() -> None:
        while True:
            job = await queue.get()
            try:
                if job is None:
                    return
                lbv_count, kjv_count = await process_job(job, output_root, retries)
                totals["lbv"] += lbv_count
                totals["kjv"] += kjv_count
            finally:
                queue.task_done()

    workers = [asyncio.create_task(worker()) for _ in range(concurrency)]
    try:
        await asyncio.gather(*workers)
    except Exception:
        for worker in workers:
            worker.cancel()
        await asyncio.gather(*workers, return_exceptions=True)
        raise

    print(
        f"Complete: {len(jobs)} verses processed; "
        f"{totals['lbv']} LBV and {totals['kjv']} KJV files generated."
    )


def parse_args() -> argparse.Namespace:
    project_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--asset-root",
        type=Path,
        default=project_root / "mobile/assets/bible/en",
    )
    parser.add_argument(
        "--output-root",
        type=Path,
        default=project_root / "audio_output",
    )
    parser.add_argument("--concurrency", type=int, default=10)
    parser.add_argument("--retries", type=int, default=4)
    parser.add_argument("--book", help="Generate only one canonical book slug")
    parser.add_argument(
        "--limit",
        type=int,
        help="Process only the first N matching verses (useful for a smoke test)",
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate and count source files without contacting Edge TTS",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.concurrency < 1:
        raise SystemExit("--concurrency must be at least 1")
    if args.retries < 1:
        raise SystemExit("--retries must be at least 1")

    only_book = to_slug(args.book) if args.book else None
    jobs = load_jobs(args.asset_root.resolve(), only_book)
    if args.limit is not None:
        if args.limit < 1:
            raise SystemExit("--limit must be at least 1")
        jobs = jobs[: args.limit]
    lbv_count = sum(job.little_bible is not None for job in jobs)
    print(
        f"Validated {len(jobs)} verses: {lbv_count} LBV and {len(jobs)} KJV tracks."
    )
    if not args.validate_only:
        asyncio.run(generate(jobs, args.output_root.resolve(), args.concurrency, args.retries))


if __name__ == "__main__":
    main()
