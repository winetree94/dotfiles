---
name: mail-server-infrastructure
description: "개인 Hetzner 메일 서버와 웹메일, 메일 전달 환경을 관리한다. 메일 서버 설정·배포, DNS·TLS·송수신 장애 진단, 백업·복구 작업에 사용한다."
---

# 메일 서버 인프라

## 대상과 범위

| 리소스 | 대상 |
| --- | --- |
| GitOps 저장소 | `~/Workspaces/tinyrack/mail-server` |
| Kubernetes 컨텍스트 | `mail-server` |
| SSH 호스트 | `mail-server` |
| 호스트 자동화 | 저장소 내부 `ansible/` |
| 대표 메일 호스트명 | `mail.winetree94.com` |

명시된 사용자 대상을 우선하고, 없으면 표에서 대상을 찾아 인프라 명령 전에 알린다. `kubectl --context mail-server`와 명시적인 Flux 컨텍스트를 사용한다. Stalwart는 메일, Bulwark는 JMAP 웹메일을 제공한다. 활성 서비스와 경로는 현재 매니페스트에서 확인한다.

`mail.winetree94.com`의 DNS 등 Cloudflare 설정은 설치된 `cf` CLI로 관리한다. 명령 선택 전에 `cf --help`, 관련 하위 명령 도움말 또는 `cf schema --help`를 읽고 계정·프로필과 `winetree94.com` 영역을 확인한다. 가능한 경우 프로필·영역을 명시한다. `cf`는 Cloudflare 리소스, GitOps는 클러스터, Ansible은 호스트·게스트 내부 IP 설정, `hcloud`는 Hetzner 리소스 할당을 담당한다. 이 메일 환경에는 Tinyrack·홈랩의 Tunnel 전용 공개 정책을 적용하지 않는다. 메일 프로토콜에 필요한 DNS·네트워크 동작을 보존한다.

- 연결, DNS, TLS, 메일 전달 진단은 [references/mail-delivery.md](references/mail-delivery.md)를 읽는다.

## Hetzner 리소스

이 클러스터는 Hetzner에서 운영한다. 아래 표로 대상을 찾고 변경 전에 현재 리소스 식별자, 서버 유형·위치, Floating IP 할당, PTR, 삭제 보호를 조회한다.

| 리소스 | 식별자 |
| --- | --- |
| hcloud 컨텍스트 | `winetree94` |
| 서버 이름 / ID | `mail-server` / `115401154` |
| Floating IP 이름 / ID | `mail-server` / `147638286` |

같은 컨텍스트에 `tinyrack` 서버도 있다. 현재 활성 프로젝트만 보지 말고 컨텍스트를 명시해 의도한 리소스와 대조한다.

```sh
hcloud context list
hcloud --context winetree94 server list -o columns=id,name,status,type,location
hcloud --context winetree94 floating-ip list -o json | jq '[.[] | {id, name, server}]'
```

Hetzner 서버와 공급자 측 Floating IP 생성·삭제·할당·PTR 설정은 현재 도움말을 확인한 뒤 `hcloud`로 관리한다. 삭제 보호 해제가 요청 작업에 명시적으로 포함되지 않았다면 유지한다. Ansible은 할당된 IP를 게스트 OS 내부에 설정하며 공급자 측 할당을 대신하지 않는다. 메일 Floating IP와 서버 기본 IP를 구분하고 관련 변경 후 A/PTR/EHLO 일치 여부를 확인한다.

이 스킬과 참고 문서에는 관련 사설·내부 IP와 서브넷 CIDR을 유지한다. 서버 기본 공인 IP와 Floating IP 값을 포함해 실제 외부 공인 IP·대역은 기록하지 않는다. 컨텍스트, 호스트명, 리소스 이름·ID로 식별하고 필요할 때 현재 공급자 설정에서 주소를 조회한다.

## 오브젝트 스토리지

Object Storage 버킷·객체는 `hcloud`가 아닌 `rclone`으로 관리한다. 아래 경로를 현재 CNPG ObjectStore·Longhorn BackupTarget과 대조한다. `hetzner_fsn:` 원격은 리전 `fsn1`, 엔드포인트 `https://fsn1.your-objectstorage.com`을 사용한다. 서버 위치와 별개로 엔드포인트에 따라 스토리지를 선택한다.

| 용도 | rclone 경로 |
| --- | --- |
| Stalwart CNPG 백업 | `hetzner_fsn:tinyrack-prod/clusters/public/apps/stalwart/<database-prefix>` |
| Longhorn 백업 | `hetzner_fsn:tinyrack-prod/clusters/public/longhorn` |

