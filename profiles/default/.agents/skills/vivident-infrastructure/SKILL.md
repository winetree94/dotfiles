---
name: vivident-infrastructure
description: "Vivident의 공통 인트라넷, 사무실 네트워크, CI 러너와 외부 인프라를 관리한다. 설정·배포·진단·백업·복구 작업에 사용하며, 프로젝트 전용 인프라는 해당 저장소로 연결한다."
---
# Vivident 인프라 관리 가이드

작업 전에 인벤토리에서 대상, 접근 방법, 관리 정본을 확인한다.

| 대상                 | 용도                    | 접근 방법                                             | 관리 위치                                                    |
| ------------------ | --------------------- | ------------------------------------------------- | -------------------------------------------------------- |
| 인트라넷               | 회사 공통 Kubernetes 서비스  | 컨텍스트 `vivident-intranet`, SSH `vivident-intranet` | `~/Workspaces/vivident/intranet` (GitOps, 호스트 운영 지침)     |
| 회사 CI 러너           | GitHub 자체 호스팅 러너      | 저장소 인벤토리에서 확인                                     | `~/Workspaces/vivident/ansible-actions-runner` (Ansible) |
| 사무실 내부망 OPNsense   | 사무실 라우터·방화벽·VPN·Caddy | SSH `vivident-firewall`                           | 직접 관리                                                    |
| 구 사무실 내부망 OPNsense | 구 사무실 내부망 라우터·방화벽·VPN | SSH `vivident-firewall-legacy`                    | 직접 관리                                                    |
| Dell S4148T-ON     | 사무실 내부망 유선 연결·코어 스위치  | Telnet                                            | 직접 관리                                                    |
| HP 1930 8포트        | 사무실 내부망 무선 구간 스위치     | Web UI                                            | 직접 관리                                                    |
| Dell N1548         | 구 사무실 내부망 스위치         | 현장 관리 정보 확인                                       | 직접 관리                                                    |

---
## 저장소가 있는 리소스의 관리

해당 저장소의 `AGENTS.md`, README(`readme.md` 포함), 필요한 `.agents/skills`를 읽고 작업한다. 저장소에서 관리하는 설정·리소스·운영 절차는 그곳을 정본으로 삼고 이 스킬이나 하위 문서에 복제하지 않는다.

영구 설정 변경은 저장소의 관리 절차를 따른다. 저장소가 관리하는 머신 설정에 대한 SSH 제어는 임시 진단에만 사용한다. 인트라넷 호스트의 권한 작업도 인트라넷 저장소 지침을 먼저 확인한다.

프로젝트 전용 인프라는 해당 프로젝트 저장소로 연결한다. 오시즈는 [oshiz-operations](../oshiz-operations/SKILL.md)를, 개인 홈랩·개인 CI와 회사망 연결의 홈랩 측은 [homelab-infrastructure](../homelab-infrastructure/SKILL.md)를 읽는다.

---
## 저장소가 없는 리소스의 관리

작업에 필요한 내부망 문서만 읽는다. 구 사무실 내부망 지정이나 해당 서브넷을 가리키는 요청이 없으면 사무실 내부망를 사용한다. 두 내부망 간 연결 작업은 양쪽 문서를 읽는다.

| 작업                                                      | 하위 문서                                                          |
| ------------------------------------------------------- | -------------------------------------------------------------- |
| 사무실 내부망 OPNsense, Caddy, Dell S4148T-ON·HP 1930, 무선·LAN | [references/opnsense.md](references/opnsense.md)               |
| 구 사무실 내부망 OPNsense, Dell N1548, 내부망 연결                  | [references/opnsense-legacy.md](references/opnsense-legacy.md) |

---
## 외부 인프라의 관리

회사 공통 AWS, Cloudflare, 오브젝트 스토리지 작업은 [references/external.md](references/external.md)를 읽는다. 외부 리소스도 관리 저장소가 있으면 해당 저장소의 절차를 따른다.
