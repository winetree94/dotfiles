---
name: tinyrack-ui
description: "@tinyrack/ui와 tinyrack_ui로 React·Flutter UI를 구성하고 공통 디자인 시스템을 개선한다. 컴포넌트 연동, 테마·토큰·접근성 개선, 플랫폼 간 디자인 일관성 확보, UI 패키지 수정·릴리스에 사용한다."
---

# Tinyrack UI

## 플랫폼 선택

소비자 프로젝트의 매니페스트, 잠금 파일, import, 요청 범위에서 플랫폼을 확인한다. Flutter web은 React가 아닌 Flutter 소비자다.

- React와 `@tinyrack/ui`는 [references/react.md](references/react.md)를 읽는다.
- Flutter와 `tinyrack_ui`는 [references/flutter.md](references/flutter.md)를 읽는다.
- 공통 토큰이나 시각적 일관성처럼 의도적으로 두 플랫폼을 다루는 작업에서만 둘 다 읽는다. 같은 저장소에 있다고 두 패키지를 모두 변경·배포할 필요는 없다.
- 재사용 패키지의 버그나 공통 기능 부족은 [references/contributing.md](references/contributing.md)도 읽는다. 일반 소비자 연동에는 업스트림 절차가 필요하지 않다.

`@tinyrack/docs` 사이트 설정·문서 연동은 `tinyrack-docs`도 사용한다. `tinyrack-net/dart-packages`의 패키지는 `tinyrack-dart-packages`가 담당하지만 `tinyrack_ui`는 이 스킬이 담당한다.

## 공통 디자인 원칙

- 편집 전에 설치된 릴리스의 문서와 공개 export를 확인한다. 기억이나 아직 배포되지 않은 체크아웃에서 API를 추측하지 않는다.
- 제품 정책과 흐름 제어는 앱에, 재사용 컴포넌트·테마·토큰·컴포넌트 의미는 Tinyrack에 둔다.
- 배포된 패키지와 공개 API를 사용한다. 필수 업스트림 릴리스를 우회하려고 `node_modules`나 pub 캐시를 수정하지 않는다.
- 라이트·다크 동작, 눈에 보이는 포커스, 대비, 키보드 조작, 접근 가능한 이름, 영향받는 상호작용 상태를 보존한다.
- 각 플랫폼의 문서화된 글꼴 연동을 통해 영어·한국어·일본어를 포함한 IBM Plex 타이포그래피를 유지한다.
- 플랫폼 고유 수명 주기, 편집, 동작을 유지하면서 의도한 디자인 일관성을 지킨다. React의 디자인 값 리터럴 금지와 Flutter의 패키지 값 우선은 각 참고 문서에 정한 서로 다른 규칙이다.

소비자 작업은 해당 플랫폼 검증과 프로젝트 필수 검사를 마쳐야 완료된다. 업스트림 작업은 해당 릴리스 검증과 원래 소비자 연동까지 끝나야 완료된다.