현재 ObjectStore에서 데이터베이스 버전과 복구 원본을 재확인한다. `tinyrack-prod`는 Tinyrack 클러스터와 공유하며, Tinyrack은 메일 접두 경로 밖의 `apps/`, `longhorn/`을 사용한다. 메일 작업은 `clusters/public/`로 제한하고 공유 버킷 전체를 동기화하거나 삭제하지 않는다.

원격은 `env_auth = true`와 비공개 객체·버킷 ACL을 사용한다. 비밀 정보를 출력하거나 영구 저장하지 않고 해당 백엔드 인증을 준비한다. `rclone listremotes`를 확인하고 `rclone lsf hetzner_fsn:tinyrack-prod/clusters/public/ --dirs-only`처럼 범위를 좁혀 조회한다. 비공개 ACL을 보존하고 삭제·`rclone sync` 전에 정확한 영향을 확인한다. 백업 정의와 인증 정보 참조는 GitOps에 유지한다. 객체 복사만으로 데이터베이스를 완전히 복구했다고 판단하지 말고 서비스 복원에 CNPG·Longhorn 절차를 사용한다.

## 모니터링

`mail-server`, `homelab`, `tinyrack`의 메트릭·로그·트레이스는 홈랩에 모여 홈랩 Grafana에서 표시한다. 메일 서버도 공통 Grafana를 사용하며 실제 데이터 소스·라벨 설정에 따라 쿼리를 mail-server 클러스터로 한정한다.

대시보드는 홈랩 Grafana 컨텍스트를 선택한 `gcx` CLI로 관리한다. 현재 도움말을 읽고 변경 전에 인스턴스, 대시보드, 데이터 소스를 확인한다. 메일 서버 전용 Grafana가 있다고 가정하지 않는다. 원본 수집기·전송 설정은 이 저장소에서 GitOps로 관리한다. 공통 수집·저장, Grafana, 대시보드 조사·변경에는 `homelab-infrastructure`를 읽는다.

## 변경과 검증

저장소 지침, README, 브랜치, 작업 트리 변경을 확인한다. 호스트·클러스터를 읽기 전용으로 조사해 진단하고 무관한 변경은 보존한다. 인증 정보는 출력·Git에서 제외한다.

- Flux는 `clusters/production`을 감시한다. 인프라는 `infrastructure/overlays/production`, 앱은 인프라에 의존해 `apps/overlays/production`을 반영한다. 오버레이 목록으로 워크로드를 활성화·비활성화하고 관련 base를 수정한다.
- 변경 base와 영향받는 오버레이를 각각 `kubectl kustomize`로 렌더링한다. 초기 구축 디렉터리를 Kustomize 빌드 루트라고 가정하지 않는다.
- README의 Helm values·앱 설정 분리 관례를 따른다. 비밀 정보는 이 저장소의 `tinyrack-production-key.crt`로 암호화한다. 다른 클러스터에서 가져온 인증서나 Tinyrack 클라우드 저장소의 동명 파일을 쓰지 않는다.
- 영구 클러스터 변경은 원칙적으로 Git·Flux를 거친다. 직접 운영 상태를 바꾸려면 명시적 요청이나 분명한 긴급 필요가 있어야 한다. 이유와 정확한 범위를 먼저 알리고 영구 상태를 Git에 반영한다. 파괴적·운영 영향 작업 전에는 대상을 확인한다.
- 호스트와 게스트 내부 Floating IP는 기존 Ansible Vault·become 절차를 사용하고 Hetzner 측 할당은 `hcloud`로 한다. 대화로 비밀번호를 요청하거나 Vivident 클러스터 호스트의 sudo 위임 규칙을 적용하지 않는다.
- Flux 리비전·준비 상태, 롤아웃, 영향받는 스토리지·데이터베이스 상태, 관련 메일 프로토콜·웹 엔드포인트를 검증한다. 연결 성공만으로 메일 전달 성공을 판단하지 않는다.

방화벽 변경 전에는 `infrastructure/base/cilium-host-firewall/README.md`를 읽는다. 관리 접근은 Tailscale로 유지한다. 문서의 `reserved:host` PolicyAuditMode와 관찰 절차를 따르며 Cilium 재시작 시 감사 모드가 사라진다는 점을 고려한다. 긴급 복구는 Tailscale 또는 Hetzner 콘솔로 접근한 뒤 Git 정책 롤백과 Flux 반영을 수행한다.

홈랩 백업 스토리지 변경에는 `homelab-infrastructure`를 읽고 리소스는 각 소유 저장소에 유지한다. 대상, Git 변경, 직접 수행한 운영 작업, 검증 근거, 남은 전달 실패를 보고하되 메일 내용이나 인증 정보를 불필요하게 노출하지 않는다.
