#!/usr/bin/env python3
"""Concurrency-safe Little Bible content work packets."""

from __future__ import annotations

import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

ROLES = {"writer", "theology", "child", "records"}
STANDARD = "2.1"


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def root() -> Path:
    current = Path.cwd().resolve()
    while current != current.parent:
        if (current / "docs" / "LittleBible_Content_Standard_v2.md").is_file():
            return current
        current = current.parent
    raise SystemExit("Run inside the Little Bible repository")


def chapter_num(raw: str) -> int:
    value = int(raw)
    if value < 1:
        raise SystemExit("chapter must be positive")
    return value


def packet(book: str, chapter: int) -> Path:
    return root() / ".content-workflow" / "chapters" / book.lower() / f"{chapter:02d}"


def chapter_file(book: str, chapter: int) -> Path:
    slug = book.lower()
    return root() / "public" / "data" / "en" / slug / f"{slug}_chapter_{chapter:02d}.json"


def load(path: Path) -> dict:
    return json.loads(path.read_text())


def write(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + f".{os.getpid()}.tmp")
    temp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    os.replace(temp, path)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def manifest(book: str, chapter: int) -> tuple[Path, dict]:
    path = packet(book, chapter) / "manifest.json"
    if not path.is_file():
        raise SystemExit("packet does not exist; run init")
    return path, load(path)


def active_claims(base: Path) -> set[str]:
    claims = base / "claims"
    if not claims.exists():
        return set()
    return {p.stem for p in claims.glob("*.json")}


def cmd_init(book: str, chapter: int) -> None:
    base = packet(book, chapter)
    base.mkdir(parents=True, exist_ok=True)
    (base / "claims").mkdir(exist_ok=True)
    (base / "reviews").mkdir(exist_ok=True)
    path = base / "manifest.json"
    if path.exists():
        raise SystemExit("packet already exists")
    write(path, {
        "book": book.title(), "bookSlug": book.lower(), "chapter": chapter,
        "standardVersion": STANDARD, "state": "reserved", "draftHash": None,
        "createdAt": now(), "updatedAt": now(), "publishedAt": None,
    })
    print(path.relative_to(root()))


def cmd_claim(book: str, chapter: int, role: str, agent: str) -> None:
    if role not in ROLES:
        raise SystemExit(f"role must be one of {sorted(ROLES)}")
    base = packet(book, chapter)
    path, data = manifest(book, chapter)
    mutex = base / ".claim-mutex"
    try:
        mutex.mkdir()
    except FileExistsError:
        raise SystemExit("another claim operation is in progress; retry")
    try:
        active = active_claims(base)
        if role in active:
            raise SystemExit(f"{role} already claimed")
        if role == "writer" and active:
            raise SystemExit(f"writer blocked by active claims: {sorted(active)}")
        if role in {"theology", "child"} and ("writer" in active or not data.get("draftHash")):
            raise SystemExit("review requires a sealed draft and no writer claim")
        if role == "records" and active:
            raise SystemExit(f"records blocked by active claims: {sorted(active)}")
        write(base / "claims" / f"{role}.json", {"role": role, "agent": agent, "claimedAt": now()})
    finally:
        mutex.rmdir()
    data["state"] = "drafting" if role == "writer" else ("reviewing" if role in {"theology", "child"} else data["state"])
    data["updatedAt"] = now()
    write(path, data)
    print(f"claimed {role} for {book} {chapter}")


def cmd_release(book: str, chapter: int, role: str) -> None:
    if role not in ROLES:
        raise SystemExit("invalid role")
    claim = packet(book, chapter) / "claims" / f"{role}.json"
    if not claim.exists():
        raise SystemExit(f"no {role} claim")
    claim.unlink()
    print(f"released {role}")


