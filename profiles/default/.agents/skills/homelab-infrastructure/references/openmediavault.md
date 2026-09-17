# OpenMediaVault 관리 가이드

필요 시 `ssh openmediavault` 명렁어로 접근하여 설정을 변경한다. `openmediavault` 는 UI를 통한 제어만이 진실이므로, UI 에서 제어되는 영역은 ssh 로 수정하지 않고 사용자에게 제어를 위임한다.

---
## 리버스 프록시

`openmediavault`에서 제공하는 서비스들은 `homelab` 쿠버네티스 클러스터에서 리버스 프록시된다. 예를 들어 다음의 도메인 주소들이 서비스로 프록시되고 있다.

- [openmediavault.intranet.winetree94.com](https://openmediavault.intranet.winetree94.com): openmediavault 콘솔
- [garage.intranet.winetree94.com](https://garage.intranet.winetree94.com): garage webui 콘솔
- [storage.intranet.winetree94.com](https://storage.intranet.winetree94.com): garage 엔드포인트

---
## Garage

Garage 는 OMV에서 Docker 로 운영되는 오브젝트 스토리지이다. 홈랩에서 운영하는 서비스에서 오브젝트 스토리지가 필요하다면 이곳을 사용한다. 저장소는 `rclone` 의 `homelab_garage`로 직접 접근 및 관리할 수 있다. 예를 들어 다음의 명령어로 버킷 리스트를 확인한다.

```
rclone lsd homelab_garage:
```

---
## Syncthing

Syncthing 은 OMV에서 Docker 로 운영되는 개인용 파일 동기화 저장소이다. 개인적으로 여러 PC간 동기화가 필요한 파일들이라면 이 서비스를 통해 운용한다. 옵시디언 문서가 이것을 통해 연동되어 있다.

---
## 외부 백업

OMV의 파일들은 Borgmatic 을 통해 외부의 Hetzner Storage Box 에 주기적으로 백업한다. 이 설정은 OMV UI 를 통해 관리되지 않으며 `/etc/borgmatic/config.yaml` 설정 파일을 직접 수정해 관리한다.

---
## 주의 사항

홈랩 전반에서 주요 저장소로 활용되므로 NAS 유지보수 시 대부분의 서비스에서 장애가 발생한다. 작업을 수행하기 전에 백업과 복구 수단을 명확히 확인한다.
