# Vivident AWS 관리 가이드

회사 공통 AWS 리소스는 AWS CLI로 관리한다. 운영 서비스는 `us-west-2` 리전에 있으며 모든 명령에 `--profile vivident --region us-west-2`를 명시한다. 프로필 기본값이나 현재 셸의 `AWS_PROFILE`, `AWS_REGION`에 의존하지 않는다.

## 작업 전 확인

먼저 AWS CLI와 `vivident` 프로필이 로컬에 있는지 확인한다. 프로필이 없으면 새 프로필을 만들거나 다른 프로필로 대체하지 말고 작업을 중단해 사용자에게 설정을 요청한다.

```bash
aws --version
aws configure list-profiles
```

`vivident` 프로필이 있으면 지정된 프로필과 리전으로 호출자 신원을 확인한다. 인증 만료, 권한 부족 등으로 확인에 실패해도 AWS 작업을 중단하고 오류를 사용자에게 전달한다.

```bash
aws --profile vivident --region us-west-2 sts get-caller-identity
```

반환된 계정과 ARN이 요청 대상과 일치하는지 확인한 뒤 진행한다. 대상이 다른 리전에 있다고 보이거나 `us-west-2`에서 발견되지 않으면 다른 리전을 탐색하지 말고 요청과 관리 정본을 다시 확인한다.

## 리소스 관리

먼저 리소스를 관리하는 저장소와 IaC가 있는지 확인한다. 관리 정본이 있으면 직접 변경하지 않고 해당 저장소의 지침과 배포 절차를 따른다. 직접 관리하는 리소스도 변경 전에 현재 상태와 정확한 식별자를 조회하고, 명령의 프로필과 리전을 생략하지 않는다.

조회 결과에 운영 서비스의 엔드포인트, 계정 ID 등 민감할 수 있는 값이 포함되면 필요한 필드만 출력하고 문서나 작업 보고에 그대로 복사하지 않는다. 삭제, 교체, 공개 접근 허용처럼 복구가 어렵거나 노출 범위를 넓히는 변경은 요청 범위를 재확인한다.

서비스 전용 AWS 리소스는 이 문서에서 직접 관리하지 않고 해당 서비스의 관리 정본을 따른다. 인트라넷 백업과 오브젝트 스토리지의 구성은 인트라넷 저장소를 정본으로 삼는다.

## Private 네트워크 접근

AWS 리소스는 주로 VPC CIDR `10.0.0.0/16` 의 Private Subnet 을 사용한다. 그래서 기본적으로 공개 경로로 접근할 수 없다.
그래서 해당 네트워크 망에 연결된 EC2 인스턴스에 Tailscale 서브넷 라우터가 배포되어 있다.
이 노드는 공인 IP를 부여하지 않으며 VPC CIDR `10.0.0.0/16`을 tailnet에 광고한다.
내부망 `opnsense` 가 Tailscale 에 연결되어 해당 VPC CIDR 을 라우팅하므로, 내부망에서는 특별한 조치 없이 AWS에 접근할 수 있다.
외부망인 경우에만 Tailscale 연결이 필요하다.

## 범용 RDS 연결 도구

비공개 PostgreSQL RDS Proxy의 IAM 인증 연결과 읽기 전용 SQL 실행은 [connect-rds.ts](../scripts/connect-rds.ts)를 사용한다. 대상 Proxy 접두사, 데이터베이스 이름, DB 사용자, AWS 프로필과 리전을 인자로 전달하므로 서비스별 환경을 추가할 수 있다.

```bash
cd <인프라-스킬-디렉터리>/scripts
bun install
bun run typecheck

bun connect-rds.ts \
  --proxy-prefix <rds-proxy-name-prefix> \
  --db-name <database> \
  --db-user <iam-db-user> \
  --profile <aws-profile> \
  --region <aws-region> \
  --check
```

`--check`, `--query`, `--file`, stdin 중 하나만 사용한다.
스크립트는 Proxy가 정확히 하나인지, 사설 IPv4와 PostgreSQL 포트로 연결되는지, IAM 인증과 예상 데이터베이스·사용자·읽기 전용 상태가 맞는지 확인한다.
SQL은 읽기 전용 트랜잭션으로 실행하며 IAM 토큰은 출력하거나 명령 인자에 넣지 않는다. 공개 접근 전환, SSM 포트 포워딩, 로컬 relay는 사용하지 않는다.

