# 오시즈 production 환경

프로젝트 환경 키는 `prd`, AWS 리전은 `us-west-2`, 데이터베이스 이름은 `eevee`다. 대상 환경을 추측하지 않는다.

## 데이터베이스

production은 비공개 RDS PostgreSQL이며 RDS Proxy에서 IAM 인증을 사용한다. 운영 분석에는 반드시 `eevee_ro`를 사용한다. WARP, 베스천, SSM 포트 포워딩은 사용하지 않는다.

```bash
aws configure list-profiles | rg -x vivident
aws --profile vivident --region us-west-2 sts get-caller-identity
psql --version

db_proxy=$(aws --profile vivident --region us-west-2 rds describe-db-proxies \
  --query 'DBProxies[?starts_with(DBProxyName, `eevee-prd-db-proxy-`)].Endpoint | [0]' --output text)
test -n "$db_proxy" && test "$db_proxy" != None
PGPASSWORD="$(aws --profile vivident --region us-west-2 rds generate-db-auth-token \
  --hostname "$db_proxy" --port 5432 --username eevee_ro)" PGCONNECT_TIMEOUT=15 psql \
  "host=$db_proxy port=5432 dbname=eevee user=eevee_ro sslmode=require" \
  --no-psqlrc --set ON_ERROR_STOP=1 \
  --command "begin transaction read only; select current_database(), current_user, current_setting('transaction_read_only'); rollback;"
```

결과는 `eevee`, `eevee_ro`, `on`이어야 한다. 다르면 쿼리하지 않는다. `PGOPTIONS`는 사용하지 않으며 실제 분석도 읽기 전용 트랜잭션 안에서 실행한다. 연결 시간 초과 시 `tailscale status`와 광고된 경로를 확인한다.

## 기타 인프라

Sentry 등 DB 이외의 접근 절차는 실제 접근법을 검증한 뒤 이 문서에 직접 추가한다.
