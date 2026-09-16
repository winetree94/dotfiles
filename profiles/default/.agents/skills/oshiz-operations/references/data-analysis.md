# 오시즈 데이터 분석

`psql`과 `OSHIZ_PRODUCTION_READONLY_DATABASE` 환경 변수로 오시즈 운영 읽기 복제본에 질의한다. 모든 연결을 운영 환경 접근으로 취급한다.

테이블·조인을 선택하기 전에 [data-model.md](data-model.md)를 읽는다.

## 연결하기

1. 값을 출력하지 않고 `psql` 설치 여부와 `OSHIZ_PRODUCTION_READONLY_DATABASE` 환경 변수 설정 여부를 확인한다.
2. 모든 쿼리는 명시적 읽기 전용 트랜잭션, `ON_ERROR_STOP`, 사용자 psql 설정 제외, 페이저 비활성화, 짧은 실행 제한 시간으로 실행한다.

## 운영 데이터 접근 제한

- `SELECT`, 카탈로그 조회, `ANALYZE` 없는 `EXPLAIN`만 실행한다.
- 권한상 가능해 보여도 DDL, DML, `CALL`, `DO`, `COPY ... PROGRAM`, 유지보수 명령, advisory lock, 데이터를 바꾸는 함수를 실행하지 않는다.
- 데이터베이스, 역할, 스키마, 권한, 세션 기본값을 변경하지 않는다.
- 연결 URL·인증 정보를 출력, 기록, 저장하거나 응답에 포함하지 않는다.
- 행 단위 개인정보·민감 정보를 반환하지 않는다. 이름, 이메일, 공급자 식별자, 메시지·기억 내용, 영수증, 서명, 거래 식별자, 원시 JSON 페이로드가 포함된다.
- 사용자 단위 결과는 집계한다. 사용자 UUID, 익명 ID, 세션 ID, 방 ID 등 고정 식별자를 노출하지 않는다. 사용자가 정당한 이유를 제시하고 명시적으로 달리 요청하지 않았다면 5명 미만 코호트 행은 숨기거나 합친다.
- 내용 조회보다 메타데이터·개수를 우선한다. JSON 구조가 필요하면 값 대신 키·유형을 확인한다.

## 분석 절차

1. 지표 정의, 기간, 시간대, 모집단, 요청한 분석 차원을 정리한다. 모호함이 결과를 실질적으로 바꿀 때만 간결한 질문 하나를 한다.
2. 분석 쿼리 전에 관련 테이블, 열, enum 값, 인덱스, 대략적인 테이블 크기를 확인한다. 스키마가 바뀔 수 있으므로 참고 문서만 믿지 않는다.
3. 타임스탬프 범위와 시간대 가정을 검증한다. DB 시각은 흔히 `timestamp without time zone`이므로 설명 없이 현지 시각이나 UTC로 표시하지 않는다.
4. 특히 `public.analytics_events`, `public.user_stat_logs`, `public.user_action_events`, 채팅 메시지에는 초반부터 날짜 범위 조건을 넣는다.
5. 삭제 레코드를 분석하는 경우가 아니라면 해당 열이 있는 테이블에 `deleted_at IS NULL`을 적용한다.
6. 집계 전에 조인의 관계 수를 확인한다. 일대다 테이블을 먼저 집계하거나 조인 전후 행 수를 비교해 중복 증폭을 막는다.
7. 비용이 클 수 있는 쿼리는 `ANALYZE` 없는 `EXPLAIN`을 사용한다. 큰 테이블의 무제한 정확한 개수 조회를 피하고 쿼리 규모 판단에는 `pg_stat_user_tables.n_live_tup`의 현재 추정치를 사용한다. 이 통계는 정확한 개수가 아니다.
8. 총계 대조, NULL 비율, 조인 전후 고유 사용자 수 비교, 다른 방식의 쿼리 등 독립적인 검사 하나 이상으로 결과를 검증한다.

구조 확인에 유용한 쿼리:

```sql
SELECT schemaname, relname AS table_name, n_live_tup AS estimated_rows
FROM pg_stat_user_tables
ORDER BY schemaname, relname;

SELECT table_schema, table_name, ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'analytics_events'
ORDER BY ordinal_position;

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'analytics_events';

SELECT jsonb_object_keys(properties) AS property_key, count(*)
FROM public.analytics_events
WHERE event_name = '<event>'
  AND event_time >= '<bounded start>'
  AND event_time < '<bounded end>'
  AND deleted_at IS NULL
GROUP BY 1
ORDER BY 2 DESC;
```

구조를 알아내려고 원시 `properties`, `payload`, `content` 또는 이에 준하는 필드를 조회하지 않는다.

## 지표별 확인 사항

- 이벤트: `user_uid`, `anonymous_id`, `session_id`를 구분하고 사용한 식별 규칙을 밝힌다. 이벤트명·JSON 속성의 의미는 확인 없이 가정하지 않는다.
- 유입: `user_marketing_attributions`를 사용하고 최초 접점·최근 접점을 정의한다. 리타기팅은 명시적으로 필터링하거나 구분한다.
- 매출: `user_payments`와 `user_purchases`를 구분한다. 성공·검증 완료 상태를 정의하고 필요에 따라 취소·삭제 레코드를 제외한다. 서로 다른 `price_unit` 통화를 합산하지 않는다.
- 리텐션: 코호트 진입 이벤트와 재방문 이벤트를 정의하고 완전한 관측 기간을 사용한다. 익명 활동 포함 여부를 밝힌다.
- 채팅: 개수, 역할, 종류, 시각 등 메시지 메타데이터를 집계한다. 메시지 `content`나 방 미리보기 문구를 가져오지 않는다.
- Idolive: 관측된 상태나 `completed_at`으로 완료를 정의한다. 생성된 세션이 모두 플레이 완료를 뜻한다고 가정하지 않는다.

## 결과 보고

사용자의 언어로 다음 내용을 포함한다.

- 질문에 대한 직접적인 답과 주요 수치.
- 지표 정의, 기간, 시간대 가정, 필터, 식별 규칙.
- 간결한 결과 표나 추세 요약.
- 인증 정보와 민감한 리터럴 값을 제외한 사용 SQL.
- 데이터 품질 한계, 소규모 코호트 숨김 여부, 수행한 검증.

측정된 사실과 해석을 명확히 구분한다. 신뢰할 만한 결론을 뒷받침할 데이터가 없다면 가정으로 대신하지 말고 그 사실을 알린다.
