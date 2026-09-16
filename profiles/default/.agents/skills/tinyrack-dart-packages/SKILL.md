---
name: tinyrack-dart-packages
description: "tinyrack-net/dart-packages의 패키지를 프로젝트에 연동하고 패키지 자체를 개선한다. cliweave, dartage, shipworld 등 해당 패키지의 도입·업그레이드·디버깅·기능 추가·릴리스에 사용한다."
---

# Tinyrack Dart 패키지

소비자 프로젝트에서는 배포된 패키지를 기준으로 삼는다. 재사용 API와 동작은 `tinyrack-net/dart-packages`에, 제품별 정책·모델·흐름 제어·화면 표현은 소비자 프로젝트에 둔다.

업스트림 기준 체크아웃:

```text
~/Workspaces/tinyrack/dart-packages
```

Dart pub 워크스페이스이며 각 패키지는 독립적인 버전으로 검증된 발행자 `tinyrack.net`이 배포한다. 현재 패키지는 다음과 같다.

| 패키지 | 용도 |
| --- | --- |
| `cliweave` | 타입이 지정된 명령 라우팅, 도움말, 자동 완성, 터미널 출력 |
| `dartage` | 순수 Dart 기반 age v1 암호화·복호화 |
| `shipworld` | Dart CLI·Flutter 데스크톱 앱의 릴리스, 서명, 데스크톱 패키징 |

이 표가 전체 목록이라고 가정하지 않는다. 패키지 구성이 중요하면 업스트림 루트 `pubspec.yaml`과 `packages/*/pubspec.yaml`을 확인한다.

## 소비자에서 패키지 사용

1. 코드 편집 전에 소비자의 `pubspec.yaml`, 잠금 파일, 해석된 패키지 메타데이터, 가져오는 라이브러리를 확인한다.
2. 설치 버전의 README와 공개 `lib/*.dart` 진입점을 읽는다. 해석된 버전을 기준으로 삼고 기억, 무관한 체크아웃, 더 최신의 미배포 리비전에서 API를 추측하지 않는다.
3. 적절한 버전 조건으로 pub.dev 릴리스를 사용한다. 업스트림 릴리스 대신 git·path 의존성, `dependency_overrides`, pub 캐시 편집을 사용하지 않는다.
4. 공개 `package:<name>/<library>.dart` 진입점만 가져온다. 다른 패키지의 `lib/src/`를 가져오지 않는다.
5. 공개 타입, 오류 의미, 비동기·플랫폼 동작, 보안 보장을 유지한다. 제품 개념을 공통 패키지에 넣지 말고 소비자에서 필요한 연결 코드를 작성한다.
6. `0.x` 패키지는 업그레이드 전에 변경 이력·마이그레이션 가이드를 읽는다. 마이너 릴리스에도 호환성을 깨는 API 변경이 있을 수 있다.

프로젝트의 기존 패키지 관리 명령을 사용한다. 순수 Dart 프로젝트:

```bash
dart pub add <package>:^<version>
dart pub get
```

Flutter 프로젝트 또는 `pubspec.yaml`에 `flutter` SDK 의존성이 있는 패키지:

```bash
flutter pub add <package>:^<version>
flutter pub get
```

패키지 목적상 Flutter가 명시적으로 필요하지 않으면 순수 Dart 패키지에 Flutter SDK 의존성을 넣지 않는다.

## 소비자 검증

먼저 소비자 저장소의 `AGENTS.md`와 기존 검증 절차를 따른다. 연동 후에는 최소한 관련 검사를 실행한다.

Dart:

```bash
dart format .
dart analyze --fatal-infos
dart test
```

Flutter:

```bash
dart format .
flutter analyze
flutter test
```

변경한 패키지 동작을 사용하는 소비자 실행 파일, 빌드, 통합·플랫폼 테스트도 실행한다. 연동 코드는 소비자에서 수정하며 내려받은 패키지 파일을 고치지 않는다.

