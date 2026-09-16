---
name: tinyrack-docs
description: "@tinyrack/docs 기반 정적 React Router 문서 사이트를 개발하고 문서 패키지를 개선한다. 사이트 설정, 콘텐츠·내비게이션·다국어 구성, 빌드 진단, 패키지 기능 추가가 필요할 때 사용한다."
---

# Tinyrack 문서 사이트

설정과 라우트 콘텐츠로 문서 사이트를 구성한다. 재사용 레이아웃, 내비게이션, 검색, 페이지 이동, SEO 자산, 정적 빌드 파이프라인은 패키지가 담당한다. 제품별 콘텐츠, 브랜딩, 랜딩 화면, 배포는 소비자 프로젝트에 둔다.

## 필수 의존성

| 의존성 | 버전 조건 | 용도 |
| --- | --- | --- |
| react, react-dom | ^19.0.0 | 런타임 |
| react-router | ^8.2.0 < 9.0.0 | 라우팅 |
| vite | ^8.0.0 | `@tailwindcss/vite`와 사용하는 빌드 도구 |
| tailwindcss | ^4.3.0 | 유틸리티 프레임워크. v4만 사용 |
| lucide-react | stable | 아이콘. 다른 아이콘 패키지 추가 금지 |
| @fontsource/ibm-plex-sans, -jp, -kr | stable | 글꼴. IBM Plex Sans만 사용 |
| @tinyrack/ui | npm 배포본 | docs의 UI 컴포넌트 의존성 |

## 사이트 설정

1. 코드 변경 전에 설치된 패키지의 README, `package.json` exports, 관련 타입 선언을 확인한다. 설치 버전을 기준으로 삼고 기억이나 다른 Tinyrack 버전에서 API를 추측하지 않는다.
2. Node.js 24 이상을 사용한다.
3. `@tinyrack/docs/config`의 `defineDocsConfig`로 `docs.config.ts`를 만든다. 프로젝트에 필요한 `contentDir`, 섹션·내비게이션, 사이트 메타데이터, 리디렉션, 언어 설정, 헤더 링크, 테마를 정의한다.
4. 공개 진입점을 연결한다. `@tinyrack/docs/react-router`의 `createDocsRoutes`·`createDocsRouterConfig`, `@tinyrack/docs/vite`의 `tinyrackDocs`, `@tinyrack/docs/styles.css`, `@tinyrack/docs/runtime`의 런타임 루트 export를 사용한다. `tinyrackDocs`는 Tailwind Vite 플러그인 **앞에** 둔다.
5. 표준 `react-router dev`, `react-router build`, `vite preview`를 사용한다. Tinyrack CLI나 스캐폴드 생성기를 찾지 않는다.

## 라우트 작성

- `contentDir`에는 라우트를 만드는 `.mdx`·`.tsx`만 둔다. 가져오는 컴포넌트, 보조 함수, 데모는 밖에 둔다.
- 모든 MDX는 최소 `title`, `description`, `section`, 0 이상의 `order`를 포함한 YAML 프런트매터로 시작한다. 프레임워크가 페이지 제목·설명을 표시하므로 작성 본문은 `##`부터 시작한다.
- 사용자 TSX 라우트는 `@tinyrack/docs/runtime`의 `DocsPage`로 렌더링한다. `frontmatter`는 인라인 정적 객체 리터럴로 전달한다. `headings`도 제공한다면 인라인 정적 배열이어야 하며 ID는 실제 제목과 일치해야 한다.
- 디렉터리 루트는 `index.mdx`·`index.tsx`를 사용한다. `layout`은 `docs`, `splash`, `standalone` 중 하나를 사용한다. 내비게이션에서 제외할 때만 `navigation: false`를 쓴다.
- 다국어 콘텐츠는 언어별 디렉터리에 두고 언어 전환용 공통 `contentKey`를 사용한다. 제품 전용 문구가 필요할 때만 기본 UI 메시지를 재정의한다.

## 아이콘과 글꼴

- 문서 콘텐츠와 사용자 TSX 페이지에는 `lucide-react`만 쓴다. 다른 아이콘 라이브러리를 도입하지 않는다.
- 모든 텍스트는 IBM Plex Sans(`@fontsource/ibm-plex-sans`, `-jp`, `-kr`)만 사용하며 콘텐츠에서 글꼴을 덮어쓰지 않는다.
- 문서 기본 레이아웃이 IBM Plex Sans를 설정하므로 소비자 스타일에서 이를 덮어쓰거나 대체·우회하지 않는다.

