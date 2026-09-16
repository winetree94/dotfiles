# 메일 서버 복구

`~/Workspaces/tinyrack/mail-server/readme.md`, `ansible/`, 현재 서비스 백업 매니페스트를 사용한다. 설정과 메일·앱 데이터를 모두 보존해야 한다.

1. `hcloud --context winetree94`로 교체 Hetzner 호스트와 복구 범위를 확정한다. 같은 컨텍스트의 Tinyrack 서버와 구분한다. 기존 메일 Floating IP의 식별 정보와 삭제 보호를 확인하고 `hcloud`로 공급자 측 할당을 수행한다. Ansible로 게스트 내부에 IP를 설정하고 기존 클러스터·서비스 CIDR로 K3s를 설치한다. Floating IP는 보조 주소이므로 Hetzner가 관리하는 기본 주소, 기본 라우팅, DHCP, IPv6 설정을 보존한다.
2. Ansible·Flux가 공유하는 `infrastructure/base/cilium/values.yaml`로 Cilium을 초기 구축한다. 현재 Ansible 인벤토리를 읽고 문서의 preflight/check/apply/verify를 수행한다. 두 번째 apply로 멱등성을 확인한다.
3. 암호화 리소스가 반영되기 전에 Vault에서 예상한 단일 Sealed Secrets 키를 복원한다. 플레이북은 키 불일치나 추가 활성 키가 있으면 중단한다. 덮어쓰거나 키를 지우지 말고 원인을 조사한다.
4. Ansible 검증 후 `tinyrack-net/mail-server`, `main`, `clusters/production`으로 Flux를 초기 구축한다. Flux가 기존 Cilium 릴리스를 이어받는다. 인프라 준비를 기다리고 앱 반영을 확인한다.
5. `rclone`으로 `hetzner_fsn:tinyrack-prod/clusters/public/`의 백업 객체를 확인한다. Stalwart 데이터베이스 백업은 `apps/stalwart/`, Longhorn은 `longhorn/` 아래다. 공유 버킷의 다른 클러스터 접두 경로를 보존한다. 필요에 따라 Longhorn 또는 데이터베이스 전용 절차로 복구한다. 워크로드 반영이나 객체 복사만으로 메일·DB 데이터 복구를 판단하지 않는다. 복구 중에는 해당 서비스에 필요한 외부 트래픽 제어를 수행한다.
6. Flux, Sealed Secrets, 인증서, 스토리지, 데이터베이스 상태, 인그레스, 메일 프로토콜을 검증한다. Floating IP·DNS·PTR 일치와 Stalwart 웹·관리 접근을 확인한다. 전달 검사는 [mail-delivery.md](mail-delivery.md)의 발송 승인 규칙을 따른다.

암호화 키 교체는 README에 따라 새 키 백업, 모든 매니페스트 재암호화·검증, 기존 키 폐기 순으로 진행한다. 키 유출이 의심되면 그 키로 보호한 실제 인증 정보도 교체해야 한다. 일반 복구의 부수 작업으로 키를 교체하지 않는다.

Vault 비밀번호와 평문 키는 Git·로그에 남기지 않는다. 복구에 필요한 홈랩 목적지 자체를 수리해야 하면 `homelab-infrastructure`를 사용한다.
