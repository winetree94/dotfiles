# Oshiz Production Data Model

This reference was verified through read-only catalog queries on 2026-07-30. Treat it as an orientation map, not a fixed contract; inspect the live catalog before analysis.

## Schemas

| Schema | Observed purpose |
| --- | --- |
| `public` | Users, analytics, sessions, attribution, economy, purchases, progression, quests, and product state |
| `dm_chat` | Direct chat rooms, messages, read state, and notification attempts |
| `admin_support_dm` | Support chat rooms, messages, and templates |
| `idolive` | Idola and promise-date sessions, scenes, choices, reports, and rewards |
| `memory` | Episodic, event, and semantic memories; content is sensitive |
| `studio` | Studio administration and content tooling |
| `drizzle` | Database migration metadata; not an analytics source |

## Primary analysis tables

| Question | Start with | Important fields and cautions |
| --- | --- | --- |
| Product events and funnels | `public.analytics_events` | `event_name`, `event_time`, `user_uid`, `anonymous_id`, `session_id`, `route`, `platform`, `app_version`, `locale`, `properties`; filter `deleted_at` and inspect JSON keys, not raw values |
| Identity stitching | `public.analytics_identities` | Maps `anonymous_id` to `user_uid`; check first/identified/last-seen timing and `deleted_at` |
| Registration and user lifecycle | `public.users` | `created_at`, `last_activity_at`, `status`, withdrawal timestamps; contains direct PII that must not be selected |
| App sessions | `public.user_app_sessions` | `started_at`, `ended_at`, `duration_seconds`, `last_route`, `metadata`; validate incomplete sessions and `deleted_at` |
| Acquisition | `public.user_marketing_attributions` | Provider, media source, campaign hierarchy, channel, first launch, retargeting, install/click/touch times; `raw_payload` and provider user IDs are sensitive |
| Payments | `public.user_payments` | Provider verification lifecycle, status, paid price, currency unit, purchase/verification/revocation times; receipt and transaction fields are sensitive |
| Purchases and grants | `public.user_purchases` | Product dimensions, status, paid/spent amounts and units, granted resources, `purchased_at`; do not mix currencies or paid and virtual spend |
| Current progression | `public.user_stats` | Level, cumulative experience, currencies, stamina, and current state; this is a snapshot, not a history table |
| Progression history | `public.user_stat_logs` | Use for state changes over time; inspect live columns and bound the time range before querying |
| Actions and counters | `public.user_action_events`, `public.user_action_counters`, `public.user_action_flags` | Inspect action semantics and uniqueness before defining activity or conversion |
| Idolive sessions | `idolive.idola_sessions` | User, event, character, status, turns, language, created/completed times; JSON context is sensitive and unnecessary for most aggregate analysis |
| Direct chat | `dm_chat.rooms`, `dm_chat.messages` | Aggregate room/message metadata only; never select message content, room previews, gift payloads, or stable IDs |

## Scale notes

At verification time, the largest observed tables included about 2.0M analytics events, 567K stat logs, 507K user-item rows, 496K user-character rows, 341K action events, and 208K direct messages. These are approximate planner statistics, not exact counts. Always use bounded predicates and re-check current estimates.

## Common join keys

- `user_uid` commonly links user-owned records to `public.users.uid`.
- `session_id` links event/session activity only after confirming format and uniqueness in both tables.
- `payment_uid` on purchases can link to `public.user_payments.uid`; confirm whether retries or multiple grants create one-to-many relationships.
- `room_uid` links direct messages to `dm_chat.rooms.uid`.
- Idolive and chat tables may reference each other through DM room/message UUIDs; inspect nullability and cardinality before joining.

Names indicate likely relationships but do not prove business semantics. Confirm keys, constraints, null rates, and sample-free distributions through catalog and aggregate queries.
