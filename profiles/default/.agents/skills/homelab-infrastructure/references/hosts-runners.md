# 로컬 호스트와 CI 러너

## 로컬 인프라

사용 전에 현재 로컬 SSH 설정과 다음 별칭이 일치하는지 확인한다.

| 기기 | SSH 별칭 | 설정 관리 주체 |
| --- | --- | --- |
| 가정용 OPNsense | `opnsense` | 기기 설정. 기준 설정 저장소 미확인 |
| OpenMediaVault NAS | `openmediavault` | 기기 설정. 기준 설정 저장소 미확인 |
| Proxmox 호스트 | `xeon` | 기기 설정. 기준 설정 저장소 미확인 |
| 홈랩 K3s 호스트 | `homelab` | 지원되는 호스트 준비는 `~/Workspaces/tinyrack/homelab/ansible` |
| Intel Arc Pro B70 두 장을 장착한 서버 | `ubuntu-gpu` | `~/Workspaces/tinyrack/ubuntu-b70`의 Ansible |

SSH 별칭과 홈랩 프록시 매니페스트는 기기를 식별하는 정보이며 어플라이언스의 GitOps 관리 체계가 있다는 뜻은 아니다. 변경 계획 전에 실제 설정과 지원 관리 인터페이스를 확인한다. 저장소를 지어내거나 모든 로컬 기기를 여기서 관리한다고 가정하거나 생성된 어플라이언스 파일을 무작정 수정하지 않는다. 접근이나 데이터 가용성을 끊을 수 있는 네트워크·스토리지 변경 전에는 백업과 복구 접근 수단을 확인한다.

OPNsense는 자신과 로컬 서비스에 대한 직접 외부 접근을 차단해야 한다. 관리는 신뢰하는 내부·사설 연결로만 한다. 인바운드 포트 포워딩은 필요한 VPN 엔드포인트에만 열고, 기존 VPN 설정에서 포트·프로토콜을 확인한다. 웹, SSH, NAS, 하이퍼바이저 예외는 추가하지 않는다. 공개 서비스는 아웃바운드 Cloudflare Tunnel을 사용하며 Cloudflare 설정은 `cf`로 관리한다. 복구 접근에서도 이 경계를 유지한다.

일반 워크스테이션 설정은 `~/Workspaces/winetree94/dev-machines`가 담당한다. Ansible 프로비저닝·설정·갱신은 `development-machines`를 사용한다. 기기가 워크스테이션을 겸하더라도 아래 CI 도구는 별도로 관리한다.

<a id="openmediavault-nas-and-storage"></a>
## OpenMediaVault NAS와 스토리지

Garage와 Syncthing은 `ssh openmediavault`의 Docker에서 실행된다. NAS 주소는 `10.132.245.8`이다. Kubernetes 워크로드가 아닌 호스트 서비스다.

- Garage 컨테이너는 `garage-garaged-1`, `garage-webui`이고 Syncthing은 `syncthing`이다. 실행 중인 컨테이너를 수정하지 말고 `com.docker.compose.project.working_dir`, `com.docker.compose.project.config_files` 라벨에서 오버라이드 파일을 포함한 현재 Compose 원본을 찾는다.
- 마운트된 데이터 디스크에는 `docker-configs/garage`, `docker-configs/syncthing`, `docker-data/garaged/{meta,data,garage.toml}`, `docker-data/syncthing/config`가 있다. Syncthing은 디스크의 `winetree94-nas`를 `/data`에 연결한다. 디스크 UUID를 추측하지 말고 `findmnt`와 컨테이너 마운트에서 실제 `/srv/dev-disk-by-uuid-*` 경로를 찾는다.
- Garage 리전은 `home`, 복제 계수는 `1`이다. 복제는 외부 백업이 아니다. 호스트 설정은 `/etc/garage.toml`로 마운트된다. 설정·환경 전체를 출력하지 말고 필요한 비밀 정보가 아닌 필드만 확인한다.
- 홈랩의 `apps/base/proxies/garage.proxy.yaml`은 `storage.intranet.winetree94.com`과 버킷 하위 도메인을 Traefik에서 NAS 포트 `3900`으로 연결한다. 같은 매니페스트가 Garage 콘솔은 `3909`, 웹사이트 호스팅은 `3902`로 연결한다. 연결 변경 시 함께 있는 Cilium 정책을 확인한다. 버킷·객체는 Garage 데이터 파일을 수정하지 말고 본 스킬에 따라 `rclone homelab_garage:`로 관리한다.

### 외부 백업

`/etc/borgmatic/config.yaml`은 Hetzner S3가 아닌 Hetzner Storage Box에 SSH로 Borg 백업을 설정한다. 도메인은 `your-storagebox.de`, 포트는 `23`, 저장소 경로는 `/./borg-repository`이며 계정별 호스트명은 현재 설정에서 찾는다. 현재 일정·보존 정책은 `borgmatic.timer`와 Borgmatic 설정을 읽는다.

백업 원본은 `/etc/borgmatic/config.yaml`, 디스크 마운트는 `findmnt`에서 확인한다. Borgmatic은 파일 단위 백업이다. NAS 데이터 디스크가 포함됐다는 이유로 전체 기기나 OS 디스크까지 백업된다고 판단하지 않는다. 완전한 범위라고 말하기 전에 원본 경로 확장, 제외 항목, 마운트 상태, 데이터베이스·앱 일관성을 확인한다. 최근 백업 결과와 복원 시험 근거는 별도로 확인한다. 백업 작업 성공이 복구 가능성을 증명하지는 않는다.

