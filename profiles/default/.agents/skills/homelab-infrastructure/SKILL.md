---
name: homelab-infrastructure
description: 개인 홈랩의 클러스터, 네트워크, 스토리지, 가상화 호스트, GPU 서버, CI 기기, 모니터링을 관리한다. 홈랩 서비스의 설정·배포·진단·백업·복구 작업에 사용한다.
---
# 홈랩 관리 가이드

작업 시 먼저 다음 인벤토리에서 대상 리소스, 관리 정본, SSH 별칭을 확인한다.

| 구분             | 부모      | 용도                                                                                    | SSH 별칭           | 관리 위치                                                  | 비고                                               |
| -------------- | ------- | ------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------------------ | ------------------------------------------------ |
| openmediavault | -       | - smb<br>- nfs<br>- docker<br>  - garage s3<br>  - syncthing<br>  - borgmatic (외부 백업) | `openmediavault` | 직접 관리                                                  | - borgmatic 을 통해 외부 hetzner storage box 로 주기적 백업 |
| opnsense       | -       | - 라우터<br>- 방화벽<br>- VPN<br>- 외부 인터넷에서 접근 지점                                           | `opnsense`       | 직접 관리                                                  | -                                                |
| proxmox        | -       | 홈랩·CI VM 하이퍼바이저                                                                       | `xeon`           | 직접 관리                                                  | - openmediavault 로 주기적 백업                        |
| ubuntu-gpu     | -       | - LLM 서버                                                                              | `ubuntu-gpu`     | `~/Workspaces/tinyrack/ubuntu-b70` (Ansible)           | - Intel B70 x 2                                  |
| homelab-k3s    | proxmox | - 홈랩 쿠버네티스                                                                            | `homelab`        | `~/Workspaces/tinyrack/homelab` (GitOps, `ansible/`)   | -                                                |
| ubuntu-ci      | proxmox | - Github self hosted runner (Linux)                                                   | `ubuntu-ci`      | `~/Workspaces/tinyrack/ansible-github-actions-runners` | -                                                |
| macmini        | -       | - Github self hosted runner (Mac)                                                     | `macmini`        | `~/Workspaces/tinyrack/ansible-github-actions-runners` | -                                                |
| windows-ci     | proxmox | - Github self hosted runner (Windows)                                                 | `windows-ci`     | `~/Workspaces/tinyrack/ansible-github-actions-runners` | -                                                |

부모가 있다는 것은 가상 환경(VM, LXC 등)임을 의미한다. 필요한 경우 SSH 별칭으로 접속하여 기기를 제어한다.

---

## 저장소가 있는 리소스의 관리

Git 저장소가 있는 리소스는 해당 저장소 가이드를 따른다. 일반적으로 다음의 절차를 통해 저장소 지침을 파악한다.

1. `AGENTS.md`가 있으면 읽는다.
2. `README.md`가 있으면 읽는다.
3. `.agents/skills` 가 있다면 필요한 내용을 읽는다.

만약 저장소에서 머신 설정이 관리된다면 SSH를 통한 제어는 임시 진단에만 사용한다.

---

## 저장소가 없는 리소스의 관리

Git 관리 위치가 없는 리소스는 다음 레퍼런스 문서를 읽고 작업한다.

| 작업                                                   | 하위 문서                                                        |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| NAS, SMB, NFS, Garage S3, Syncthing, borgmatic       | [references/openmediavault.md](references/openmediavault.md) |
| OPNsense 설정, 방화벽·VPN 경계, Cloudflare 공개 경로, Tailscale | [references/opnsense.md](references/opnsense.md)             |
| Proxmox 관리                                           | [references/proxmox.md](references/proxmox.md)               |

---

## 외부 인프라의 관리

클라우드플레어(Cloudflare), 헤츠너(Hetzner) 등 홈랩에서 활용되는 외부 인프라 제어 필요 시 하위 문서([references/external](references/external.md))를 읽고 작업한다.

---


## 메트릭·로그·트레이스 분석

Grafana에 수집되는 데이터는 대시보드나 Explore에서 먼저 조회한다. 같은 시간대와 대상을 기준으로 메트릭의 이상 징후, 관련 로그, 트레이스의 지연·실패 구간을 연결해 확인한다.

알림(Alert) 확인이 필요하면 `himalaya` cli 도구를 통해 `stalwart-admin@winetree94.com` 메일함을 확인한다.

데이터가 없으면 인벤토리의 SSH 별칭으로 대상 머신에 접속하거나 쿠버네티스에서 직접 확인한다.

- **메트릭:** 머신의 자원 사용량과 서비스 상태를 확인한다. 현재 상태만으로 과거 상태를 단정하지 않는다.
- **로그:** `journalctl`, 컨테이너 로그, `kubectl --context <context> logs` 등으로 원본을 조회한다.
- **트레이스:** 미수집 시 요청 ID와 시각으로 서비스별 로그를 연결해 호출 흐름을 추적한다. 기록이 부족하면 확인 가능한 범위를 명시한다.

원래 수집되던 데이터가 끊겼다면 수집기와 전송 경로도 점검한다.

