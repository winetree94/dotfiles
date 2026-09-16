---
name: web-research
description: Research, inspect, extract, and enumerate web content with a private SearXNG instance, falling back to the Serper API when SearXNG is unavailable. Use when an agent needs to search the web, discover sources, inspect candidate pages, and gather evidence efficiently.
allowed-tools: Bash(curl:*) Bash(jq:*)
---

# Web Research

Use this skill when you need web discovery before reading pages in detail.

Primary search backend for this environment:

- Base URL: `https://search.winetree94.com`
- Search endpoint: `https://search.winetree94.com/search`
- Supported methods: `GET` and `POST`
- Preferred response format: `json`

This instance has been verified to respond to `format=json`.

## Backend availability and fallback

Use SearXNG first. Bound requests with connection and total timeouts (for example,
`curl --fail --connect-timeout 10 --max-time 30`) and check both HTTP success and
the JSON response. Preserve failure status when piping commands with
`set -o pipefail`.

If `search.winetree94.com` is unavailable because of connection/DNS/TLS failures,
timeouts, access errors, rate limiting (HTTP 429), server errors, or an unusable
response instead of search JSON, briefly report the failure and use Serper.
An empty but valid search result is not an outage; refine the query first.

## When to use it

Use this skill for:

- finding relevant sources for a topic
- discovering official docs, changelogs, issues, or blog posts
- narrowing broad topics into a small set of candidate URLs
- comparing multiple sources before citing or summarizing them

Do not stop at search results alone when the task needs source-backed conclusions. Search first, then fetch and inspect the best pages.

## Core workflow

1. Convert the task into 1 to 3 targeted search queries.
2. Query SearXNG JSON results first; use the authorized Serper fallback if unavailable.
3. Extract the highest-signal URLs.
4. Fetch the selected pages with `WebFetch` for readable content.
5. Cross-check important claims across more than one source when accuracy matters.
6. Return findings with URLs and note uncertainty when sources disagree.

## Search API

SearXNG supports `GET /search`, `POST /search`, `GET /`, and `POST /`.

Required parameter:

- `q`: search query

Useful optional parameters:

- `format=json`: machine-readable results
- `categories=general,news,science,it`: comma-separated categories
- `engines=google,bing,duckduckgo`: comma-separated engines when needed
- `language=en`: result language
- `pageno=1`: page number
- `time_range=day|month|year`: recent material when supported by engines
- `safesearch=0|1|2`: safe-search level

## Preferred command patterns

Simple search:

```bash
curl -sS 'https://search.winetree94.com/search?q=rust+borrow+checker&format=json'
```

Search with categories and time range:

```bash
curl -sS 'https://search.winetree94.com/search?q=postgres+17+release+notes&categories=it&time_range=year&format=json'
```

POST form request:

```bash
curl -sS -X POST 'https://search.winetree94.com/search' \
  -d 'q=site:docs.python.org pathlib relative_to' \
  -d 'format=json'
```

Extract titles and URLs with `jq`:

```bash
curl -sS 'https://search.winetree94.com/search?q=site:github.com+searxng+search+api&format=json' \
  | jq -r '.results[] | [.title, .url] | @tsv'
```

Inspect top results only:

```bash
curl -sS 'https://search.winetree94.com/search?q=site:developer.mozilla.org+AbortController&format=json' \
  | jq -r '.results[:5][] | .url'
```

## Serper API fallback

- Endpoint: `POST https://google.serper.dev/search`
- Authentication: `X-API-KEY` header populated from `SERPER_API_KEY`.
- Request: JSON with `q`; optional `num` limits requested results.
- Organic results: `.organic[]` with `title`, `link`, and `snippet` (not
  SearXNG's `.results[]`, `url`, and `content`).

Check that the environment variable is set without printing its value. Do not
hardcode the key, write it into files, or enable shell tracing or verbose HTTP
logging around authenticated calls. Use `jq` to encode queries as JSON rather
than interpolating them into a JSON string:

```bash
set -o pipefail
: "${SERPER_API_KEY:?Set SERPER_API_KEY before using the Serper fallback}"
jq -nc --arg q 'site:docs.python.org pathlib relative_to' '{q: $q, num: 5}' \
  | curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
      'https://google.serper.dev/search' \
      -H "X-API-KEY: ${SERPER_API_KEY}" \
      -H 'Content-Type: application/json' \
      --data-binary @- \
  | jq -r '.organic[:5][] | [.title, .link, (.snippet // "")] | @tsv'
```

Apply the same source triage and page-fetching workflow to Serper results. Do
not forward SearXNG-specific parameters such as `engines`, `categories`, or
`time_range` unchanged; check Serper's supported parameters when those filters
are needed.

## Query construction guidance

Prefer focused queries over broad ones.

- official docs: `site:docs.example.com feature name`
- GitHub issues: `site:github.com/org/repo/issues exact error text`
- release notes: `product version release notes`
- comparisons: `topic A vs B official benchmark`
- debugging: exact error string plus framework or library name

When the first query is weak, refine by adding one of:

- an official domain restriction with `site:`
- the product, package, or repo name
- a version number
- a time constraint using `time_range`

## Result triage

Prefer sources in this order when applicable:

1. official documentation
2. project repositories and issue trackers
3. primary announcements or release notes
4. reputable secondary explanations

Be cautious with scraped content farms, AI-generated summaries, and pages that repeat claims without primary evidence.

## Fetching pages after search

After discovering URLs, use `WebFetch` to read the actual page content.

Typical pattern:

1. search with SearXNG JSON, or Serper when SearXNG is unavailable
2. extract 2 to 5 URLs
3. fetch the strongest candidates
4. summarize only what the fetched pages support

## Reporting expectations

When returning research results:

- cite the page URLs you actually inspected
- distinguish direct evidence from inference
- mention if search results were sparse or conflicting
- mention if freshness matters and whether you used `time_range`

## References

- [SearXNG API examples](references/searxng-api-examples.md)
- [Source evaluation checklist](references/source-evaluation-checklist.md)
