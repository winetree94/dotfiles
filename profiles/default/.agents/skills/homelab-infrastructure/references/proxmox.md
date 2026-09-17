# Proxmox 호스트와 게스트

`ssh xeon`은 홈랩 클러스터와 가상화된 CI 기기의 하이퍼바이저다. 어플라이언스 기준 설정 저장소는 확인되지 않았으므로 기기 설정 방식으로 변경한다.

| VM ID | 게스트          | 용도            | 관리 주체                            | 사양                           |
| ----- | ------------ | ------------- | -------------------------------- | ---------------------------- |
| `100` | `homelab`    | 홈랩 K3s 클러스터   | 홈랩 GitOps 저장소와 `ansible/`        | 8코어, 24GiB, `local-lvm` 512G |
| `101` | `windows-ci` | Windows CI 러너 | `ansible-github-actions-runners` | 8코어, 8GiB, 512G              |
| `102` | `ubuntu-ci`  | Linux CI 러너   | `ansible-github-actions-runners` | 8코어, 8GiB, 512G              |

VM ID와 실행 상태는 바뀔 수 있으므로 작업 전에 `qm list`, `pct list`, 대상 게스트 설정을 다시 확인한다. `macmini` 등 모든 CI 인벤토리 호스트가 Proxmox 게스트라고 가정하지 않는다.

VM 하드웨어·디스크·수명 주기는 Proxmox가, 게스트 OS·워크로드는 각 저장소가 관리한다. 경계를 넘는 변경은 양쪽 절차를 모두 따르고, 게스트를 중지해야 하면 영향받는 서비스와 작업 실행 상태를 먼저 확인한 뒤 중지 대상을 밝힌다.

## 스토리지

- `local`(dir)과 `local-lvm`(lvmthin)이 게스트 디스크를 저장하고, `nas`(CIFS)가 백업 등 여러 콘텐츠를 저장한다. `nas`는 NAS의 `proxmox` 공유를 `/mnt/pve/nas`에 마운트한다.
- 게스트 디스크 위치는 선택한 VM 설정과 `pvesm status`로 확인한다. 스토리지 이름만 보고 디스크 배치를 가정하지 않는다.
- 백업 목적지가 설정되어 있다는 것과 VM 백업 일정·성공은 다르다. 필요하면 백업 작업 목록과 최근 결과를 확인한다. 호스트 유지보수, 디스크·VM 변경 전에 현재 스토리지, 백업 작업, 게스트 활동을 확인한다.

NAS 공유·용량·백업 설정은 [openmediavault.md](openmediavault.md)를 읽는다. 접근이나 데이터 가용성을 끊을 수 있는 스토리지 변경 전에는 백업과 복구 접근 수단을 확인한다.

## 게스트 작업

- 게스트 안의 워크로드는 해당 저장소 절차를 따른다. 홈랩 노드는 `~/Workspaces/tinyrack/homelab`의 GitOps를, CI 게스트는 `~/Workspaces/tinyrack/ansible-github-actions-runners`의 Ansible을 따른다.
