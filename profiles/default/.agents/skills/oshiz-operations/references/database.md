# 오시즈 데이터베이스

## 환경과 연결

작업 대상 환경 하나를 먼저 확정한다. `dev`, `stg`, `prd`는 각각 dev, staging, production을 뜻한다.

| 환경 키 | RDS Proxy 접두사      |
| ------- | --------------------- |
| `dev`   | `eevee-dev-db-proxy-` |
| `stg`   | `eevee-stg-db-proxy-` |
| `prd`   | `eevee-prd-db-proxy-` |

오시즈의 모든 환경은 `eevee` 데이터베이스와 `eevee_ro` 조회 계정을 사용한다. 연결 전 `vivident-infrastructure` 스킬과 AWS 레퍼런스를 읽고, 그곳의 범용 RDS 도구로 1회성 `--query` 명령을 실행한다.

```bash
bun <인프라-스킬-디렉터리>/scripts/connect-rds.ts --proxy-prefix eevee-prd-db-proxy- --db-name eevee --db-user eevee_ro --profile vivident --region us-west-2 --query 'SELECT current_database(), current_user' --statement-timeout 30000
```

환경별 Proxy 접두사를 대상에 맞게 바꾸며, 대화형 셸이나 별도 SQL 파일은 사용하지 않는다.

## 발견과 분석

1. 지표, 기간, 시간대, 모집단, 분석 차원, 식별 기준을 정한다. 모호함이 결과를 실질적으로 바꿀 때만 질문한다.
2. `information_schema`, `pg_catalog`에서 관련 테이블·열·자료형·enum·키·제약·인덱스를 찾는다. `pg_stat_user_tables`의 추정 행 수로 규모를 살핀다.
3. 짧은 기간의 집계로 시각·상태·NULL 분포와 조인 키의 유일성·관계 수를 검증한다. JSON은 원문 대신 키·자료형을 확인한다.
4. 검증한 쿼리의 기간을 필요한 범위로 넓힌다. 비용이 큰 쿼리는 `ANALYZE` 없는 `EXPLAIN`으로 확인하고 무제한 전체 개수 조회를 피한다.
5. 총계 대조나 독립적인 집계로 결과를 검증하고, 지표 정의·기간·필터·검증 내용과 한계를 보고한다.

## 운영 데이터 접근 제한

- `SELECT`, 카탈로그 조회, `ANALYZE` 없는 `EXPLAIN`만 실행한다.
- DDL, DML, `CALL`, `DO`, `COPY ... PROGRAM`, 유지보수 명령, advisory lock, 데이터를 바꾸는 함수를 실행하지 않는다.
- 데이터베이스·역할·스키마·권한·세션 기본값을 변경하지 않는다.
