# Concurrent content protocol

## Work packet layout

Each chapter uses:

```text
.content-workflow/chapters/{book}/{NN}/
  manifest.json
  claims/{role}.json
  reviews/theology.json
  reviews/child.json
```

The chapter itself remains in `public/data/en/{book}/{book}_chapter_{NN}.json`.

## Roles and write sets

| Role | May write | Must not write |
|---|---|---|
| writer | assigned chapter JSON; writer claim | reviews, indexes, global tracker |
| theology | theology review and claim | chapter, child review, records |
| child | child review and claim | chapter, theology review, records |
| records | indexes, tracker, manifest publication fields, records claim | chapter prose, reviews |

Claims use atomic directory creation. A role claim is exclusive per chapter. Theology and child claims do not conflict with each other. The writer cannot claim while either review claim exists; reviewers cannot claim while writer is active; records cannot claim while any other claim is active.

## State transitions

`reserved -> drafting -> sealed -> reviewing -> revision_required -> sealed -> approved -> published`

A seal records SHA-256 of the complete chapter. Every review records that hash and standard version. Any reseal with a changed hash makes previous reviews stale; never carry approval forward.

## Commands

From repository root:

```bash
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py init john 8
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py claim john 8 writer codex-agent
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py seal john 8
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py release john 8 writer
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py claim john 8 theology claude-theology
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py claim john 8 child codex-child
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py review john 8 theology PASS
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py review john 8 child PASS
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py release john 8 theology
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py release john 8 child
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py ready john 8
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py claim john 8 records codex-records
# The record keeper now updates the book index and completion tracker.
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py publish john 8
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py release john 8 records
python3 .agents/skills/little-bible-content-workflow/scripts/workflow.py status john 8
```

Use agent identifiers that identify tool and role. Do not put secrets in packets.

## Recovery

Never steal a claim merely because it is old. Confirm the owning agent is stopped, then use `release`. If a process dies during writing, validate the chapter before sealing. If the hash changes after review, rerun both reviews.
