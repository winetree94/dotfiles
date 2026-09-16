# 업스트림 기여

`tinyrack-net/design`의 재사용 가능한 버그 또는 부족한 컴포넌트·위젯·토큰·변형·테마 기능을 다룰 때만 읽는다.

## 범위 확정

배포 패키지로 소비자 요구를 충족할 수 없으면 의존하는 소비자 변경을 멈추고 조합만으로 해결할 수 없는 이유를 설명한다. 공개 API, 동작, 상태, 변형, 토큰, 영향받는 플랫폼, 일관성 영향, 테스트, 시맨틱 버전 증가를 제안한다. 현재 요청이나 앞선 승인이 업스트림 변경을 포함하지 않으면 명시적 승인을 받는다. 이미 승인된 기여를 다시 승인받지 않는다.

영향받는 패키지만 선택한다. React 또는 Flutter만 바꾸면 다른 패키지를 수정·배포할 필요는 없다. 공통 토큰·일관성 작업은 두 플랫폼 참고 문서와 관련 패키지 검사가 필요하다.

## 작업 트리와 구현

기준 체크아웃은 `~/Workspaces/tinyrack/design`이다. 현재 `origin/main`을 가져오고 기준 체크아웃을 수정하지 않은 채 이름을 정한 새 작업 트리를 만든다.

```bash
cd ~/Workspaces/tinyrack/design
git fetch origin main
git worktree add -b ui-<change-slug> ../design-<change-slug> origin/main
cd ../design-<change-slug>
pnpm install
```

Flutter 전용 작업의 브랜치 접두사는 `flutter-<change-slug>`를 사용한다. Flutter 변경은 `packages/tinyrack_ui`에서 `flutter pub get`도 실행한다.

편집 전에 업스트림 `AGENTS.md`, 적용되는 저장소 스킬, 관련 매니페스트, export, 인접 컴포넌트, CI·발행 절차를 읽는다. 해당하는 [react.md](react.md) 또는 [flutter.md](flutter.md)의 구현 규칙과 검사를 적용한다. 공통 컴포넌트 외형·상호작용 변경은 저장소 루트에서 다음도 실행한다.

```bash
pnpm --filter @tinyrack/homepage test:visual-parity
```

## PR과 릴리스

1. 현재 매니페스트, 레지스트리, 태그 상태에서 각 관련 패키지의 시맨틱 버전을 결정한다. 버전·변경 이력과 관련 API 문서·예제를 PR에 포함한다.
2. `tinyrack-net/design`의 `main` 대상으로 PR을 연다. 리뷰와 필수 CI·플랫폼·미리보기·일관성 검사 문제는 새 커밋으로 해결한다. 기존 승인을 존중하면서 승인과 검사 통과 후에만 병합한다.
3. 태그 전에 병합된 매니페스트와 현재 발행 절차를 읽는다. 정확한 병합 커밋에 태그하고 해당 릴리스의 실행을 추적한다. 푸시된 릴리스 태그를 옮기거나 재사용하지 않는다.

| 패키지 | 릴리스 태그 | 발행 확인 |
| --- | --- | --- |
| `@tinyrack/ui` | `ui-v<X>.<Y>.<Z>` | npm 워크플로와 정확한 버전의 레지스트리 메타데이터 |
| `tinyrack_ui` | 주석 태그 `tinyrack_ui-v<X>.<Y>.<Z>` | `.github/workflows/publish-flutter.yml`과 pub.dev의 정확한 릴리스 |

npm은 배포 버전과 아티팩트 메타데이터를 확인한다.

```bash
npm view @tinyrack/ui@<version> version dist.tarball dist.integrity repository --json
```

워크플로가 특정 dist-tag로 발행하면 그 태그도 확인한다. 계속 바뀌는 `latest`만 릴리스 증거로 삼지 않는다.

## 소비자로 돌아가기

해당 릴리스를 확인한 뒤 미완료 변경을 버리지 않고 완료된 작업 트리를 제거한다. 소비자를 배포 버전으로 올리고 잠금 파일을 갱신한다. Flutter는 `flutter pub get`을 사용한다. 원래 연동과 플랫폼별 소비자 검사를 마친다. 실패했거나 진행 중인 릴리스를 패키지 캐시 편집·Flutter 의존성 재정의로 우회하지 않는다.
