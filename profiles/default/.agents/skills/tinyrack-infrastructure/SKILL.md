---
name: tinyrack-infrastructure
description: "Tinyrack의 Hetzner Kubernetes 클라우드 인프라를 관리한다. 해당 환경의 서비스 배포, 네트워크 설정, 장애 진단, 백업·복구 작업에 사용한다."
---

# Tinyrack 인프라

## 대상과 담당 범위

| 리소스 | 대상 |
| --- | --- |
| GitOps 저장소 | `~/Workspaces/tinyrack/infrastructure` |
| Kubernetes 컨텍스트 | `tinyrack` |
| SSH 호스트 | `tinyrack-server` |
| 호스트 자동화 | 저장소 내부 `ansible/` |

명시된 사용자 대상을 우선하고 없으면 이 표를 사용해 인프라 명령 전에 대상을 알린다. `kubectl --context tinyrack`와 명시적인 Flux 컨텍스트를 사용한다. Tinyrack 조직 소속이거나 Issuary 같은 서비스명만으로 이 클러스터라고 판단하지 않는다. 모호하면 요청한 배포나 호스트명을 확인한다.

편집 전에 저장소 지침, README, 브랜치, 작업 트리 변경을 확인한다. 활성 서비스는 `apps/overlays/production/kustomization.yaml`에서 찾는다. README 목록은 매니페스트보다 오래됐을 수 있다. 무관한 변경을 보존하고 비밀 정보는 출력·Git에서 제외한다.

## Hetzner 리소스

클러스터는 Hetzner에서 운영한다. 다음 표로 대상을 찾고 변경 전에 현재 리소스 식별자, 서버 유형·위치, Floating IP 할당을 조회한다.

| 리소스 | 식별자 |
| --- | --- |
| hcloud 컨텍스트 | `winetree94` |
| 서버 이름 / ID | `tinyrack` / `115687231` |

같은 컨텍스트에 `mail-server`도 있으므로 컨텍스트만으로 환경을 선택할 수 없다. `hcloud --context winetree94`를 명시하고 리소스 식별 정보와 의도한 환경을 모두 대조한다.

```sh
hcloud context list
hcloud --context winetree94 server list -o columns=id,name,status,type,location
hcloud --context winetree94 floating-ip list -o json | jq '[.[] | {id, name, server}]'
```

Hetzner 서버와 공급자 측 Floating IP 생성·삭제·할당은 `hcloud`로 관리한다. 변경 전에 관련 명령 도움말을 확인한다. 호스트 OS·게스트 내부 IP는 Ansible, Kubernetes는 GitOps, Cloudflare DNS·Tunnel은 `cf`로 관리한다. 기본 IP를 알고 있어도 Tunnel 전용 외부 접근 정책을 우회할 수는 없다.

이 스킬과 참고 문서에는 관련 사설·내부 IP와 서브넷 CIDR을 유지한다. 서버 기본 공인 IP와 Floating IP 값을 포함한 실제 외부 공인 IP·대역은 기록하지 않는다. 컨텍스트, 호스트명, 리소스 이름·ID로 식별하고 필요할 때 현재 공급자 설정에서 주소를 조회한다.

## 오브젝트 스토리지

Object Storage 버킷·객체는 `hcloud`가 아닌 `rclone`으로 관리한다. 아래 경로를 현재 CNPG ObjectStore·Longhorn BackupTarget과 대조한다. `hetzner_fsn:` 원격은 리전 `fsn1`, 엔드포인트 `https://fsn1.your-objectstorage.com`을 사용한다.

| 용도 | rclone 경로 |
| --- | --- |
| CNPG 백업 | `hetzner_fsn:tinyrack-prod/apps/<app>/<database-prefix>` |
| Longhorn 백업 | `hetzner_fsn:tinyrack-prod/longhorn` |

개별 작업 전에 현재 ObjectStore에서 앱·데이터베이스 접두 경로를 찾는다. 버킷은 메일 서버와 공유하며 메일 경로는 `clusters/public/` 아래다. `tinyrack-prod` 전체를 이 클러스터 전용으로 취급하거나 클러스터 하나의 작업에 전체 버킷 동기화·삭제를 수행하지 않는다.

`hetzner_hel:`도 설정되어 있다. 리전은 `hel1`, 엔드포인트는 `https://hel1.your-objectstorage.com`이다. 사용 전에 요청 대상에 맞는 원격을 확인한다. 서버 위치가 아닌 실제 스토리지 엔드포인트로 선택한다. 두 Hetzner 원격 모두 `env_auth = true`와 비공개 객체·버킷 ACL을 사용한다. 인증 정보를 노출하지 않고 준비하고 `rclone listremotes`를 확인한다. `rclone lsf hetzner_fsn:tinyrack-prod/apps/ --dirs-only`처럼 범위를 좁혀 조회한다.

비공개 ACL을 보존하고 삭제·`rclone sync` 전에 정확한 영향을 확인한다. Kubernetes 백업 정의는 GitOps로 관리한다. 버킷·객체 관리는 CNPG·Longhorn 복구 절차를 대신하지 않는다. Storage Box와 블록 Volume은 별도 상품이다.

