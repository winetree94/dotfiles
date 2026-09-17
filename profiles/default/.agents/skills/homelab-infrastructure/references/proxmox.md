# Proxmox 관리 가이드

필요 시 `ssh xeon` 명령어를 통해 접근하여 설정을 변경한다. 가상 환경의 종료, 중단 등 장애를 유발할 수 있는 행위는 사용자 동의 없이 진행하지 않는다.

VM ID와 실행 상태는 바뀔 수 있으므로 작업 전에 `qm list`, `pct list` 등의 명령어로 대상 게스트 설정을 다시 확인한다.

---
## 스토리지

가상 환경의 디스크는 `local`(dir)과 `local-lvm`(lvmthin)에 저장하고, `nas`(CIFS)를 통해 설치 이미지(iso), 백업 등 여러 콘텐츠를 저장한다. `nas`는 `openmediavault`의 `proxmox` SMB 공유를 `/mnt/pve/nas`에 마운트한다.

NAS 상태·용량·백업 설정은 [openmediavault.md](openmediavault.md)를 참고한다.

