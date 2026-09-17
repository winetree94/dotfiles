---
name: homelab-infrastructure
description: 개인 홈랩의 클러스터, 네트워크, 스토리지, 가상화 호스트, GPU 서버, CI 기기를 관리한다. 홈랩 서비스의 설정·배포·진단·백업·복구 작업에 사용한다.
---

# 홈랩 관리 가이드

작업 시 먼저 다음 인벤토리에서 대상 리소스, 관리 정본, SSH 별칭을 확인한다.

| 구분             | 부모      | 용도                                                                                    | SSH 별칭           | 관리 위치                                                  | 비고                                               |
| -------------- | ------- | ------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------------------ | ------------------------------------------------ |
| openmediavault | -       | - smb<br>- nfs<br>- docker<br>  - garage s3<br>  - syncthing<br>  - borgmatic (외부 백업) | `openmediavault` | 기기 직접 관리                                               | - borgmatic 을 통해 외부 hetzner storage box 로 주기적 백업 |
| opnsense       | -       | - 라우터<br>- 방화벽<br>- VPN<br>- 외부 인터넷에서 접근 지점                                           | `opnsense`       | 기기 직접 관리                                               | -                                                |
| proxmox        | -       | 홈랩·CI VM 하이퍼바이저                                                                       | `xeon`           | 기기 직접 관리                                               | - openmediavault 로 주기적 백업                        |
| ubuntu-gpu     | -       | - LLM 서버                                                                              | `ubuntu-gpu`     | `~/Workspaces/tinyrack/ubuntu-b70` (Ansible)           | - Intel B70 x 2                                  |
| homelab-k3s    | proxmox | - 홈랩 쿠버네티스                                                                            | `homelab`        | `~/Workspaces/tinyrack/homelab` (GitOps, `ansible/`)   | -                                                |
| ubuntu-ci      | proxmox | - Github self hosted runner (Linux)                                                   | `ubuntu-ci`      | `~/Workspaces/tinyrack/ansible-github-actions-runners` | -                                                |
| macmini        | -       | - Github self hosted runner (Mac)                                                     | `macmini`        | `~/Workspaces/tinyrack/ansible-github-actions-runners` | -                                                |
| windows-ci     | proxmox | - Github self hosted runner (Windows)                                                 | `windows-ci`     | `~/Workspaces/tinyrack/ansible-github-actions-runners` | -                                                |

부모가 있다는 것은 가상 환경(VM, LXC 등)임을 의미한다. 필요한 경우 SSH 별칭으로 접속하여 기기를 제어한다.

## 저장소 관리 리소스

관리 위치가 Git 저장소인 리소스는 해당 저장소 가이드를 따른다.

1. `AGENTS.md`가 있으면 읽는다.
2. `README.md`가 있으면 읽는다.
3. `.agents/skills` 에서 필요한 내용을 읽는다.

저장소 지침이 없거나 현재 구성과 맞지 않으면 추측해서 변경하지 않는다. 저장소와 실제 상태를 읽기 전용으로 확인하고 누락된 지침을 보고한다.

- `ubuntu-gpu`: `~/Workspaces/tinyrack/ubuntu-b70`에서 `AGENTS.md`, `README.md`, `Makefile`, 인벤토리, 관련 역할, 선택한 `profiles/<model>/`을 읽는다. SSH를 통한 영구 변경은 사용하지 않는다.
- `homelab-k3s`: `~/Workspaces/tinyrack/homelab`에서 `AGENTS.md`와 관련 Flux 매니페스트를 읽는다. `kubectl`을 사용할 때는 항상 컨텍스트를 `homelab`으로 명시한다.
- CI 러너: `~/Workspaces/tinyrack/ansible-github-actions-runners`에서 `README.md`, `Makefile`, 인벤토리와 관련 역할을 읽는다. 세 운영체제 기기가 같은 저장소를 공유하므로 인벤토리에서 대상과 플랫폼 그룹을 확인한다.

SSH를 통한 제어는 저장소 관리 리소스의 임시 진단에만 사용한다. 영구 변경은 저장소가 정의한 재현 가능하고 멱등한 절차로 수행한다.

## 기기 직접 관리 리소스

Git 관리 위치가 없는 리소스는 다음 레퍼런스를 읽고 작업한다.

| 작업                                                   | 하위 문서                                                        |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| NAS, SMB, NFS, Garage S3, Syncthing, borgmatic       | [references/openmediavault.md](references/openmediavault.md) |
| OPNsense 설정, 방화벽·VPN 경계, Cloudflare 공개 경로, Tailscale | [references/opnsense.md](references/opnsense.md)             |
| Proxmox 관리                                           | [references/proxmox.md](references/proxmox.md)               |

## 교차 리소스 경계

두 관리 정본에 걸친 변경은 관련 문서와 실제 설정을 모두 읽고 경계를 넘는 대상을 명시한다.

- 홈랩과 NAS: Garage와 Syncthing은 NAS의 Docker 서비스이고, 클러스터의 프록시 경로는 홈랩 GitOps가 관리한다. 앱 데이터베이스·Longhorn 백업 설정은 홈랩이, Garage 버킷과 NAS 파일 백업은 OpenMediaVault가 관리한다.
- 홈랩과 OPNsense: 공개 진입 경계와 Cloudflare Tunnel은 OPNsense가, 클러스터 내부 연결과 커넥터 매니페스트는 홈랩 GitOps가 관리한다.
- Proxmox와 게스트: VM 하드웨어·디스크·수명 주기는 Proxmox가, 게스트 OS와 워크로드는 홈랩 또는 러너 저장소가 관리한다.
- GPU와 모니터링: GPU 저장소가 호스트·추론 메트릭 수집을, 홈랩이 중앙 수집·저장과 대시보드를 관리한다. 원본 설정과 대시보드 변경을 같은 저장소 작업으로 취급하지 않는다.

연결 장애는 관련 관리 정본을 확인한 뒤 DNS, 클라이언트 라우팅, 프록시 경로, 백엔드 도달 가능성, 방화벽·Cilium 정책 순으로 추적한다. 문서에 오래된 주소가 있다는 이유만으로 포트를 열거나 경로를 바꾸지 않는다.
