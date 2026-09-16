---
name: homelab-infrastructure
description: "개인 홈랩의 클러스터, 네트워크, 스토리지, 가상화 호스트, GPU 서버, CI 기기를 관리한다. 홈랩 서비스의 설정·배포·진단·백업·복구 작업에 사용한다."
---

# 홈랩 인프라

## 대상 확인

이 스킬과 참고 문서에는 관련 사설·내부 IP 주소와 서브넷 CIDR을 유지한다. 외부 공인 IP 주소나 주소 대역은 기록하지 않는다. 외부 공개 리소스는 컨텍스트, SSH 별칭, 호스트명, 리소스 이름·ID로 식별하고 필요한 주소는 현재 설정에서 조회한다.

| 대상 | `~/Workspaces` 아래 저장소 | 컨텍스트 | SSH 별칭 |
| --- | --- | --- | --- |
| 홈랩 클러스터 | `tinyrack/homelab` | `homelab` | `homelab` |
| NAS와 스토리지 서비스 | 기준 저장소 미확인. OMV·기기 설정 사용 | 없음 | `openmediavault` |
| Proxmox 하이퍼바이저 | 기준 저장소 미확인. Proxmox 설정 사용 | 없음 | `xeon` |
| Intel Arc Pro B70 두 장을 장착한 서버 | `tinyrack/ubuntu-b70` (Ansible) | 없음 | `ubuntu-gpu` |
| 개인 CI 기기 | `tinyrack/ansible-github-actions-runners` | 없음 | 해당 인벤토리에서 확인 |

사용자가 명시한 대상을 우선하고, 없으면 이 표와 현재 저장소 설정에서 찾는다. 인프라 명령 실행 전에 대상을 알린다. `kubectl --context <context>`와 명시적인 Flux 컨텍스트를 사용하며 현재 컨텍스트에 의존하지 않는다. n8n, SearXNG, Issuary는 다른 환경에도 있으므로 서비스명만으로 대상을 판단하지 않는다.

- 클러스터 내부 Traefik 경로, 로컬 라우팅, 환경 간 연결은 [references/proxy-network.md](references/proxy-network.md)를 읽는다.
- OPNsense, NAS·Garage·Syncthing·borgmatic, Proxmox 게스트, B70 GPU 서버, CI 기기는 [references/hosts-runners.md](references/hosts-runners.md)를 읽는다.
- 클러스터 초기 구축, 교체, 데이터 복구는 [references/recovery.md](references/recovery.md)를 읽는다.

## 오브젝트 스토리지

