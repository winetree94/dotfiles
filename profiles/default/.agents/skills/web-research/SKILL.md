---
name: web-research
description: "웹에서 정보를 찾고 출처를 검토·비교해 근거를 수집한다. 최신 정보 확인, 공식 자료 탐색, 사실 검증, 출처에 근거한 답변이 필요할 때 사용한다."
allowed-tools: Bash(curl:*) Bash(jq:*)
---

# 웹 조사

페이지를 자세히 읽기 전에 웹에서 자료를 찾을 때 사용한다.

이 환경의 기본 검색 백엔드:

- 기본 URL: `https://search.winetree94.com`
- 검색 엔드포인트: `https://search.winetree94.com/search`
- 지원 메서드: `GET`, `POST`
- 우선할 응답 형식: `json`

## 백엔드 가용성과 대체 경로

SearXNG를 먼저 사용한다. 예를 들어 `curl --fail --connect-timeout 10 --max-time 30`처럼 연결·전체 시간 제한을 두고 HTTP 성공 여부와 JSON 응답을 모두 확인한다. 파이프 사용 시 `set -o pipefail`로 실패 상태를 보존한다.

`search.winetree94.com`이 연결·DNS·TLS 오류, 시간 초과, 접근 오류, 요청 제한(HTTP 429), 서버 오류 또는 검색 JSON 대신 사용할 수 없는 응답을 반환하면 실패를 간단히 알리고 Serper를 사용한다. 유효한 검색 결과가 비어 있는 것은 장애가 아니므로 먼저 검색어를 다듬는다.

## 사용 시점

- 주제에 맞는 출처 찾기.
- 공식 문서, 변경 이력, 이슈, 블로그 글 발견.
- 넓은 주제를 소수 후보 URL로 좁히기.
- 인용·요약 전에 여러 출처 비교.

출처에 근거한 결론이 필요하면 검색 결과에서 멈추지 않는다. 검색 후 가장 적합한 페이지를 가져와 읽는다.

## 핵심 절차

1. 요청을 구체적인 검색어 1~3개로 바꾼다.
2. SearXNG JSON을 먼저 조회하고 사용할 수 없으면 허용된 Serper 대체 경로를 사용한다.
3. 가장 유용한 URL을 추린다.
4. `WebFetch`로 선택한 페이지의 읽기 쉬운 본문을 가져온다.
5. 정확성이 중요하면 핵심 주장을 여러 출처로 교차 확인한다.
6. URL과 함께 결과를 보고하고 출처가 다르면 불확실성을 밝힌다.

## 검색 API

SearXNG는 `GET /search`, `POST /search`, `GET /`, `POST /`를 지원한다.

필수 매개변수는 검색어 `q`다. 유용한 선택 매개변수:

- `format=json`: 기계가 읽기 쉬운 결과.
- `categories=general,news,science,it`: 쉼표로 구분한 카테고리.
- `engines=google,bing,duckduckgo`: 필요할 때 지정하는 검색 엔진 목록.
- `language=en`: 결과 언어.
- `pageno=1`: 페이지 번호.
- `time_range=day|month|year`: 엔진이 지원하면 최근 자료로 제한.
- `safesearch=0|1|2`: 안전 검색 수준.

## 권장 명령 형식

간단한 검색:

```bash
curl -sS 'https://search.winetree94.com/search?q=rust+borrow+checker&format=json'
```

카테고리·기간 조건 검색:

```bash
curl -sS 'https://search.winetree94.com/search?q=postgres+17+release+notes&categories=it&time_range=year&format=json'
```

POST 폼 요청:

```bash
curl -sS -X POST 'https://search.winetree94.com/search' \
  -d 'q=site:docs.python.org pathlib relative_to' \
  -d 'format=json'
```

`jq`로 제목·URL 추출:

```bash
curl -sS 'https://search.winetree94.com/search?q=site:github.com+searxng+search+api&format=json' \
  | jq -r '.results[] | [.title, .url] | @tsv'
```

상위 결과만 확인:

```bash
curl -sS 'https://search.winetree94.com/search?q=site:developer.mozilla.org+AbortController&format=json' \
  | jq -r '.results[:5][] | .url'
```

## Serper API 대체 경로

- 엔드포인트: `POST https://google.serper.dev/search`.
- 인증: `SERPER_API_KEY`를 `X-API-KEY` 헤더로 전달.
- 요청: `q`를 포함한 JSON. 선택적 `num`으로 결과 수 제한.
- 일반 검색 결과: `.organic[]`의 `title`, `link`, `snippet`. SearXNG의 `.results[]`, `url`, `content`와 다름.

값을 출력하지 않고 환경 변수 설정 여부를 확인한다. 키를 하드코딩하거나 파일에 쓰지 않는다. 인증 호출에서 셸 추적이나 상세 HTTP 로그를 켜지 않는다. 검색어를 JSON 문자열에 직접 끼워 넣지 말고 `jq`로 인코딩한다.

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

Serper 결과에도 같은 출처 선별·페이지 조회 절차를 적용한다. SearXNG 전용 `engines`, `categories`, `time_range`를 그대로 전달하지 않는다. 필터가 필요하면 Serper가 지원하는 매개변수를 확인한다.

## 검색어 작성

넓은 검색어보다 구체적인 검색어를 우선한다.

- 공식 문서: `site:docs.example.com feature name`.
- GitHub 이슈: `site:github.com/org/repo/issues exact error text`.
- 릴리스 노트: `product version release notes`.
- 비교: `topic A vs B official benchmark`.
- 디버깅: 정확한 오류 문구와 프레임워크·라이브러리 이름.

첫 결과가 부실하면 `site:` 공식 도메인 제한, 제품·패키지·저장소 이름, 버전 번호, `time_range` 기간 조건을 추가한다.

## 결과 선별

해당하면 다음 순서로 출처를 우선한다.

1. 공식 문서.
2. 프로젝트 저장소와 이슈 추적기.
3. 1차 발표와 릴리스 노트.
4. 신뢰할 만한 2차 설명.

긁어 모은 콘텐츠 사이트, AI 요약, 1차 근거 없이 주장을 반복하는 페이지는 주의한다.

## 검색 후 페이지 가져오기

URL을 찾으면 `WebFetch`로 실제 본문을 읽는다. 보통 SearXNG JSON 또는 장애 시 Serper로 검색하고, URL 2~5개를 추린 뒤 가장 적합한 후보를 읽는다. 가져온 페이지가 뒷받침하는 내용만 요약한다.

## 결과 보고

- 실제로 확인한 페이지 URL을 인용한다.
- 직접적인 근거와 추론을 구분한다.
- 검색 결과가 부족하거나 서로 충돌하면 알린다.
- 최신성이 중요한지와 `time_range` 사용 여부를 밝힌다.

## 참고 문서

- [SearXNG API 예시](references/searxng-api-examples.md)
- [출처 평가 체크리스트](references/source-evaluation-checklist.md)
