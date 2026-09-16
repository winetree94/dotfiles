# 플랫폼과 기기 등록

## 인벤토리와 연결 방식

현재 저장소는 Ubuntu 26.04 이상, macOS, Windows 10/11을 지원한다. 플랫폼을 추가하기 전에 설정 플레이북의 OS 검증 조건을 읽는다. 임의의 Linux 배포판을 Ubuntu로 취급하려고 검증을 우회하지 않는다.

원격 호스트는 정적 인벤토리 그룹 `ubuntu`, `macos`, `windows` 중 하나에 속해야 첫 연결 전부터 셸과 권한 상승 설정이 준비된다. 런타임 팩트로 그룹과 실제 OS가 일치하는지 검증한다. `desktop` 같은 호스트명이 Windows를 뜻하지는 않는다.

명시적으로 활성화한 `localhost`는 실행 시 OS를 분류하며 정적 OS 그룹에 넣지 않는다. 네이티브 Windows는 ansible-core 컨트롤러로 사용할 수 없다. WSL에서 `localhost`는 Linux 게스트를 뜻하며 Windows 호스트는 별도 OpenSSH 대상으로 등록해야 한다. 다른 작업의 부수 효과로 주석 처리된 인벤토리 항목을 활성화하지 않는다.

| 플랫폼 | 주요 동작 |
| --- | --- |
| Ubuntu | 데스크톱 세션을 감지해 GUI 앱을 자동 활성화한다. 저장소의 `sudo_wrapped` become 플러그인을 사용하며 Linux Homebrew는 플레이북이 초기 설치한다. |
| macOS | GUI가 기본 활성화되고 Homebrew가 미리 필요하다. Xcode 역할이 공통 도구보다 먼저 Command Line Tools를 준비한다. 권한이 필요한 작업은 sudo를 쓴다. |
| Windows | OpenSSH, PowerShell, `runas`를 사용하고 패키지는 공통 winget 역할로 설치한다. 권한 상승에는 Windows Hello PIN이 아닌 계정 비밀번호가 필요하다. |
| WSL | GUI 자동 감지에서 제외하고 VPN 역할은 기본 비활성화한다. 스왑은 Windows 호스트가 관리하므로 네이티브 Ubuntu 스왑 관리를 건너뛴다. |

재정의는 현재 그룹 변수, 호스트 변수, 플레이북 실행 조건을 확인한다. OS 이름만으로 GUI·VPN 동작을 추측하거나 호스트 네트워크를 고치려고 게스트 VPN을 자동 활성화하지 않는다.

## 기기 등록

1. 요청 기기, 지원 OS, 연결 계정, SSH 초기 설정을 확인한다. README의 플랫폼별 준비 사항을 읽는다. 최초 authorized key 설치, macOS 원격 로그인, Windows OpenSSH·PowerShell 설정, 계정 로그인은 사용자 조치가 필요할 수 있다.
2. `inventories/hosts.yml`의 해당 정적 그룹에 호스트를 추가하고, 기기별 재정의는 `inventories/host_vars/<host>.yml`에 둔다.
3. 암호화된 단일 `inventories/group_vars/all/vault.yml` 구조를 유지한다. 호스트 인증 정보는 호스트명의 하이픈을 밑줄로 바꾼 `vault_<host>_username`, `vault_<host>_become_password`를 쓰고 인벤토리에서 연결 변수에 매핑한다. 그 밖의 비밀 정보 매핑은 역할 안이 아닌 `group_vars/all/main.yml`에 둔다.
4. 본 스킬의 검증 및 대상 한정 등록 절차를 따른다. 설정 전에 연결을, 적용 뒤에는 실제 결과를 확인한다.

저장소의 `.vault_pass`는 `bw`로 개인 Bitwarden 항목 `dev-machines (ansible vault)`에서 가져온다. 설정에 필요할 때만 값을 출력하지 않고 조회한다. Git 추적에서 제외된 비공개 로컬 비밀번호 파일 방식을 유지한다.

SSH 키 내용은 `vault_ssh_private_key`에서 `ansible_private_key`를 거쳐 Ansible의 실행별 에이전트(`ssh_agent = auto`)로 전달된다. 이를 개인 키 파일 내보내기나 SSH 비밀번호 인증으로 바꾸지 않는다. 추적 중인 공개 키는 다른 곳에서도 사용하므로 키 교체를 기기 하나의 정리 작업으로 취급하지 않는다.

Apple ID·App Store 로그인, VPN 인증 등 문서에 명시된 수동 단계는 프로비저닝과 구분한다. VPN이나 Syncthing 설치가 터널 인증 정보, Syncthing 기기·폴더, 방화벽 규칙 설정까지 포함하지는 않는다. 패키지만 설치하고 완전히 사용 가능하다고 말하지 말고 남은 설정을 알린다.
