---
name: tinyrack-docs
description: Build and maintain static React Router documentation sites that consume the published @tinyrack/docs package. Use when configuring a docs site, authoring MDX or TSX routes, wiring React Router and Vite entrypoints, adding locales or navigation, or diagnosing consumer-side docs builds. When the docs package itself needs a fix or new capability, pauses, proposes to the user, and drives the contribution workflow from worktree through PR, CI, merge, and release before returning to the consumer project.
---

# Tinyrack Docs

Build the documentation site from config and route content. Let the package own
the reusable shell, navigation, search, pagination, SEO assets, and static build
pipeline; keep product-specific content, branding, landing visuals, and
deployment in the consuming project.

## Required Dependencies

| Dependency | Constraint | Purpose |
|---|---|---|
| react, react-dom | ^19.0.0 | Runtime |
| react-router | ^8.2.0 < 9.0.0 | Routing |
| vite | ^8.0.0 | Build tool with `@tailwindcss/vite` |
| tailwindcss | ^4.3.0 | Utility framework — v4 only |
| lucide-react | stable | Icon library — do not add any other icon package |
| @fontsource/ibm-plex-sans, -jp, -kr | stable | Typeface — IBM Plex Sans exclusively |
| @tinyrack/ui | from npm | UI component dependency of docs |

## Set Up the Site

1. Inspect the installed package's README, `package.json` exports, and relevant
   type declarations before changing code. Treat that installed version as the
   source of truth; do not infer APIs from memory or another Tinyrack version.
2. Use Node.js 24 or newer.
3. Create `docs.config.ts` with `defineDocsConfig` from
   `@tinyrack/docs/config`. Define `contentDir`, sections or navigation, site
   metadata, redirects, locale configuration, header links, and theme settings
   required by the project.
4. Connect the public entrypoints:
   - `createDocsRoutes` and `createDocsRouterConfig` from
     `@tinyrack/docs/react-router`
   - `tinyrackDocs` from `@tinyrack/docs/vite`, placed **before** the Tailwind
     Vite plugin
   - `@tinyrack/docs/styles.css` and the runtime root exports from
     `@tinyrack/docs/runtime`
5. Use the standard `react-router dev`, `react-router build`, and `vite preview`
   commands. Do not look for a Tinyrack CLI or scaffold generator.

## Author Routes

- Put only route-producing `.mdx` and `.tsx` files under `contentDir`. Keep
  imported components, helpers, and demos outside it.
- Start every MDX file with YAML frontmatter containing at least `title`,
  `description`, `section`, and a non-negative `order`. Begin authored content
  at `##`; the framework renders the page title and description.
- Render custom TSX routes with `DocsPage` from `@tinyrack/docs/runtime`. Pass
  `frontmatter` as an inline static object literal. When supplied, `headings`
  must also be an inline static array and its IDs must match rendered headings.
- Use `index.mdx` or `index.tsx` for a directory root. Use `layout` values
  `docs`, `splash`, or `standalone`, and use `navigation: false` only when the
  route should be omitted from navigation.
- For localized sites, keep locale content under locale directories and use a
  shared `contentKey` for language alternates. Override built-in UI messages
  only when the site needs product-specific wording.

## Icon and Typography Rules

- Use only `lucide-react` icons in documentation content and custom TSX pages.
  Do not introduce additional icon libraries.
- Use only IBM Plex Sans (`@fontsource/ibm-plex-sans`, `-jp`, `-kr`) for all
  text. Do not override the typeface in docs content.
- The docs shell already configures IBM Plex Sans — consumer styles should not
  override, replace, or bypass this.

## Verify the Site

- Run the consumer project's typecheck and focused content or configuration
  tests.
- Run the full static `react-router build`; treat manifest, frontmatter,
  redirect, Pagefind, or asset errors as build failures.
- Preview the generated site at its configured base path and verify navigation,
  search, locale alternates, metadata, and static assets relevant to the change.
- Fix consumer configuration and content in the consumer project. Do not patch
  installed package files under `node_modules`.

## Docs Package Contribution Workflow

When `@tinyrack/docs` itself has a bug, missing capability, or the consuming
site needs framework-level behavior the package does not provide, do not
work around it in consumer code. Follow this workflow exactly.

### Step 1: Pause and Propose

- Stop work on the consumer docs task immediately.
- Present the user with a clear proposal:
  - **What change** is needed in `@tinyrack/docs` (new API, config field, build
    hook, routing behavior, shell feature, etc.).
  - **Why** it cannot be achieved through consumer-side configuration or
    content authoring alone.
  - **Impact** — which subpath, type, plugin, or runtime export it affects.
- Wait for explicit user approval before proceeding.

### Step 2: Create Worktree

```bash
cd ~/Workspaces/tinyrack/design
git fetch origin main
git worktree add --detach ../design-<feature-slug> origin/main
cd ../design-<feature-slug>
pnpm install
```

### Step 3: Develop the Docs Change

- Modify only the `packages/docs/src/` source tree.
- Keep public exports through the established subpaths:
  - `@tinyrack/docs/config` — configuration types and `defineDocsConfig`.
  - `@tinyrack/docs/react-router` — route creation and router config.
  - `@tinyrack/docs/runtime` — runtime React components and utilities.
  - `@tinyrack/docs/vite` — the `tinyrackDocs` Vite plugin.
  - `@tinyrack/docs/styles.css` — published stylesheet.
- When adding a new public export, update `packages/docs/package.json` exports
  map and verify the packed consumer can resolve it.
- Respect existing patterns: config is declarative, routes are filesystem-derived,
  the shell is owned by the package, and consumer content is owned by the
  consuming project.
- Use only `lucide-react` icons and IBM Plex Sans typography in any UI changes.

### Step 4: Verify and Open PR

```bash
pnpm biome check .
pnpm build
pnpm --filter @tinyrack/docs test
pnpm pack:docs
```

- Commit changes on a feature branch.
- Push and open a PR against `tinyrack-net/design` `main`.
- Wait for all CI checks to pass (`biome`, `ui` test job, `docs` test job).

### Step 5: Merge and Release

- Merge the PR after approval and green CI.
- On the merge commit, create an annotated tag: `docs-v<X>.<Y>.<Z>`.
- Build and pack `@tinyrack/ui` first (docs depends on it via `workspace:^`),
  push the tag, and monitor `.github/workflows/publish-docs-npm.yml` to
  completion.
- Confirm the new version is live and its UI dependency is correct:

  ```bash
  npm view @tinyrack/docs@latest version dependencies.@tinyrack/ui --json
  ```

### Step 6: Return to Consumer Project

- Remove the worktree: `git worktree remove ../design-<feature-slug>`.
- Return to the consumer project directory.
- Update `@tinyrack/docs` to the newly released version.
- Apply the new configuration, API, or behavior where the proposal was
  originally triggered.
- Rebuild and verify the consumer docs site end-to-end.