## 업스트림 기여 범위

배포 패키지에 버그가 있거나, 재사용 기능이 부족하거나, 여러 제품에 필요한 공개 API가 없을 때 기여 절차를 사용한다. 어댑터 작성을 피하려고 제품 전용 동작을 업스트림에 넣지 않는다.

### 1단계: 중단하고 제안하기

- 업스트림 한계를 발견한 지점에서 소비자 작업을 멈춘다.
- 관찰한 동작과 소비자 측 조합으로 올바르게 해결할 수 없는 이유를 설명한다.
- 대상 패키지, 공개 API·동작 변경, 호환성 영향, 테스트, 예상 시맨틱 버전 증가를 제안한다.
- 업스트림 저장소를 변경하기 전에 사용자 명시적 승인을 기다린다.

### 2단계: 새 작업 트리 만들기

기준 체크아웃의 로컬 `main`은 오래됐을 수 있으므로 여기서 분기하지 않는다. 최신 `origin/main`을 가져온 뒤 바로 이름을 정한 기능 브랜치를 만든다.

```bash
cd ~/Workspaces/tinyrack/dart-packages
git fetch origin main
git worktree add -b <package>-<change-slug> ../dart-packages-<change-slug> origin/main
cd ../dart-packages-<change-slug>
dart pub get
```

브랜치·작업 트리를 만들기 전에 기존 목록을 확인해 충돌하지 않는 이름을 고른다. 최신 상태로 맞추려고 기준 체크아웃을 수정·초기화·정리하지 않는다.

### 3단계: 패키지 변경 개발

- 편집 전에 업스트림 `AGENTS.md`, 루트 `pubspec.yaml`, 패키지 README, 변경 이력, 공개 진입점, 구현, 테스트를 읽는다.
- 워크스페이스 설정·CI·발행 변경이 꼭 필요한 경우 외에는 해당 패키지 안에서 수정한다.
- 공개 라이브러리는 `lib/`, 내부 구현은 `lib/src/`에 두어 공개·비공개 경계를 유지한다.
- 집중된 회귀·기능 테스트를 추가한다. 가능하면 지원하는 모든 플랫폼에서 플랫폼별 동작을 검증한다.
- 동작·공개 API가 바뀌면 사용자 API 문서, 예제, README, 마이그레이션 안내를 갱신한다.
- 같은 PR에서 해당 패키지 `CHANGELOG.md`와 `pubspec.yaml` 버전을 갱신한다. 시맨틱 버전을 따르며 `0.x`의 호환성 파괴 변경은 보통 마이너 버전을 올린다.
- 설명, SDK 범위, 저장소, 주제, 라이선스 표시, 공개 API 문서 등 pub.dev 메타데이터를 유효하게 유지한다.
- 새 패키지는 루트 pub 워크스페이스에 추가하고 기존 관례에 맞는 CI·태그 기반 발행 워크플로를 추가한다.

Flutter 패키지는 기존 Flutter 버전 조건이 있으면 따르고 의존성 해석, 분석, 테스트, 패키지 검증에 Flutter 명령을 쓴다. 무관한 순수 Dart 워크스페이스 패키지를 Flutter로 바꾸지 않는다.

### 4단계: 업스트림 변경 검증

변경한 순수 Dart 패키지마다 해당 디렉터리에서 실행한다.

```bash
dart format .
dart analyze --fatal-infos
dart test
dart doc
dart pub publish --dry-run
```

워크스페이스 메타데이터나 패키지 간 관계가 바뀌면 저장소 루트에서 `dart pub get`과 워크스페이스 전체 분석을 실행한다.

`dartage`는 오프라인·참조 구현 상호운용 테스트를 모두 실행한다.

```bash
dart test -x interop
cd test/interop
pnpm install --frozen-lockfile
cd ../..
dart test -t interop
```

`shipworld`는 Windows에서 저장소 커버리지 검사를 수행하고 pub 워크스페이스 밖에서도 작동하는지 확인한다.

