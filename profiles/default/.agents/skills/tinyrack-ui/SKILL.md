---
name: tinyrack-ui
description: Build and maintain React interfaces that consume the published @tinyrack/ui package. Enforces design system token compliance and Tailwind v4 conventions. When the existing component set is insufficient for a product requirement, pauses, proposes a new system component to the user, and drives the contribution workflow from worktree through PR, CI, merge, and release before returning to the consumer project.
---

# Tinyrack UI

Use the installed package's public subpaths and preserve the explicit token-first
styling contract. Treat the application as the owner of product behavior and
Tinyrack as the owner of reusable component semantics.

## Required Dependencies

| Dependency | Constraint | Purpose |
|---|---|---|
| react, react-dom | ^19.0.0 | Component runtime |
| tailwindcss | ^4.3.0 | Utility framework — v4 only, use `@tailwindcss/vite` |
| lucide-react | stable | Icon library — do not add any other icon package |
| @fontsource/ibm-plex-sans | stable | Typeface — use IBM Plex Sans exclusively |

## Package Usage

1. Inspect the installed package's README, `package.json` exports, and relevant
   type declarations before changing code. Treat that installed version as the
   source of truth; do not infer APIs from memory or another Tinyrack version.
2. Import foundation CSS before component CSS:

   ```tsx
   import '@tinyrack/ui/core.css';
   import '@tinyrack/ui/components/button.css';
   import { TRButton } from '@tinyrack/ui/components/button';
   ```

3. Import only the public subpath needed by the interface. Do not invent a root
   barrel, `/react` or `/dom` suffix, overlay-manager path, or Astro renderer.
4. Compose compound components through their semantic namespace parts, such as
   `TRTabs.Root`, `TRTabs.List`, `TRTabs.Tab`, and `TRTabs.Panel`.
5. Preserve the component's native props, events, refs, state callbacks, focus
   behavior, and accessibility semantics. Add application-specific labels and
   status text where the product context requires them.

## Public Paths

| Purpose | Path |
|---|---|
| Component | `@tinyrack/ui/components/<component>` |
| Component CSS | `@tinyrack/ui/components/<component>.css` |
| Token metadata | `@tinyrack/ui/core` |
| Foundation CSS | `@tinyrack/ui/core.css` |
| React MDX map | `@tinyrack/ui/mdx` |
| React MDX CSS | `@tinyrack/ui/mdx.css` |
| Provider | `@tinyrack/ui/providers/<provider>` |

Import component CSS explicitly. Ensure `core.css` reaches the Tailwind build
before component styles so Tinyrack tokens, responsive variants, and authored
Tailwind v4 CSS resolve correctly.

## Design Token Compliance

- Follow the token hierarchy: **base colors → functional/semantic tokens →
  component tokens**.
- Component CSS must consume semantic `--tinyrack-*` tokens. Customizable
  `--tr-*` component tokens must fall back to them.
- **Never** use raw palette values or literal design values (hex, rgb, px) in
  component or consumer styles.
- If an existing foundation token is insufficient, do not work around it with a
  literal value — propose adding the missing token through the contribution
  workflow.
- Preserve light and dark behavior, visible focus rings, and required contrast
  ratios across all interactive states.
- Tailwind v4 `@theme` variables in `core.css` are the integration point between
  Tinyrack tokens and Tailwind utilities — do not duplicate or override them.

## Icon and Typography Rules

- Use only `lucide-react` icons. Do not introduce additional icon libraries
  (Heroicons, Radix Icons, Material Icons, custom SVGs, etc.).
- Use only IBM Plex Sans (`@fontsource/ibm-plex-sans`) and its CJK variants
  (`@fontsource/ibm-plex-sans-jp`, `@fontsource/ibm-plex-sans-kr`).
- Do not add fallback font stacks that bypass the typeface.

## System Component Contribution Workflow

When a product requirement cannot be met by any existing `@tinyrack/ui`
component, do not hack around it with raw HTML, inline styles, or third-party
components. Follow this workflow exactly.

### Step 1: Pause and Propose

- Stop work on the consumer feature immediately.
- Present the user with a clear proposal:
  - **What component** is needed (name, purpose).
  - **Why** existing components are insufficient.
  - **Scope** — what public API, variants, states, and tokens it requires.
- Wait for explicit user approval before proceeding.

### Step 2: Create Worktree

```bash
cd ~/Workspaces/tinyrack/design
git fetch origin main
git worktree add --detach ../design-<component-slug> origin/main
cd ../design-<component-slug>
pnpm install
```

### Step 3: Develop the Component

- Create a colocated directory: `packages/ui/src/components/<name>/`.
- Implement in semantic files (`<name>.tsx`, `<name>.css`) with a public
  `index.tsx` barrel.
- Keep `index.tsx` limited to imports, exports, types, and compound namespace
  assembly — no JSX, state, effects, or event handlers.
- Wrap Base UI primitives for accessible behavior (focus, keyboard, portals,
  positioning, dismissal). Do not re-export Base UI raw.
- Style exclusively with semantic `--tinyrack-*` tokens via component CSS.
- Export compound parts and their prop types individually and through the
  semantic namespace.
- Target React 19: accept `ref` as a normal prop, no new `forwardRef` wrappers.
- Add `"use client"` only when client behavior requires it.
- Ship CSS separately at `@tinyrack/ui/components/<component>.css` — component
  JS must not auto-import it.

### Step 4: Verify and Open PR

```bash
pnpm biome check .
pnpm build
pnpm --filter @tinyrack/ui test:unit
pnpm --filter @tinyrack/ui test:e2e
pnpm pack:ui
```

- Commit changes on a feature branch.
- Push and open a PR against `tinyrack-net/design` `main`.
- Wait for all CI checks to pass (`biome`, `ui` test job, `docs` test job).

### Step 5: Merge and Release

- Merge the PR after approval and green CI.
- On the merge commit, create an annotated tag: `ui-v<X>.<Y>.<Z>`.
- Push the tag and monitor `.github/workflows/publish-npm.yml` to completion.
- Confirm the new version is live:

  ```bash
  npm view @tinyrack/ui@latest version dist.tarball --json
  ```

### Step 6: Return to Consumer Project

- Remove the worktree: `git worktree remove ../design-<component-slug>`.
- Return to the consumer project directory.
- Update `@tinyrack/ui` to the newly released version.
- Import and apply the new component where the proposal was originally triggered.

## Verification

- Run the consumer project's typecheck and relevant component or browser tests.
- Build the consumer application to exercise Tailwind v4 processing and package
  export resolution.
- Inspect interactive states for keyboard operation, focus, dismissal, portal
  placement, disabled behavior, and accessible naming.
- Fix consumer integration in the consumer project. Do not patch installed
  package files under `node_modules`.
