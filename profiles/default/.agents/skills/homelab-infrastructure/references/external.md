# 외부 인프라 관리 가이드

## Cloudflare

공개 DNS, 터널 등 홈랩에서 의존하는 클라우드플레어 리소스 제어가 필요한 경우 `cf` CLI 도구를 통해 수행한다. 예를 들어 다음의 명령어를 통해 DNS 레코드 목록을 확인할 수 있다.

```bash
cf dns records list --zone winetree94.com
```

---
## Hetzner

OMV 등에서 활용되는 Hetzner 리소스 제어가 필요한 경우 `hcloud` CLI 도구를 통해 수행한다. 예를 들어 다음의 명령어를 통해 스토리지 박스 목록을 확인할 수 있다.

```bash
hcloud storage-box list
```

