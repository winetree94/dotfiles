---
name: tinyrack-infrastructure
description: "Tinyrack의 클라우드 클러스터와 관련 외부 인프라를 관리한다. 서비스 설정·배포, 네트워크 진단, 백업·복구 작업에 사용한다."
---

# Tinyrack 인프라 관리 가이드

작업 전에 인벤토리에서 대상, 접근 방법, 관리 정본을 확인한다.

| 대상            | 용도                           | 접근 방법                      | 관리 위치                                           |
| ------------- | ---------------------------- | -------------------------- | ----------------------------------------------- |
| tinyrack 클러스터 | 클라우드 서비스                     | Kubernetes 컨텍스트 `tinyrack` | `~/Workspaces/tinyrack/infrastructure` (GitOps) |
| 클러스터 호스트      | OS·K3S·네트워크 설정               | SSH `tinyrack-server`      | 같은 저장소의 `ansible/`                              |
| 외부 리소스        | Hetzner·Cloudflare·오브젝트 스토리지 | 공급자 CLI·rclone             | [외부 인프라 문서](references/external.md)             |

조직명이나 서비스명만으로 이 클러스터를 선택하지 말고 요청한 배포의 관리 저장소를 확인한다.

## 저장소가 있는 리소스의 관리

해당 저장소의 `AGENTS.md`, README(`readme.md` 포함), 필요한 `.agents/skills`를 읽고 작업한다. 설정·리소스·운영 절차는 저장소를 정본으로 삼고 이 스킬이나 하위 문서에 복제하지 않는다.

영구 설정 변경은 저장소의 관리 절차를 따른다. 저장소가 관리하는 머신 설정에 대한 SSH 제어는 임시 진단에만 사용한다.

## 작업 경로

| 작업 | 관리 경로 |
| --- | --- |
| 서비스·호스트 설정, 배포, 백업 정책·복구, 호스트 방화벽 | 위 저장소의 지침·README와 해당 설정 |
| Hetzner, Cloudflare, 백업 객체 관리 | [references/external.md](references/external.md) |

공통 메트릭·로그·트레이스와 Grafana는 홈랩에서 관리한다. 수집·전송 설정은 이 저장소를, 공통 수집·저장·대시보드는 [homelab-infrastructure](../homelab-infrastructure/SKILL.md)를 읽고 홈랩 저장소를 따른다. 대시보드는 홈랩 인스턴스를 선택한 `gcx` CLI를 사용한다. 조회는 현재 데이터 소스·라벨에 따라 이 클러스터로 한정한다.

개인 홈랩은 [homelab-infrastructure](../homelab-infrastructure/SKILL.md), 메일 서버는 [mail-server-infrastructure](../mail-server-infrastructure/SKILL.md)가 담당한다.
