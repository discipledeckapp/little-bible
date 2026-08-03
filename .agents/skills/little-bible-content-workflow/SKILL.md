---
name: little-bible-content-workflow
description: Coordinate concurrent Little Bible chapter writing, theological review, child-learning review, revision, validation, publication, and completion tracking across Codex, Claude, or human agents. Use when starting, resuming, assigning, inspecting, or publishing chapter work, especially when roles operate concurrently and must not overwrite one another.
---

# Little Bible Content Workflow

Read `references/protocol.md` completely before coordinating work. Use `scripts/workflow.py` for packet creation, role claims, draft sealing, review recording, status, and readiness checks.

## Core rule

Parallelize across independent role-owned artifacts, never across writers editing the same file.

Safe concurrency:

- One writer per chapter JSON.
- Theology and child reviewers run concurrently after the same draft hash is sealed.
- Reviewers write separate artifacts.
- Record keeper publishes only after matching approvals.
- Different chapters may have different writers concurrently when each has its own work packet.

## Standard cycle

1. Initialize a packet and claim `writer`.
2. Draft and validate the complete chapter.
3. Seal the draft; release `writer`.
4. Claim `theology` and `child` concurrently; write separate reviews against the sealed hash.
5. If either fails, release reviews, claim `writer`, revise, and reseal. Old reviews become stale automatically.
6. When both pass, claim `records`, run readiness, publish/index/update counts, and mark published.

Never let reviewers edit drafts, writers edit reviews/records, or record keepers change content.

