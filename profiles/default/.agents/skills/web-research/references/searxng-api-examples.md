# SearXNG API 예시

기본 인스턴스: `https://search.winetree94.com`.

## 기본 JSON 검색

```bash
curl -sS 'https://search.winetree94.com/search?q=opentelemetry+semantic+conventions&format=json'
```

## 도메인 제한

```bash
curl -sS 'https://search.winetree94.com/search?q=site:opentelemetry.io+semantic+conventions&format=json'
```

## 최근 자료 검색

```bash
curl -sS 'https://search.winetree94.com/search?q=nodejs+release+notes&time_range=year&format=json'
```

## 카테고리 사용

```bash
curl -sS 'https://search.winetree94.com/search?q=sqlite+wal+mode&categories=it&format=json'
```

## 결과 필드 확인

JSON 응답의 일반적인 최상위 필드:

- `query`
- `number_of_results`
- `results`
- `answers`
- `suggestions`
- `infoboxes`
- `unresponsive_engines`

`results[]` 내부의 일반적인 필드:

- `title`
- `url`
- `content`
- `engine`
- `engines`
- `category`
- `publishedDate`
- `score`

## 상위 URL 추출

```bash
curl -sS 'https://search.winetree94.com/search?q=site:developer.mozilla.org+fetch+AbortSignal&format=json' \
  | jq -r '.results[:5][] | .url'
```

## 간단한 표 추출

```bash
curl -sS 'https://search.winetree94.com/search?q=site:docs.python.org+asyncio+timeout&format=json' \
  | jq -r '.results[:10][] | [.engine, .title, .url] | @tsv'
```

## 참고 사항

- 간단한 검색은 `GET`을 사용한다.
- 검색 문자열이 길거나 명령 구성을 깔끔하게 하고 싶으면 `POST`를 사용한다.
- 검색 결과는 출처를 찾는 단계일 뿐이다. 확정적인 주장을 하기 전에 대상 페이지를 가져와 읽는다.
