---
name: oshiz-operations
description: "비비던트에서 운영하는 오시즈의 서비스 운영과 데이터 분석을 수행한다. 장애 대응, 배포·릴리스, 고객 지원, 제품 운영, 지표·사용자 행동 분석이 필요할 때 사용한다."
---

# 오시즈 운영

오시즈는 Vivident가 운영하는 미연시 게임이다.

## 작업 경로 선택

- 앱, 인프라, 배포, 장애, 릴리스, 제품, 자산, 카탈로그, 프롬프트 작업은 `~/Workspaces/vivident/eevee`의 오시즈 프로젝트를 사용한다. 체크아웃이 있는지 확인하고 루트와 관련 디렉터리 지침을 읽은 뒤 프로젝트 내부 스킬과 현재 설정을 따른다.
- 지표, 퍼널, 리텐션, 매출, 사용자 행동, 이벤트, 채팅, Idolive, 코호트, 고객 지원 조사에 운영 데이터가 필요하면 [references/data-analysis.md](references/data-analysis.md)와 [references/data-model.md](references/data-model.md)를 읽는다.

## 서비스 운영 경계 유지

- 고객 계정, 결제, 이용 권한, 보상, 콘텐츠를 임의의 DB 쓰기로 수정하지 않는다.
- 운영 데이터의 개인정보·읽기 전용 제약은 데이터 분석 참고 문서에 둔다.
