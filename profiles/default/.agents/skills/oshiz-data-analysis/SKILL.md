---
name: oshiz-data-analysis
description: Analyze Oshiz (오시즈) production data with psql through OSHIZ_PRODUCTION_READONLY_DATABASE. Use when the user requests Oshiz metrics, funnels, retention, revenue, user behavior, events, chats, Idolive, cohorts, or other database-backed analysis.
---

# Oshiz Data Analysis

Use `psql` and the `OSHIZ_PRODUCTION_READONLY_DATABASE` environment variable to answer data questions against the Oshiz production read replica. Treat every connection as production access.

Read [references/data-model.md](references/data-model.md) before choosing tables or joins.

## Connect safely

1. Confirm that `psql` is installed and the environment variable is set without printing its value.
2. The configured URL may contain `sslmode=no-verify`, which libpq does not accept. Replace only that query parameter in memory with `sslmode=require`; never print or persist the resulting URL.
3. Run every query in an explicit read-only transaction with `ON_ERROR_STOP`, no user psql configuration, no pager, and a short statement timeout.

Use this PowerShell pattern:

```powershell
$databaseUrl = $env:OSHIZ_PRODUCTION_READONLY_DATABASE -replace '([?&]sslmode=)no-verify(?=(&|$))', '${1}require'
psql "$databaseUrl" -X --set=ON_ERROR_STOP=1 --pset=pager=off --command="BEGIN READ ONLY; SET LOCAL statement_timeout = '30s'; SET LOCAL lock_timeout = '3s'; SELECT ...; COMMIT;"
```

If the variable is missing, stop and report that `OSHIZ_PRODUCTION_READONLY_DATABASE` must be configured. Do not ask the user to paste credentials into chat.

## Enforce production boundaries

- Run only `SELECT`, catalog inspection, and `EXPLAIN` without `ANALYZE`.
- Never run DDL, DML, `CALL`, `DO`, `COPY ... PROGRAM`, maintenance commands, advisory locks, or data-changing functions, even if permissions appear to allow them.
- Do not change the database, role, schema, permissions, or session defaults.
- Never print, log, save, or return the connection URL or credentials.
- Do not return row-level personal or sensitive data. This includes names, emails, provider identifiers, message content, memory content, receipt data, signatures, transaction identifiers, and raw JSON payloads.
- Aggregate user-level results. Do not expose user UUIDs, anonymous IDs, session IDs, room IDs, or other stable identifiers. Suppress or combine cohort rows with fewer than 5 users unless the user provides a legitimate reason and explicitly requests otherwise.
- Prefer metadata and counts over content inspection. If JSON structure is needed, inspect keys or types rather than values.

## Analyze methodically

1. Restate the metric definition, date range, timezone, population, and requested dimensions. Ask one concise question only when ambiguity could materially change the result.
2. Inspect relevant tables, columns, enum values, indexes, and approximate table sizes before writing the analytical query. The schema can drift; do not rely solely on the reference.
3. Validate timestamp coverage and timezone assumptions. Database timestamps are commonly `timestamp without time zone`, so never silently label them as local time or UTC.
4. Add bounded date predicates early, especially for `public.analytics_events`, `public.user_stat_logs`, `public.user_action_events`, and chat messages.
5. Account for soft deletion with `deleted_at IS NULL` when the table has that column, unless the analysis explicitly concerns deleted records.
6. Check join cardinality before aggregating. Pre-aggregate one-to-many tables or compare row counts before and after joins to avoid multiplication.
7. Use `EXPLAIN` without `ANALYZE` for potentially expensive queries. Avoid unrestricted exact counts on large tables; use `pg_stat_user_tables.n_live_tup` for initial sizing.
8. Validate results with at least one independent check, such as reconciling totals, checking null rates, comparing distinct users before and after joins, or testing a second formulation.

Useful discovery queries:

```sql
SELECT schemaname, relname AS table_name, n_live_tup AS estimated_rows
FROM pg_stat_user_tables
ORDER BY schemaname, relname;

SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'analytics_events'
ORDER BY ordinal_position;

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'analytics_events';

SELECT jsonb_object_keys(properties) AS property_key, count(*)
FROM public.analytics_events
WHERE event_name = '<event>'
  AND event_time >= '<bounded start>'
  AND event_time < '<bounded end>'
  AND deleted_at IS NULL
GROUP BY 1
ORDER BY 2 DESC;
```

Do not select raw `properties`, `payload`, `content`, or equivalent fields to discover their structure.

## Apply metric-specific checks

- Event analysis: distinguish `user_uid`, `anonymous_id`, and `session_id`; state the identity rule used. Do not assume an event name or JSON property meaning without inspecting it.
- Acquisition analysis: use `user_marketing_attributions`, define first-touch versus latest-touch, and filter or segment retargeting explicitly.
- Revenue analysis: distinguish `user_payments` from `user_purchases`, define successful/verified status, exclude revoked or deleted records where appropriate, and never sum across different `price_unit` currencies.
- Retention analysis: define the cohort event and return event, use complete observation windows, and disclose whether anonymous activity is included.
- Chat analysis: aggregate message metadata such as counts, roles, kinds, and timing. Never retrieve message `content` or room preview text.
- Idolive analysis: define completion from observed status and/or `completed_at`; do not assume all created sessions represent completed play.

## Report results

Respond in the user's language. Include:

- The direct answer and key numbers.
- Metric definitions, period, timezone assumption, filters, and identity rule.
- A compact result table or trend summary.
- The SQL used, with no credentials or sensitive literal values.
- Data-quality caveats, small-cohort suppression, and validation performed.

Clearly distinguish measured facts from interpretation. If the available data cannot support a reliable conclusion, say so rather than substituting assumptions.
