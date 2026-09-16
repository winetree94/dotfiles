# Vivident 사무실 스위치

## 메인 사무실 구성

아래 장비·포트 표로 기기를 찾고 변경 전에는 실제 설정을 다시 확인한다.

| 기기·포트 | 역할 |
| --- | --- |
| Dell S4148T-ON | OS10을 실행하는 메인 사무실 코어 스위치. 현재 버전은 `show version`으로 확인 |
| Dell ethernet1/1/54 | Asus PN42 OPNsense 라우터, `vivident-firewall`, LAN `re1`, `10.78.142.1/16`. 액세스 VLAN 10. 현재 링크 속도·협상 상태 확인 |
| Dell ethernet1/1/53 | 무선 기기를 연결하는 HP 1930 8포트 스위치 |
| Dell ethernet1/1/51 및 1/1/52 | NAS 링크, port-channel 1. 일반 액세스 포트로 전용하지 않음 |
| 그 밖의 활성 Dell 액세스 포트 | 유선 워크스테이션과 서버 |

레거시 사무실에는 별도 `10.79.0.0/16` 네트워크의 Dell N1548이 있다. 메인 사무실 관리 정보·포트 매핑을 적용하지 않는다.

구성과 로컬 접근 메모는 `~/Obsidian/Vivident/Memo/switch.md`에 있다. 오래된 도표는 장비를 찾는 단서이지 현재 라우터·멀티 WAN 구성의 증거가 아니다.

## 관리 접근

### Dell S4148T-ON

- 관리 주소는 `192.168.1.254`다. Telnet을 사용하고 연결 시 도달 가능성을 확인한다.
- 인증 정보는 회사 Bitwarden의 `Dell S4148T (Telnet)` 항목이며 `S4148T`로 검색할 수 있다. 별칭을 불러오는 셸에서 `bw-vivident`를 사용한다. 예: `zsh -lic 'bw-vivident status'`. 비밀번호·세션 토큰을 기록하지 않고 클라이언트에 직접 전달한다.
- 문서의 로컬 접근은 같은 사무실 LAN의 PC에 사용하지 않는 `192.168.1.x/24` 주소를 설정한다. 메모의 예시는 게이트웨이 없는 `192.168.1.100`이며 할당 전에 충돌을 확인한다. 주소 설정은 읽기 전용 진단이 아닌 기기 변경이다.
- 관리 서브넷이 Tailscale로 라우팅되거나 일반 `10.78.0.0/16` 출발지에서 도달 가능하다고 가정하지 않는다.

승인된 라우터 경유 연결에서는 `re1`에 임시 보조 주소를 추가해 직접 연결 경로를 만들 수 있다. 다만 LAN 아웃바운드 NAT가 명시적으로 `192.168.1.100`에 바인딩한 연결도 `10.78.142.1`로 바꿀 수 있다. Telnet 시간 초과를 스위치 장애로 판단하기 전에 현재 경로, `pfctl -sn`, 패킷 헤더를 확인한다. ARP 성공만으로 TCP 연결 가능성을 판단하지 않는다.

임시 NAT 예외가 필요하면 해당 LAN NAT 규칙 앞에 선택한 관리 출발지, `192.168.1.254`, TCP 23, `re1`로 한정한다. 기존 규칙·동적 앵커를 보존하고 구문을 검증한다. 예외 하나를 전체 규칙 집합으로 불러오거나 무관한 상태를 비우지 않는다. 접근 후에는 작업에서 추가한 예외·보조 주소만 제거하고 정리 여부를 확인한다. 이 접근 절차 자체가 라우터 설정 변경을 허가하는 것은 아니다.

보조 주소와 필요한 NAT 처리가 준비되면 라우터에서 출발지를 지정해 연결한다.

```sh
telnet -s 192.168.1.100 192.168.1.254
```

### HP 1930과 무선 관리

사무실 메모에 기록된 정보:

- 스위치 UI: `https://wireless.switch.intranet.moelive.tech`
- 무선 관리: `https://wifi.intranet.moelive.tech`
- 회사 Bitwarden 검색어: `wireless` 또는 `wifi`. `bw-vivident` 사용.

메모에서 가져온 URL이므로 사용 시 이름 해석과 접근을 확인한다.

## Dell 읽기 전용 진단

OS10 진단 명령이며 설치 버전의 도움말을 확인한다.

```text
terminal length 0
show version
show clock
show interface status
show running-configuration interface ethernet 1/1/54
show interface ethernet 1/1/54
show interface ethernet 1/1/54 eee
show mac address-table address <current-router-re1-mac>
show spanning-tree interface ethernet 1/1/54 detail
show logging log-file 100
show processes cpu
```

MAC 조회로 포트를 확인하기 전에 `<current-router-re1-mac>`을 현재 라우터 `re1` 주소로 바꾼다. `terminal length 0`은 관리 세션의 페이지 표시를 바꾼다.

- 로그 조회는 개수를 제한한다. 무제한 조회나 광범위한 과거 로그 필터링은 CLI 프로세스 CPU 사용량을 높일 수 있다. 설치된 OS10의 문법을 확인하고 `show logging last 40`이 지원된다고 가정하지 않는다.
- 이벤트를 대조하기 전에 스위치·라우터 시계를 비교한다. 표시된 시간대만으로 시각이 정확하다고 판단하지 않는다.
- 인터페이스 카운터는 수개월 누적될 수 있다. 마지막 초기화 후 경과 시간과 증분을 비교한다. 누적 드롭·스로틀만으로 장애 원인을 단정하지 않는다.
- 링크 상태, CRC·오류, 트래픽 방향, 흐름 제어, MAC 학습, STP를 함께 확인한다. 복구 후 forwarding 상태가 장애 중 상태를 증명하지는 않는다.
- 자동화 세션은 실제 CLI 프롬프트와 설정 모드 접미사를 명시적으로 구분한다. `>`로 끝나는 일반 패턴은 syslog 심각도 접두사를 프롬프트로 오인할 수 있다. 수집 출력에서 인증 정보 에코를 숨긴다.

승인된 변경은 실행 중 설정과 시작 설정을 구분하고 영구 저장 요청·수행 여부를 보고한다. 링크 변경 명령은 관리 연결을 끊을 수 있으므로 다시 연결해 실제 결과를 확인한 뒤 재시도한다.