```powershell
dart run tool/verify_coverage.dart shipworld
dart run packages/shipworld/tool/validate_standalone.dart
```

`shipworld` 데스크톱 패키징 변경은 현재 CI에 정의된 관련 Windows MSIX, macOS 서명·아카이브, Linux AppImage, Homebrew, Flutter 페이로드 작업도 실행해야 한다. 호스트 플랫폼 단위 테스트만으로 다른 플랫폼의 생성물을 충분히 검증했다고 판단하지 않는다.

Flutter 패키지는 해당 디렉터리에서 대응하는 검사를 실행한다.

```bash
dart format .
flutter analyze
flutter test
dart doc
flutter pub publish --dry-run
```

현재 업스트림 `AGENTS.md`와 CI가 요구하는 추가 명령도 실행한다. 실패를 해결한 뒤 PR을 열거나 갱신한다.

### 5단계: PR 열고 검증하기

- 커밋 전에 `git status`, `git diff`, 최근 커밋을 확인한다.
- 의도한 패키지와 관련 워크스페이스 변경만 커밋한다.
- 기능 브랜치를 푸시하고 `tinyrack-net/dart-packages`의 `main` 대상으로 PR을 연다.
- 소비자 문제, 공개 API·동작 변경, 호환성 영향, 버전 변경, 검증 내용을 요약한다.
- 현재 필수 GitHub 검사가 모두 통과할 때까지 기다린다. 기억 속 작업 이름 대신 저장소 워크플로를 확인한다. 현재는 포맷·분석, 플랫폼별 패키지 테스트, `dartage` 상호운용, 문서, 발행 모의 실행, 패키지별 커버리지, `shipworld` 독립 실행·Flutter 데스크톱 페이로드 검증을 포함한다.
- 리뷰·CI 실패는 새 커밋으로 해결한다. 검사를 우회하거나 강제 푸시하지 않는다.

### 6단계: 병합과 릴리스

- 승인과 필수 검사 통과 후에만 병합한다.
- 갱신된 `main`을 가져와 정확한 병합 커밋을 확인한다. 병합된 `pubspec.yaml`에서 버전을 읽고 버전을 지어내거나 재사용하지 않는다.
- 해당 병합 커밋에 패키지별 주석 태그를 만든다.

```bash
  git tag -a <package>-v<X>.<Y>.<Z> <merged-commit> -m "<package> <X>.<Y>.<Z>"
  git push origin <package>-v<X>.<Y>.<Z>
  ```

- 해당 `.github/workflows/publish-<package>.yml` 실행이 성공할 때까지 확인한다. PR만 병합되고 발행이 성공하지 않았다면 릴리스 완료가 아니다.
- 소비자 갱신 전에 `https://pub.dev/api/packages/<package>`에서 정확한 버전이 제공되는지 확인한다.
- 발행 실패는 업스트림 릴리스 절차에서 진단·수정한다. 기존 태그를 옮기거나 몰래 다른 커밋을 발행하지 않는다.

### 7단계: 소비자로 돌아가기

- 기준 업스트림 체크아웃에서 완료된 작업 트리를 제거한다.

```bash
  cd ~/Workspaces/tinyrack/dart-packages
  git worktree remove ../dart-packages-<change-slug>
  ```

- 원래 소비자 저장소로 돌아가 `dart pub add` 또는 `flutter pub add`로 패키지 조건을 새 배포 버전으로 바꾼다.
- 재정의 없이 의존성을 해석하고 잠금 파일이 배포된 pub.dev 버전을 선택했는지 확인한다.
- 멈춘 지점부터 소비자 변경을 재개하고 관련 빌드·통합 테스트를 포함한 전체 소비자 검증을 실행한다.

업스트림 릴리스가 제공되고, 소비자가 pub.dev에서 이를 사용하며, 업스트림·소비자 검증이 모두 통과하기 전에는 원래 소비자 작업을 완료했다고 보고하지 않는다.