def cmd_seal(book: str, chapter: int) -> None:
    path, data = manifest(book, chapter)
    base = packet(book, chapter)
    if "writer" not in active_claims(base):
        raise SystemExit("writer must hold claim to seal")
    source = chapter_file(book, chapter)
    parsed = load(source)
    verses = parsed.get("verses", [])
    expected = list(range(1, len(verses) + 1))
    if not verses or [v.get("verse") for v in verses] != expected:
        raise SystemExit("chapter verses are missing or non-sequential")
    new_hash = digest(source)
    data["draftHash"] = new_hash
    data["state"] = "sealed"
    data["updatedAt"] = now()
    write(path, data)
    print(new_hash)


def cmd_review(book: str, chapter: int, role: str, verdict: str) -> None:
    if role not in {"theology", "child"} or verdict not in {"PASS", "FAIL"}:
        raise SystemExit("review requires theology|child and PASS|FAIL")
    path, data = manifest(book, chapter)
    if role not in active_claims(packet(book, chapter)):
        raise SystemExit(f"{role} must hold claim")
    current = digest(chapter_file(book, chapter))
    if current != data.get("draftHash"):
        raise SystemExit("STALE: chapter differs from sealed hash")
    write(packet(book, chapter) / "reviews" / f"{role}.json", {
        "role": role, "verdict": verdict, "draftHash": current,
        "standardVersion": STANDARD, "reviewedAt": now(),
    })
    data["state"] = "revision_required" if verdict == "FAIL" else "reviewing"
    data["updatedAt"] = now()
    write(path, data)
    print(f"recorded {role} {verdict}")


def readiness(book: str, chapter: int) -> tuple[bool, str]:
    _, data = manifest(book, chapter)
    source = chapter_file(book, chapter)
    if not source.is_file() or digest(source) != data.get("draftHash"):
        return False, "draft is missing or stale"
    for role in ("theology", "child"):
        review_path = packet(book, chapter) / "reviews" / f"{role}.json"
        if not review_path.is_file():
            return False, f"missing {role} review"
        review = load(review_path)
        if review.get("verdict") != "PASS" or review.get("draftHash") != data["draftHash"]:
            return False, f"{role} review failed or is stale"
    return True, "ready"


def cmd_ready(book: str, chapter: int) -> None:
    ready, reason = readiness(book, chapter)
    print(reason)
    if not ready:
        raise SystemExit(1)


def cmd_publish(book: str, chapter: int) -> None:
    path, data = manifest(book, chapter)
    if "records" not in active_claims(packet(book, chapter)):
        raise SystemExit("records must hold claim")
    ready, reason = readiness(book, chapter)
    if not ready:
        raise SystemExit(reason)
    data["state"] = "published"
    data["publishedAt"] = now()
    data["updatedAt"] = now()
    write(path, data)
    print(f"marked {book} {chapter} published")


def cmd_status(book: str, chapter: int) -> None:
    _, data = manifest(book, chapter)
    data["activeClaims"] = sorted(active_claims(packet(book, chapter)))
    data["ready"], data["readinessReason"] = readiness(book, chapter)
    print(json.dumps(data, indent=2))


def main() -> None:
    if len(sys.argv) < 4:
        raise SystemExit("usage: workflow.py COMMAND BOOK CHAPTER [ARGS]")
    command, book, raw_chapter, *args = sys.argv[1:]
    chapter = chapter_num(raw_chapter)
    if command == "init" and not args:
        cmd_init(book, chapter)
    elif command == "claim" and len(args) == 2:
        cmd_claim(book, chapter, args[0], args[1])
    elif command == "release" and len(args) == 1:
        cmd_release(book, chapter, args[0])
    elif command == "seal" and not args:
        cmd_seal(book, chapter)
    elif command == "review" and len(args) == 2:
        cmd_review(book, chapter, args[0], args[1])
    elif command == "ready" and not args:
        cmd_ready(book, chapter)
    elif command == "publish" and not args:
        cmd_publish(book, chapter)
    elif command == "status" and not args:
        cmd_status(book, chapter)
    else:
        raise SystemExit("invalid command or arguments")


if __name__ == "__main__":
    main()
