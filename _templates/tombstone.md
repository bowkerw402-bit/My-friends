---
kind: tombstone
date: YYYY-MM-DD
---

# Tombstone — <what was archived>

> Nothing is ever hard-deleted. Archiving = moving to `90-archive/` (vault) or `_graveyard/`
> (business) with this marker, so anything can be recovered.

- **What:** <folder / file>
- **Moved from:** `<original absolute path>`
- **Moved to:** `<archive path>`
- **Git backup:** `<bundle name / commit sha>` (created before the move)
- **Reason:** <why it was archived — stale / duplicate / superseded / killed>
- **Superseded by:** `<canonical path>` (if a duplicate/merge)
- **Recover with:** `git mv "<archive path>" "<original path>"`  (or restore from the bundle)
