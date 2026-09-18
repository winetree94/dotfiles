---
name: web-research
description: "웹에서 정보를 찾고 출처를 검토·비교해 근거를 수집한다. 최신 정보 확인, 공식 자료 탐색, 사실 검증, 출처에 근거한 답변이 필요할 때 사용한다."
allowed-tools: Bash(curl:*) Bash(jq:*)
---

# 웹 조사

검색 결과를 근거로 삼기 전에 원문 페이지를 확인하고, 실제로 확인한 URL을 인용한다. 검색은 다음 순서로 한다.

## 1. 기본 검색: Serper

Serper를 첫 번째 검색 백엔드로 사용한다.

- 엔드포인트: `POST https://google.serper.dev/search`
- 인증: 환경 변수 `SERPER_API_KEY`를 `X-API-KEY` 헤더로 전달한다.
- 요청 본문: `q`를 포함한 JSON. 필요하면 Serper가 지원하는 선택 필드를 추가한다.
- 결과: `.organic[]`의 `title`, `link`, `snippet`을 확인한다.

키를 출력하거나 하드코딩하지 말고, 셸 추적과 상세 HTTP 로그를 사용하지 않는다. 검색어는 `jq --arg`로 JSON 인코딩한다.

```bash
set -o pipefail
: "${SERPER_API_KEY:?Set SERPER_API_KEY before using Serper}"
jq -nc --arg q 'site:docs.python.org pathlib relative_to' '{q: $q, num: 5}' \
  | curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
      'https://google.serper.dev/search' \
      -H "X-API-KEY: ${SERPER_API_KEY}" \
      -H 'Content-Type: application/json' \
      --data-binary @- \
  | jq -r '.organic[:5][] | [.title, .link, (.snippet // "")] | @tsv'
```

서비스 장애, 할당량 소진으로 Serper를 사용할 수 없는 경우 실패 원인을 간단히 기록하고 SearXNG로 전환한다. 검색 결과가 비어 있는 것은 백엔드 장애가 아니므로 검색어를 먼저 다듬는다.

## 2. 대체 검색: SearXNG

위 조건으로 Serper를 사용할 수 없을 때만 SearXNG를 사용한다. 엔드포인트와 매개변수, 오류 처리, 예시는 [SearXNG API 레퍼런스](references/searxng-api-examples.md)를 읽는다.

## 공통 조사 절차

1. 질문을 구체적인 검색어 1~3개로 바꾼다. 공식 문서는 `site:`와 제품·버전을 활용한다.
2. 검색 결과에서 신뢰할 만한 URL 2~5개를 추린다.
3. 선택한 페이지의 원문을 가져온다. `WebFetch`가 제공되면 사용하고, 이 스킬의 허용 도구만 사용할 수 있는 환경에서는 `curl`로 가져온 뒤 필요한 본문을 추출한다.
4. 정확성이 중요하면 공식 문서·릴리스 노트·저장소 등 여러 출처로 핵심 주장을 교차 확인한다.
5. 직접 확인한 근거와 추론을 구분해 URL과 함께 보고하고, 부족하거나 충돌하는 근거는 명시한다.

출처는 공식 문서, 유지 관리자의 릴리스 노트·블로그, 소스 저장소·이슈, 신뢰할 만한 2차 설명 순으로 우선한다. 검색 순위만 높은 스팸, 작성자 불명 페이지, 오래된 버전 자료, 1차 근거 없는 요약은 주의한다. 자세한 점검표는 [출처 평가 체크리스트](references/source-evaluation-checklist.md)를 따른다.
