# 오시즈 staging 환경

프로젝트 환경 키는 `stg`, AWS 리전은 `us-west-2`, 데이터베이스 이름은 `eevee`다.

## 데이터베이스

staging은 비공개 RDS PostgreSQL이며 RDS Proxy에서 IAM 인증을 사용한다. 조회와 분석에는 `eevee_ro`를 사용한다. WARP, 베스천, SSM 포트 포워딩은 사용하지 않는다.

```bash
bun ~/.agents/skills/oshiz-operations/scripts/db-connect.ts staging
```

스크립트는 `vivident` 프로필, `us-west-2`, 사설 DNS, TCP 5432, IAM 인증과 `eevee / eevee_ro / on`을 검증한 뒤 대화형 `psql`을 연다. 검증에 실패하면 셸을 열지 않는다. 실제 조회도 읽기 전용 트랜잭션 안에서 실행한다.

## 기타 인프라

Sentry 등 DB 이외의 접근 절차는 실제 접근법을 검증한 뒤 이 문서에 직접 추가한다.