## GitOps 변경

- Flux는 `clusters/production`을 감시한다. 인프라와 앱은 각각 `infrastructure/overlays/production`, `apps/overlays/production`을 반영하며 앱은 인프라에 의존한다.
- 관련 base와 필요한 오버레이 항목을 수정한다. 변경 base와 영향받는 오버레이는 각각 `kubectl kustomize`로 렌더링한다. Flux 초기 구축 디렉터리는 Kustomize 빌드 루트가 아니다.
- Helm 수명 주기는 HelmRelease 매니페스트에, values는 인접 values 파일·ConfigMap에 둔다. 기존 ConfigMap 해시·감시 라벨 관례를 따른다.
- 새 비밀 정보는 이 저장소의 `tinyrack-production-key.crt`로 암호화한다. 메일 저장소의 같은 이름 인증서는 호환되지 않는다. 평문 인증 정보나 개인 키를 커밋하지 않는다.
- 영구 변경은 Git·Flux로 전달한 뒤 소스 리비전, 관련 Kustomization·HelmRelease 준비 상태, 롤아웃, 서비스 상태를 확인한다.

진단은 클러스터·호스트의 읽기 전용 조회로 한다. 직접 운영 상태를 바꾸는 것은 명시적 요청이나 분명한 긴급 대응에 한정한다. 이유와 정확한 범위를 먼저 밝히고 영구 목표 상태를 Git에 반영한다. 파괴적·운영 영향 작업 전에는 대상을 확인한다. 지원되는 호스트 변경은 기존 Ansible Vault·become 절차를 사용한다. 대화로 비밀번호를 요청하지 않는다. Vivident sudo 위임 규칙은 해당 클러스터 호스트에만 적용된다.

## 모니터링

`tinyrack`, `homelab`, `mail-server`의 메트릭·로그·트레이스는 홈랩에 모여 홈랩 Grafana에서 표시한다. Tinyrack도 공통 Grafana를 쓰고 실제 데이터 소스·라벨 설정에 따라 쿼리를 tinyrack 클러스터로 한정한다.

대시보드는 홈랩 Grafana 컨텍스트를 선택한 `gcx` CLI로 관리한다. 현재 도움말을 읽고 변경 전에 인스턴스, 대시보드, 데이터 소스를 확인한다. Tinyrack 전용 Grafana가 있다고 가정하지 않는다. 원본 수집기·전송 설정은 이 저장소에서 GitOps로 관리한다. 공통 수집·저장, Grafana, 대시보드 조사·변경에는 `homelab-infrastructure`를 읽는다.

## 네트워크와 복구

`forum.tinyrack.net`, `auth.tinyrack.net` 등 공개 서비스는 Cloudflare Tunnel로만 접근한다. 원본 공인 IP 직접 접근은 차단한다. 배포·진단·복구에서도 이 경계를 유지한다. 터널을 우회하려고 공개 앱·관리 포트를 열거나 원본 직결 DNS를 만들지 않는다. SSH·Kubernetes API 관리는 별도로 Tailscale을 사용한다. 문서화된 Cilium 호스트 방화벽은 공용 `eth0`의 TCP 인그레스를 차단한다.

Cloudflare DNS·Tunnel은 설치된 `cf` CLI로 관리한다. `cf --help`, 관련 하위 명령 도움말, `cf schema --help`로 현재 API를 확인하고 터널 명령 문법을 지어내지 않는다. 변경 전에 계정·프로필, 영역, 호스트명, 터널을 확인하며 가능하면 `--profile`, `--zone`을 명시한다. 현재 DNS, 터널 경로, 커넥터 상태를 먼저 확인한다. Cloudflare 설정은 `cf`, Kubernetes가 관리하는 커넥터·원본 설정은 이 GitOps 저장소를 사용한다. API 토큰·터널 인증 정보를 출력하지 않는다.

현재 Cloudflare 커넥터, Traefik 경로, 백엔드 엔드포인트, Cilium 정책으로 장애 위치를 찾는다. Cloudflare 설정 작업은 관련 Cloudflare 스킬도 읽는다. 호스트 방화벽 변경 전에는 저장소의 `reserved:host` PolicyAuditMode와 판정 관찰 절차를 따른다. 감사 모드는 Cilium 재시작 후 유지되지 않는다. 긴급 복구는 Tailscale 또는 Hetzner 콘솔과 Git 롤백을 사용한다. 문서화된 절차에서 요구할 때만 관련 Flux 리소스를 중단·재반영한다.

초기 구축, 호스트 교체, 데이터 복구는 [references/recovery.md](references/recovery.md)를 읽는다. 홈랩 백업 목적지 변경에는 `homelab-infrastructure`를 사용하며 앱 백업 작업은 이 저장소가 담당한다. 메일 워크로드는 `mail-server-infrastructure`가 담당한다.

확정한 대상, Git 변경, 직접 수행한 운영 작업, 검증 근거와 미완료 전달·복구 단계를 보고한다.