Garage는 Kubernetes 밖의 `openmediavault`에서 Docker로 실행된다. 홈랩 Traefik이 스토리지 엔드포인트를 NAS로 연결한다. Kubernetes 소비자와 프록시 설정은 홈랩 GitOps 저장소에서 관리한다. NAS 서비스 운영과 borgmatic 외부 백업은 [NAS와 스토리지](references/hosts-runners.md#openmediavault-nas-and-storage)에 설명되어 있다.

버킷과 객체는 `rclone`으로 관리한다. 설정된 원격 `homelab_garage:`는 리전 `home`, 엔드포인트 `https://storage.intranet.winetree94.com`을 사용한다. 환경 인증(`env_auth = true`)과 비공개 객체·버킷 ACL을 사용한다. 대상 스토리지에 맞는 인증 정보를 전달하되 출력하거나 스킬·Git에 저장하지 않는다.

다음 백업 경로로 대상을 찾고, 작업 전에 현재 CNPG ObjectStore 또는 Longhorn BackupTarget을 확인한다.

| 용도 | rclone 경로 |
| --- | --- |
| 앱 데이터베이스 백업 | `homelab_garage:tinyrack-homelab/apps/<app>/<database-prefix>` |
| Grafana 데이터베이스 백업 | `homelab_garage:tinyrack-homelab/infrastructure/monitoring/<grafana-database-prefix>` |
| Longhorn 백업 | `homelab_garage:tinyrack-homelab/clusters/tinyrack-homelab/longhorn` |

저장소의 OpenWebUI values도 이 엔드포인트에 `tinyrack-homelab-openwebui-storage` 버킷을 설정한다. 작업 전에 현재 앱 설정을 확인한다. `rclone listremotes`와 `rclone lsf homelab_garage:tinyrack-homelab/apps/ --dirs-only`처럼 범위를 좁힌 조회를 사용한다. PostgreSQL 버전을 고정해서 가정하지 말고 현재 ObjectStore에서 정확한 데이터베이스 접두 경로를 찾는다.

버킷 작업은 GitOps 백업 설정 및 CNPG·Longhorn 복구 절차와 구분한다. 요청한 버킷·접두 경로만 대상으로 삼고 비공개 ACL을 유지한다. 삭제나 `rclone sync`는 대상 객체를 지울 수 있으므로 영향을 먼저 확인한다. Garage 호스트·서비스 운영과 S3 버킷 관리는 별개다.

## 통합 모니터링

`mail-server`, `homelab`, `tinyrack`의 메트릭·로그·트레이스는 홈랩에 모이고 홈랩 Grafana에서 표시한다. 공통 수집·저장 인프라와 Grafana는 홈랩이, 각 원본 클러스터의 수집기와 전송 설정은 해당 클러스터가 관리한다.

Grafana 대시보드는 `gcx` CLI로 관리한다. `gcx --help`와 관련 하위 명령 도움말을 읽고 홈랩 Grafana 컨텍스트를 선택한다. 변경 전에 인스턴스, 대시보드, 데이터 소스를 확인한다. 실제 데이터 소스 식별자와 클러스터 라벨은 현재 설정에서 찾고, 클러스터마다 별도 Grafana가 있다고 가정하지 않는다. 대시보드는 `gcx`로, Kubernetes가 관리하는 모니터링 인프라는 GitOps로 변경한다.

텔레메트리가 누락되면 원본 수집기·익스포터, 전송 경로, 홈랩 수집·저장, Grafana 데이터 소스·쿼리 순으로 추적한다. 쿼리는 해당 원본 클러스터로 제한한다. 원본 설정의 조사·변경이 필요하면 `mail-server-infrastructure`나 `tinyrack-infrastructure`를 읽는다.

## 변경과 검증

홈랩 서비스는 원본 IP로 외부에서 직접 접근할 수 없어야 한다. OPNsense는 외부에서 시작된 비요청 접근을 차단하고, 공개 서비스는 Cloudflare Tunnel로만 제공한다. 원본을 직접 가리키는 DNS 레코드를 만들거나 WAN에 앱, SSH, Kubernetes API, NAS, 하이퍼바이저 포트를 열지 않는다. OPNsense 관리 인터페이스도 외부에 노출하지 않는다. 인바운드 포트 포워딩은 필요한 VPN 엔드포인트의 실제 포트·프로토콜에만 허용한다. VPN 포트를 추측하거나 무관한 서비스를 포워딩하지 않는다. 장애 조사와 복구에서도 이 제한을 유지한다.

Cloudflare DNS와 Tunnel은 설치된 `cf` CLI로 관리한다. `cf --help`, 하위 명령 도움말, `cf schema --help`로 현재 명령을 확인하고 변경 전에 계정·프로필, 영역, 호스트명, 터널을 식별한다. 가능한 경우 프로필·영역을 명시한다. Kubernetes가 관리하는 커넥터와 원본 서버 변경은 GitOps에 두며 `cf`를 OPNsense 방화벽 설정 도구로 사용하지 않는다.

편집 전에 저장소 지침, README, 브랜치, 작업 트리 변경을 확인한다. 클러스터·호스트의 읽기 전용 조회로 진단하고 무관한 변경을 보존한다. 인증 정보는 출력과 Git에서 제외한다.

영구 클러스터 설정은 원칙적으로 Git과 Flux를 거친다. 직접 운영 상태를 바꾸는 작업은 명시적인 요청이나 분명한 긴급 대응 필요가 있을 때만 한다. 이유와 범위를 먼저 밝히고 영구 변경을 Git에도 반영한다. 파괴적이거나 운영에 영향을 주는 작업 전에는 정확한 대상을 확인한다. 지원되는 호스트 변경은 저장소의 Ansible을 사용하며 기존 Vault·become 절차는 유효하다. 대화로 sudo 비밀번호를 요청하지 않는다. Vivident 클러스터 호스트의 sudo 위임 규칙은 이 개인 호스트들에 적용되지 않는다.

홈랩 클러스터 작업 기준:

- Flux는 `clusters/production`을 감시한다. `infrastructure`가 `infrastructure/overlays/production`을 먼저 반영하고, `apps`는 `dependsOn`을 통해 `apps/overlays/production`을 반영한다.
- 오버레이 `kustomization.yaml`에서 워크로드를 활성화한다. 대부분 항목은 `apps/base/<name>` 또는 `infrastructure/base/<name>`을 가리키는 Flux Kustomization 리소스다.
- 영향받는 오버레이와 변경한 base를 각각 `kubectl kustomize`로 렌더링한다. `clusters/production`을 Kustomize 루트로 렌더링하지 않는다. 검증 시 Helm·소스 의존성과 원격 리소스를 고려한다.
- README의 Helm values와 ConfigMap 관례를 따른다. 경로별 Traefik Cilium 정책은 해당 앱·프록시 옆에, 공통 진입점 정책은 인프라에 둔다.
- 저장소의 `tinyrack-homelab-secret-key.crt`로 비밀 정보를 암호화한다. `*.secret.yaml`이 JSON 형식 SealedSecret일 수 있으므로 kind를 확인하고 평문 Secret으로 바꾸지 않는다. 개인 키를 커밋하지 않는다.
- 저장소의 Git 절차로 변경을 전달한다. Flux 소스 리비전, 관련 Kustomization·HelmRelease 준비 상태, 롤아웃, 서비스 상태를 확인한다. 대상, Git 변경, 직접 수행한 운영 작업, 검증 근거를 보고한다.

홈랩에서 Vivident로 가는 경로는 LAN 클라이언트 → 홈랩 OPNsense → `vivident-tailscale-router` Pod → Tailscale → 회사 서브넷 라우터 → 회사 LAN이다. 내부 주소와 전달 설정은 [네트워크 상세](references/proxy-network.md#local-network-and-remote-sites)를 참고한다.

`vivident-tailscale-router`는 이름과 달리 홈랩 저장소가 관리한다. 회사 측 조사·변경도 필요할 때만 `vivident-infrastructure`를 함께 읽는다. 메일 워크로드는 `mail-server-infrastructure`, 클라우드 클러스터는 `tinyrack-infrastructure`를 사용하며 해당 리소스의 관리 책임을 홈랩으로 옮기지 않는다.
