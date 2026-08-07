#!/usr/bin/env python3
"""Applies authored package metadata (genre, verseContext) to every story JSON.

Both fields are required by the pre-launch content gate in
docs/LittleBible_Delivery_Plan.md. They are declared once in
scripts/story_metadata.json so the authored text lives in one reviewable place,
then written into each mobile/assets/stories/*.json as top-level fields —
alongside sensitivityTier, the other package-level declaration.

Run: python3 scripts/apply_story_metadata.py [--check]
  --check exits non-zero without writing if any story is missing or stale.
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / "mobile" / "assets" / "stories"
METADATA = ROOT / "scripts" / "story_metadata.json"

# Genres from the "Genre-aware structure requirement" table in the delivery plan.
VALID_GENRES = {"narrative", "wisdom", "lament", "teaching", "parable", "poetry"}

# Field order: package-level declarations sit together at the top of the file,
# before the human-facing title/subtitle.
AFTER_KEY = "sensitivityTier"


def load_metadata() -> dict:
    data = json.loads(METADATA.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("_")}


def reorder(story: dict, meta: dict) -> dict:
    """Rebuilds the dict with genre/verseContext inserted just after sensitivityTier."""
    out = {}
    for key, value in story.items():
        if key in ("genre", "verseContext"):
            continue  # re-inserted at the canonical position below
        out[key] = value
        if key == AFTER_KEY:
            out["genre"] = meta["genre"]
            out["verseContext"] = meta["verseContext"]
    return out


def main() -> int:
    check_only = "--check" in sys.argv
    metadata = load_metadata()
    files = sorted(STORIES.glob("*.json"))

    problems: list[str] = []
    changed: list[str] = []

    for path in files:
        story = json.loads(path.read_text(encoding="utf-8"))
        story_id = story["id"]

        meta = metadata.get(story_id)
        if meta is None:
            problems.append(f"{story_id}: no entry in scripts/story_metadata.json")
            continue
        if meta["genre"] not in VALID_GENRES:
            problems.append(f"{story_id}: invalid genre {meta['genre']!r}")
            continue
        if AFTER_KEY not in story:
            problems.append(f"{story_id}: missing {AFTER_KEY}, cannot place metadata")
            continue

        updated = reorder(story, meta)
        rendered = json.dumps(updated, indent=2, ensure_ascii=False) + "\n"
        if rendered == path.read_text(encoding="utf-8"):
            continue

        changed.append(story_id)
        if not check_only:
            path.write_text(rendered, encoding="utf-8")

    unknown = set(metadata) - {json.loads(p.read_text(encoding="utf-8"))["id"] for p in files}
    for story_id in sorted(unknown):
        problems.append(f"{story_id}: in metadata but has no story JSON")

    for problem in problems:
        print(f"ERROR {problem}", file=sys.stderr)

    if check_only:
        for story_id in changed:
            print(f"STALE {story_id}: genre/verseContext out of date", file=sys.stderr)
        if problems or changed:
            return 1
        print(f"OK {len(files)} stories carry genre + verseContext")
        return 0

    if problems:
        return 1
    print(f"Updated {len(changed)} of {len(files)} stories")
    return 0


if __name__ == "__main__":
    sys.exit(main())
