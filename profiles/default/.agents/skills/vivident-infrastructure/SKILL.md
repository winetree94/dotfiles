---
name: vivident-infrastructure
description: "Vivident의 인트라넷 클러스터, 사무실 네트워크, 회사 CI 러너를 관리한다. 인트라넷 서비스 배포, 라우터·스위치·프록시 설정, 연결 장애 진단, 러너 운영에 사용한다."
---

# Vivident 인프라

## 인트라넷 Kubernetes

회사 인트라넷 서비스는 자체 호스팅 Kubernetes 클러스터에서 실행된다.

| 리소스 | 대상 |
| --- | --- |
| Kubernetes 컨텍스트 | `vivident-intranet` |
| GitOps 저장소 | `~/Workspaces/vivident/intranet` |
| 클러스터 호스트 | `ssh vivident-intranet` |

명시된 사용자 대상을 우선하고 없으면 표에서 찾아 인프라 명령 전에 알린다. n8n·SearXNG 같은 서비스는 다른 환경에도 있으므로 클러스터 선택 전에 의도한 배포를 확인한다. 앱 저장소 `vivident/eevee`는 인트라넷 GitOps 원본이 아니다.

`kubectl --context vivident-intranet ...`로 대상을 명시한다. 현재 컨텍스트를 전환하는 표준 명령은 다음과 같다.

```sh
kubectl config use-context vivident-intranet
```

- 편집 전에 저장소 지침, README, 브랜치, 작업 트리 변경을 확인하고 무관한 수정은 보존한다. 모든 영구 Kubernetes 리소스는 이 GitOps 저장소에서 관리·전달해야 한다.
- kubectl, Helm 등 운영 API 클라이언트로 영구 클러스터 리소스를 직접 적용·변경하지 않는다. 임시 디버깅만 예외이며 범위를 제한하고 끝나면 임시 리소스를 제거한다.
- 진단은 클러스터 쿼리와 SSH의 읽기 전용 조회로 한다. 변경은 저장소 편집, 관련 매니페스트 검증, 기존 GitOps 전달 절차, 반영·서비스 상태 확인 순으로 한다.
- 클러스터 호스트 작업에 sudo가 필요하면 사용자에게 명령 실행을 맡긴다. 목적과 정확한 명령을 제시하고 받은 결과로 이어간다. 비밀번호 없는 sudo를 포함해 직접 실행하지 않으며 다른 권한 실행 경로로 우회하지 않는다.
- 이 Vivident 전용 규칙은 긴급 운영 직접 변경이나 비밀번호 없는 호스트 권한 명령을 허용하는 일반 지침보다 우선한다.

### Argo CD와 검증

이 저장소는 Flux가 아닌 Argo CD를 사용한다. `apps/overlays/production`, `infra/overlays/production`은 Argo CD Application을 정의하며 보통 각각 `apps/base/<name>`, `infra/base/<name>`을 참조한다. 관련 Application의 소스, 대상 리비전, 목적지, 동기화 정책을 읽는다. 로컬 base 대신 Helm이나 여러 소스를 쓰는 경우도 있다.

해당하면 변경한 Kustomize base를 `kubectl kustomize`로 렌더링하고 Application·Helm 설정은 별도로 검증한다. 오버레이 디렉터리가 Kustomize 루트라고 가정하지 않는다. 저장소 Git 절차로 전달하고 Argo CD 반영 리비전, Sync·Health, 워크로드 롤아웃, 서비스 상태를 확인한다. 렌더링한 매니페스트를 직접 적용해 GitOps를 우회하지 않는다. 초기 구축·복구는 범위를 정한 별도 절차가 필요하며 클러스터 호스트의 권한 작업은 여전히 사용자에게 맡긴다.

새 비밀 정보는 커밋 전에 저장소의 `vivident-intranet.key.pub` 인증서로 암호화한다. 일반 secret 파일명에도 SealedSecret이 있을 수 있으므로 리소스 kind를 확인한다. 평문 인증 정보나 암호화용 개인 키를 출력·커밋하지 않는다.

## 오브젝트 스토리지

버킷·객체는 `rclone`으로 관리한다. 백업은 AWS S3 버킷 `vivident-intranet`, 리전 `ap-northeast-2`, 엔드포인트 `https://s3.ap-northeast-2.amazonaws.com`을 사용한다. DB 백업은 `apps/`, `infra/`, Longhorn은 `longhorn/` 아래다. 작업 전에 현재 ObjectStore·BackupTarget에서 정확한 접두 경로를 읽는다.

설정된 `vivident_intranet_s3:` 원격을 사용한다. `type = s3`, `provider = Other`, `env_auth = true`, 리전 `ap-northeast-2`, 위 AWS 엔드포인트, 비공개 객체·버킷 ACL을 사용한다. 적절한 AWS 인증 정보를 환경 변수로 전달하되 출력하거나 이 스킬·Git에 저장하지 않는다. Garage·Hetzner 원격으로 대체하거나 인증 정보를 공유한다고 가정하지 않는다.

