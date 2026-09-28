---
name: oshiz-operations
description: "비비던트에서 운영하는 오시즈의 서비스 운영과 데이터 분석을 수행한다. 장애 대응, 배포·릴리스, 고객 지원, 제품 운영, 지표·사용자 행동 분석이 필요할 때 사용한다."
---

# 오시즈 운영

오시즈는 Vivident가 운영하는 미연시 게임이다.

## 공통 원칙

- AWS 인프라 접근의 정본은 `vivident-infrastructure` 스킬이다. 프로필은 `vivident`, 리전은 `us-west-2`를 사용하며 로컬에 프로필이 없거나 호출자 신원을 확인할 수 없으면 작업을 중단한다.
- 프로젝트 설정이나 리소스의 현재 상태가 필요하면 해당 관리 정본과 실제 AWS 조회 결과를 확인한다. 이 스킬에 교체 가능한 리소스 ID나 프로젝트 설정을 복제하지 않는다.

## 배포 환경 선택

작업 대상 환경 하나를 확정하고 해당 문서만 읽는다. 내부 환경 키는 `dev`, `stg`, `prd`를 사용하지만 사용자 표시 이름과 문서명은 각각 dev, staging, production이다.

| 배포 환경 | 프로젝트 환경 키 | 문서 |
| --- | --- | --- |
| dev | `dev` | [references/dev.md](references/dev.md) |
| staging | `stg` | [references/staging.md](references/staging.md) |
| production | `prd` | [references/production.md](references/production.md) |

환경이 불명확하고 선택에 따라 외부 상태나 조회 데이터가 달라지면 진행 전에 사용자에게 확인한다. 다른 환경의 엔드포인트, 리소스 ID, 자격 증명을 재사용하지 않는다.

지표, 퍼널, 리텐션, 매출, 사용자 행동, 이벤트, 채팅, Idolive, 코호트, 고객 지원 조사에는 [references/data-analysis.md](references/data-analysis.md)를 추가로 읽는다. 스키마와 업무 의미는 분석 시작 시 실제 데이터베이스와 코드에서 확인한다.

환경별 DB 접속은 각 환경 문서의 Bun 헬퍼 명령을 사용한다. 헬퍼는 `vivident`/`us-west-2`, Proxy DNS·TCP, IAM `eevee_ro`, 읽기 전용 검증을 수행한 뒤 대화형 `psql`을 연다.

## 서비스 운영 경계 유지

- 고객 계정, 결제, 이용 권한, 보상, 콘텐츠를 임의의 DB 쓰기로 수정하지 않는다.
- 운영 데이터의 개인정보·읽기 전용 제약은 데이터 분석 참고 문서에 둔다.
