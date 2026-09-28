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

오시즈 전용 AWS 리소스는 이 문서에서 직접 관리하지 않고 [oshiz-operations](../../oshiz-operations/SKILL.md)를 따른다. 인트라넷 백업과 오브젝트 스토리지의 구성은 인트라넷 저장소를 정본으로 삼는다.

## Tailscale 서브넷 라우터

비공개 AWS 리소스에는 private subnet의 전용 EC2 한 대를 Tailscale 서브넷 라우터로 두고 접근한다. 공인 IP를 부여하지 않으며 VPC CIDR `10.0.0.0/16`을 tailnet에 광고한다. WARP, 베스천, 별도 relay 계층은 사용하지 않는다.

라우터는 AWS CLI로 직접 생성하며 다음 조건을 유지한다.

- IAM instance profile에 `AmazonSSMManagedInstanceCore`를 부착한다. SSM은 복구·진단용이며 평상시 DB 포워딩 경로가 아니다.
- 라우터 보안 그룹 인바운드는 비워 둔다. RDS Proxy·Redis·NATS 보안 그룹에서 라우터 보안 그룹으로 필요한 포트만 허용한다.
- source/destination check를 끄고 IPv4·IPv6 forwarding을 켠다.
- Tailscale 등록은 운영자가 Session Manager 셸에서 수동 수행한다. auth key를 문서나 user-data에 저장하지 않는다.
- Tailscale DNS 설정에서 us-west-2.rds.amazonaws.com 질의는 VPC Resolver 10.0.0.2로 보내도록 split DNS를 구성한다. 로컬 PC의 /etc/hosts, 라우팅, resolver 설정은 변경하지 않는다.

인스턴스 생성 뒤 `tailscaled`와 forwarding 상태를 확인한다. 운영자는 Session Manager 셸에서 다음 명령을 직접 실행하고 Tailscale 관리 화면에서 subnet route를 승인한다.

```bash
sudo tailscale up \
  --advertise-routes=10.0.0.0/16 \
  --snat-subnet-routes=true \
  --accept-dns=false
```

장비에서 `tailscale status`가 로그인 상태이고 `10.0.0.0/16` 경로가 활성화된 것을 확인한다. 라우터를 교체할 때는 새 인스턴스와 보안 그룹·라우팅을 검증한 뒤 기존 노드를 제거한다.

## 비공개 RDS PostgreSQL 연결

비공개 RDS는 공개 접근으로 전환하지 않는다. Tailscale 서브넷 라우터를 통해 RDS Proxy 엔드포인트로 직접 연결하고, 실제 Proxy 호스트명을 대상으로 RDS IAM 토큰을 발급한다. SSM 포트 포워딩이나 로컬 relay를 사용하지 않는다.

RDS Proxy가 DUAL 네트워크 타입이면 일반 DNS가 IPv6 주소를 우선 반환할 수 있다. 클라이언트의 로컬 설정을 바꾸지 말고 Tailscale split DNS를 통해 AWS VPC Resolver가 사설 IPv4 주소를 반환하도록 한다. 확인 명령은 다음과 같다.

```bash
dig +short A @10.0.0.2 <rds-proxy-endpoint>
nc -4 -vz <rds-proxy-endpoint> 5432
```

### RDS 대상 확인

대상 DB 인스턴스의 엔드포인트, 데이터베이스 이름, VPC와 보안 그룹을 확인한다.

```bash
aws --profile vivident --region us-west-2 rds describe-db-instances \
  --db-instance-identifier <db-instance-identifier> \
  --query 'DBInstances[0].{Endpoint:Endpoint.Address,Port:Endpoint.Port,DBName:DBName,Public:PubliclyAccessible,Vpc:DBSubnetGroup.VpcId,SecurityGroups:VpcSecurityGroups[*].GroupId}' \
  --output json
```

`Public`이 `false`이면 공개 접근을 활성화하거나 광범위한 인바운드 규칙을 추가하지 않는다. Tailscale 라우터 보안 그룹이 RDS 보안 그룹의 PostgreSQL 포트에 허용되어 있는지 확인한다.

```bash
aws --profile vivident --region us-west-2 ssm describe-instance-information \
  --query 'InstanceInformationList[?PingStatus==`Online`].{Id:InstanceId,Platform:PlatformName,LastPing:LastPingDateTime}' \
  --output table
```

선택한 인스턴스의 네트워크 경로와 보안 그룹이 RDS 보안 그룹의 PostgreSQL 포트에 허용되어 있어야 한다. 인스턴스 이름이나 ID를 추측하지 않고 조회 결과와 관리 정본에서 대상을 확정한다.

### IAM 토큰으로 직접 접속

실제 RDS Proxy 엔드포인트를 대상으로 IAM 토큰을 발급하고 해당 호스트로 직접 접속한다. 토큰이나 접속 정보를 셸 기록, 문서, 작업 보고에 남기지 않는다.

```bash
dbhost='<rds-endpoint>'

PGPASSWORD="$(
  aws --profile vivident --region us-west-2 rds generate-db-auth-token \
    --hostname "$dbhost" \
    --port 5432 \
    --username <db-user>
)" \
psql \
  "host=$dbhost port=5432 dbname=<db-name> user=<db-user> sslmode=require" \
  --no-psqlrc \
  --set ON_ERROR_STOP=1 \
  --command 'select current_database(), current_user, version();'
```

연결 결과의 데이터베이스와 사용자가 예상과 다르면 즉시 세션을 종료하고 쓰기 작업을 하지 않는다. IAM 토큰은 짧은 시간만 유효하므로 만료되면 새로 발급한다. 별도로 `PGPASSWORD`를 설정했다면 작업 후 제거한다.

```bash
unset PGPASSWORD
```

### 문제 해결

- `tailscale status`가 로그아웃 상태: 운영자가 라우터에서 `tailscale up`을 다시 실행하고 관리 화면에서 경로를 승인한다.
- 직접 연결 timeout: 로컬 tailnet 경로, 라우터 forwarding, RDS와 라우터의 보안 그룹, 라우팅, NACL을 확인한다.
- `TargetNotConnected` 또는 SSM 권한 오류: 라우터의 IAM instance profile과 SSM 관리형 상태를 확인한다.
- `PAM authentication failed` 또는 `rds-db:connect` 거부: DB 사용자의 `rds_iam` 구성원 여부와 IAM 정책을 확인한다.
- `database does not exist`: RDS 조회 결과의 `DBName`과 접속 명령의 데이터베이스 이름을 비교한다.
- 연결 확인 결과가 예상과 다름: 작업을 중단하고 대상 식별자와 관리 정본을 다시 확인한다.

## 공식 문서

- [AWS CLI 구성 및 자격 증명](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS CLI `sts get-caller-identity`](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html)
- [Amazon RDS IAM 데이터베이스 인증](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
- [AWS CLI `start-session`](https://docs.aws.amazon.com/cli/latest/reference/ssm/start-session.html)
- [AWS CLI `generate-db-auth-token`](https://docs.aws.amazon.com/cli/latest/reference/rds/generate-db-auth-token.html)
