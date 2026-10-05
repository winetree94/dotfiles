---
name: oshiz-operations
description: "비비던트(vivident)에서 운영하는 오시즈(oshiz)의 서비스 운영과 데이터 분석을 수행한다. 장애 대응, 배포·릴리스, 고객 지원, 제품 운영, 지표·사용자 행동 분석이 필요할 때 사용한다."
---

# 오시즈 운영

오시즈는 Vivident가 운영하는 미연시 게임이다.

## 공통 원칙

- AWS·네트워크·RDS·Sentry 인프라에 접근하기 전 [vivident-infrastructure 스킬](../vivident-infrastructure/SKILL.md)과 필요한 레퍼런스를 먼저 읽는다. 인프라 연결 절차와 자격 증명 규칙은 해당 스킬을 따른다.
- 프로젝트 설정이나 리소스의 현재 상태가 필요하면 해당 관리 정본과 실제 AWS 조회 결과를 확인한다. 이 스킬에 교체 가능한 리소스 ID나 프로젝트 설정을 복제하지 않는다.

## 운영 레퍼런스

오시즈 데이터나 지표를 다루는 작업은 [references/database.md](references/database.md), 오류·성능 조사는 [references/sentry.md](references/sentry.md)를 읽는다.

## 서비스 운영 경계 유지

- 고객 계정, 결제, 이용 권한, 보상, 콘텐츠를 임의의 DB 쓰기로 수정하지 않는다.
- 운영 데이터의 개인정보·읽기 전용 제약은 데이터 분석 참고 문서에 둔다.