| 용도 | rclone 경로 |
| --- | --- |
| 앱 데이터베이스 백업 | `vivident_intranet_s3:vivident-intranet/apps/` |
| 인프라 데이터베이스 백업 | `vivident_intranet_s3:vivident-intranet/infra/` |
| Longhorn 백업 | `vivident_intranet_s3:vivident-intranet/longhorn/` |

범위를 좁힌 읽기 전용 조회에는 `rclone lsf vivident_intranet_s3:vivident-intranet/apps/ --dirs-only`를 사용한다. 버킷 접근은 비공개로 유지하고 요청한 접두 경로만 작업한다. Kubernetes 백업 설정은 GitOps를, 데이터베이스·볼륨 복원은 담당 오퍼레이터의 복구 절차를 따른다.

## 네트워크와 리버스 프록시

회사 라우터 두 대는 모두 OPNsense다. 사용자가 레거시 사이트를 지정하거나 작업이 해당 서브넷을 명확히 가리키지 않으면 메인 라우터를 사용한다.

| 사이트 | SSH 접근 | 내부 서브넷 |
| --- | --- | --- |
| 메인, 기본 대상 | `ssh vivident-firewall` | `10.78.0.0/16` |
| 레거시, 물리적으로 분리된 네트워크 | `ssh vivident-firewall-legacy` | `10.79.0.0/16` |

이 스킬과 참고 문서에는 관련 사설·내부 IP와 서브넷 CIDR을 유지한다. 외부 공인 IP·대역은 기록하지 않는다. 공개 리소스는 컨텍스트, SSH 별칭, 호스트명으로 식별하고 필요할 때 현재 설정에서 주소를 조회한다. 변경 전에 내부 주소·서브넷을 현재 라우터·저장소 설정과 대조한다.

라우터는 Tailscale로 연결되어 두 네트워크 사이를 라우팅한다. 하나의 로컬 서브넷으로 취급하거나 레거시 라우터가 메인 사이트 프록시를 제공한다고 가정하지 않는다.

인트라넷 서비스는 메인 라우터의 Caddy가 Kubernetes로 리버스 프록시한다. 호스트명 예시는 `outline.k8s.intranet.moelive.tech`다.

연결 장애는 관련 DNS 해석, 클라이언트 경로, OPNsense 방화벽·Tailscale 라우팅, 메인 라우터 Caddy 설정, Kubernetes Service·엔드포인트를 확인한다. 어느 구간이 실패하는지 찾은 뒤 변경한다. 실제 업스트림·배포 설정은 현재 상태에서 확인하며 IP, 포트, 네임스페이스, 설정 경로를 지어내지 않는다.

개인 홈랩의 `vivident-tailscale-router`는 `homelab` 컨텍스트이며 `homelab-infrastructure`가 담당한다. 회사 연결의 가정 측을 조사할 때 해당 스킬을 읽는다. 이름에 Vivident가 있다는 이유로 회사 클러스터를 선택하지 않는다.

### 사무실 스위치

메인 사무실은 Dell S4148T-ON 코어 스위치와 무선 구간의 HP 1930 8포트 스위치를 사용한다. 접근, 포트 매핑, LAN 링크 진단은 [references/office-switches.md](references/office-switches.md)를 읽는다. 변경 전에 실제 포트·MAC 매핑을 확인한다. 레거시 사이트의 Dell N1548은 별도 기기다.

## GitHub 자체 호스팅 러너

다음 저장소의 Ansible로 러너 기기를 관리한다.

```text
~/Workspaces/vivident/ansible-actions-runner
```

- SSH는 읽기 전용 진단에 사용할 수 있다. 임의의 기기 변경은 하지 않는다.
- 기기 변경은 기존 관례에 따라 이 저장소의 Ansible 인벤토리, 플레이북, 역할, 템플릿에 구현한다. Ansible 설정을 수동 셸 변경으로 대신하지 않는다.
- 인벤토리에서 대상 기기를 확인하고 관련 Ansible 설정을 검증한 뒤 문서화된 Ansible 절차로 적용한다. 지원하면 check·diff 모드를 사용하되 비밀 정보를 노출하지 않는다.
- 재현 가능성과 멱등성을 유지하도록 작업의 Ansible 변경을 커밋·푸시한다. 무관한 작업 트리 변경은 보존한다. 푸시나 실행이 막히면 미완료 항목을 보고한다.
- 적용 후 러너 상태를 검증하고 가능하면 멱등성도 확인한다.

호스트 별칭은 러너 인벤토리에서 확인한다. 개인 `tinyrack/ansible-github-actions-runners`는 `homelab-infrastructure`가 담당하는 별도 환경이다. 위 클러스터 호스트 sudo 위임 규칙이 러너 저장소의 기존 Ansible 권한 상승까지 전면 금지하는 것은 아니다.

확정한 대상, Git 변경, 임시 디버깅·기기 변경, 검증 근거를 보고한다. 파괴적·운영 영향 작업은 실행 전에 정확한 범위를 확인하며 모든 작업에서 비밀 정보 노출을 피한다.
