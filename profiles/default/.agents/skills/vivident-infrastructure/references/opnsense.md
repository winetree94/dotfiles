# Vivident 오피스 Opnsense 관리 가이드

사무실 내부망은 `10.78.0.0/16`서브넷을 사용하며 `ssh vivident-firewall`로 OPNsense에 접근한다. 라우팅·방화벽·VPN과 인트라넷 Caddy 프록시를 담당한다.

OPNsense 인증 정보 Bitwarden ID: `d8238c54-eb30-4820-b4dd-c3fc3ee8de98`

현 사무실과 구 사무실 OPNsense 모두에 Tailscale이 설치되어 있으며, 서로의 subnet route를 통해 망이 연결된다. 두 내부망은 별도 로컬 서브넷이다.

인트라넷 서비스는 사무실 OPNsense의 Caddy 를 통해 리버스 프록시된다.

---
## 보안 규정

- 공인 IP 주소로 접근 가능한 서비스는 없어야 한다.
- 외부에서 내부망으로 진입할 수 있는 유일한 경로는 Tailscale 이여야 한다.
- 공개 서비스는 반드시 Cloudflare Tunnel 을 사용해 공인 IP를 노출하지 않는다.
- 공개 DNS 에는 공인 IP로 직결되는 레코드를 만들지 않는다.
- 내부망에서 공개 주소로 접근 시 불필요하게 Cloudflare Tunnel 을 거치지 않도록 내부용 DNS 라우팅을 구성한다.
- 방화벽 규칙은 요구사항에 필요한 최소 권한만을 할당한다.

---
## 사무실 스위치

사무실 내부망의 유선 연결은 Dell S4148T-ON(OS10), 무선 구간은 HP 1930 8포트 스위치가 담당한다. 아래 포트는 탐색 단서이며 변경 전 실제 설정과 MAC 매핑을 확인한다.

| Dell 포트                 | 연결                                       |
| ----------------------- | ---------------------------------------- |
| ethernet1/1/54          | 사무실 내부망 OPNsense의 LAN `re1`, 액세스 VLAN 10 |
| ethernet1/1/53          | HP 1930, 무선 구간                           |
| ethernet1/1/51 및 1/1/52 | NAS, port-channel 1. 일반 액세스 포트로 전용하지 않음  |

계정 정보는 아래 Bitwarden ID로 `bw-vivident get username '<item-id>'`, `bw-vivident get password '<item-id>'`를 사용해 가져온다. 조회 결과는 출력·기록하지 않고 접속 도구에 직접 전달한다.

---
### Dell S4148T-ON

관리 주소는 `192.168.1.254`이며 Telnet으로 접근한다.
Bitwarden ID: `5e214da5-a997-43a9-a435-ca98d711c8af`

로컬 접근은 같은 사무실 LAN의 PC에 사용하지 않는 `192.168.1.x/24` 주소를 설정한다. 예를 들어 게이트웨이 없이 `192.168.1.100`을 사용하되 충돌 여부를 먼저 확인한다. 관리망이 Tailscale이나 일반 사무실 서브넷에서 바로 접근 가능하다고 가정하지 않는다. PC·라우터 주소 변경은 전역 지침의 시스템 설정 변경 절차를 따른다.

라우터 경유 접근에는 LAN `re1`의 보조 주소가 필요할 수 있다. LAN 아웃바운드 NAT가 지정한 출발지를 바꿀 수 있으므로, 시간 초과 시 현재 경로·NAT·패킷 헤더를 확인한다. ARP 응답만으로 Telnet 연결 가능성을 판단하지 않는다.

허가된 임시 NAT 예외는 관리 출발지, 스위치 주소, TCP 23, `re1`로 한정한다. 기존 규칙·동적 앵커를 보존하고 구문을 검증하며, 예외 하나로 전체 규칙을 교체하거나 무관한 상태를 비우지 않는다. 작업 후 추가한 예외·보조 주소만 제거하고 확인한다.

#### 통신 장애 진단

1. 장애 범위를 먼저 구분한다. 유선 단말 하나, 무선 구간, NAS, 내부망 전체 중 어디에 영향을 주는지 확인하고 관련 단말 포트와 업링크를 조사한다. 관리 Telnet 접속 실패만으로 데이터 통신 장애라고 판단하지 않는다.
2. `show version`, `show clock`, `show interface status`로 OS10 버전·시각·링크를 확인한다. 단말이나 OPNsense의 현재 MAC을 `show mac address-table address <mac>`으로 찾아 실제 연결 포트를 확인한다.
3. 대상 포트의 설정과 상태를 확인한다. 아래는 라우터 연결 포트의 예시이며 실제 포트로 바꾼다. 같은 트래픽 조건에서 두 번 조회해 CRC·오류·드롭·트래픽 카운터의 증분과 링크 속도·협상 상태를 비교한다.

```text
show running-configuration interface ethernet 1/1/54
show interface ethernet 1/1/54
show spanning-tree interface ethernet 1/1/54 detail
```

4. 링크가 정상이라면 양쪽 포트의 VLAN·태깅, MAC 학습, STP 전달 상태를 확인한다. NAS 문제는 51/52번과 port-channel 1의 멤버·LACP 상태를 NAS 측과 함께 확인한다. 무선만 실패하면 53번 이후 HP·AP·SSID 경로를 확인하고, `vivident-guest`의 내부망 차단은 정상 정책으로 구분한다.
5. `show logging log-file 100`처럼 개수를 제한해 링크 변동·STP 이벤트를 확인한다. 장비 간 시각 차이를 고려하고, 복구 후 정상 상태만으로 장애 당시 원인을 단정하지 않는다. 명령 지원 여부와 LAG 조회 문법은 설치된 OS10 도움말에서 확인한다.

진단 중 카운터 초기화, MAC 테이블 삭제, 포트 재시작으로 증거를 지우지 않는다. 변경이 필요하면 관찰 결과를 남긴 뒤 수행하고, 처음 실패한 통신과 카운터 증분을 다시 확인한다.

자동화 세션은 실제 CLI 프롬프트와 설정 모드를 구분한다. 단순히 `>`로 끝나는 패턴은 syslog 접두사를 프롬프트로 오인할 수 있다. 설정 변경 시 실행 중 설정과 시작 설정을 구분하고 영구 저장 여부를 보고한다. 접속이 끊기면 재접속해 실제 결과를 확인한 뒤 재시도한다.

---
### HP 1930과 무선 관리

무선 네트워크는 `vivident-office`와 `vivident-guest`로 구분한다. `vivident-guest`는 게스트용이며 내부망 접근을 차단해야 한다. 무선·방화벽 설정 변경 후 게스트 네트워크에서 내부망에 접근할 수 없는지 검증한다.

사무실 LAN에서 이름 해석과 접근을 확인한 뒤 Web UI를 사용한다.

| 대상      | 관리 URL                                        | Bitwarden ID                           |
| ------- | --------------------------------------------- | -------------------------------------- |
| HP 1930 | https://wireless.switch.intranet.moelive.tech | `fb062b8a-3c7f-4354-8cc5-782f555e5c44` |
| 무선 관리   | https://wifi.intranet.moelive.tech            | `adb7041c-0b7f-4e23-9266-7ad3958b912e` |

무선 네트워크 접속 정보:

| 네트워크              | Bitwarden ID                           |
| ----------------- | -------------------------------------- |
| `vivident-office` | `938af2a0-74cf-4b1b-a5f2-b6ba1b84244e` |
| `vivident-guest`  | `f6f540b4-da07-4b64-bb86-e858101f6bec` |
