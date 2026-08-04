---
name: tinyrack-web-ui
description: Build and maintain React web interfaces that consume the published @tinyrack/ui npm package. Use for React component integration, design-token compliance, Tailwind v4 styling, package upgrades, or upstream web component fixes, additions, releases, and consumer reintegration. Do not use for Flutter or the tinyrack_ui pub package.
---

# Tinyrack Web UI

Use the installed package's public subpaths and preserve the token-first styling
contract. Keep product behavior in the application and reusable component
semantics in Tinyrack. Use `tinyrack-flutter-ui` instead for Flutter work.

## Required Dependencies

| Dependency | Constraint | Purpose |
|---|---|---|
| react, react-dom | ^19.0.0 | Component runtime |
| tailwindcss | ^4.3.0 | Utility framework; use `@tailwindcss/vite` |
| lucide-react | stable | Sole icon library |
| @fontsource/ibm-plex-sans | stable | Sole typeface family |

## Consume the Package

1. Inspect the resolved package's README, `package.json` exports, and relevant
   type declarations before editing. Treat that installed version as the source
   of truth.
2. Import foundation CSS before component CSS:

   ```tsx
   import '@tinyrack/ui/core.css';
   import '@tinyrack/ui/components/button.css';
   import { TRButton } from '@tinyrack/ui/components/button';
   ```

3. Import only the public subpath needed. Do not invent a root barrel, `/react`
   or `/dom` suffix, overlay-manager path, or Astro renderer.
4. Compose compound components through semantic namespace parts such as
   `TRTabs.Root`, `TRTabs.List`, `TRTabs.Tab`, and `TRTabs.Panel`.
5. Preserve native props, events, refs, state callbacks, focus behavior, and
   accessibility semantics.

| Purpose | Public path |
|---|---|
| Component | `@tinyrack/ui/components/<component>` |
| Component CSS | `@tinyrack/ui/components/<component>.css` |
| Token metadata | `@tinyrack/ui/core` |
| Foundation CSS | `@tinyrack/ui/core.css` |
| React MDX map/CSS | `@tinyrack/ui/mdx`, `@tinyrack/ui/mdx.css` |
| Provider | `@tinyrack/ui/providers/<provider>` |

Ensure `core.css` reaches the Tailwind build before component styles. Do not
substitute the Flutter `tinyrack_ui` package in a web consumer.

## Preserve the Design System

- Follow `base colors -> semantic tokens -> component tokens`.
- Consume semantic `--tinyrack-*` tokens from component CSS. Make customizable
  `--tr-*` component tokens fall back to them.
- Do not use raw palettes or literal design values such as hex, rgb, or px in
  component or consumer styles. Propose a missing foundation token instead.
- Preserve light and dark behavior, visible focus, required contrast, keyboard
  operation, and accessible naming across interactive states.
- Do not duplicate or override the Tailwind v4 `@theme` integration in
  `core.css`.
- Use only Lucide React icons and IBM Plex Sans, including the official Korean
  and Japanese variants. Do not add another icon or font system.

## Contribute a Missing System Component

When existing `@tinyrack/ui` components cannot satisfy a reusable requirement,
stop the consumer change and propose the component, insufficiency, public API,
states, variants, and tokens. Wait for explicit approval before changing the
upstream repository.

1. Create a fresh worktree from `origin/main` without modifying the canonical
   checkout:

   ```bash
   cd ~/Workspaces/tinyrack/design
   git fetch origin main
   git worktree add -b ui-<component-slug> ../design-<component-slug> origin/main
   cd ../design-<component-slug>
   pnpm install
   ```

2. Read the upstream `AGENTS.md` and all triggered repository skills. Implement
   under `packages/ui/src/components/<name>/` with semantic implementation and
   CSS files plus an export-only `index.tsx`.
3. Wrap Base UI behavior rather than re-exporting it. Target React 19, accept
   `ref` as a prop, add `"use client"` only when required, and ship CSS as a
   separate public subpath.
4. Run the checks required by the current upstream guidance. For a new or broad
   component change, include:

   ```bash
   pnpm biome check .
   pnpm --filter @tinyrack/ui test:unit
   pnpm --filter @tinyrack/ui test:e2e
   pnpm pack:ui
   ```

5. Read the current package manifest and publish workflow, choose the semantic
   version from registry and tag state, and include the version and changelog
   update in the PR. Open it against `tinyrack-net/design` `main`, address review
   and CI in new commits, and merge only after approval and green checks.
6. Create `ui-v<X>.<Y>.<Z>` for the merged manifest version on the exact merge
   commit, monitor the exact npm publish workflow, and verify the registry
   metadata:

   ```bash
   npm view @tinyrack/ui@latest version dist.tarball dist.integrity repository --json
   ```

7. Remove the completed worktree, upgrade the consumer to the published
   version, and finish the original integration. Never patch `node_modules`.

## Verify the Consumer

- Run the consumer's typecheck and relevant component or browser tests.
- Build the application to exercise Tailwind v4 processing and package exports.
- Inspect keyboard, focus, dismissal, portal, disabled, loading, and accessible
  naming behavior affected by the change.