진단은 타이머·서비스 상태와 설정을 읽기 전용으로 확인한다. 백업 생성, 오래된 백업 정리, 수리를 포함한 일관성 검사, 복원은 별도 작업이며 문서 확인에 포함하지 않는다. NAS 디스크 백업과 Garage 안에 저장된 클러스터 CNPG·Longhorn 백업을 구분한다.

## Xeon Proxmox 호스트

`ssh xeon`은 홈랩 클러스터와 가상화된 CI 기기의 하이퍼바이저다. 다음 표로 게스트 설정 관리 주체를 찾는다.

| VM ID | 게스트 | 게스트 설정 관리 주체 |
| --- | --- | --- |
| `100` | `homelab` | 홈랩 GitOps 저장소와 호스트 준비용 Ansible |
| `101` | `windows-ci` | 아래 개인 GitHub Actions Ansible 저장소 |
| `102` | `ubuntu-ci` | 아래 개인 GitHub Actions Ansible 저장소 |

VM ID와 실행 상태는 바뀔 수 있으므로 작업 전에 `qm list`, `pct list`, 대상 게스트 설정을 다시 확인한다. `macmini` 등 모든 CI 인벤토리 호스트가 Proxmox 게스트라고 가정하지 않는다.

VM 하드웨어·디스크·수명 주기는 Proxmox가, 게스트 OS·워크로드는 각 저장소가 관리한다. 게스트 디스크 위치는 선택한 VM 설정과 `local-lvm`을 포함한 현재 Proxmox 스토리지 설정에서 확인한다. Proxmox 스토리지 `nas`는 NAS의 `proxmox` 공유를 `/mnt/pve/nas`에 CIFS로 마운트하며 백업 등 여러 콘텐츠를 저장하도록 설정되어 있다. 백업 목적지가 있다는 것만으로 VM 백업 일정이나 성공이 확인되지는 않는다. 호스트 유지보수, 디스크·VM 변경 전에 현재 스토리지, 백업 작업, 게스트 활동을 확인한다.

## Intel B70 GPU 서버

`ssh ubuntu-gpu`는 Intel Arc Pro B70 두 장을 사용하는 별도 Ubuntu GPU·LLM 서버이며 `~/Workspaces/tinyrack/ubuntu-b70`이 관리한다. 진단에 필요하면 현재 OS 버전, GPU 목록, Docker·Alloy 서비스 상태를 확인한다.

영구 변경은 임시 SSH 편집 대신 이 저장소의 Ansible·Git 절차로 한다. `AGENTS.md`, README, Makefile, 인벤토리, 관련 역할, 선택한 `profiles/<model>/`의 매니페스트·Compose 파일을 읽는다. 프로필이 모델 리비전, 체크섬, 컨테이너 이미지를 고정하므로 특정 추론 모델이나 GPU 병렬 처리 모드를 가정하지 말고 현재 설정을 확인한다.

`make models`로 프로필을 확인한다. 문서화된 배포 순서는 `make verify`, `make ping`, `make check MODEL=<profile>`, `make apply MODEL=<profile>`이며 `apply`도 검증 과정과 `test-api`를 실행한다. 이는 배포 절차이므로 읽기 전용 조사 중에 실행하지 않는다. 암호화된 Ansible Vault·become 연동을 유지한다. 방화벽과 TLS 관리는 이 저장소 범위 밖이다.

Alloy는 호스트·추론·GPU별 메트릭을 공통 모니터링 백엔드로 보낸다. 대시보드는 `gcx`로 홈랩 Grafana에서 변경한다. 벤치마크·실험 타깃은 운영 추론 서비스를 교체하고 API 트래픽을 끊을 수 있다. 무해한 상태 검사로 취급하지 말고 명시적으로 계획한 유지보수 시간과 저장소 복구 절차를 사용한다.

## 개인 GitHub Actions 기기

저장소: `~/Workspaces/tinyrack/ansible-github-actions-runners`.

README, Makefile, 인벤토리, 관련 역할을 읽는다. 알려진 기기는 `ubuntu-ci`, `macmini`, `windows-ci`이며 연결 정보와 플랫폼 그룹은 인벤토리가 기준이다. Vivident 러너가 아니라 `tinyrack-net` 조직의 `homelab` 그룹 러너다.

- 기존 Ansible 역할·플레이북과 Git 절차로 재현 가능한 설정을 변경한다. Vault 기반 권한 상승을 유지하며 Vault 비밀 정보를 출력하거나 평문 인증 정보를 커밋하지 않는다.
- 관련 `make syntax`, `make lint`, `make preflight`, `make check`로 검증한다. 필요에 맞게 인벤토리 범위를 명시해 적용하고 반복 적용으로 멱등성을 확인한다. `make verify`로 도구, 서비스, GitHub 온라인·그룹·라벨 상태를 검사한다.
- 사용자 라벨은 GitHub 호스팅 러너용 작업을 잘못 가져가지 않도록 `tinyrack-` 접두사를 쓴다. 고정 러너 수를 복사하지 말고 인벤토리에서 이름과 디렉터리를 확인한다.
- `make update`는 별도로 의도해서 수행하는 패키지 유지보수다. 재부팅하지 않으므로 재부팅 필요 상태를 보고한다. 사용 중인 도구·앱을 바꿀 수 있는 갱신 전에는 작업 실행 상태와 macmini 워크스테이션 사용 여부를 확인한다.
- 폐기에는 호스트와 러너 식별자 또는 명시적인 `all`이 필요하다. 유휴 러너에서 README의 check/decommission 절차를 수행하고, 다음 apply에서 재생성되지 않도록 인벤토리 항목을 제거한다. 진단의 부수 효과로 폐기하지 않는다.

Apple ID 로그인처럼 사람이 해야 하는 준비는 저장소 문서대로 사용자에게 맡긴다. 오래된 플랫폼 설정 단계를 복제하지 말고 현재 지침을 읽는다.
