# 홈랩 복구

현재 운영 기준은 `~/Workspaces/tinyrack/homelab/readme.md`, 해당 `AGENTS.md`, `ansible/`다. README에 현재 Cilium 초기 구축 방식이 있으므로 AGENTS.md의 오래된 요약을 따라 구식 네트워크 구성을 재설치하지 않는다.

복구는 별도 오버레이가 아닌 평소의 Flux 경로 `clusters/production`을 사용한다. 요청 범위 안에서만 복구하며 일상적인 서비스 진단에 포함하지 않는다.

1. README의 `clusters/production/apps.yaml.bak` 관례에 따라 Git에서 앱 반영을 일시 중단하고 푸시한다. 인프라 반영은 유지한다.
2. `ansible/`로 교체 호스트 준비, K3s 설치, Cilium 초기 구축, Vault의 Sealed Secrets 키 복원을 수행한다. 인벤토리를 확인하고 문서의 preflight/check/apply/verify 절차와 멱등성 확인용 두 번째 apply를 따른다.
3. Cilium 정상 상태와 올바른 복구 키를 확인하기 전에는 Flux를 초기 구축하지 않는다. Ansible이 설치한 Cilium 릴리스·values를 나중에 Flux가 이어받는다. Multus와 LAN 연결을 보존한다.
4. 현재 README에 따라 `tinyrack-net/homelab` 저장소의 `main` 브랜치, `clusters/production` 경로로 초기 구축한다. 인프라와 Longhorn 백업 대상이 준비될 때까지 기다린다.
5. 같은 Longhorn 마이너 버전에서 생성된 적절한 Ready 시스템 백업을 복원한다. PostgreSQL은 일반적인 Longhorn 데이터베이스 볼륨 복원이 아니라 S3의 CNPG·Barman 복구를 사용한다.
6. 과거 볼륨 백업으로 복원된 CNPG 데이터 PVC를 확인한다. 삭제 전에 정확한 대상, 유효한 데이터베이스 백업, 복구 범위를 확정하고 PV·Longhorn 볼륨을 문서대로 처리하는지 확인한다. 일상적인 정리 단계로 클러스터 전체를 삭제하지 않는다.
7. Git으로 앱 진입점을 복원한다. Cloudflare Tunnel 외부 트래픽을 재개하기 전에 CNPG 복구, Flux, 인증서, 인그레스, 스토리지, 핵심 앱 데이터를 확인한다. Cloudflare 경로·DNS는 `cf`로 확인하고 커넥터 매니페스트는 GitOps에 유지한다. OPNsense가 서비스·관리 인터페이스의 직접 외부 접근을 여전히 차단하는지 확인한다. 설정된 VPN 엔드포인트 외에는 WAN 포트 포워딩을 추가하지 않는다.

Garage 백업 객체는 `rclone`으로 확인한다. Longhorn은 `homelab_garage:tinyrack-homelab/clusters/tinyrack-homelab/longhorn`, CNPG는 현재 ObjectStore의 `apps/` 또는 `infrastructure/` 접두 경로를 사용한다. 버킷·객체 관리는 위 복구 절차를 대신하지 않는다. 버전, 스토리지 대상, 복구 설정은 현재 백업·초기 구축 매니페스트에서 확인한다. 매니페스트가 반영됐다는 이유만으로 데이터가 있다고 가정하지 않는다.