## 사이트 검증

- 소비자 프로젝트의 타입 검사와 관련 콘텐츠·설정 테스트를 실행한다.
- 전체 정적 `react-router build`를 실행한다. 매니페스트, 프런트매터, 리디렉션, Pagefind, 자산 오류는 빌드 실패로 취급한다.
- 설정된 기본 경로에서 결과를 미리 보고 변경과 관련한 내비게이션, 검색, 언어 전환, 메타데이터, 정적 자산을 확인한다.
- 소비자 설정·콘텐츠는 소비자 프로젝트에서 고친다. `node_modules`의 설치 패키지를 수정하지 않는다.

## 문서 패키지 기여 절차

`@tinyrack/docs` 자체에 버그·기능 부족이 있거나 소비자 사이트에 패키지가 제공하지 않는 프레임워크 동작이 필요하면 소비자 코드로 우회하지 않는다. 다음 절차를 정확히 따른다.

### 1단계: 중단하고 제안하기

- 소비자 문서 작업을 즉시 멈춘다.
- 필요한 변경(API, 설정 필드, 빌드 훅, 라우팅, 기본 레이아웃 기능 등), 소비자 설정·콘텐츠만으로 해결할 수 없는 이유, 영향받는 하위 경로·타입·플러그인·런타임 export를 명확히 제안한다.
- 진행 전에 사용자의 명시적 승인을 기다린다.

### 2단계: 작업 트리 만들기

```bash
cd ~/Workspaces/tinyrack/design
git fetch origin main
git worktree add --detach ../design-<feature-slug> origin/main
cd ../design-<feature-slug>
pnpm install
```

### 3단계: 문서 패키지 변경 개발

- `packages/docs/src/` 소스 트리만 수정한다.
- 공개 export는 기존 하위 경로를 유지한다. `@tinyrack/docs/config`는 설정 타입과 `defineDocsConfig`, `@tinyrack/docs/react-router`는 라우트·라우터 설정 생성, `@tinyrack/docs/runtime`은 React 런타임 컴포넌트·유틸리티, `@tinyrack/docs/vite`는 `tinyrackDocs` 플러그인, `@tinyrack/docs/styles.css`는 배포 스타일시트다.
- 공개 export를 추가하면 `packages/docs/package.json` exports도 갱신하고 패킹한 패키지를 쓰는 소비자에서 해석되는지 확인한다.
- 선언형 설정, 파일 시스템 기반 라우트, 패키지가 관리하는 기본 레이아웃, 소비자가 관리하는 콘텐츠라는 기존 방식을 유지한다.
- UI 변경에도 `lucide-react`와 IBM Plex Sans만 쓴다.

### 4단계: 검증하고 PR 열기

```bash
pnpm biome check .
pnpm build
pnpm --filter @tinyrack/docs test
pnpm pack:docs
```

- 기능 브랜치에 커밋한다.
- 푸시하고 `tinyrack-net/design`의 `main` 대상으로 PR을 연다.
- 모든 CI(`biome`, `ui` 테스트 작업, `docs` 테스트 작업)가 통과할 때까지 기다린다.

### 5단계: 병합과 릴리스

- 승인과 CI 통과 후 PR을 병합한다.
- 병합 커밋에 주석 태그 `docs-v<X>.<Y>.<Z>`를 만든다.
- docs가 `workspace:^`로 의존하는 `@tinyrack/ui`를 먼저 빌드·패킹한다. 태그를 푸시하고 `.github/workflows/publish-docs-npm.yml` 완료까지 확인한다.
- 새 버전 발행과 UI 의존성을 확인한다.

```bash
  npm view @tinyrack/docs@latest version dependencies.@tinyrack/ui --json
  ```

### 6단계: 소비자 프로젝트로 돌아가기

- `git worktree remove ../design-<feature-slug>`로 작업 트리를 제거한다.
- 소비자 프로젝트 디렉터리로 돌아간다.
- `@tinyrack/docs`를 새 릴리스로 갱신한다.
- 처음 제안이 필요했던 부분에 새 설정·API·동작을 적용한다.
- 소비자 문서 사이트를 다시 빌드하고 처음부터 끝까지 검증한다.
