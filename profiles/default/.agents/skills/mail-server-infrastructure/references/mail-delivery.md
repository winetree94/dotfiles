# 메일 전달과 네트워크 진단

현재 저장소 README, Stalwart·Bulwark 매니페스트, Service, 인그레스 경로, Cilium 정책, Ansible 네트워크 설정을 읽는다. 이 소스의 주소·프로토콜 설정을 현재 목표 상태로 보고 읽기 전용 관찰 결과와 비교한다.

## 트래픽과 식별 정보

- 대표 메일 호스트명은 `mail.winetree94.com`이다. 현재 CLI 도움말을 확인한 뒤 올바른 계정·프로필과 `winetree94.com` 영역을 선택해 `cf`로 Cloudflare DNS를 조회·관리한다. SMTP·IMAP이 일반 HTTP 프록시를 쓸 수 있다고 가정하거나 다른 환경의 Tunnel 전용 정책을 강제하지 않는다. PTR은 IP 공급자가 관리하며 Cloudflare DNS를 관리한다고 역방향 DNS도 관리하는 것은 아니다.
- Stalwart는 LoadBalancer Service로 SMTP·submission, IMAP, POP3, ManageSieve를 제공하고 Traefik은 웹·관리 화면을 처리한다. 포트 목록을 추측해 열지 말고 Service 정의에서 실제 포트를 확인한다.
- Ansible은 메일 호스트에 Hetzner Floating IP를 영구 설정한다. Stalwart의 외부 IPv4 트래픽은 이 주소를 사용하도록 설계되어 있다. 메일 호스트명의 A 레코드와 Floating IP PTR이 일치해야 하며 문서의 EHLO 호스트명은 `mail.winetree94.com`이다.
- 문서상 Stalwart 라우팅은 로컬 도메인을 `local`, 외부 도메인을 IPv4 전용 `mx`로 보낸다. 라우팅 변경 전에 런타임 설정과 저장소를 대조한다.

## 조사

수신 실패는 수신 도메인 MX 해석, 목적지 주소, 리스너·TLS 연결, 방화벽 판정, Stalwart 수락·로컬 전달 순으로 추적한다. 발신 실패는 큐 상태와 SMTP 응답 코드, DNS·MX 해석, 선택 경로, 외부 송신 IP·PTR·EHLO, 발신 도메인의 SPF·DKIM·DMARC를 확인한다. 전송 거부와 인증·평판 문제를 구분한다.

웹메일 장애는 SMTP 리스너 문제로 단정하지 말고 Bulwark, JMAP 엔드포인트, TLS, 인그레스 경로를 확인한다. 사용자 메일이나 비밀 정보를 통째로 출력하기보다 메타데이터와 범위를 좁힌 로그를 우선한다.

담당 설정 원본을 수정하고 반영 상태와 처음 실패한 경로를 검증한다. 시험 메일 발송은 외부에 영향을 주는 작업이다. 사용자가 발송을 명시적으로 허용하고 발신자·수신자가 정해졌을 때만 보낸다. 그렇지 않으면 완료한 비발송 검사와 아직 남은 전달 시험을 보고한다.
