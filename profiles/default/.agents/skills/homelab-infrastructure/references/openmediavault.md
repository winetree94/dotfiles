# OpenMediaVault NAS와 스토리지

`ssh openmediavault`, 주소 `10.132.245.8`. 어플라이언스 기준 설정 저장소는 확인되지 않았으므로 기기 설정 방식으로 변경하고, 생성된 설정 파일을 무작정 수정하지 않는다.

Garage와 Syncthing은 Kubernetes 워크로드가 아니라 이 호스트의 Docker 서비스다. 클러스터 쪽 프록시 경로는 `~/Workspaces/tinyrack/homelab` 저장소의 `AGENTS.md`와 관련 Flux 매니페스트를 읽는다.

## Docker 서비스

컨테이너는 `garage-garaged-1`(S3 API), `garage-webui`(콘솔), `syncthing`이다. 실행 중인 컨테이너를 직접 고치지 말고 Compose 원본을 찾아 수정한다.

- 확인한 Compose 원본: 데이터 디스크의 `docker-configs/garage/{garage.yml,compose.override.yml}`과 `docker-configs/syncthing/{syncthing.yml,compose.override.yml}`.
- 현재 값은 `docker inspect -f '{{index .Config.Labels "com.docker.compose.project.config_files"}}' <container>`로 확인한다. 디스크 UUID를 추측하지 말고 `findmnt`와 컨테이너 마운트에서 실제 `/srv/dev-disk-by-uuid-*` 경로를 찾는다.
- 데이터·설정 경로: `docker-configs/garage`, `docker-configs/syncthing`, `docker-data/garaged/{meta,data,garage.toml}`, `docker-data/syncthing/config`. Syncthing은 디스크의 `winetree94-nas`를 `/data`에 연결한다.

## Garage

- 저장소 리전은 `home`, 복제 계수는 `1`이다. 복제는 외부 백업이 아니다. 호스트 설정은 `/etc/garage.toml`로 마운트된다. 설정·환경 전체를 출력하지 말고 필요한 비밀 정보가 아닌 필드만 확인한다.
- 엔드포인트는 `https://storage.intranet.winetree94.com`, `rclone` 원격은 `homelab_garage:`다. 환경 인증(`env_auth = true`)과 비공개 객체·버킷 ACL을 유지한다.
- 홈랩의 `apps/base/proxies/garage.proxy.yaml`이 Garage S3 API를 NAS `3900`, 콘솔을 `3909`, 웹사이트 호스팅을 `3902`로 연결한다. 연결 변경 시 함께 있는 Cilium 정책을 확인한다.
- 버킷과 객체는 Garage 데이터 파일을 고치지 말고 `rclone`으로 관리한다. 요청한 버킷·접두 경로만 대상으로 삼고, 삭제나 `rclone sync`는 대상 객체를 지울 수 있으므로 영향을 먼저 확인한다. 인증 정보는 출력하거나 스킬·Git에 저장하지 않는다.

다음 백업 경로로 대상을 찾고, 작업 전에 현재 CNPG ObjectStore 또는 Longhorn BackupTarget을 확인한다. PostgreSQL 버전을 고정해서 가정하지 말고 ObjectStore에서 정확한 데이터베이스 접두 경로를 찾는다.

| 용도 | rclone 경로 |
| --- | --- |
| 앱 데이터베이스 백업 | `homelab_garage:tinyrack-homelab/apps/<app>/<database-prefix>` |
| Grafana 데이터베이스 백업 | `homelab_garage:tinyrack-homelab/infrastructure/monitoring/<grafana-database-prefix>` |
| Longhorn 백업 | `homelab_garage:tinyrack-homelab/clusters/tinyrack-homelab/longhorn` |

범위를 좁힌 조회는 `rclone listremotes`, `rclone lsf homelab_garage:tinyrack-homelab/apps/ --dirs-only`처럼 한다. 버킷 작업은 GitOps 백업 설정 및 CNPG·Longhorn 복구 절차와 구분한다. Garage 호스트·서비스 운영과 S3 버킷 관리는 별개다.

## 외부 백업

`/etc/borgmatic/config.yaml`은 Hetzner S3가 아닌 Hetzner Storage Box에 SSH로 Borg 백업을 설정한다. 도메인은 `your-storagebox.de`, 포트는 `23`, 저장소 경로는 `/./borg-repository`이며 계정별 호스트명은 현재 설정에서 찾는다. 현재 일정·보존 정책은 `borgmatic.timer`와 설정 파일을 읽는다.

Borgmatic은 파일 단위 백업이다. NAS 데이터 디스크가 포함됐다는 이유로 전체 기기나 OS 디스크까지 백업된다고 판단하지 않는다. 완전한 범위라고 말하기 전에 원본 경로 확장, 제외 항목, 마운트 상태, 데이터베이스·앱 일관성을 확인한다. 백업 작업 성공이 복구 가능성을 증명하지는 않으므로 최근 결과와 복원 시험 근거를 별도로 확인한다.

진단은 타이머·서비스 상태와 설정을 읽기 전용으로 확인한다. 백업 생성, 오래된 백업 정리, 수리를 포함한 일관성 검사, 복원은 별도 작업이며 문서 확인에 포함하지 않는다. NAS 디스크 백업과 Garage 안에 저장된 클러스터 CNPG·Longhorn 백업을 구분한다.

## 변경 경계

접근이나 데이터 가용성을 끊을 수 있는 네트워크·스토리지 변경 전에 백업과 복구 접근 수단을 확인한다. Proxmox가 이 NAS의 `proxmox` 공유를 CIFS로 마운트하므로, 공유·권한·네트워크 변경은 [proxmox.md](proxmox.md)의 스토리지 설명과 함께 검토한다.
