# 오시즈 운영 데이터 모델

이 문서는 고정된 계약이 아닌 구조 안내다. 분석 전에 실제 카탈로그를 확인한다. 특정 시점의 조사 결과는 이 문서가 아닌 분석 보고서에 남긴다.

## 스키마

| 스키마 | 용도 |
| --- | --- |
| `public` | 사용자, 분석, 세션, 유입 기여, 재화, 구매, 성장, 퀘스트, 제품 상태 |
| `dm_chat` | 개인 채팅방, 메시지, 읽음 상태, 알림 시도 |
| `admin_support_dm` | 고객 지원 채팅방, 메시지, 템플릿 |
| `idolive` | Idola·약속 데이트 세션, 장면, 선택, 보고서, 보상 |
| `memory` | 에피소드·이벤트·의미 기억. 내용은 민감 정보 |
| `studio` | 스튜디오 관리와 콘텐츠 도구 |
| `drizzle` | DB 마이그레이션 메타데이터. 분석 소스가 아님 |

## 주요 분석 테이블

| 질문 | 시작 테이블 | 주요 필드와 주의점 |
| --- | --- | --- |
| 제품 이벤트·퍼널 | `public.analytics_events` | `event_name`, `event_time`, `user_uid`, `anonymous_id`, `session_id`, `route`, `platform`, `app_version`, `locale`, `properties`. `deleted_at`을 필터링하고 JSON 원시 값이 아닌 키를 확인 |
| 사용자 식별 정보 연결 | `public.analytics_identities` | `anonymous_id`와 `user_uid`를 연결. 최초·식별·최근 관측 시점과 `deleted_at` 확인 |
| 가입·사용자 수명 주기 | `public.users` | `created_at`, `last_activity_at`, `status`, 탈퇴 시각. 직접 식별 개인정보가 있으므로 조회하지 않음 |
| 앱 세션 | `public.user_app_sessions` | `started_at`, `ended_at`, `duration_seconds`, `last_route`, `metadata`. 미완료 세션과 `deleted_at` 검증 |
| 사용자 유입 | `public.user_marketing_attributions` | 공급자, 매체, 캠페인 계층, 채널, 첫 실행, 리타기팅, 설치·클릭·접점 시각. `raw_payload`와 공급자 사용자 ID는 민감 정보 |
| 결제 | `public.user_payments` | 공급자 검증 과정, 상태, 결제 가격, 통화 단위, 구매·검증·취소 시각. 영수증·거래 필드는 민감 정보 |
| 구매·지급 | `public.user_purchases` | 상품 차원, 상태, 결제·소비 금액과 단위, 지급 자원, `purchased_at`. 통화끼리 또는 유료 결제와 가상 재화 소비를 섞지 않음 |
| 현재 성장 상태 | `public.user_stats` | 레벨, 누적 경험치, 재화, 스태미나, 현재 상태. 이력이 아닌 스냅샷 |
| 성장 이력 | `public.user_stat_logs` | 시간에 따른 상태 변화. 실제 열을 확인하고 기간을 제한한 뒤 조회 |
| 행동·카운터 | `public.user_action_events`, `public.user_action_counters`, `public.user_action_flags` | 활동·전환 정의 전에 행동 의미와 유일성 확인 |
| Idolive 세션 | `idolive.idola_sessions` | 사용자, 이벤트, 캐릭터, 상태, 턴, 언어, 생성·완료 시각. JSON 맥락은 민감하며 대부분 집계에 불필요 |
| 개인 채팅 | `dm_chat.rooms`, `dm_chat.messages` | 방·메시지 메타데이터만 집계. 메시지 내용, 방 미리보기, 선물 페이로드, 고정 식별자는 조회 금지 |

## 일반적인 조인 키

- `user_uid`는 보통 사용자 소유 레코드와 `public.users.uid`를 연결한다.
- `session_id`는 양쪽 테이블의 형식·유일성을 확인한 뒤 이벤트·세션 활동 연결에 사용한다.
- 구매의 `payment_uid`는 `public.user_payments.uid`에 연결할 수 있다. 재시도나 여러 지급으로 일대다 관계가 생기는지 확인한다.
- `room_uid`는 개인 메시지와 `dm_chat.rooms.uid`를 연결한다.
- Idolive와 채팅 테이블은 DM 방·메시지 UUID로 서로 참조할 수 있다. 조인 전에 NULL 허용 여부와 관계 수를 확인한다.

이름은 관계를 짐작하는 단서일 뿐 업무 의미를 입증하지 않는다. 카탈로그와 집계 쿼리로 키, 제약, NULL 비율, 개별 표본을 노출하지 않는 분포를 확인한다.
