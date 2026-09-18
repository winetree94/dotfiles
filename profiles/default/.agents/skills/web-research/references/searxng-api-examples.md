# SearXNG API 예시

Serper를 사용할 수 없을 때 사용하는 대체 검색 백엔드다.

- 기본 URL: `https://search.winetree94.com`
- 검색 엔드포인트: `https://search.winetree94.com/search`
- 지원 메서드: `GET`, `POST`
- 응답 형식: `format=json`

연결·전체 시간 제한을 두고 HTTP 성공 여부와 JSON 응답을 모두 확인한다. 파이프를 사용하면 `set -o pipefail`로 실패 상태를 보존한다.

연결·DNS·TLS 오류, 시간 초과, 접근 오류, HTTP 429/5xx 또는 검색 JSON 대신 사용할 수 없는 응답은 백엔드 실패다. 유효한 JSON 검색 결과가 비어 있는 것은 장애가 아니므로 검색어를 먼저 다듬는다.

## 기본 JSON 검색

```bash
set -o pipefail
curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
  'https://search.winetree94.com/search?q=opentelemetry+semantic+conventions&format=json' \
  | jq -e '.results | arrays' >/dev/null
```

## 도메인 제한

```bash
curl -sS 'https://search.winetree94.com/search?q=site:opentelemetry.io+semantic+conventions&format=json'
```

## POST 폼 요청

```bash
curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
  -X POST 'https://search.winetree94.com/search' \
  -d 'q=site:docs.python.org pathlib relative_to' \
  -d 'format=json'
```

## 최근 자료 검색

```bash
curl -sS 'https://search.winetree94.com/search?q=nodejs+release+notes&time_range=year&format=json'
```

## 카테고리 사용

```bash
curl -sS 'https://search.winetree94.com/search?q=sqlite+wal+mode&categories=it&format=json'
```

## 검색 매개변수

필수 매개변수는 `q`다. 필요할 때 다음 선택 매개변수를 사용한다.

- `format=json`: 기계가 읽을 수 있는 응답.
- `categories=general,news,science,it`: 쉼표로 구분한 카테고리.
- `engines=google,bing,duckduckgo`: 검색 엔진 목록.
- `language=en`: 결과 언어.
- `pageno=1`: 페이지 번호.
- `time_range=day|month|year`: 엔진이 지원하는 경우 기간 제한.
- `safesearch=0|1|2`: 안전 검색 수준.

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
- SearXNG의 결과 필드와 매개변수는 Serper 요청에 그대로 사용할 수 없다.
- 검색 결과는 출처를 찾는 단계일 뿐이다. 확정적인 주장을 하기 전에 대상 페이지를 가져와 읽는다.
