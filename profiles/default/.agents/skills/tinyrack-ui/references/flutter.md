# Flutter UI

## 패키지 사용

소비자의 `pubspec.yaml`, 잠금 파일, 해석된 패키지 메타데이터, import를 확인한다. 설치된 패키지의 README, `pubspec.yaml`, 문서, 공개 `lib/tinyrack_ui.dart` export를 읽는다.

적절한 버전 조건으로 pub.dev 릴리스를 사용한다.

```bash
flutter pub add tinyrack_ui:^<version>
flutter pub get
```

공개 라이브러리를 가져온다.

```dart
import 'package:flutter/material.dart';
import 'package:tinyrack_ui/tinyrack_ui.dart';
```

`package:tinyrack_ui/src/...`를 가져오거나 pub 캐시를 수정하지 않는다. 배포된 업스트림 릴리스 대신 path·git 의존성이나 `dependency_overrides`를 쓰지 않는다. 하위 Material 위젯을 조합하기 전에 공개 TR 위젯과 타입이 지정된 변형을 우선하고 두 테마를 모두 설정한다.

```dart
MaterialApp(
  theme: TinyrackTheme.light(),
  darkTheme: TinyrackTheme.dark(),
  home: const ProductScreen(),
);
```

위젯 수명 주기, 콜백, 포커스, 키보드 동작, 시맨틱, 플랫폼 동작, 텍스트 방향, 접근성 라벨을 보존한다.

## 스타일 규칙

- 공개 Tinyrack 테마, 토큰, 변형, 타이포그래피, 위젯을 사용한다. 패키지 값이 있으면 임의의 `Color`, `TextStyle`, 간격, 반경, 애니메이션 리터럴을 피한다.
- 패키지에 포함된 영어·한국어·일본어 IBM Plex 글꼴을 사용한다. 별도의 앱 글꼴 체계를 도입하지 않는다.
- 일반 Material 위젯으로 외형을 재현하기보다 타입이 지정된 변형과 의미가 정해진 TR 복합 요소를 우선한다.
- 공통 접근성·테마 규칙과 함께 해당하는 disabled, loading, readonly, invalid, hover, pointer 상태를 보존한다.
- React와 의도한 일관성을 구현하더라도 Flutter 고유 편집, 수명 주기, 플랫폼 동작을 유지한다.

## 업스트림 구현과 검사

업스트림 작업은 [contributing.md](contributing.md)를 따른다. `packages/tinyrack_ui/pubspec.yaml`, README, 공개 export, 인접 위젯, 토큰 생성 절차, 테스트, 현재 CI·발행 절차를 읽는다.

공개 export는 `lib/`, 구현은 `lib/src/`에 둔다. 공개 동작을 바꾸면 API 문서·예제도 갱신한다. 생성된 토큰을 손으로 수정하지 말고 현재 저장소 생성기와 일관성 검증 절차를 사용한다.

공개 변경에는 집중 테스트와 패키지 전체 필수 검사를 `packages/tinyrack_ui`에서 실행한다.

```bash
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
dart pub publish --dry-run
```

플랫폼 동작이나 자산이 바뀌면 영향받는 Android, iOS, Linux, macOS, web, Windows 빌드를 실행한다. 공통 외형·상호작용 변경에는 기여 참고 문서의 일관성 검사도 필요하다.

## 소비자 검증

- `dart format .`, `flutter analyze`, `flutter test`를 실행하고 더 엄격한 소비자 지침이 있으면 따른다.
- 영향받는 앱, 통합 테스트, 골든 테스트, 플랫폼 빌드를 실행한다.
- 라이트·다크 테마, 지원 언어, 키보드·화면 낭독기 시맨틱, 텍스트 배율, 레이아웃 제약, 관련 상호작용 상태를 확인한다.
