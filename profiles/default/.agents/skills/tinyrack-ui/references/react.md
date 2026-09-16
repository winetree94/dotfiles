# React UI

## 필수 의존성

| 의존성 | 버전 조건 | 용도 |
| --- | --- | --- |
| react, react-dom | ^19.0.0 | 컴포넌트 런타임 |
| tailwindcss | ^4.3.0 | 유틸리티 프레임워크. `@tailwindcss/vite` 사용 |
| lucide-react | stable | 유일한 아이콘 라이브러리 |
| @fontsource/ibm-plex-sans | stable | 유일한 글꼴 계열 |

## 패키지 사용

실제로 설치된 패키지의 README, `package.json` exports, 관련 타입 선언을 확인한다. 설치된 릴리스를 API의 기준으로 삼는다.

기반 CSS를 컴포넌트 CSS보다 먼저 가져온다.

```tsx
import '@tinyrack/ui/core.css';
import '@tinyrack/ui/components/button.css';
import { TRButton } from '@tinyrack/ui/components/button';
```

| 용도 | 공개 경로 |
| --- | --- |
| 컴포넌트 | `@tinyrack/ui/components/<component>` |
| 컴포넌트 CSS | `@tinyrack/ui/components/<component>.css` |
| 토큰 메타데이터 | `@tinyrack/ui/core` |
| 기반 CSS | `@tinyrack/ui/core.css` |
| React MDX 매핑·CSS | `@tinyrack/ui/mdx`, `@tinyrack/ui/mdx.css` |
| 프로바이더 | `@tinyrack/ui/providers/<provider>` |

필요한 공개 하위 경로만 가져온다. 루트 통합 export, `/react`·`/dom` 접미사, overlay-manager 경로, Astro 렌더러를 지어내지 않는다. Tailwind 빌드에서 `core.css`가 컴포넌트 스타일보다 먼저 처리되게 한다.

복합 컴포넌트는 `TRTabs.Root`, `TRTabs.List`, `TRTabs.Tab`, `TRTabs.Panel`처럼 의미가 정해진 부분으로 조합한다. 네이티브 props, 이벤트, refs, 상태 콜백, 포커스 동작, 접근성 의미를 보존한다.

## 스타일 규칙

- 기본 색상 → 의미 토큰 → 컴포넌트 토큰 순서를 따른다.
- 컴포넌트 CSS에서는 의미 토큰 `--tinyrack-*`를 사용한다. 사용자 지정 가능한 `--tr-*` 컴포넌트 토큰은 이를 기본값으로 삼아야 한다.
- 컴포넌트·소비자 스타일에 원시 팔레트나 hex, rgb, px 같은 디자인 값 리터럴을 쓰지 않는다. 필요한 기반 토큰이 없다면 추가를 제안한다.
- `core.css`의 Tailwind v4 `@theme` 연동을 중복하거나 덮어쓰지 않는다.
- Lucide React 아이콘과 공식 한국어·일본어 변형을 포함한 IBM Plex Sans만 사용한다. 다른 아이콘·글꼴 체계를 도입하지 않는다.

## 업스트림 구현과 검사

업스트림 작업이 필요하면 [contributing.md](contributing.md)를 따른다. `packages/ui/src/components/<name>/`에 의미에 맞는 구현·CSS 파일과 export만 담은 `index.tsx`를 둔다. Base UI를 그대로 다시 내보내지 말고 동작을 감싸서 제공한다. React 19를 대상으로 하고 `ref`를 prop으로 받는다. 필요할 때만 `"use client"`를 추가하며 CSS는 별도 공개 하위 경로로 배포한다.

현재 업스트림 지침을 따른다. 새 컴포넌트나 광범위한 변경에는 저장소 루트에서 다음 검사를 수행한다.

```bash
pnpm biome check .
pnpm --filter @tinyrack/ui test:unit
pnpm --filter @tinyrack/ui test:e2e
pnpm pack:ui
```

## 소비자 검증

- 소비자 프로젝트의 타입 검사와 관련 컴포넌트·브라우저 테스트를 실행한다.
- 앱을 빌드해 Tailwind v4 처리와 패키지 export를 확인한다.
- 영향받는 키보드, 포커스, 닫기, 포털, 비활성화, 로딩, 접근 가능한 이름 동작을 확인한다.
