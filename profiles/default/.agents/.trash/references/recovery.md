# Tinyrack 클라우드 복구

기준 자료는 `~/Workspaces/tinyrack/infrastructure/readme.md`, `ansible/`, 현재 백업 매니페스트다. 일반 배포가 아닌 요청받은 복구에 이 절차를 사용한다.

1. `hcloud --context winetree94`로 Tinyrack Hetzner 서버를 확인한다. 같은 컨텍스트에 메일 서버도 있다. 복구 범위 안에서 `hcloud`로 교체 서버와 공급자 측 Floating IP 할당을 관리한다. 지원 OS, SSH 계정, Tailscale 연결을 준비하고 승인된 교체에 맞춰 인벤토리를 갱신한다. 여기서 Ansible은 호스트명, Tailscale 로그인, OS 업그레이드를 관리하지 않는다.
2. Git에서 `clusters/production/apps.yaml`을 `apps.yaml.bak`으로 바꾸고 변경을 전달해 앱을 일시 중단한다. 인프라 반영은 유지한다.
3. 기존 Ansible Vault를 안전하게 구성하고 syntax/lint/preflight/check/apply/verify 절차를 따른다. 호스트 의존성, K3s, Cilium, Sealed Secrets 복구 키를 준비한다. 두 번째 apply는 멱등적이어야 한다.
4. 기존 Pod·Service CIDR을 유지한다. 기존 설정이나 암호화 키가 예상 값과 다르면 멈추고 진단한다. 플레이북을 통과시키려고 키를 덮어쓰거나 CIDR을 바꾸지 않는다. 암호화 리소스 반영 전에 예상한 단일 복구 키를 확인한다.
5. Ansible 검증을 통과하면 `tinyrack-net/infrastructure`, `main`, `clusters/production`으로 Flux를 초기 구축한다. Flux가 Ansible이 설치한 Cilium 릴리스를 이어받는다.
6. 인프라를 기다린 뒤 현재 README에 따라 필요한 Longhorn 볼륨을 복원한다. 데이터베이스는 앱 수준 백업을 사용하며 Memos·Discourse는 CNPG로 복구한다. 그 밖의 활성 앱은 매니페스트에서 적절한 백업 절차를 확인한다.
7. Git으로 앱 진입점을 복원한다. 데이터 복구, Flux, 인증서, Cloudflare Tunnel 인그레스, 앱 상태를 검증한다. Cloudflare DNS·터널 경로는 `cf`로 확인·수리하고 커넥터 매니페스트는 GitOps에 둔다. 복구를 쉽게 하려고 포트를 열지 말고 공인 IP 직접 접근 차단이 유지되는지 확인한다.

CNPG 백업은 `hetzner_fsn:tinyrack-prod/apps/`, Longhorn은 `hetzner_fsn:tinyrack-prod/longhorn`이다. `rclone`으로 버킷·객체를 확인한 뒤 해당 CNPG·Longhorn 절차로 복원한다. 이 버킷의 `clusters/public/`에는 메일 백업도 있으므로 보존한다. 현재 대상과 사용할 수 있는 복구 시점을 확인한다. Git이 복원하는 것은 설정이며 영구 데이터가 아니다. 별도로 확인된 홈랩 목적지 자체에 작업이 필요할 때만 `homelab-infrastructure`를 읽는다.

키 이름, 버전, 네트워크 값, 백업 목적지는 복사한 명령 목록이 아닌 현재 저장소에서 확인한다. Vault 기반 Ansible 권한 상승을 유지하고 비밀 자료를 출력하지 않는다.
