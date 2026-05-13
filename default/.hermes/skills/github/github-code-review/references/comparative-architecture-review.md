# Comparative Architecture Review Notes

Use this when a PR should be evaluated against a mature external implementation (e.g. comparing a database-backed scheduler/queue PR against Stalwart Mail Server's queue/task design).

## Workflow

1. Ground the local PR first:
   - `git diff origin/main...HEAD --stat`
   - `git log origin/main..HEAD --oneline`
   - Read core changed files, not only the diff.
2. Research the external system from docs and source:
   - Search docs for architecture/operations terms.
   - Prefer source inspection for concrete behavior.
   - If GitHub code search needs auth, shallow-clone the public repo into `/tmp/<project>` and use local search/read tools.
3. Compare by design dimensions, not file-by-file similarity:
   - persistence model
   - due-job/event indexing
   - lock/lease ownership and fencing
   - contention behavior
   - retry/backoff/expiry semantics
   - concurrency and backpressure controls
   - admin/observability operations
   - portability constraints (e.g. SQLite + Postgres vs Postgres-only primitives)
4. Separate verdict by fit-for-purpose:
   - Mature systems may have features that are unnecessary for the PR's product scale.
   - Identify which gaps are merge blockers, which are high-value follow-ups, and which would be over-engineering.

## Example: DB-backed scheduler/queue vs Stalwart-style mail queue

Stalwart-style patterns worth checking for:

- Persistent task/message state plus a separate due-event key/index.
- Range scan of due events up to `now`/next refresh rather than fetching a single candidate.
- Distributed lock/TTL around delivery attempts.
- Lock contention is treated as a miss for that item; the queue manager can continue considering other due events.
- Per-queue concurrency/backpressure limits (`threads`/capacity).
- Retry schedules/backoff, notification schedule, and expiry/attempt limits.
- Admin operations: query failed/pending tasks, pause/resume, force retry.

For a small auth/server scheduler, a portable CAS-update design with `lockedBy`/`lockedUntil`, lease renewal, and fenced completion can be enough. Common high-value improvement: on CAS contention, continue to another due candidate in the same tick instead of returning `null` immediately.
