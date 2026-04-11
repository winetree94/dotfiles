# SearXNG API Examples

Base instance:

- `https://search.winetree94.com`

## Basic JSON search

```bash
curl -sS 'https://search.winetree94.com/search?q=opentelemetry+semantic+conventions&format=json'
```

## Limit to a domain

```bash
curl -sS 'https://search.winetree94.com/search?q=site:opentelemetry.io+semantic+conventions&format=json'
```

## Search recent material

```bash
curl -sS 'https://search.winetree94.com/search?q=nodejs+release+notes&time_range=year&format=json'
```

## Use a category

```bash
curl -sS 'https://search.winetree94.com/search?q=sqlite+wal+mode&categories=it&format=json'
```

## Inspect result fields

Common top-level fields in JSON responses:

- `query`
- `number_of_results`
- `results`
- `answers`
- `suggestions`
- `infoboxes`
- `unresponsive_engines`

Common fields inside `results[]`:

- `title`
- `url`
- `content`
- `engine`
- `engines`
- `category`
- `publishedDate`
- `score`

## Extract top URLs

```bash
curl -sS 'https://search.winetree94.com/search?q=site:developer.mozilla.org+fetch+AbortSignal&format=json' \
  | jq -r '.results[:5][] | .url'
```

## Extract a compact table

```bash
curl -sS 'https://search.winetree94.com/search?q=site:docs.python.org+asyncio+timeout&format=json' \
  | jq -r '.results[:10][] | [.engine, .title, .url] | @tsv'
```

## Notes

- Use `GET` for simple queries.
- Use `POST` when query strings are long or you want cleaner command composition.
- Search results are only a discovery step. Fetch the destination pages before making strong claims.
