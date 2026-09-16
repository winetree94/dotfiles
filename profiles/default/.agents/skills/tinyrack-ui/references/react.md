# React UI

## Required dependencies

| Dependency | Constraint | Purpose |
| --- | --- | --- |
| react, react-dom | ^19.0.0 | Component runtime |
| tailwindcss | ^4.3.0 | Utility framework; use `@tailwindcss/vite` |
| lucide-react | stable | Sole icon library |
| @fontsource/ibm-plex-sans | stable | Sole typeface family |

## Consume the package

Inspect the resolved package's README, `package.json` exports, and relevant type
declarations. Treat the installed release as the API source of truth.

Import foundation CSS before component CSS:

```tsx
import '@tinyrack/ui/core.css';
import '@tinyrack/ui/components/button.css';
import { TRButton } from '@tinyrack/ui/components/button';
```

| Purpose | Public path |
| --- | --- |
| Component | `@tinyrack/ui/components/<component>` |
| Component CSS | `@tinyrack/ui/components/<component>.css` |
| Token metadata | `@tinyrack/ui/core` |
| Foundation CSS | `@tinyrack/ui/core.css` |
| React MDX map/CSS | `@tinyrack/ui/mdx`, `@tinyrack/ui/mdx.css` |
| Provider | `@tinyrack/ui/providers/<provider>` |

Import only the required public subpaths. Do not invent a root barrel, `/react`
or `/dom` suffix, overlay-manager path, or Astro renderer. Ensure `core.css`
reaches the Tailwind build before component styles.

Compose compound components through semantic parts such as `TRTabs.Root`,
`TRTabs.List`, `TRTabs.Tab`, and `TRTabs.Panel`. Preserve native props, events,
refs, state callbacks, focus behavior, and accessibility semantics.

## Styling contract

- Follow `base colors -> semantic tokens -> component tokens`.
- Consume semantic `--tinyrack-*` tokens from component CSS. Customizable
  `--tr-*` component tokens must fall back to them.
- Do not use raw palettes or literal design values such as hex, rgb, or px in
  component or consumer styles. Propose a missing foundation token instead.
- Do not duplicate or override the Tailwind v4 `@theme` integration in `core.css`.
- Use only Lucide React icons and IBM Plex Sans, including the official Korean
  and Japanese variants. Do not introduce another icon or font system.

## Upstream implementation and checks

When upstream work is needed, follow [contributing.md](contributing.md).
Implement under `packages/ui/src/components/<name>/` with semantic implementation
and CSS files plus an export-only `index.tsx`. Wrap Base UI behavior rather than
re-exporting it. Target React 19, accept `ref` as a prop, add `"use client"` only
when required, and ship CSS as a separate public subpath.

Follow current upstream instructions. For a new or broad component change,
include these checks from the repository root:

```bash
pnpm biome check .
pnpm --filter @tinyrack/ui test:unit
pnpm --filter @tinyrack/ui test:e2e
pnpm pack:ui
```

## Verify the consumer

- Run the consumer's typecheck and relevant component or browser tests.
- Build the application to exercise Tailwind v4 processing and package exports.
- Inspect affected keyboard, focus, dismissal, portal, disabled, loading, and
  accessible naming behavior.
